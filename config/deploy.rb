# A Capistrano deployment file for lettersrb.com
# by David Jacobs, (c) 2013

require 'bundler/capistrano'
require 'capistrano-rbenv'

# Helpers
def run_in_current(command, env='production')
  run_in_path(command, current_path, env)
end

def run_in_shared(command, env='production')
  run_in_path(command, shared_path, env)
end

def run_in_path(command, path, env='production')
  run "cd #{path} && RACK_ENV=#{env} #{command}"
end

def local_repo(name, user=user, domain=domain)
  # "file:///home/#{user}/git/#{name}.git"
  "/home/#{user}/git/#{name}.git"
end

def ssh_repo(name, user=user, domain=domain)
  "ssh://#{user}@#{domain}/home/#{user}/git/#{name}.git"
end

# Universal values
set :user,             'david'
set :domain,           'wit.io'
set :application,      'letters-web'

# Ruby version management
set :rbenv_ruby_version, '1.9.3-p429'

role :web,             domain
role :app,             domain
role :db,              domain, :primary => true

set :deploy_to,        "/home/#{user}/www/lettersrb.com" # FIXME
# set :deploy_via,       :remote_cache

# Set the Path
# Add bundler_stubs to PATH so we don't have to prefix
# binary calls with the atrocious `bundle exec`
default_environment['PATH'] = "#{current_path}/bundler_stubs:$PATH"
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# Bundler
# Create symlinks to Bundler-installed binaries in bundler_stubs
set :bundle_flags,     '--deployment --quiet --binstubs=./bundler_stubs'

# Version control - General
set :use_sudo,         false
set :scm_verbose,      false

# Version control - Remote Rails application repo
set :scm,              :git
set :repository,       local_repo(application)
set :local_repository, "helos:#{local_repo(application)}"
set :branch,           'master'

namespace :servers do
  set :server_files, ['nginx/sites-enabled/letters-web.conf']
  namespace :link do
    desc 'link server config files in file system'
    task :config do
      source_dir = "#{current_path}/config/"
      dest_dir = "/etc/"

      server_files.each do |file|
        source_file = source_dir + file
        dest_file = dest_dir + file
        sudo "ln -nfs #{source_file} #{dest_file}"
      end
    end

    task :maintenance do
      source_dir = "#{current_path}/public/maintenance"
      dest_dir = "maintenance"
      run_in_shared "ln -s #{source_dir} maintenance"
    end
  end

  desc 'clean server config files from file system'
  task :clean do
    server_files.each do |file|
      sudo "rm /etc/#{file}"
    end
  end
end

namespace :css do
  task :compile do
    run_in_current "compass compile"
  end
end

# Server - Unicorn
namespace :unicorn do
  set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"

  desc "start unicorn master"
  task :start do
    config = 'config/unicorn.rb'
    run_in_current "unicorn -c #{config} -E production -D"
  end

  task :stop do
    run_in_current "[ -f #{unicorn_pid} ] && kill -9 $(cat #{unicorn_pid})"
  end

  task :graceful_stop do
    run_in_current "kill -s QUIT $(cat #{unicorn_pid})"
  end

  task :reload do
    run_in_current "kill -s USR2 $(cat #{unicorn_pid})"
  end

  task :restart do
    stop
    start
  end
end

# Server - Nginx
namespace :nginx do
  desc 'reload nginx server'
  task :reload do
    sudo '/etc/init.d/nginx reload'
  end
end

# Deployment - Clear out default tasks that rely on deprecated libraries
namespace :deploy do
  task :start do
    unicorn.start
  end

  task :stop do
    unicorn.stop
  end

  task :restart do
    unicorn.restart
  end

  task :config do
    servers.link.config
  end

  task :migrations do; end
  task :migrate do; end
end

# Dependencies
# Bootstrap correctly
before 'deploy:cold',         'deploy:setup'

# Only keep latest releases
after 'deploy',               'deploy:cleanup'
after 'deploy',               'css:compile'

# Link old server config if we rollback
after 'rollback:default',     'servers:link:config'

# Link current maintenance page
before 'deploy:maintenance',  'servers:link:maintenance'

# Link new server config if updated
before 'deploy:config',       'deploy'
after 'servers:link:config',  'nginx:reload'
