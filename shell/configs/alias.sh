# ============ Aliases =====================
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# reload zshrc
alias reload='. ~/.zshrc'


alias _!!='sudo !!'

# editor
EDITOR=code
alias e=$EDITOR
alias e.='e .'
alias c='code'
alias c.='c .'
alias cs='cursor'
alias cs.='cs .'
alias codei='code-insiders'
alias ci='codei'
alias ci.='codei .'
alias codei.='codei .'

# AIs
alias cld='claude'
alias claude-danger='claude --dangerously-skip-permissions'
alias claude-headless='claude -p --allow-dangerously-skip-permissions --output-format "stream-json" --permission-mode bypassPermissions --verbose'
alias claude-auto='claude --enable-auto-mode'
alias cla='claude agents'
alias cla-danger='claude agents --dangerously-skip-permissions'

# Claude Code profiles — session switcher
# Usage: claude-profile [ls|list] [<profile>] [-h|--help]
# Profiles live in the gitignored $DOTFILER_ROOT/claude-profiles.local (format:
# claude-profiles.local.example). bin/cp-router reads the same file. Without it, default = ~/.claude.
_claude_profiles_local() {
  local f
  for f in "${DOTFILER_ROOT:+$DOTFILER_ROOT/claude-profiles.local}" "$HOME/dev/workspace/mine/dotfiler/claude-profiles.local"; do
    [ -n "$f" ] && [ -r "$f" ] && { printf '%s\n' "$f"; return 0; }
  done
  return 1
}

# One line per profile: <name> <dir> [alias ...]
_claude_profiles_table() {
  local f rows=""
  if f="$(_claude_profiles_local)"; then
    rows="$(sed -e 's/#.*//' -e "s|~/|$HOME/|g" "$f" | awk 'NF { $1 = $1; print }')"
  fi
  # default always exists: it is where Claude goes with no CLAUDE_CONFIG_DIR.
  printf '%s\n' "$rows" | grep -q '^default ' || echo "default $HOME/.claude 0 me"
  [ -n "$rows" ] && printf '%s\n' "$rows"
}

claude-profile() {
  local _table _name _dir _rest _w _d _current
  _table="$(_claude_profiles_table)"

  _claude_profile_current_name() {
    local n d r
    if [[ -z "$CLAUDE_CONFIG_DIR" ]]; then echo "default"; return; fi
    while read -r n d r; do
      [[ "${d%/}" == "${CLAUDE_CONFIG_DIR%/}" ]] && { echo "$n"; return; }
    done <<< "$_table"
    echo "${CLAUDE_CONFIG_DIR##*/.claude-}"
  }

  _claude_profile_help() {
    local n d r
    echo "Usage: claude-profile [ls|list] [<profile>] [-h|--help]"
    echo ""
    echo "Commands:"
    echo "  (none)        show current active profile"
    echo "  ls, list      list all profiles"
    echo "  <profile>     switch to profile"
    echo ""
    echo "Profiles:"
    while read -r n d r; do
      printf '  %-8s %-22s %s\n' "$n" "${r:+(aliases: $r)}" "${d/#$HOME/~}"
    done <<< "$_table"
    echo ""
    echo "More profiles: $DOTFILER_ROOT/claude-profiles.local (gitignored)"
  }

  _claude_profile_list() {
    local n d r
    _current="$(_claude_profile_current_name)"
    echo "Profiles:"
    while read -r n d r; do
      if [[ "$n" == "$_current" ]]; then echo "  * $n  (active)"; else echo "    $n"; fi
    done <<< "$_table"
  }

  _claude_profile_save() {
    if [[ -z "$1" ]]; then
      echo "unset CLAUDE_CONFIG_DIR" > ~/.claude_profile
    else
      echo "export CLAUDE_CONFIG_DIR=$1" > ~/.claude_profile
    fi
  }

  if [[ -z "$1" ]]; then
    if [[ -z "$CLAUDE_CONFIG_DIR" ]]; then
      echo "Claude profile: default (~/.claude)"
    else
      echo "Claude profile: $(_claude_profile_current_name) ($CLAUDE_CONFIG_DIR)"
    fi
    return 0
  fi

  case "$1" in
    -h|--help) _claude_profile_help; return 0 ;;
    ls|list) _claude_profile_list; return 0 ;;
  esac

  _name=""
  while read -r _w _d _rest; do      # name, dir, aliases
    if [[ " $_w $_rest " == *" $1 "* ]]; then _name="$_w"; _dir="$_d"; break; fi
  done <<< "$_table"

  if [[ -z "$_name" ]]; then
    echo "claude-profile: unknown profile '$1'" >&2
    echo "" >&2
    _claude_profile_help >&2
    return 1
  fi
  if [[ "$_name" == "default" ]]; then
    unset CLAUDE_CONFIG_DIR
    _claude_profile_save ""
    echo "Claude profile: default (~/.claude)"
  else
    export CLAUDE_CONFIG_DIR="$_dir"
    _claude_profile_save "$CLAUDE_CONFIG_DIR"
    echo "Claude profile: $_name ($CLAUDE_CONFIG_DIR)"
  fi
}

