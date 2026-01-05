#!/usr/bin/env bash
# Admin https://www.yuque.com/lwmacct

__main() {

  {
    : # 初始化文件
    mkdir -p /apps/data/{workspace,logs,supervisor.d}
    tar -vcpf - -C /apps/links . | (cd / && tar -xpf - --skip-old-files)
    (cd /apps/data/workspace && go work init)
  } 2>&1 | tee /apps/data/logs/entry-tar.log

  {
    echo "start init"
    for _script in /apps/data/init.d/*.sh; do
      if [ -r "$_script" ]; then
        echo "Run $_script"
        timeout 30 bash "$_script"
      fi
    done
  } 2>&1 | tee -a /apps/data/logs/entry-init.log

  cat >/etc/supervisord.conf <<EOF
[unix_http_server]
file=/run/supervisord.sock
chmod=0700
chown=nobody:nogroup

[supervisord]
user=root
nodaemon=true
pidfile=/var/run/supervisord.pid
logfile=/var/log/supervisord.log
logfile_maxbytes=100MB
logfile_backups=2

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///run/supervisord.sock
prompt=mysupervisor
history_file=~/.sc_history

[include]
files = /etc/supervisor/conf.d/*.conf /apps/data/supervisor.d/*.conf
EOF
  exec supervisord

}

__main
