#!/bin/bash

# ==============================================================================
# AutoHeal Deploy - Health Monitor Setup Script
# ==============================================================================
# Installs a systemd timer to run the health monitor every 20 seconds.
# ==============================================================================

# This assumes the repo is cloned to /home/ubuntu/autoheal-deploy as per userdata.sh
SCRIPT_PATH="/home/ubuntu/autoheal-deploy/scripts/health_monitor.sh"

# Make the health monitor executable
chmod +x $SCRIPT_PATH

# Remove any legacy cron entry for this script
(crontab -l 2>/dev/null | grep -v -F "$SCRIPT_PATH") | crontab -

# Create systemd service
cat <<EOF | sudo tee /etc/systemd/system/autoheal.service >/dev/null
[Unit]
Description=AutoHeal health monitor

[Service]
Type=oneshot
ExecStart=/bin/bash $SCRIPT_PATH
EOF

# Create systemd timer (every 20 seconds)
cat <<EOF | sudo tee /etc/systemd/system/autoheal.timer >/dev/null
[Unit]
Description=Run AutoHeal health monitor every 20 seconds

[Timer]
OnBootSec=20s
OnUnitActiveSec=20s
AccuracySec=1s
Unit=autoheal.service
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now autoheal.timer

echo "Auto-healing timer configured to run every 20 seconds."