# Claude Code profiles — explicit per-invocation aliases
alias claude-work="CLAUDE_CONFIG_DIR=~/.claude-work command claude"
alias claude-dev="CLAUDE_CONFIG_DIR=~/.claude-dev command claude"
alias claude-work-danger="CLAUDE_CONFIG_DIR=~/.claude-work command claude --dangerously-skip-permissions"
alias claude-dev-danger="CLAUDE_CONFIG_DIR=~/.claude-dev command claude --dangerously-skip-permissions"

alias gmi='gemini'
alias gemi='gemini'
alias gmp='gemini -p'

# command overwrite
if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -lh --git'
  alias dir='eza -T -L 1'
elif command -v exa >/dev/null 2>&1; then
  alias ls='exa'
  alias ll='exa -lh --git'
  alias dir='exa -T -L 1'
fi
alias cat='ccat'
alias img='imgcat'
alias mv='mv -v'
alias rm='rm -i -v'
# alias rm='trash'
alias cp='cp -v'
alias volume='m volume'
alias mute='m volume 0'
alias src='source'

# command alias
alias cls='clear'
alias notes='notesmd-cli'
alias newest='ll -s created | tr " " "\n"| tail -1'
alias o='open'
alias oo='open .'
alias obs='/Applications/Obsidian.app/Contents/MacOS/Obsidian'
alias v='vim'
alias x+='chmod +x'
alias py='python3'
alias py2='python2'
alias codei='code-insiders'
alias jpter='jupyter'
alias pip='pip3'
alias trans='~/.shell/trans'
alias transzh='~/.shell/trans :zh-TW -b'
alias readme='vim README.md'
alias hy='hyper'
alias tldr='tldr -v'
alias gw='./gradlew'
alias format='pygmentize'

# alias suffix for file extensions
# usage: just involke the file as a command

# -- img
alias -s png='img'
alias -s jpg='img'
alias -s jpeg='img'
# -- media
alias -s mp3='mpv'
alias -s wav='mpv'

alias -s pdf='open'
alias -s zip='unzip -l'
alias -s 7z='7z l'
alias -s txt='cat'
alias -s md='cursor'
alias -s json='cat'





# Dotfiles quick edit
alias vimz='vim $HOME/.zshrc'
alias vimzl='vim $HOME/.zsh.local'
alias vimh='vim $HOME/.hyper.js'
alias vimt='vim $HOME/.tmux.conf'
alias vima='vim $SHELL_DIR/alias.sh'
alias vimv='vim $HOME/.vimrc'
alias vimfd='vim $HOME/.functions/dev_finctions'
alias vimfo='vim $HOME/.functions/other_functions'
alias vimfs='vim $HOME/.functions/shell_functions'
alias vrm='vim ./README.md'
alias sublRM='subl ./README.md'
alias codeRM='code ./README.md'

# For adb
alias devices='adb devices'
alias connect='adb connect'
alias disconnect='adb disconnect'
alias 'adb install'='adb install -r'

# For python
alias py-activate='source ./venv/bin/activate'


# Entertainment
alias ptt='ssh bbsu@ptt.cc'
alias youtube='mpsyt'
# alias rdeddit='rtv'
alias yt-dl='youtube-dl'

# For Javis
alias javis='py ~/.function_support/ifttt_webhook/javis.py'


# For git
# alias git='/usr/local/bin/git'
alias flow='git flow'
alias gco-='git checkout -'
alias git_create_ignore='_f_git_ignore'
alias gitignore='_f_git_ignore'
alias gaf='_f_git_add'
alias gdifff='_f_git_diff'
alias glogf='_f_git_log'


# For Heroku
alias heroP='git push heroku'
alias herop='git push heroku'
alias heroL='heroku logs -t'


# Work faster
alias pretty_json='python3 -m json.tool'
alias json='pretty_json'
alias parse_chr='py $HOME/Dev/Py/charles-session-parse/parser.py'
alias dex2jar='. ~/dev/apk_decompile/dex2jar/dex2jar-2.0/d2j-dex2jar.sh'
alias avd='$ANDROID_SDK/emulator/emulator'

# Navigation
alias desk='cd ~/Desktop'
alias di='dirs -v | head -10 | yank'

# Google Cloud Platform
alias 'g_dev_deploy'='gcloud app deploy --version dev'
alias 'g_dev_stop'='gcloud app versions stop dev'
alias 'g_dev_start'='gcloud app versions start dev'


# NPM
alias 'npmid'='npm install -D'
alias 'npmi'='npm install'

# For fasd
alias a='fasd -a'        # any
alias s='fasd -si'       # show / search / select
alias sd='fasd -sid'     # interactive directory selection
alias sf='fasd -sif'     # interactive file selection



alias nvm='echo "using fnm..."; echo ""; fnm'

alias task='tb'

# From coreutils
alias timeout=gtimeout


# alias gcloud="docker run --rm -ti \
#     --platform linux/amd64 \
#     -v $HOME/.config/gcloud:/root/.config/gcloud \
#     google/cloud-sdk gcloud"


# Shell Help System
alias help='shelp'
alias h='shelp'
alias shelp-rebuild='shelp-build --clean'
alias shelp-update='shelp-build --quiet'

# un-alias
unalias g 2>/dev/null || true
unalias l 2>/dev/null || true
unalias glgm 2>/dev/null || true
unalias glg 2>/dev/null || true
unalias glgg 2>/dev/null || true
unalias glog 2>/dev/null || true
unalias gloga 2>/dev/null || true
unalias grh 2>/dev/null || true
unalias gcloud 2>/dev/null || true
