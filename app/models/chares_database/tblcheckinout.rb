# == Schema Information
#
# Table name: tblcheckinout
#
#  userId   :string(20)       not null
#  recDate  :date             not null
#  checkin  :datetime
#  checkout :datetime
#  refTime  :datetime
#

module CharesDatabase
  class Tblcheckinout < ThirdTable
    #self.primary_key = 'uid'
    self.table_name = 'tblcheckinout'
  end
end
