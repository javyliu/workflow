class Department < ActiveRecord::Base
  self.primary_key = 'code'
  has_many :users, foreign_key: :dept_code
  belongs_to :attend_rule

  before_save :delete_caches

  #[组名，可使用假期id]
  GroupAB = [:group_ab,[1,2,3,4,6,7,8,9,10,11,12,13]] #%w{0102 0103} #工作室
  GroupNoSwitchTime = [:group_no_switch_time,[1,2,3,4,6,7,8,9,10,11,12,13]] #%w{0104 0105 0106} #市场及营销
  GroupSwitchTime =   [:group_switch_time,[1,2,3,4,5,6,7,8,9,10,11,12,13]]#非工作室

  def self.cache_all_depts
    Rails.cache.fetch(:all_depts) do
      self.find_by_sql("select  DISTINCT dept_code,departments.name from users inner join departments on dept_code = code ORDER BY dept_code ").map{|e| [e.name,e.dept_code]}
    end
  end

  private

  def delete_caches
    Rails.cache.delete(:all_depts)
  end
end
