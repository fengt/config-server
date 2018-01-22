# config valid only for current version of Capistrano
lock "3.8.2"

set :application, "config-server"
set :repo_url, "git@github.com:fengt/config-server.git"

set :version, "0.0.1-SNAPSHOT"
set :jar_file, "config-server-#{fetch(:version)}.jar"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/JavaWeb/config.wltest.com"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
append :linked_dirs, "bin", "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
	
	task :start do
     on roles :app do
       within "#{fetch(:deploy_to)}" do
         unless test("[ -f #{fetch(:jar_pid)} ]")
           info ">>>> starting "
           execute :nohup, :java, "-jar -Dspring.profiles.active=#{fetch(:profile)} #{fetch(:jar_file)} >nohup.log 2>&1 & sleep 1"
         else
           error ">>>> already started"
         end
       end
     end
  	end

	task :stop do
     on roles :app do
       within "#{fetch(:deploy_to)}" do
         if test("[ -f #{fetch(:jar_pid)} ]")
           info ">>>> stopping  "
           execute :kill, "-9 `cat #{fetch(:jar_pid)}`"
           execute :rm, "#{fetch(:jar_pid)}"
         else
           error ">>>> can not stop, there is no live app"
         end
       end
     end
  end

  task :restart do
     invoke :"deploy:stop"
     invoke :"deploy:start"
  end

  task :build do
     on roles :app do
       within current_path do
         execute :sh, "gradlew build -xTest"
       end
     end
  end

  task :copy_to_target do
     on roles :app do
       within current_path do
         execute :cp, "build/libs/#{fetch(:jar_file)} #{fetch(:deploy_to)}"
       end
     end
  end

  task :rebuild do
     invoke :"deploy:build"
     invoke :"deploy:copy_to_target"
     invoke :"deploy:stop"
     invoke :"deploy:start"
  end
end

after "deploy:publishing", "deploy:rebuild"