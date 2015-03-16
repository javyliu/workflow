class PromptDailyMailJob < ActiveJob::Base
  queue_as :default

  #催缴邮件
  def perform(*args)

    #如果是非工作日，不作催缴
    return unless SpecDay.workday?(date: Date.today)

    Task.pending_tasks.each do |item|

      _task = Task.init_from_subject(item)

      next unless _task

      #每个任务的日期可能不同,周末的情况

      if _task.count >= OaConfig.setting(:prompt_max_times).to_i #不再发起催缴
        _task.increment!
        _task.update(:state,Task::Expired)
        _task.remove
        #发送过期邮件至考勤处理人员
        Usermailer.expired_error(_task.task_name).deliver_later
        puts "sending expired mail"
        next
      end

      _task.increment!

      case _task.type
      when "F001"
        leaders = User.leaders_by_date(_task.date)
        _leader = leaders.detect { |e| e.first == _task.leader_user_id }
        #构建催缴邮件并发出去
        #发送邮件
        if _leader && _leader[2].length > 0
          Usermailer.daily_kaoqing(_task.leader_user_id,uids: _leader[2].uniq,date: _task.date.to_s,count: _task.count ).deliver_later
          puts "sending prompt daily mail #{_task.leader_user_id} "
        end
      when "F002"

      when "F003"

      end

    end
  end
end
