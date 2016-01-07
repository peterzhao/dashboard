#!/bin/bash
set -e
process=`ps -ef | grep 'app.rb' | grep 'grep' -v | awk '{print $2}'`
if [ "$process" != "" ]; then
  kill -9 $process
  echo The server has been stopped.
else
  echo The server is not running. 
fi

