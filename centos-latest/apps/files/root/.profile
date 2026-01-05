# shellcheck disable=SC2148,SC1090

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
  if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi
fi
mesg n 2>/dev/null || true
