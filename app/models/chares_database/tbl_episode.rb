# == Schema Information
#
# Table name: tblepisode
#
#  id           :integer          not null, primary key
#  userId       :string(10)
#  type         :string(20)
#  startDate    :date
#  endDate      :date
#  comments     :text(65535)
#  approvedBy   :string(10)
#  approvedDate :datetime
#

module CharesDatabase
  class TblEpisode < ThirdTable
    self.table_name = 'tblepisode'
    self.inheritance_column = 'alt_type'
  end
end
