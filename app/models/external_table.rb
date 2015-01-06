class ExternalTable < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :kaoqing_database
end

