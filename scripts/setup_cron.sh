#!/bin/bash

# ==============================================================================
# AutoHeal Deploy - Cron Setup Script
# ==============================================================================
# Adds the health monitor script to the crontab to run every minute.
# ==============================================================================

# This assumes the repo is cloned to /home/ubuntu/autoheal-deploy as per userdata.sh
SCRIPT_PATH="/home/ubuntu/autoheal-deploy/scripts/health_monitor.sh"

# Make the health monitor executable
chmod +x $SCRIPT_PATH

# Check if the cron job already exists to avoid duplicates
(crontab -l 2>/dev/null | grep -v -F "$SCRIPT_PATH") | crontab -

# Add the new cron job
(crontab -l 2>/dev/null; echo "* * * * * /bin/bash $SCRIPT_PATH") | crontab -

echo "Cron job for auto-healing successfully setup to run every minute."
