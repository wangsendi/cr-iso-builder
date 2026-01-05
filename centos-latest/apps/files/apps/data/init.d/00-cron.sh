#!/usr/bin/env bash

__main() {

  cat >/apps/data/supervisor.d/cron.conf <<EOF
[program:cron]
command=cron -f
autostart=true
autorestart=true
startretries=3
user=root
redirect_stderr=true
stdout_logfile=/apps/data/logs/cron.stdout.log
stdout_logfile_maxbytes=10MB
stdout_logfile_backups=3
stderr_logfile=/apps/data/logs/cron.stderr.log
stderr_logfile_maxbytes=10MB
stderr_logfile_backups=3
environment=TERM="xterm"
EOF
}
