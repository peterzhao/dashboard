#!/bin/bash
set -e
process=`ps -ef | grep 'app.rb' | grep 'grep' -v | awk '{print $2}'`
if [ "$process" == "" ]; then
  ruby app.rb >logs/server 2>&1 &
  sleep 2
  new_process=`ps -ef | grep 'app.rb' | grep 'grep' -v | awk '{print $2}'`
  if [ "$new_process" == "" ]; then
    echo The server has failed to start.
    exit 1
  else
    echo The server has been started succussfully! 
  fi
else
  echo The server is running. 
fi
