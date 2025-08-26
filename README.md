# Zsh Doppler Plugin

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/lsdcapital/zsh-doppler)](https://github.com/lsdcapital/zsh-doppler/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/lsdcapital/zsh-doppler)](https://github.com/lsdcapital/zsh-doppler/issues)

A lightweight Zsh plugin that displays your current [Doppler](https://doppler.com) project and configuration in your shell prompt from environment variables. Perfect for developers working with multiple Doppler environments who want to keep track of their current context.

![Demo](https://img.shields.io/badge/demo-%5Bmyproject%2Fdev%5D-cyan)

## Features

- ⚡ **Lightning Fast** - Zero CLI overhead, reads only environment variables
- 🚀 **CI/CD Perfect** - Works seamlessly in Docker, CI/CD, and production environments
- 🎯 **Auto-detection** - Shows when `DOPPLER_PROJECT` and `DOPPLER_CONFIG` are set
- 🎨 **Customizable** - Configure colors, format, prefix/suffix, and more
- 🔌 **Compatible** - Works with Oh My Zsh, Prezto, or standalone Zsh
- 💎 **Powerlevel10k** - Full custom segment support with instant prompt compatibility
- 🛡️ **Reliable** - No external commands that could hang or fail

## Requirements

- Zsh
- Environment variables `DOPPLER_PROJECT` and `DOPPLER_CONFIG` (automatically set by `doppler run`)

## Installation

### Oh My Zsh

1. Clone this repository to your Oh My Zsh custom plugins directory:
```bash
git clone https://github.com/lsdcapital/zsh-doppler.git ~/.oh-my-zsh/custom/plugins/zsh-doppler
```

2. Add `zsh-doppler` to your plugins list in `~/.zshrc`:
```bash
plugins=(git zsh-doppler)
```

3. Restart your terminal or run:
```bash
source ~/.zshrc
```

### Standalone Installation

1. Clone the repository:
```bash
git clone https://github.com/lsdcapital/zsh-doppler.git ~/.zsh-doppler
```

2. Add this line to your `~/.zshrc`:
```bash
source ~/.zsh-doppler/zsh-doppler.plugin.zsh
```

3. Restart your terminal or run:
```bash
source ~/.zshrc
```

### Zinit

```bash
zinit light lsdcapital/zsh-doppler
```

### Zplug

```bash
zplug "lsdcapital/zsh-doppler"
```

### Antigen

```bash
antigen bundle lsdcapital/zsh-doppler
```

### Manual Installation

Simply download `zsh-doppler.plugin.zsh` and source it in your `~/.zshrc`:
```bash
source /path/to/zsh-doppler.plugin.zsh
```

### Powerlevel10k Installation

If you're using Powerlevel10k (which overrides standard prompts), follow these steps:

1. Install the plugin using any method above
2. Run the p10k setup helper:
```bash
doppler_p10k_setup
```
3. Add `doppler` to your prompt elements in `~/.p10k.zsh`:
```bash
# Add to right side prompt
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  doppler  # Add this line
  status
  command_execution_time
  # ... your existing elements ...
)
```
4. Restart your terminal or run: `p10k reload`

## Usage

The plugin automatically detects Doppler project and configuration from environment variables. To use the plugin, you need to set these environment variables, which happens automatically when you use `doppler run`.

### Environment Variables

The plugin reads these environment variables:
- `DOPPLER_PROJECT` - Your Doppler project name
- `DOPPLER_CONFIG` - Your Doppler configuration/environment name  
- `DOPPLER_ENVIRONMENT` - Alternative to `DOPPLER_CONFIG`

These are automatically set when you use:
```bash
doppler run -- your-command
```

Or you can set them manually:
```bash
export DOPPLER_PROJECT=myapp
export DOPPLER_CONFIG=dev
```

### Basic Setup (Standard Zsh)

For standard Zsh (non-Powerlevel10k), add the Doppler info to your prompt by including `$(doppler_prompt_info)` in your `PROMPT` or `RPROMPT`:

```bash
# Left side of prompt
PROMPT='$(doppler_prompt_info) %~ $ '

# Right side of prompt  
RPROMPT='$(doppler_prompt_info)'

# Integration with existing prompt
PROMPT='%F{green}%n@%m%f $(doppler_prompt_info)%F{blue}%~%f $ '
```

### Powerlevel10k Setup

If you're using Powerlevel10k, the plugin automatically provides a custom segment. Use the helper function:

```bash
doppler_p10k_setup
```

This will show you how to add the `doppler` segment to your p10k configuration.

### Quick Setup Helper

Run the setup helper to see configuration examples:
```bash
doppler_prompt_setup
```

### Example Output

When you're in a directory configured with Doppler:
```
[myproject/dev] ~/code/myapp $
```

## Configuration

Customize the plugin behavior with these environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `DOPPLER_PROMPT_ENABLED` | `true` | Enable/disable the plugin |
| `DOPPLER_PROMPT_PREFIX` | `[` | Text before Doppler info |
| `DOPPLER_PROMPT_SUFFIX` | `]` | Text after Doppler info |
| `DOPPLER_PROMPT_SEPARATOR` | `/` | Separator between project and config |
| `DOPPLER_PROMPT_FORMAT` | `%project%separator%config` | Format template |
| `DOPPLER_PROMPT_COLOR` | `cyan` | Color name |
| `DOPPLER_P10K_AUTO_ADD` | `false` | Auto-add to p10k right prompt |

### Powerlevel10k Configuration

Additional variables for Powerlevel10k users:

| Variable | Default | Description |
|----------|---------|-------------|
| `POWERLEVEL9K_DOPPLER_FOREGROUND` | `cyan` | Text color |
| `POWERLEVEL9K_DOPPLER_BACKGROUND` | `none` | Background color |
| `POWERLEVEL9K_DOPPLER_VISUAL_IDENTIFIER_EXPANSION` | `🔐` | Icon |
| `POWERLEVEL9K_DOPPLER_PREFIX` | `[` | Text before (p10k) |
| `POWERLEVEL9K_DOPPLER_SUFFIX` | `]` | Text after (p10k) |
| `POWERLEVEL9K_DOPPLER_FORMAT` | Uses `DOPPLER_PROMPT_FORMAT` | P10k format template |

### Configuration Examples

```bash
# Disable the prompt
export DOPPLER_PROMPT_ENABLED=false

# Custom format with different separators
export DOPPLER_PROMPT_PREFIX="("
export DOPPLER_PROMPT_SUFFIX=")"
export DOPPLER_PROMPT_SEPARATOR=" → "
# Output: (myproject → dev)

# Show only the config name
export DOPPLER_PROMPT_FORMAT="%config"
export DOPPLER_PROMPT_PREFIX="env:"
export DOPPLER_PROMPT_SUFFIX=""
# Output: env:dev

# Different colors
export DOPPLER_PROMPT_COLOR="yellow"   # Available: red, green, blue, yellow, magenta, cyan, white
```

### Format Template

The `DOPPLER_PROMPT_FORMAT` variable supports these placeholders:

- `%project` - Doppler project name
- `%config` - Doppler config name  
- `%separator` - The separator character/string

## Utility Functions

### Test Connection
```bash
doppler_prompt_test
```
Checks if Doppler CLI is available and shows current configuration.

### Show Current Configuration
```bash
doppler_prompt_config
```
Displays all current plugin settings and output.

### Powerlevel10k Setup Helper
```bash
doppler_p10k_setup
```
Shows p10k-specific configuration instructions (only works with p10k).

### Manual Prompt Update
```bash
doppler_prompt_info
```
Returns the formatted Doppler info string (also available as `doppler_prompt`).

## Examples

### Minimalist
```bash
export DOPPLER_PROMPT_PREFIX=""
export DOPPLER_PROMPT_SUFFIX=" "
export DOPPLER_PROMPT_FORMAT="%config"
PROMPT='$(doppler_prompt_info)%~ $ '
# Output: dev ~/myapp $
```

### Detailed
```bash
export DOPPLER_PROMPT_PREFIX="doppler:["
export DOPPLER_PROMPT_SUFFIX="] "
export DOPPLER_PROMPT_COLOR="magenta"
PROMPT='$(doppler_prompt_info)%~ $ '
# Output: doppler:[myproject/dev] ~/myapp $
```

### Right-side Prompt
```bash
RPROMPT='$(doppler_prompt_info) %T'
# Shows Doppler info and time on the right side
```

## Troubleshooting

### Plugin Not Showing
1. Check if you're in a directory with Doppler configuration:
   ```bash
   doppler configure
   ```

2. Test the plugin:
   ```bash
   doppler_prompt_test
   ```

3. Verify Doppler CLI is installed:
   ```bash
   doppler --version
   ```

### Performance Issues
- Increase cache TTL: `export DOPPLER_PROMPT_CACHE_TTL=30`
- Check if Doppler CLI is responding slowly: `time doppler configure get project`

### Prompt Not Updating
Make sure you have prompt substitution enabled:
```bash
setopt prompt_subst
```

## Compatibility

This plugin works with:
- ✅ Oh My Zsh
- ✅ Prezto
- ✅ Standalone Zsh
- ✅ **Powerlevel10k** - Full custom segment support
- ✅ Powerlevel9k - Compatible with p10k segment API
- ✅ Any Zsh framework that supports plugins

Tested with:
- macOS (Zsh 5.8+)
- Linux (Zsh 5.0+)
- Doppler CLI 3.0+

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test with different Zsh configurations
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Related Projects

- [Doppler CLI](https://github.com/DopplerHQ/cli) - Official Doppler command-line tool
- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) - Framework for managing Zsh configuration

## Support

- 🐛 [Report issues](https://github.com/your-username/zsh-doppler/issues)
- 📖 [Doppler Documentation](https://docs.doppler.com)
- 💬 [Doppler Community](https://doppler.com/community)