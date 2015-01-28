class Department < ActiveRecord::Base
  self.primary_key = 'code'
  has_many :users, foreign_key: :dept_code
  belongs_to :attend_rule

  before_save :delete_caches

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
