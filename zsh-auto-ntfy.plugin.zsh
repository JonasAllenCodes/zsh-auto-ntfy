# zsh-auto-ntfy.plugin.zsh
# Automatic ntfy notifications for long-running Zsh commands
# Author: JonasAllenCodes
# Version: 1.0.0
# https://github.com/JonasAllenCodes/zsh-auto-ntfy  # Update to your repo
# Requires: ntfy CLI and bc (for duration calc)

# Default config (override via env vars in ~/.zshrc)
: ${NTFY_THRESHOLD:=30}
: ${NTFY_TOPIC:="mytopic"}
: ${NTFY_TITLE:="Terminal"}
: ${NTFY_IGNORED_COMMANDS:=("nvim" "vim" "lazydocker" "lazyvim")}

# Debug mode (set export NTFY_DEBUG=1 in ~/.zshrc to enable echoes)
: ${NTFY_DEBUG:=0}

# Check for dependencies (warn if missing)
if ! command -v ntfy >/dev/null 2>&1; then
    echo "Warning: ntfy CLI not found. Install it for notifications to work."
fi
if ! command -v bc >/dev/null 2>&1; then
    echo "Warning: bc not found. Install bc for accurate durations."
fi

# Function to send ntfy notification
_ntfy_notify() {
    local exit_status=$?
    local status_icon="$([ $exit_status -eq 0 ] && echo "✅" || echo "⚠️")"
    local last_command=$(fc -ln -1)  # Clean last command line
    last_command="${last_command:0:80}..."  # Truncate to 80 chars + ellipsis if longer
    [[ $NTFY_DEBUG == 1 ]] && echo "DEBUG: Sending ntfy: $status_icon $last_command took ${ZSH_LAST_DURATION}s"
    ntfy publish -t "${NTFY_TITLE}" "${NTFY_TOPIC}" "$status_icon $last_command took ${ZSH_LAST_DURATION}s (Exit: $exit_status)"
    local ntfy_status=$?
    [[ $NTFY_DEBUG == 1 ]] && echo "DEBUG: ntfy exited with status $ntfy_status"
}

# Pre-command hook: Record start time
_ntfy_preexec() {
    ZSH_START_TIME=$(date +%s.%N)
    [[ $NTFY_DEBUG == 1 ]] && echo "DEBUG: Preexec - Start time: $ZSH_START_TIME"
}

# Post-command hook: Calculate duration and notify if over threshold
_ntfy_precmd() {
    if [[ -n $ZSH_START_TIME ]]; then
        local now=$(date +%s.%N)
        ZSH_LAST_DURATION=$(echo "$now - $ZSH_START_TIME" | bc -l | cut -d. -f1)
        [[ $NTFY_DEBUG == 1 ]] && echo "DEBUG: Prec cmd - Duration: $ZSH_LAST_DURATION s"
        if (( ZSH_LAST_DURATION > NTFY_THRESHOLD )); then
            [[ $NTFY_DEBUG == 1 ]] && echo "DEBUG: Threshold met ($ZSH_LAST_DURATION > $NTFY_THRESHOLD)"
            local last_command=$(fc -ln -1)
            # Skip if it matches any ignored
            local ignored=false
            for ignore in "${NTFY_IGNORED_COMMANDS[@]}"; do
                if [[ "$last_command" == "$ignore "* ]] || [[ "$last_command" == "$ignore" ]]; then
                    ignored=true
                    break
                fi
            done
            if [[ $ignored == true ]]; then
                [[ $NTFY_DEBUG == 1 ]] && echo "DEBUG: Ignored command: $last_command"
            else
                [[ $NTFY_DEBUG == 1 ]] && echo "DEBUG: Not ignored - notifying"
                _ntfy_notify
            fi
        fi
        unset ZSH_START_TIME
    fi
}

# Always hook into Zsh (idempotent on single source; Zinit handles multiples)
autoload -Uz add-zsh-hook
add-zsh-hook preexec _ntfy_preexec
add-zsh-hook precmd _ntfy_precmd
[[ $NTFY_DEBUG == 1 ]] && echo "ntfy-notify: Loaded (threshold: $NTFY_THRESHOLD s, topic: $NTFY_TOPIC)"

# Public function to toggle plugin (e.g., for temporary disable)
ntfy-notify-toggle() {
    if add-zsh-hook -L precmd 2>/dev/null | grep -q _ntfy_precmd; then
        add-zsh-hook -D precmd _ntfy_precmd
        add-zsh-hook -D preexec _ntfy_preexec
        echo "ntfy-notify: Disabled"
    else
        autoload -Uz add-zsh-hook
        add-zsh-hook preexec _ntfy_preexec
        add-zsh-hook precmd _ntfy_precmd
        echo "ntfy-notify: Enabled"
    fi
}
