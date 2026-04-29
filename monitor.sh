#!/bin/bash
echo '========================================='
echo '  AutoHeal Live Monitor - Health Check   '
echo '========================================='
while true; do
  RESULT=$(curl -s --max-time 2 http://localhost:3000/health)
  TIME=$(date '+%H:%M:%S')
  if [ -z "$RESULT" ]; then
    echo "[$TIME]  STATUS: DOWN  -  Container not responding!"
  else
    echo "[$TIME]  STATUS: UP    -  $RESULT"
  fi
  sleep 2
done
