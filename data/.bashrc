# Test for an interactive shell. There is no need to set anything past this
# point for scp and rcp, and it's important to refrain from outputting
# anything in those cases.
if [[ $- != *i* ]]; then
    return
fi

# Source defaults under Fedora Linux.
if [[ -e /etc/fedora-release && -e /etc/bashrc ]]; then
    source /etc/bashrc
    unset -v PROMPT_COMMAND
fi

# Determine whether we run in a terminal possibly capable of displaying
# eye-candy (e.g., fancy Unicode characters).
if [[ ${TERM} == screen* ]]; then
    __REAL_TERM="${__SCREEN_TERM}"
else
    __REAL_TERM="${TERM}"
fi
if [[ ${__REAL_TERM} == xterm* ]]; then
    __EYE_CANDY='true'
fi

# Get ANSI colors and text attributes.
if [[ $(uname) == 'FreeBSD' ]]; then
    # termcap code
    __CAP_SET_FG='AF'
    __CAP_SET_BG='AB'
    __CAP_SET_BOLD='md'
    __CAP_SET_DIM='mh'
    __CAP_RESET='me'
else
    # terminfo code
    __CAP_SET_FG='setaf'
    __CAP_SET_BG='setab'
    __CAP_SET_BOLD='bold'
    __CAP_SET_DIM='dim'
    __CAP_RESET='sgr0'
fi
__FG_BLACK=$(tput ${__CAP_SET_FG} 0)
__FG_RED=$(tput ${__CAP_SET_FG} 1)
__FG_GREEN=$(tput ${__CAP_SET_FG} 2)
__FG_YELLOW=$(tput ${__CAP_SET_FG} 3)
__FG_BLUE=$(tput ${__CAP_SET_FG} 4)
__FG_MAGENTA=$(tput ${__CAP_SET_FG} 5)
__FG_CYAN=$(tput ${__CAP_SET_FG} 6)
__FG_WHITE=$(tput ${__CAP_SET_FG} 7)
__BG_BLACK=$(tput ${__CAP_SET_BG} 0)
__BG_RED=$(tput ${__CAP_SET_BG} 1)
__BG_GREEN=$(tput ${__CAP_SET_BG} 2)
__BG_YELLOW=$(tput ${__CAP_SET_BG} 3)
__BG_BLUE=$(tput ${__CAP_SET_BG} 4)
__BG_MAGENTA=$(tput ${__CAP_SET_BG} 5)
__BG_CYAN=$(tput ${__CAP_SET_BG} 6)
__BG_WHITE=$(tput ${__CAP_SET_BG} 7)
__BOLD=$(tput ${__CAP_SET_BOLD})
__DIM=$(tput ${__CAP_SET_DIM})
__RESET=$(tput ${__CAP_RESET})

# Set some characters and strings used in the prompt.
__STR_PROMPT_DIVIDER='--'
__STR_PROMPT_END='--> '
__CHAR_PROMPT_CHECK_MARK='o'
__CHAR_PROMPT_CROSS_MARK='x'

# Set system-specific adjustments regarding colors and attributes.
if [[ $(uname) == 'FreeBSD' ]]; then
    # For some reason, in Screen under FreeBSD (at least in Konsole),
    # dim bold results in text being underlined as well, so we resort to
    # plain bold. The issue might be termcap-related, as "tput mh" (for
    # half-bright mode) does not work, either. So maybe Screen resorts
    # to using underline, but idk.
    __ATTR_SCREEN_DIM_BOLD='b'
else
    __ATTR_SCREEN_DIM_BOLD='db'
fi
if [[ ${__EYE_CANDY} ]]; then
    __FG_BLACK_DIM_BOLD="${__FG_BLACK}${__DIM}${__BOLD}"
    __ATTR_SCREEN_DIM_BOLD_FOR_BLACK_FG="${__ATTR_SCREEN_DIM_BOLD}"
