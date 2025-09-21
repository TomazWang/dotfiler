# This file is for exporting environment variables and modifying the PATH.

export ANDROID_SDK="$HOME/Library/Android/sdk"
export ANDROID_HOME="$ANDROID_SDK"
latest_build_tools_ver=$(ls $HOME/Library/Android/sdk/build-tools/ | sort -n -r | head -1)

export SPACESHIP_ROOT="${ZSH_CUSTOM}/themes/spaceship-prompt"

declare -a dirs_to_prepend
dirs_to_prepend=(
    "$ANDROID_HOME/platform-tools"
    "$ANDROID_HOME/emulator"
    "$ANDROID_HOME/tools/bin"
    "$ANDROID_HOME/tools"
    "$ANDROID_HOME/build-tools/${latest_build_tools_ver}"
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    "/Users/tomazwang/dev/gradle-profiler/buishellld/install/gradle-profiler/bin"
    "$SPACESHIP_ROOT"
)

for dir in ${(k)dirs_to_prepend[@]}
do
    if [ -d ${dir} ]; then
        # If direrctory exits, then prepend it to existing PATH
        PATH="${dir}:$PATH"
    fi
done
unset dirs_to_prepend
unset latest_build_tools_ver

# tmux color
export TERM=screen-256color

# Set EDITOR
export EDITOR=$(which vim)

# For SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"

# Add the bin directory to the PATH
# Get the dotfiler root directory (relative to this script's location)
DOTFILER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export PATH="$DOTFILER_ROOT/bin:$PATH"
