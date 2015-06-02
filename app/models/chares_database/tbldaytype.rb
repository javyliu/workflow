# == Schema Information
#
# Table name: tbldaytype
#
#  flddate :date             not null, primary key
#  type    :integer
#  comment :string(40)
#

module CharesDatabase
  class Tbldaytype < ThirdTable
    self.table_name = 'tbldaytype'
    self.primary_key = 'flddate'
    self.inheritance_column = 'ntype'
  end
end