else
    # On the Linux console, (dim) bold black text is ugly. Therefore,
    # omit the dim and bold attributes for such text in the prompt and
    # in Screen.
    __FG_BLACK_DIM_BOLD="${__FG_BLACK}"
    __ATTR_SCREEN_DIM_BOLD_FOR_BLACK_FG=''
fi
export __ATTR_SCREEN_DIM_BOLD
export __ATTR_SCREEN_DIM_BOLD_FOR_BLACK_FG

# Define a function to update all dynamic parts of the prompt. The
# functions called by this function update variables that store the
# dynamic parts of the prompt. This is necessary because "\[" and "\]"
# (for a sequence of non-printing characters) are not recognized in
# command substitutions in $PS1, possibly because command substitution
# takes place after $PS1 is decoded. The alternative would be to use
# several functions that format the printing and non-printing portions
# of each dynamic part separately, and call those functions directly in
# $PS1. However, this proves difficult for the status indicator, which
# relies on an unaltered $? (which gets modified by subsequent function
# calls; okay, this can be prevented, as we do below). In addition,
# multiple functions for each dynamic part are tedious, as for example
# the check for a git repo in the working directory would have to be
# performed three times (if not done before display of the prompt with
# the result stored in a variable). Therefore, we store the printing and
# non-printing portions in variables, update them in a single function
# per dynamic part before the prompt is displayed, and then reference
# the variables in $PS1 with the appropriate "\[" and "\]".
__bash_prompt_update_dynamic_parts() {
    local status=$?

    __bash_prompt_update_status_indicator $status
    __bash_prompt_update_vc_state
    __bash_prompt_update_env_state

    return $status
}

