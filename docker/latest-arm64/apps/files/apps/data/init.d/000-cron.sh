#!/usr/bin/env bash

__main() {
  cat >/etc/supervisor/conf.d/cron.conf <<EOF
[program:cron]
command=cron -f
autostart=true
autorestart=true
startretries=3
user=root
redirect_stderr=true
stdout_logfile=/var/log/cron.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
environment=TERM="xterm"
EOF
}

__main
