# dotnet
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# rust
. "$HOME/.cargo/env"

# fnm
FNM_PATH="/home/dpper/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/home/dpper/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi
