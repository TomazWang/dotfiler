_fzf_complete_foo() {
  _fzf_complete "--multi --reverse --header-lines=3" "$@" < <(
    ls
  )
}

_fzf_complete_foo_post() {
  awk '{print $1}'
}


# fh - repeat history
recmd() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

alias historyfz=recmd