# Define a function to update the prompt's status indicator.
__bash_prompt_update_status_indicator() {
    [[ $# -eq 1 ]] || return 1

    if [[ $1 -eq 0 ]]; then
        local char="${__CHAR_PROMPT_CHECK_MARK}"
        local bg="${__BG_GREEN}"
    else
        local char="${__CHAR_PROMPT_CROSS_MARK}"
        local bg="${__BG_RED}"
    fi

    __BASH_PROMPT_DYN_STATUS_INDICATOR_PRE="${__FG_WHITE}${bg}${__BOLD}"
    __BASH_PROMPT_DYN_STATUS_INDICATOR_MAIN=" ${char} "
    __BASH_PROMPT_DYN_STATUS_INDICATOR_POST="${__RESET}"

    return 0
}

# Define a function to update the version control state in the prompt.
__bash_prompt_update_vc_state() {
    __BASH_PROMPT_DYN_VC_STATE_PRE=''
    __BASH_PROMPT_DYN_VC_STATE_MAIN=''
    __BASH_PROMPT_DYN_VC_STATE_POST=''

    # TODO

    return 0
}

# Define a function to update the environment state in the prompt.
__bash_prompt_update_env_state() {
    __BASH_PROMPT_DYN_ENV_STATE_PRE=''
    __BASH_PROMPT_DYN_ENV_STATE_MAIN=''
    __BASH_PROMPT_DYN_ENV_STATE_POST=''

    # TODO

    return 0
}

# Define prompt, window title, and icon name.
__BASH_PROMPT="\[\${__BASH_PROMPT_DYN_STATUS_INDICATOR_PRE}\]\${__BASH_PROMPT_DYN_STATUS_INDICATOR_MAIN}\[\${__BASH_PROMPT_DYN_STATUS_INDICATOR_POST}\]${__STR_PROMPT_DIVIDER}\[${__FG_BLACK}${__BG_WHITE}\] \u@\h \[${__RESET}\]${__STR_PROMPT_DIVIDER}\[${__FG_BLACK_DIM_BOLD}${__BG_CYAN}\] \w \[${__RESET}\]\[\${__BASH_PROMPT_DYN_VC_STATE_PRE}\]\${__BASH_PROMPT_DYN_VC_STATE_MAIN}\[\${__BASH_PROMPT_DYN_VC_STATE_POST}\]\[\${__BASH_PROMPT_DYN_ENV_STATE_PRE}\]\${__BASH_PROMPT_DYN_ENV_STATE_MAIN}\[\${__BASH_PROMPT_DYN_ENV_STATE_POST}\]${__STR_PROMPT_END}"
__BASH_WINDOW_TITLE='\u@\h: \W'
__BASH_ICON_NAME='\W'

# Define a function to update the window title and icon name.
__bash_update_window_title() {
    [[ $# -eq 2 ]] || return 1
    local window_title=$1
    local icon_name=$2

    case ${TERM} in
        xterm*)
            printf "\e]2;%s\a" "$window_title"
            printf "\e]1;%s\a" "$icon_name"
            ;;

        screen*)
            # Set Screen window's title.
            printf "\ek%s\e\\" "$window_title"
            # Set Screen window's hardstatus.
            printf "\e]0;%s\a" "$window_title"
            ;;
    esac

    return 0
}

# Define a function to set the bash prompt (PS1) so that it modifies the
# window title and icon name. The function also sets up updates of the
# dynamic parts of the prompt.
__bash_set_prompt() {
    [[ $# -eq 3 ]] || return 1
    local prompt=$1
    local window_title=$2
    local icon_name=$3

    case ${TERM} in
        xterm*)
            export PS1="\[\e]2;${window_title}\a\e]1;${icon_name}\a\]${prompt}"
            ;;

        screen*)
            # In this case, "\\\\" is necessary to get a single
            # backslash in $PS1, as "\\" becomes "\" in a double-quoted
            # string and "\\" again gets substituted by "\" in
            # $PS1. With just "\\\e" in the string below, we would get
            # "\\e" after the string is interpreted, resulting in a
            # literal backslash and the character "e" after decoding of
            # $PS1, instead of a literal backslash (the end of the
            # window title sequence) followed by ESC (the start of the
            # hardstatus sequence).
            export PS1="\[\ek${window_title}\e\\\\\e]0;${window_title}\a\]${prompt}"
            ;;

        *)
            export PS1="${prompt}"
    esac

    PROMPT_COMMAND='__bash_prompt_update_dynamic_parts'

    return 0
}

# Set the prompt, which will modify the window title and icon name
# dynamically. In addition, dynamically set the window title and icon
# name to the currently running command.
__bash_set_prompt "$__BASH_PROMPT" "$__BASH_WINDOW_TITLE" "$__BASH_ICON_NAME"
trap '__bash_update_window_title "${BASH_COMMAND}" "${BASH_COMMAND%% *}"' DEBUG

# Set paths.
export PATH="$PATH:$HOME/.local/bin:$HOME/bin"
export PERL5LIB="$HOME/lib/perl5"
export R_LIBS_USER="$HOME/lib/R"

# Integrate Google Cloud CLI/SDK.
__SCRIPT_GCLOUD_PATH="$HOME/opt/google-cloud-sdk/path.bash.inc"
__SCRIPT_GCLOUD_COMPLETION="$HOME/opt/google-cloud-sdk/completion.bash.inc"
[ -e "$__SCRIPT_GCLOUD_PATH"       ] && source "$__SCRIPT_GCLOUD_PATH"
[ -e "$__SCRIPT_GCLOUD_COMPLETION" ] && source "$__SCRIPT_GCLOUD_COMPLETION"

# Set aliases.
alias ll='ls -lh'
alias la='ll -A'
alias lt='la -t'
alias htop='btop' # Prevent us from inadvertently calling htop.

# Set default programs.
export EDITOR='emacs -nw'
export VISUAL='emacs -nw'
export PAGER='less'

# Set options to less.
export LESS='-R -M'

# Enable colored ls output under FreeBSD.
export CLICOLOR=1

# Set the lock program to be used by Screen.
#export LOCKPRG="$HOME/bin/lock-terminal"
export LOCKPRG='builtin'
