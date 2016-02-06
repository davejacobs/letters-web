worker_processes 1

# Load source into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 5

root_dir = "/home/david/www/letters-web/"
shared_path = "#{root_dir}/shared"

# Listen on a Unix data socket
listen "#{root_dir}/current/tmp/unicorn.sock", :backlog => 2048
stdout_path "#{shared_path}/log/unicorn.stdout.log"
stderr_path "#{shared_path}/log/unicorn.stderr.log"
pid "#{shared_path}/pids/unicorn.pid"

before_fork do |server, worker|
  old_pid = 'tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      puts "[info] Killing #{File.read(old_pid)}"
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  else
    puts "[info] None found"
  end
end

after_fork do |server, worker|
  begin
    uid, gid = Process.euid, Process.egid
    user, group = 'david', 'david'
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid
    worker.tmp.chown(target_uid, target_gid)
    if uid != target_uid || gid != target_gid
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue => e
  end
end
