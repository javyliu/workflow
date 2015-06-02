# == Schema Information
#
# Table name: report_titles
#
#  id   :integer          not null, primary key
#  name :string(40)
#  des  :string(20)
#  ord  :integer
#

class ReportTitle < ActiveRecord::Base
end
