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
        begin
          case _task.attr_value(:state)
          when Task::Completed #已做完确认,发送已确认邮件
            Usermailer.error_approved(_task.leader_user_id,"您部门#{_task.date}的考勤信息已确认完成，请不要重复确认，如有问题，请登录web界面进行更改！",_task.date).deliver_later
            next
          when Task::Expired #已催缴十次
            Usermailer.error_approved(_task.leader_user_id,"您部门#{_task.date}的考勤信息确认时间已过期，如有问题，请登录web界面进行更改！",_task.date).deliver_later
            next
          end

          case _task.type
          when "F001" #考勤确认
            #leader_user_id = _task.content["leader_user_id"]
            changed_user_names = handle_journal(m,_task.leader_user_id,_task.date)
            if changed_user_names.present? #如果数据有更改，则删除任务并发送确认邮件，否则继续催缴
              _task.update(:state,Task::Completed)#设置任务完成
              _task.remove(all: true) #删除催缴任务
              Usermailer.daily_approved(_task.leader_user_id,changed_user_names,_task.date).deliver_later
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
          Usermailer.error_approved(_task.leader_user_id,"您回复的#{_task.task_name}的确认信息出错了，请与管理员联系或请登录web界面进行更改！",_task.date).deliver_later
          Rails.logger.info  "kaoqing_error:#{e.message}"
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
    message.parts && message.parts.each do |part|
      puts part.content_type.inspect
      puts part.charset
      next if part.content_type !~ /^text\/html/
      #只解析html格式邮件
      body =Nokogiri::HTML(part.body.decoded.force_encoding(part.charset),"UTF-8")
      #get need fill user
      next if (_need_fills = body.css("tr.need_fill")).blank?
      _need_fills.each do |item|
        aff_tds = item.css("td[abbr^=c_aff]")
        #如果有未确认的行，则直接返回
        return false if aff_tds.text().tap{|t|Rails.logger.info("-------#{t}---------")}.blank?

        user_name = item.css("td[abbr=c_user_name]").text
        _description = item.css("td[abbr=c_aff_spec_appr]").text
        _user_id = item.attr(:id)
        aff_tds.each do |td|
          _text = td.text.strip
          next if _text.blank?

          journal = Journal.new(user_id: _user_id ,update_date:date)
          #取邮件中的默认描述
          journal.description = item.css("td[abbr=c_ref_cmd]").text.strip
          journal.dval = 0
          _med = td.attr(:abbr).strip
          Rails.logger.info("-------method:#{_med} -text:#{_text}")
          cktype = Journal::CheckType.assoc(_med)
          raise "cktype is nil" unless cktype
          journal.check_type = cktype.second
          if _med == "c_aff_spec_appr" #特批
            journal.description = "#{cktype.third}#{_text}"
          else
            journal.description = "#{cktype.third}#{_text}#{cktype.fourth} #{_description}"
            journal.dval = _text.to_f * cktype.last
          end
          Rails.logger.info("--#{_text.to_f}--#{cktype.last}--------#{journal.dval}")
          if journal.save #成功，发送成功邮件
            Rails.logger.info("success-journal：#{journal.inspect}")
            changed_user_names.push([user_name,journal.description,_text])
          else #存储报错 给用户发送出错邮件
            Rails.logger.info("error-journal：#{journal.inspect}")
          end
        end
      end #end parts
      break
    end
    changed_user_names
  end
end
