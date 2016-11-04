#考勤管理系统

本设计目地是为了解决人事资源管理部门更加便捷地进行公司员工管理，更加准确地汇总数据，统计员工考勤，加强员工考勤自助管理，提高人事部门人员工作效率，统一多系统资源、实现人事部门无纸化办公的集成解决方案。

##架构

本系统基于B/S架构，Linux系统，Nginx Web HTTP服务器，使用Rails框架，
Mysql数据库，Memcached及Redis存储系统构建后台系统。
前端通过Foundation、jQuery、SASS、CoffeeScript等技术提高用户体验、降低开发成本。

##模块

人事资源及考勤管理系统主要包括
- 用户管理模块（增删更查）
- 假期管理模块
- 申请审批模块
- 员工自助模块
- 管理员后台配置模块
- 门禁数据同步模块
- 定时邮件通知及催缴模块
- 员工数据同步模块
- 角色权限管理模块
- 邮件确认处理模块
- 报表导出模块

## 命令生成

work for the kaoqing in pearlpalm

alias start_workflow='cd $HOME/workflow/;passenger start --pid-file=$HOME/workflow/tmp/passenger.pid -S /tmp/workflow.com.socket -d -e development;cd -'
alias stop_workflow='rm /tmp/workflow.com.socket;kill `cat $HOME/workflow/tmp/passenger.pid`'

alias start_sidekiq='bundle exec sidekiq -d'
alias stop_sidekiq='sidekiqctl stop tmp/pids/sidekiq.pid'
