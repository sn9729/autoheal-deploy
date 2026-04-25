#!/bin/bash

# ==============================================================================
# AutoHeal Deploy - Health Monitor Script
# ==============================================================================
# This script continuously monitors the /health endpoint of the Node.js application.
# If the endpoint fails to return a 200 HTTP status, it attempts to self-heal
# by restarting the Docker container and logs all activities.
# ==============================================================================

LOG_FILE="/var/log/autoheal.log"
APP_URL="http://localhost:3000/health"
CONTAINER_NAME="autoheal-app"

# Ensure the log file exists and is writable (requires sudo initially but usually runs as root/ubuntu)
sudo touch $LOG_FILE || true
sudo chmod 666 $LOG_FILE || true

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting health check..." >> $LOG_FILE

# Perform the curl request, silently (-s), outputting only the HTTP code
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL)

if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Health check failed with status $HTTP_STATUS. Initiating recovery..." >> $LOG_FILE
    
    # Attempt to restart the container
    docker restart $CONTAINER_NAME
    
    # Wait for the container to spin up
    sleep 15
    
    # Re-verify the health
    HTTP_STATUS_RETRY=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL)
    
    if [ "$HTTP_STATUS_RETRY" -ne 200 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] CRITICAL: Container restart failed. App is still down (Status: $HTTP_STATUS_RETRY)." >> $LOG_FILE
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: App recovered successfully after restart." >> $LOG_FILE
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] App healthy." >> $LOG_FILE
fi
