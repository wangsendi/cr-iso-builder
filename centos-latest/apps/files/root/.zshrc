__main() {

  {
    : # 执行 ~/.zshrc.d/*.sh
    _file=~/.zshrc.d/alias.sh && mkdir -p ${_file%/*}
    for file in ~/.zshrc.d/*.sh; do
      if [[ -r $file ]]; then
        source "$file"
      fi
    done
  }

  # 判断 SHELL 是否为 bash, 如果是则不加载 $ZSH/oh-my-zsh.sh
  if [[ "$BASH_VERSION" != "" ]]; then return; fi

  {
    # 只在「交互式 shell 且不在 tmux 里」时自动执行
    if [[ $- == *i* ]] && [ -z "$TMUX" ]; then
      if ! tmux has-session -t "tmux" 2>/dev/null; then
        cd "/apps/data/workspace/$(hostname)" || true
        tmux new-session -s "tmux" "$@"
      fi
    fi
  }

  {
    export ZSH="/opt/ohmyzsh"
    export ZSH_CUSTOM="$ZSH/custom"
    ZSH_THEME="bira" # robbyrussell=默认主题, agnoster=高亮主题, bira = 简单主题
    ZSH_COMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump"
    plugins=(
      zsh-autosuggestions
      zsh-syntax-highlighting
      zsh-completions
      per-directory-history
      zsh-history-substring-search
      you-should-use
      zsh-interactive-cd
      git
      docker
    )
    source $ZSH/oh-my-zsh.sh
  }

}

__main
