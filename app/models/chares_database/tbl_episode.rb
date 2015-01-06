module CharesDatabase
  class TblEpisode < ThirdTable
    self.table_name = 'tblepisode'
    self.inheritance_column = 'alt_type'
  end
end
