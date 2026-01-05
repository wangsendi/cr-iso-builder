#!/usr/bin/env bash

__main() {

  mkdir -p /root/.ssh && chmod 700 /root/.ssh

  # 连接新设备时不提示指纹信息
  [[ ! -f "/root/.ssh/config" ]] && echo "StrictHostKeyChecking no" >>/root/.ssh/config

  # 如果 SSH_SECRET_KEY 为空，则生成新的 SSH 密钥
  if [[ -z "${SSH_SECRET_KEY}" ]]; then
    # 只有当 id_ed25519 不存在时才生成，避免 Overwrite 提示
    if [[ ! -f "/root/.ssh/id_ed25519" ]]; then
      ssh-keygen -t ed25519 -N '' -f /root/.ssh/id_ed25519 -C "$(hostname)"
    fi
  else
    # 如果 SSH_NOT_OVERWRITE 不为 1 或 id_ed25519 文件不存在，则写入 SSH_SECRET_KEY
    if [[ "${SSH_NOT_OVERWRITE}" != "1" || ! -f "/root/.ssh/id_ed25519" ]]; then
      echo "$SSH_SECRET_KEY" | base64 -d >/root/.ssh/id_ed25519
      chmod 600 /root/.ssh/id_ed25519
      ssh-keygen -y -f /root/.ssh/id_ed25519 >/root/.ssh/id_ed25519.pub
      chmod 644 /root/.ssh/id_ed25519.pub
    fi
  fi
}

__main
