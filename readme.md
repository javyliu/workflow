work for the kaoqing in pearlpalm

alias start_workflow='cd $HOME/workflow/;passenger start --pid-file=$HOME/workflow/tmp/passenger.pid -S /tmp/workflow.com.socket -d -e development;cd -'
alias stop_workflow='rm /tmp/workflow.com.socket;kill `cat $HOME/workflow/tmp/passenger.pid`'

alias start_sidekiq='bundle exec sidekiq -d'
alias stop_sidekiq='sidekiqctl stop tmp/pids/sidekiq.pid'
