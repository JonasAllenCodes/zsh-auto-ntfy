# zsh-auto-ntfy

Tired of staring at your terminal, wondering if that build, script, or compilation is ever going to finish? zsh-auto-ntfy is your Zsh sidekick: it automatically detects long-running commands (tunable to any duration you want) and pings your phone with a sleek ntfy.sh push notification the instant they're done. Grab a coffee, tackle that quick errand, or just stretch your legs—come back refreshed, knowing exactly when to dive back in, without the constant "is it ready yet?" checks.

## Requirements

*   [ntfy](https://ntfy.sh/docs/cli/): The ntfy command-line interface.
*   `bc`: For timing calculations. It can be installed on Debian/Ubuntu with `sudo apt install bc`, on RHEL/CentOS with `sudo yum install bc`, or on macOS with `brew install bc`.

## Installation

### [zinit](https://github.com/zdharma-continuum/zinit)

```zsh
zinit light JonasAllenCodes/zsh-auto-ntfy
```

### Zplug

```zsh
zplug "JonasAllenCodes/zsh-auto-ntfy"
```

### Antigen

```zsh
antigen bundle "JonasAllenCodes/zsh-auto-ntfy"
```

### Oh My Zsh

1.  Clone the repository into your Oh My Zsh custom plugins directory:

    ```zsh
    git clone https://github.com/JonasAllenCodes/zsh-auto-ntfy.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-auto-ntfy
    ```

2.  Add the plugin to the `plugins` array in your `.zshrc` file:

    ```zsh
    plugins=(... zsh-auto-ntfy)
    ```

## Configuration

You can override the default configuration by setting the following environment variables in your `.zshrc` file before the plugin is loaded.

*   `NTFY_THRESHOLD`: The minimum duration (in seconds) a command must run to trigger a notification. (Default: `30`)
*   `NTFY_TOPIC`: The ntfy topic to publish notifications to. (Default: `"mytopic"`)
*   `NTFY_TITLE`: The title of the ntfy notification. (Default: `"Terminal"`)
*   `NTFY_IGNORED_COMMANDS`: An array of commands to ignore. Notifications will not be sent for these commands. (Default: `("nvim" "vim" "lazydocker" "lazyvim")`)
*   `NTFY_DEBUG`: Set to `1` to enable debug logging. (Default: `0`)

Example configuration:

```zsh
# .zshrc

# zsh-auto-ntfy configuration
export NTFY_THRESHOLD="15"
export NTFY_TOPIC="my-workstation"
export NTFY_TITLE="Zsh on $(hostname)"
export NTFY_IGNORED_COMMANDS=("nvim" "vim" "emacs" "lazygit")

# Initialize your plugin manager (e.g., zinit)
# zinit light JonasAllenCodes/zsh-auto-ntfy
```

## Usage

The plugin works automatically. To temporarily disable or re-enable notifications, you can use the provided command.

### Toggling Notifications

*   `ntfy-notify-toggle`: Toggles notifications on and off. The command will print whether notifications are now `Enabled` or `Disabled`.

## License

[MIT](./LICENSE)
