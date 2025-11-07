export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
git
podman
dotnet
dnf
gh
zsh-autosuggestions
rust
zsh-syntax-highlighting
)

#fix to remove zcoredump from $HOME direcrory
ZSH_CACHE="$HOME/.cache/zsh"
if [[ ! -d $ZSH_CACHE ]]; then
  mkdir -p $ZSH_CACHE
fi
ZSH_COMPDUMP="$ZSH_CACHE/.zcompdump-${HOST}-${ZSH_VERSION}"
HISTFILE="$ZSH_CACHE/zsh_history"

source $ZSH/oh-my-zsh.sh

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c6c6c"
