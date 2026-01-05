# shellcheck disable=all
# author https://github.com/lwmacct

__main() {
  [[ -n $ZSH_VERSION ]] && setopt no_nomatch

  # 安全加载 env 文件：只解析 KEY=VALUE 格式，拒绝可执行内容
  _safe_source_env() {
    [[ ! -f $1 ]] && return
    while IFS= read -r _line || [[ -n $_line ]]; do
      # 跳过空行和注释
      [[ -z $_line || $_line == \#* ]] && continue
      # 严格匹配: KEY=VALUE 格式
      if [[ $_line =~ ^[a-zA-Z_][a-zA-Z0-9_]*= ]]; then
        # 使用 glob 模式检测危险字符: $ ` (比正则更兼容 zsh/bash)
        if [[ $_line == *'$'* || $_line == *'`'* ]]; then
          echo "[env.sh] 跳过危险行 ($1): $_line" >&2
          continue
        fi
        export "${_line?}"
      fi
    done <"$1"
  }

  # 加载 workspace 下的环境变量文件 (按优先级排序)
  {
    find /apps/data/workspace/*/ -maxdepth 1 -type f -name '.env.example' 2>/dev/null
    find /apps/data/workspace/*/ -maxdepth 1 -type f -name '.env' 2>/dev/null
  } | grep -vE "(/ln-)|(vendor)" | while IFS= read -r _f; do
    _safe_source_env "$_f"
  done

  # 加载 /root/.env
  _safe_source_env /root/.env
}

__main
