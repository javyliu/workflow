module CharesDatabase
  #class Tblcheckinout < ThirdTable
  class Tblcheckinout < ExternalTable
    self.primary_key = 'uid' #only for migrate data
    self.table_name = 'tblcheckinout'
  end
end
