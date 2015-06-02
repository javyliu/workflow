# == Schema Information
#
# Table name: tblyearinfo
#
#  year        :integer          not null
#  uid         :string(20)       not null, primary key
#  yearHolody  :integer          not null
#  sickLeave   :integer          not null
#  affairLeave :integer          not null
#  switchLeave :integer          not null
#  aPoint      :integer          not null
#

module CharesDatabase
  class Tblyearinfo < ThirdTable
    self.primary_key = 'uid' #only for migrate data
    self.table_name = 'tblyearinfo'
  end
end
