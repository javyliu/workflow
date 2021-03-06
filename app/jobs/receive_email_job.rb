require 'nokogiri'
require 'net/pop'
class ReceiveEmailJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    Net::POP3.start(*(ENV['POP_SETTING'].split(","))) do |pop|
      if pop.mails.empty?
        Rails.logger.info  'No mail.'
        return
      end
      #i = 0
      pop.delete_all do |m|   # or "pop.mails.each ..."
        m = Mail.new(m.pop)
        #binding.pry
        _task = Task.init_from_subject(m.subject)
        next unless _task #不作处理

        #是否过期
        _date = Date.parse(_task.date)
        if !_date.between?(*Journal.count_time_range(is_for_validate: true))
          _task.remove(all: true)
          Usermailer.error_approved(_task.leader_user_id,"您回复的#{_task.task_name}的确认信息出错了，该日考勤已过了确认时间",_task.date).deliver_later
          next
        end

        begin
          #unless _task.leader_user_id.to_i.in?([1002,1608])
          case _task.attr_value(:state)
          when Task::Completed #已做完确认,发送已确认邮件
            Usermailer.error_approved(_task.leader_user_id,"您部门#{_task.date}的考勤信息已确认完成，请不要重复确认，如有问题，请登录web界面进行更改！",_task.date).deliver_later
            next
          when Task::Expired #已催缴十次
            Usermailer.error_approved(_task.leader_user_id,"您部门#{_task.date}的考勤信息确认时间已过期，如有问题，请登录web界面进行更改！",_task.date).deliver_later
            next
          end
          #end

          case _task.type
          when "F001" #考勤确认
            #leader_user_id = _task.content["leader_user_id"]
            changed_user_names = handle_journal(m,_task.leader_user_id,_task.date)
            if changed_user_names.present? #如果数据有更改，则删除任务并发送确认邮件，否则继续催缴
              _task.update(:state,Task::Completed)#设置任务完成
              _task.remove(all: true) #删除催缴任务
              Usermailer.daily_approved(_task.leader_user_id,changed_user_names,_task.date).deliver_later
            else
              Usermailer.error_approved(_task.leader_user_id,"您部门#{_task.date}的考勤信息确认失败，请确认是否有未填写的异常考勤信息或登录web界面进行更改！",_task.date).deliver_later
            end
          when "F002" #请假确认
            #TODO
          when "F003" #请假确认
            #TODO
          else
            puts "非考勤邮件#{m.subject}"
            next
          end

        rescue Exception => e
          Rails.logger.info  "kaoqing_error:#{e.inspect}"
          Usermailer.error_approved(_task.leader_user_id,"您回复的#{_task.task_name}的确认信息出错了，请与管理员联系或请登录web界面进行更改！",_task.date).deliver_later
        end

        #f.write mail.body
        #i += 1
        puts "#{pop.mails.size} mails popped."
      end
    end

  end

  private


  def handle_journal(message,leader_user_id,date)
    changed_user_names = []
    message.all_parts && message.all_parts.each do |part|
      #binding.pry
      Rails.logger.info part.content_type.inspect
      Rails.logger.info part.charset
      next if part.content_type !~ /^text\/html/
      #只解析html格式邮件
      #binding.pry
      #2015-03-31 21:21 gb2312时要使用 fonce_encoding 为 gbk
      Rails.logger.info "-------------get body----------------"
      body =Nokogiri::HTML(part.body.decoded.force_encoding(part.charset.downcase == "utf-8" ? 'utf-8':'gbk'),"UTF-8") rescue Rails.logger.info("编码错误:#{$!.message}")
      Rails.logger.info "-------------get body success----------------"
      #get need fill user
      #binding.pry
      #2015-03-31 21:21 gb2312时要使用 fonce_encoding 为 gbk
      next if (_need_fills = body.css("tr.need_fill").presence || body.css("tr[name=need_fill]")).blank?
      Rails.logger.info "-------------judge blank row----------------"
      #如果有未确认的行，则直接返回
      return false if _need_fills.any? {|_tr|_tr.css("td[id^=c_aff]").text().tap{|t|Rails.logger.info("空行======text:#{_tr.inspect}") if t.blank?}.blank?}
      Rails.logger.info "-------------need_fill rows is presence-----"
      _need_fills.each do |item|
        aff_tds = item.css("td[id^=c_aff]")
        user_name = item.css("td[id=c_user_name]").text.strip
        #_description = item.css("td[id=c_aff_spec_appr]").text
        _user_id = item.attr(:id)
        Rails.logger.info "-------------cycle need_fills rows-#{user_name}---------------"
        aff_tds.each do |td|
          _text = td.text.strip
          next if _text.blank?

          _med = td.attr(:id).strip
          #使用others来替换不常用的异常考勤类型
          if  _med == "c_aff_others"
            cktype = Journal.cktype_from_key(_text.first)
            _text = _text[1..-1]
          else
            cktype = Journal::CheckType.assoc(_med)
          end
          Rails.logger.info("-------method:#{_med} -text:#{_text}")
          raise "cktype is nil" unless cktype

          journal = Journal.find_or_initialize_by(user_id: _user_id ,update_date:date,check_type: cktype.second )
          #取邮件中的默认描述
          journal.description = item.css("td[id=c_ref_cmd]").text.strip
          journal.dval = 0

          #journal.check_type = cktype.second
          #2016-04-17
          if _med == "c_aff_spec_appr" #特批描述
            journal = journal.spec_appr_holiday
            raise "无对应休假特批" unless journal
            journal.description = _text
          else
            journal.description = "#{cktype.third}#{_text}#{cktype.fourth}"
            #2015-04-17 17:46 javy 所有值都转化为绝对值
            #journal.dval = (cktype[5] ? _text.to_f : _text.to_f.abs) * cktype.last
            journal.dval = _text.to_f.abs * cktype.last
          end
          Rails.logger.info("--#{_text.to_f}--#{cktype.last}--------#{journal.dval}")
          if journal.save #成功，发送成功邮件
            Rails.logger.info("success-journal：#{journal.inspect}")
            changed_user_names.push([user_name,journal.description,_text])
          else #存储报错 给用户发送出错邮件
            #Rails.logger.info("error-journal：#{journal.inspect}")
            raise "save journal error#{journal.inspect}"
          end
        end
      end #end parts
      break
    end
    changed_user_names
  end
end
