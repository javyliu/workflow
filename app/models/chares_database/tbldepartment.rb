module CharesDatabase
  #2015-03-26 17:54 javy 在正式库中添加两个表
  class Tbldepartment < ActiveRecord::Base
    self.table_name = 'tbldepartment'
    #self.primary_key = 'mgrCode'
    self.primary_key = 'deptCode'

    def self.which_rule(old_rule)
      if old_rule.deptCode.start_with?("0108") and old_rule.deptCode != "010899" #平台用固定工作时间
        return 4
      end
      return nil if old_rule.deptCode == '0110' #后勤不做考勤
      case old_rule.attenRules
      when "RuleFlexibalWorkingTime"
        #运营和市场,天擎无倒休
        old_rule.deptCode.start_with?('0104','0105','0106') || old_rule.deptCode.start_with?("0106") ? 5 : 3
      when "RuleABPoint"
        2
      when "RuleBPoint4QiLe"
        1
      end
    end

    def self.sys_departments
      CharesDatabase::Tbldepartment.find_each do |item|
        next if item.deptCode.end_with?("99")
        _dept = Department.find_or_initialize_by(code:item.deptCode, attend_rule_id: 2)
        _dept.name = item.deptName
        _dept.mgr_code = item.mgrCode if _dept.new_record?
        #_dept.assign_attributes(name:item.deptName,mgr_code:item.mgrCode)
        _dept.save!
      end
    end
  end
end
