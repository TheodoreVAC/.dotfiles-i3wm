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
ZSH_THEME="oh-my-via/via"

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
# zsh-syntax-highlighting — blue theme
# zsh-syntax-highlighting
typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[command]='fg=#60a5fa'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#60a5fa'
ZSH_HIGHLIGHT_STYLES[function]='fg=#93c5fd'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#93c5fd'

ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f87171'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#60a5fa'

ZSH_HIGHLIGHT_STYLES[path]='fg=#bfdbfe'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#93c5fd'

ZSH_HIGHLIGHT_STYLES[single-quoted]='fg=#93c5fd'
ZSH_HIGHLIGHT_STYLES[double-quoted]='fg=#93c5fd'

ZSH_HIGHLIGHT_STYLES[comment]='fg=#64748b'

# autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#3b5f8a'

plugins=(
    git
)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
fi

# Arch packages install these plugins outside Oh My Zsh's bundled plugin tree.
[[ ! -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] || \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

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
export EZA_COLORS='di=38;2;137;180;250:ln=38;2;111;119;133:ex=38;2;166;227;161:fi=38;2;216;222;233:pi=38;2;250;179;135:so=38;2;203;166;247:bd=38;2;250;179;135:cd=38;2;250;179;135:da=38;2;111;119;133:uu=38;2;216;222;233:gu=38;2;111;119;133:xx=38;2;111;119;133:*.mkv=38;2;250;179;135:*.mp4=38;2;250;179;135:*.mp4v=38;2;250;179;135:*.m4v=38;2;250;179;135:*.mov=38;2;250;179;135:*.qt=38;2;250;179;135:*.avi=38;2;250;179;135:*.webm=38;2;250;179;135:*.mpg=38;2;250;179;135:*.mpeg=38;2;250;179;135:*.m2v=38;2;250;179;135:*.m2ts=38;2;250;179;135:*.mts=38;2;250;179;135:*.vob=38;2;250;179;135:*.wmv=38;2;250;179;135:*.asf=38;2;250;179;135:*.rm=38;2;250;179;135:*.rmvb=38;2;250;179;135:*.flc=38;2;250;179;135:*.fli=38;2;250;179;135:*.flv=38;2;250;179;135:*.ogv=38;2;250;179;135:*.ogx=38;2;250;179;135:*.3gp=38;2;250;179;135:*.3g2=38;2;250;179;135:*.mxf=38;2;250;179;135'
export PATH="$HOME/.local/bin:$PATH"

# Cursor: blinking vertical bar
printf '\e[5 q'
export PATH="$PATH:$HOME/go/bin"

# Load syntax highlighting last so it can observe aliases and other commands.
[[ ! -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] || \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
