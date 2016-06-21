class LeaderData
  include Singleton

  delegate :detect,:assoc,:to =>  :json_data

  #只会在类初始化时调用，并把初始化的结果存在类实例变量 @singleton__instance__中
  def initialize
    @json_data = self.class.init
  end

  def json_data
    @json_data
  end

  #returned like
  #
  #{"1002"=>{"attend_rule_id"=>3, "user_ids"=>["1013", "1128", "1551", "1178", "2178", "1002", "1003", "1004", "1021", "1078", "2177"]},
  # "1003"=>{"attend_rule_id"=>2, "user_ids"=>["1011", "1008", "1105", "1006", "1009"]},
  # "1004"=>{"attend_rule_id"=>3, "user_ids"=>["1014", "1042", "1192"]},
  # "1009"=>{"attend_rule_id"=>2, "user_ids"=>["1097", "1018", "1148"]},
  # ....}
  def grouped_leader_data
    @grouped_leader_data ||= @json_data.each_with_object({}) do |item,r|
       r[item.uid] ||={}
       r[item.uid]["attend_rule_id"] = item.attend_rule_id if r[item.uid]["attend_rule_id"].nil?
       r[item.uid]["attend_rule_id"] = item.attend_rule_id if item.o_dept==0
       (r[item.uid]["user_ids"] ||= []).concat( item.user_ids)
    end

  end



  def self.init
    #return leaders with rule and user_ids like following
    #[["1002", "RuleFlexibalWorkingTime", ["1003", "2177", "1002", "1021", "1004", "2178", "1078", "1551", "1013", "1128", "1178"],...]

    Rails.cache.fetch(:leaders_data) do

         User.find_by_sql( <<-heredoc
    select tmp.attend_rule_id,tmp.mgr_code uid, GROUP_CONCAT(tmp.user_ids) user_ids,o_dept from (
    select b.attend_rule_id,b.mgr_code,GROUP_CONCAT(a.uid) user_ids,0 o_dept from users a INNER JOIN departments b on a.dept_code = b.`code` #部门下属用户
    where  a.mgr_code is NULL  GROUP BY b.`code`
     UNION
    select b.attend_rule_id,a.mgr_code,GROUP_CONCAT(a.uid) user_ids,1 o_dept from users a INNER JOIN departments b on a.dept_code = b.`code` #手工指定用户
    where  a.mgr_code <> -1 and a.mgr_code is not NULL  GROUP BY a.mgr_code,b.attend_rule_id
    ) as tmp where tmp.attend_rule_id is not NULL GROUP BY tmp.mgr_code ,tmp.attend_rule_id;
                                     heredoc
                         ).each{|item| item.user_ids = item.user_ids.split(',')}#.each_with_object({}){|item,r| r[item.uid] ||={};r[item.uid]["attend_rule_id"] = item.attend_rule_id if r[item.uid]["attend_rule_id"].nil?;r[item.uid]["attend_rule_id"] = item.attend_rule_id if item.o_dept==0 ; (r[item.uid]["user_ids"] ||= []).concat( item.user_ids.split(','))}#.inject([]){|uids,item|uids.push([item.uid,item.attend_rule_id,item.o_dept,item.user_ids.split(",").tap{|t|t.delete(item.uid) if item.uid != '1002'}])}
      end
  end

  def self.destroy
    @singleton__instance__ = nil
    Rails.cache.delete(:leaders_data)
    #Sidekiq.redis do |_redis|
    #  _redis.del("leaders_data")
    #end
  end


end
