worker_processes 2

# Load source into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 5

# Listen on a Unix data socket
listen '/home/david/www/lettersrb.com/current/tmp/sockets/unicorn.sock', :backlog => 2048

stdout_path "/home/david/www/lettersrb.com/current/log/unicorn.stdout.log"
stderr_path "/home/david/www/lettersrb.com/current/log/unicorn.stderr.log"

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
