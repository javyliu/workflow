class YearInfo < ActiveRecord::Base
  belongs_to :user

  include JavyTool::Csv

end
