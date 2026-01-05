#### ----------------- 使用说明 -----------------
#
# 按键绑定：
#   / → fzf 历史命令搜索
#   @ → fzf 文件/目录路径搜索
#
# 触发条件：
#   • 空行时直接按键即可触发
#   • 已有内容时需先输入空格再按键触发
#
# 示例：
#   输入      触发    选择         结果
#   ──────────────────────────────────────
#   /        ✅      ls -la       ls -la
#   @        ✅      file.txt     file.txt
#   abc /    ✅      ls -la       abc ls -la
#   abc @    ✅      file.txt     abc file.txt
#   abc/     ❌      -            abc/
#   abc@     ❌      -            abc@
#
# 依赖：
#   • fzf    - 模糊搜索工具
#   • fd     - 快速文件查找（可选，路径搜索需要）
#

#### ----------------- 只在 zsh 环境下启用 -----------------
# 非 zsh 直接返回（如果是被 source 到别的 shell 里时也安全）
if [ -z "${ZSH_VERSION-}" ]; then
  return 0 2>/dev/null || exit 0
fi

#### ----------------- fzf 基础配置（可选） -----------------
if [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
fi

#### ----------------- 初始化 fd/fdfind -----------------
# 用数组缓存命令和默认参数
typeset -ga _FD_CMD

__fzf_path_init_fd() {
  if command -v fd >/dev/null 2>&1; then
    _FD_CMD=(fd --strip-cwd-prefix)
  elif command -v fdfind >/dev/null 2>&1; then
    _FD_CMD=(fdfind --strip-cwd-prefix)
  else
    _FD_CMD=() # 没有可用 fd 命令
  fi
}

#### ----------------- 判断"是否满足触发条件" -----------------
# 空行直接触发，有内容时需要空格前缀
__fzf_can_trigger() {
  if [[ -z "$LBUFFER" ]]; then
    return 0 # 空行，可以触发
  fi
  [[ "$LBUFFER" =~ [[:space:]]$ ]] # 有内容时需要空格前缀
}

#### ----------------- fzf 历史搜索 widget -----------------
__fzf_history_widget() {
  # 不满足触发条件时，当普通字符插入
  if ! __fzf_can_trigger; then
    zle self-insert
    return
  fi

  local _selected=$(fc -rl 1 | fzf --height 40% --reverse --prompt='' +s --tac)
  if [[ -n "$_selected" ]]; then
    # 移除历史行号前缀 (如 "  123 command")
    local _cmd="${_selected#*[[:space:]][[:space:]]}"
    # 追加到现有内容后面
    if [[ -z "$LBUFFER" ]]; then
      LBUFFER="$_cmd" # 空行直接追加
    else
      LBUFFER="${LBUFFER% } $_cmd" # 有内容时去掉触发空格，加一个分隔空格
    fi
  fi
  zle reset-prompt
}
zle -N __fzf_history_widget

#### ----------------- fzf 选择文件/目录并插入 -----------------
__fzf_path_widget() {
  # 如果没 fd/fdfind，就退回普通字符行为
  if ((${#_FD_CMD[@]} == 0)); then
    zle self-insert
    return
  fi

  if __fzf_can_trigger; then
    local _target
    # 当前目录下所有文件+目录，遵守 .gitignore，并去掉 ./ 前缀
    # 如需包含隐藏文件，可以改成： "${_FD_CMD[@]}" --hidden .
    _target=$("${_FD_CMD[@]}" . 2>/dev/null | fzf --height 40% --reverse --prompt '')
    local _ret=$?
    if [[ $_ret -ne 0 ]]; then
      zle reset-prompt
      return $_ret
    fi

    # 追加到现有内容后面
    if [[ -z "$LBUFFER" ]]; then
      LBUFFER="$_target" # 空行直接追加
    else
      LBUFFER="${LBUFFER% } $_target" # 有内容时去掉触发空格，加一个分隔空格
    fi
    zle reset-prompt # 重绘命令行
  else
    # 没有空格前缀时，当普通字符插入
    zle self-insert
  fi
}

#### ----------------- 主入口 -----------------
__main() {
  __fzf_path_init_fd

  # 没有 fd/fdfind 就不绑定 widget，避免浪费按键
  ((${#_FD_CMD[@]} > 0)) || return

  zle -N __fzf_path_widget
  bindkey '/' __fzf_history_widget # / → 历史搜索
  bindkey '@' __fzf_path_widget    # @ → 路径搜索
}

__main
