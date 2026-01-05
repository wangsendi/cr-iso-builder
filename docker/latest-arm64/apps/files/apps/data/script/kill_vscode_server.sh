#!/usr/bin/env bash

# 检查一次没有客户端客连接的 code-server 进程
__kill_vscode_server() {
  # shellcheck disable=SC2009
  if [[ $(ps -ef | grep -v $$ | grep 'type=fileWatcher$' -c) != '0' ]]; then return; fi

  {
    # 如果是 linuxkit 系统，则直接关闭进程
    if [[ "$(uname -r | grep linuxkit -c)" == "1" ]]; then
      pkill -f '# Watch|vscode-server|cursor-server'
      sleep 2
      {
        # 如果没有任何进程在 ? 终端下运行，则关闭进程
        _ps_eo=$(ps -eo pid,tty,stat,command)
        if [[ "$(echo "$_ps_eo" | grep -vE '(kill_vscode_server.sh|command)$' | awk '$2 == "?"' | wc -l)" == "0" ]]; then
          docker stop $HOSTNAME >/dev/null 2>&1
          return
        fi
      }
      return
    fi
  }

  {
    # 如果不是 linuxkit 系统，则判断进程运行时间是否大于10分钟，如果大于10分钟，则关闭进程
    _last_pid=$(ps -ef | grep '(vscode|cursor)-server.*node\s' -E | awk '{print $2}' | sort -n | tac | head -n1)
    if [[ "$_last_pid" == "" ]]; then return; fi
    _etimes=$(ps -p "$_last_pid" -o etimes= | tr -d ' ' | head -n1)
    echo "_last_pid: $_last_pid, _etimes: $_etimes"

    if [[ -n "$_etimes" ]] && [[ "$_etimes" =~ ^[0-9]+$ ]] && ((_etimes > 600)); then
      pkill -f '# Watch|vscode-server|cursor-server'
    fi
  }

}

__kill_vscode_server
