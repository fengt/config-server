set :stage, :test

set :profile, "test"

set :deploy_to, "/JavaWeb/config.wltest.com"

set :jar_pid, "#{shared_path}/tmp/pids/application.pid"

set :server_name, "10.3.54.69"

set :branch, "master"

set :default_env, {
  'PATH' => 'PATH=/home/pixiu/soft/jdk1.8.0_11/bin:$PATH'
}

server fetch(:server_name), user: 'pixiu', roles: %w{web app}