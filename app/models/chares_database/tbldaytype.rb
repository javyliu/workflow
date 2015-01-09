module CharesDatabase
  class Tbldaytype < ThirdTable
    self.table_name = 'tbldaytype'
    self.primary_key = 'flddate'
    self.inheritance_column = 'ntype'
  end
end
