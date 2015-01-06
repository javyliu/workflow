module CharesDatabase
  class ThirdTable < ActiveRecord::Base
    self.abstract_class = true
    establish_connection :chares_database
  end
end
