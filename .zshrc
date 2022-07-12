
# You should have received the contents of zsh-hl/ and zsh-as/ directory with this file.
# These come from https://github.com/zsh-users.

setopt NO_BEEP
setopt C_BASES
setopt OCTAL_ZEROES
setopt PRINT_EIGHT_BIT
setopt SH_NULLCMD
setopt AUTO_CONTINUE
setopt NO_BG_NICE
setopt PATH_DIRS
setopt NO_NOMATCH
setopt EXTENDED_GLOB
disable -p '^'
setopt LIST_PACKED
setopt BASH_AUTO_LIST
setopt NO_AUTO_MENU
setopt NO_CORRECT
setopt NO_ALWAYS_LAST_PROMPT
setopt NO_FLOW_CONTROL
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

SAVEHIST=9000
HISTSIZE=9000
HISTFILE=~/.zsh_history

LISTMAX=0
REPORTTIME=60
TIMEFMT="%J  %U user %S system %P cpu %MM memory %*E total"
MAILCHECK=0

# gitpwd - print %~, limited to $NDIR segments, with inline git branch
NDIRS=3
gitpwd() {
    local -a segs splitprefix; local gitprefix branch
    segs=("${(Oas:/:)${(D)PWD}}")
    segs=("${(@)segs/(#b)(?(#c10))??*(?(#c5))/${(j:...:)match}}")

    if gitprefix=$(git rev-parse --show-prefix 2>/dev/null); then
        splitprefix=("${(s:/:)gitprefix}")
        if ! branch=$(git symbolic-ref -q --short HEAD); then
            branch=$(git name-rev --name-only HEAD 2>/dev/null)
            [[ $branch = *\~* ]] || branch+="~0"    # distinguish detached HEAD
        fi
        if (( $#splitprefix > NDIRS )); then
            print -n "${segs[$#splitprefix]}@$branch "
        else
            segs[$#splitprefix]+=@$branch
        fi
    fi

    (( $#segs == NDIRS+1 )) && [[ $segs[-1] == "" ]] && print -n /
    print "${(j:/:)${(@Oa)segs[1,NDIRS]}}"
}

# Execution time start
_exec_time_preexec_hook() {
    _exec_time_start=$(date +%s)
}

# Execution time end
_exec_time_precmd_hook() {
    [[ -z $_exec_time_start ]] && return
    local _exec_time_stop=$(date +%s)
    _exec_time_duration=$(( $_exec_time_stop - $_exec_time_start ))
    unset _exec_time_start
}

displaytime() {
    local T=$1
    local M=$((T/60))
    local S=$((T%60))
    if [[ $M > 0 ]]; then
        printf '%dm %ds' $M $S
    else
        printf '%ds' $S
    fi
}

# window title
_wndtitle_precmd_hook () { print -Pn '\e]0;$(gitpwd)\a' }

autoload -Uz add-zsh-hook
add-zsh-hook preexec _exec_time_preexec_hook
add-zsh-hook precmd _exec_time_precmd_hook
add-zsh-hook precmd _wndtitle_precmd_hook

_paint_exec_time() {
    if [[ $_exec_time_duration -ge 2 ]]; then
        print -n $(displaytime $_exec_time_duration)
        _exec_time_duration=0
        _exec_time_start=0
    fi
}

# prompt pt. 2
setopt PROMPT_SUBST
PS1=' %F{9}%? %F{211}$(date +"[%H:%M]") %F{220}$(gitpwd) %F{225}%#%f '
RPROMPT='%F{104}$(_paint_exec_time) '

autoload -Uz compinit
compinit
# paste to termbin
alias termbin='nc termbin.com 9999'
# repeat N times
alias repn="perl -e 'print((shift@ARGV)x(shift@ARGV));'"
# paste to 0x0
0x0() { curl -F "file=@${1:--}" https://0x0.st/ }
# wrap long lines using backslashes
wrap() { perl -pe 's/.{'$(( ${COLUMNS:-80} - 1))'}/$&\\\n/g' -- "$@" }
# reload zshrc
alias reload='source ~/.zshrc'
# create a 256M ramdisk
alias ramdisk='sudo mount -t tmpfs -o size=256m tmpfs /mnt/ramdisk && cd /mnt/ramdisk'
# muscle memory
alias quit="exit"
# faster navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
# colors!
_cls() { if [ -t 1 ]; then /bin/ls --color $*; else /bin/ls $*; fi }
alias l="_cls -lF"
alias la="_cls -lAF"
alias lsd="_cls -lF | grep --color=never '^d'"
alias ls="_cls"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
# random things
mkd() { mkdir -p "$1" && cd "$1" }
exe() { chmod a+x "$1" }
alias md='mkdir'
alias poweroff='/sbin/shutdown -P now'
alias reboot='/sbin/shutdown -r now'
# set the shell
SHELL=/usr/bin/zsh
# keybinds!
key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"
[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word
# ctrl+s => accept autosuggestion
bindkey "^S" forward-char
# syntax highlighting
. ~/zsh-hl/zsh-syntax-highlighting.zsh
. ~/zsh-as/zsh-autosuggestions.zsh
# things and stuff
PATH="/home/palaiologos/.nvm/versions/node/v14.16.0/bin:/home/palaiologos/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/palaiologos/.local/bin:/usr/local/djgpp/bin/:/usr/local/sbin"
(eval `ssh-agent` && ssh-add) > /dev/null 2> /dev/null
