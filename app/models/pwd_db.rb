module PwdDb

  class ExternalTable < ActiveRecord::Base
    self.abstract_class = true

    def self.connect(db_config)
      self.establish_connection(db_config).connection
    end

  end
  #Redmine
  #PwdDb::RedmineUser.user_update(name,pwd: '12345')
  #PwdDb::RedmineUser.user_update(name,delete: true)
  class RedmineUser
    #self.table_name = 'users'
    #用于更新或删除redmine用户的密码或删除该用户 status=3 时标记为删除
    def self.user_update(uname,cols={})
      _pwd = cols.delete(:pwd)
      _delete = cols.delete(:delete)
      return '参数错误' unless _pwd || _delete

      if _pwd
        cols[:salt] = SecureRandom.hex
        cols[:hashed_password] = self.hash_password("#{cols[:salt]}#{self.hash_password(_pwd)}")
      end

      cols[:status] = 3 if _delete
      _set_sql = "update users set #{PwdDb.gen_set_sql(cols)} where login='#{uname}'"

      Rails.logger.info("pwd_log: #{_set_sql}")
      begin
        #ActiveRecord::Base.establish_connection(:redmine).connection.execute(_set_sql)
        PwdDb::ExternalTable.connect(:redmine).execute(_set_sql)
        "Redmine系统#{uname}账号操作成功!"
      rescue
        Rails.logger.info $!
        "Redmine系统#{uname}账号操作失败!"
      end
    end

    def self.hash_password(clear_pwd)
      Digest::SHA1.hexdigest(clear_pwd)
    end
  end

  #日报系统
  class DailyReportUser
    #self.table_name = 'user'

    def self.user_update(uname,cols={})
      _pwd = cols.delete(:pwd)
      _delete = cols.delete(:delete)
      return '参数错误' unless _pwd || _delete

      cols[:password] = self.hash_password(_pwd) if _pwd
      cols[:valid] = 0 if _delete
      _set_sql = "update user set #{PwdDb.gen_set_sql(cols)} where loginname='#{uname}'"
      Rails.logger.info("pwd_log: #{_set_sql}")
      begin
        PwdDb::ExternalTable.connect(:dailyreport).execute(_set_sql)
        "日报系统#{uname}账号操作成功!"
      rescue
        Rails.logger.info $!
        "日报系统#{uname}账号操作失败!"
      end

    end

    def self.hash_password(clear_pwd)
      "*#{Base64.strict_encode64(Digest::MD5.digest(clear_pwd))}"
    end
  end

  #GM 工具
  class PipGmUser
    #self.table_name = 'tbl_admin'
    def self.user_update(uname,cols={})
      _pwd = cols.delete(:pwd)
      _delete = cols.delete(:delete)
      return '参数错误' unless _pwd || _delete

      _set_sql = if _pwd
                   cols[:password] = self.hash_password(_pwd)
                   "update tbl_admin set #{PwdDb.gen_set_sql(cols)} where name='#{uname}' and domain='pip'"
                 elsif _delete
                   "delete from tbl_admin where name='#{uname}' and domain='pip'"
                 end

      Rails.logger.info("pwd_log: #{_set_sql}")
      if _set_sql
        begin
          PwdDb::ExternalTable.connect(:pipgm).execute(_set_sql)
          "GM系统#{uname}账号操作成功!"
        rescue
          Rails.logger.info $!
          "GM系统#{uname}账号操作失败!"
        end
      else
        "GM系统操作失败，请传入正确参数"
      end
    end

    def self.hash_password(clear_pwd)
      "##{Digest::MD5.hexdigest(clear_pwd).upcase}"
    end
  end

  #cvs and svn
  class SvnUser
    def self.user_update(uname,cols={})
      _pwd = cols.delete(:pwd)
      _delete = cols.delete(:delete)
      return '参数错误' unless _pwd || _delete


      _set_sql = if _pwd
                   "sudo /root/sh/user_manager.sh change #{uname} #{_pwd}"
                 else
                   "sudo /root/sh/user_manager.sh delete #{uname} "
                 end

      #"\e[32m 0.3CVS user qmliu passwd was changed successful \e[m\n\e[32m 0.3SVN user qmliu passwd was changed successful \e[m\n\e[31m 0.4CVS user qmliu is not exists \e[m\n"
      res = `#{_set_sql}`

      #去除颜色值
      res.gsub(/\e\[\d*m[ ]?/,'').split($/)

    end
  end

  #uts
  class UtsUser
    ApiPass = "SxgJE#LJsP"
    ServerList = [
      ["ServerManager昌平服务器","221.179.216.54:7001/ServerManager/"],
      ["ServerManager世纪互联服务器","211.151.99.70:7001/ServerManager/"],
      ["ServerManager广东睿江服务器","121.201.1.95:7001/ServerManager/"],
      ["官服UTS","211.151.99.70:7070/uts/"],
      ["移动版本UTS","211.151.99.70:7070/uts_cmcc/"],
      ["数据平台","211.151.99.88:8000/PipData/"]
    ]

    def self.user_update(uname,cols={})
      _pwd = cols.delete(:pwd)
      _delete = cols.delete(:delete)
      return '参数错误' unless _pwd || _delete

      _params = {apipass: ApiPass,username: uname}

      _path = if _pwd
                   _params[:password] = _pwd
                   "gmmodifypassword?#{_params.to_query}"
                 else
                   "gmdeleteaccount?#{_params.to_query}"
                 end

      msgs = []

      ServerList.each do |item|
        msgs.push([item.first,PwdDb.fetch("http://#{item.second}#{_path}")])
      end

      msgs.map do |item,msg|
        if msg.empty? #该接口只返回状态，不返回数据，即body为空
          "#{item}账号操作成功！"
        else
          "#{item}账号操作失败！原因：#{msg}"
        end
      end
    end


  end


  module_function
  def gen_set_sql(cols)
    cols.inject([]){|t,(k,v)| t.push("#{k.to_s}='#{v}'")}.join(",")
  end

  def fetch(uri_str, limit = 3)
    return 'too many HTTP redirects' if limit == 0
    Rails.logger.info(uri_str)
    url = URI.parse(uri_str)
    response = begin
                 Net::HTTP.start(url.host, url.port,open_timeout: 10) do |http|
                   http.request( Net::HTTP::Get.new(url.request_uri))
                 end
               rescue Net::OpenTimeout => e
                 e.message
               rescue
                 $!
               end

    puts response.content_type

    case response
    when Net::HTTPSuccess
      if response.content_type == 'application/json'
        JSON.parse(response.body).symbolize_keys
      else
        response.body.split($/)
      end
    when Net::HTTPRedirection
      location = response['location']
      warn "redirected to #{location}"
      fetch(location, limit - 1)
    when Net::HTTPInternalServerError
      response.message
    else
      response.to_s
    end
  end
end

