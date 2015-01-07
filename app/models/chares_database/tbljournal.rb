module CharesDatabase
  class Tbljournal < ThirdTable
    self.primary_key = 'uid' #only for migrate data
    self.table_name = 'tbljournal'
  end
end
