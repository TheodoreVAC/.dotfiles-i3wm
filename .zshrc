# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
if [[ -r "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
  export ZSH="$HOME/.oh-my-zsh"
else
  export ZSH="/usr/share/oh-my-zsh"
fi
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="oh-my-via/my-via"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change the frequency the auto-updater is run (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line to set how old an update must be before it's applied, manually or via the auto-updater (in days).
# zstyle ':omz:update' cooldown 10

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# zsh-syntax-highlighting — red theme
# zsh-syntax-highlighting
typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[command]='fg=#E63946'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#E63946'
ZSH_HIGHLIGHT_STYLES[function]='fg=#FF5A63'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#FF5A63'

ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF5A63'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#E63946'

ZSH_HIGHLIGHT_STYLES[path]='fg=#E0A458'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#C2555F'

ZSH_HIGHLIGHT_STYLES[single-quoted]='fg=#E9843F'
ZSH_HIGHLIGHT_STYLES[double-quoted]='fg=#E9843F'

ZSH_HIGHLIGHT_STYLES[comment]='fg=#8C7376'

# autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#7a3e44'

plugins=(
    git
)

# Системные пакеты держат плагины вне дерева Oh My Zsh; если их нет,
# используем копии, идущие в комплекте с Oh My Zsh.
_zsh_autosuggestions=/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
_zsh_highlighting=/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -r "$_zsh_autosuggestions" ]] || plugins+=(zsh-autosuggestions)

# oh-my-via: красный username без @хоста (переопределяет дефолты темы)
typeset -g OHMYVIA_CONTEXT_HOSTNAME=empty
typeset -g OHMYVIA_CONTEXT_USER_COLOR='%B%F{#E63946}'
typeset -g OHMYVIA_CONTEXT_ROOT_COLOR='%B%F{#E63946}'
typeset -g OHMYVIA_STATUS_OK_COLOR='%F{#E63946}'

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
fi

[[ ! -r "$_zsh_autosuggestions" ]] || source "$_zsh_autosuggestions"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias ls='eza --icons'
alias ll='eza -lah --icons'
alias la='eza -a --icons'
alias l='eza -lah --icons'
alias lt='eza --tree --icons'
export EZA_COLORS='di=38;2;230;57;70:ln=38;2;255;138;144:ex=38;2;224;164;88:fi=38;2;234;220;222:pi=38;2;233;132;63:so=38;2;194;85;95:bd=38;2;233;132;63:cd=38;2;233;132;63:da=38;2;140;115;118:uu=38;2;234;220;222:gu=38;2;140;115;118:xx=38;2;194;85;95:*.mkv=38;2;233;132;63:*.mp4=38;2;233;132;63:*.mp4v=38;2;233;132;63:*.m4v=38;2;233;132;63:*.mov=38;2;233;132;63:*.qt=38;2;233;132;63:*.avi=38;2;233;132;63:*.webm=38;2;233;132;63:*.mpg=38;2;233;132;63:*.mpeg=38;2;233;132;63:*.m2v=38;2;233;132;63:*.m2ts=38;2;233;132;63:*.mts=38;2;233;132;63:*.vob=38;2;233;132;63:*.wmv=38;2;233;132;63:*.asf=38;2;233;132;63:*.rm=38;2;233;132;63:*.rmvb=38;2;233;132;63:*.flc=38;2;233;132;63:*.fli=38;2;233;132;63:*.flv=38;2;233;132;63:*.ogv=38;2;233;132;63:*.ogx=38;2;233;132;63:*.3gp=38;2;233;132;63:*.3g2=38;2;233;132;63:*.mxf=38;2;233;132;63'
export PATH="$HOME/.local/bin:$PATH"

# Cursor: blinking vertical bar
printf '\e[5 q'
export PATH="$PATH:$HOME/go/bin"

# Load syntax highlighting last so it can observe aliases and other commands.
if [[ -r "$_zsh_highlighting" ]]; then
    source "$_zsh_highlighting"
elif [[ -r "$ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ]]; then
    source "$ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
fi
