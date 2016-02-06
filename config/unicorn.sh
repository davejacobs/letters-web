#!/bin/bash

export PATH="/home/david/.rbenv/bin:/home/david/.rbenv/shims":$PATH
eval "$(rbenv init -)"

# Do nothing, wait for signal
# This is required to make Unicorns PID system interoperable with Supervisor
frozen() {
  tail -f /dev/null
}

cd /home/david/www/letters-web/current
bundler_stubs/unicorn -c config/unicorn.rb -E production -D

kill_pid() {
  # Kill redmine on stop
  unicorn_pid=$(cat '/home/david/www/letters-web/current/tmp/pids/unicorn.pid')

  echo 'pid is in' $(ls /home/david/www/letters-web/current/tmp/pids)
  kill -s QUIT "$unicorn_pid"
}

trap kill_pid SIGKILL SIGINT EXIT

# Make sure to freeze process so Supervisor doesn't think it needs 
# to kill and restart
frozen
