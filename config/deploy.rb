# A Capistrano deployment file for lettersrb.com
# by David Jacobs, (c) 2016

require "bundler/capistrano"
require "capistrano-rbenv"

set :user,             "david"
set :domain,           "wit.io"
set :application,      "letters-web"

# Ruby version management
set :rbenv_ruby_version, "1.9.3-p551"

role :web,             domain
role :app,             domain
role :db,              domain, :primary => true

set :deploy_to,        "/home/#{user}/www/#{application}"
# set :deploy_via,       :remote_cache

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# Create symlinks to Bundler-installed binaries in bundler_stubs
set :bundle_flags,     "--deployment --quiet --binstubs=./bundler_stubs"

# Version control - General
set :use_sudo,         false
set :scm_verbose,      false
set :repository,       "git@bitbucket.org:davetypes/letters-www.git"
set :branch,           "master"

namespace :unicorn do
  task :start { run "supervisorctl start unicorn" }
  task :stop { run "supervisorctl stop unicorn" }
  task :reload { run "supervisorctl restart unicorn" }
end

namespace :nginx do
  set :nginx_files, ["#{application}.conf"]

  task :reload { sudo "nginx -s reload" }

  namespace :config do
    task :link do
      source_dir = "#{current_path}/config/"
      dest_dir = "/etc/nginx/sites-enabled/"

      nginx_files.each do |file|
        source_file = source_dir + file
        dest_file = dest_dir + file
        sudo "ln -nfs #{source_file} #{dest_file}"
      end
    end

    task :clean do
      nginx_files.each do |file|
        sudo "rm /etc/nginx/sites-enabled/#{file}"
      end
    end
  end
end

namespace :deploy do
  task :start { unicorn.start }
  task :stop { unicorn.stop }
  task :restart { unicorn.reload }
  task :config { servers.config.link }
  task :migrations do; end
  task :migrate do; end
end

# Bootstrap correctly
before "deploy:cold", "deploy:setup"

# Only keep latest releases
after "deploy", "deploy:cleanup"

# Link old server config if we rollback
after "rollback:default", "servers:config:link"
after "servers:config:link",  "nginx:reload"

# Link new server config if updated
before "deploy:config",       "deploy"
