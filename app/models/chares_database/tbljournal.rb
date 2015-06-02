# == Schema Information
#
# Table name: tbljournal
#
#  uid        :string(20)       not null, primary key
#  updateDate :date
#  tp         :integer          not null
#  cmmt       :string(255)
#  dval       :integer          not null
#

module CharesDatabase
  class Tbljournal < ThirdTable
    self.primary_key = 'uid' #only for migrate data
    self.table_name = 'tbljournal'
  end
end
