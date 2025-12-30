# Zsh Doppler Plugin

[![Tests](https://github.com/lsdcapital/zsh-doppler/actions/workflows/test.yml/badge.svg)](https://github.com/lsdcapital/zsh-doppler/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/lsdcapital/zsh-doppler)](https://github.com/lsdcapital/zsh-doppler/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/lsdcapital/zsh-doppler)](https://github.com/lsdcapital/zsh-doppler/issues)

A lightweight Zsh plugin that displays your current [Doppler](https://doppler.com) project and configuration in your shell prompt from environment variables. Perfect for developers working with multiple Doppler environments who want to keep track of their current context.

![Demo](https://img.shields.io/badge/demo-%5Bmyproject%2Fdev%5D-cyan)

## Features

- ⚡ **Lightning Fast** - Reads from Doppler CLI configuration and environment variables
- 🚀 **CI/CD Perfect** - Works seamlessly in Docker, CI/CD, and production environments
- 🎯 **Auto-detection** - Shows when `DOPPLER_PROJECT` and `DOPPLER_CONFIG` are set or configured
- 🎨 **Smart Colors** - Environment-based colors (green for dev, yellow for staging, red for prod)
- 🔧 **Highly Customizable** - Configure colors, format, prefix/suffix, and more
- 🔌 **Compatible** - Works with Oh My Zsh, Prezto, or standalone Zsh
- 💎 **Powerlevel10k** - Full custom segment support with instant prompt compatibility
- 🛡️ **Reliable** - Graceful fallbacks and error handling
- ✅ **Well Tested** - Comprehensive test suite with 30+ tests

## Quick Start

Get up and running in under 2 minutes:

1. **Install** (Oh My Zsh):
   ```bash
   git clone https://github.com/lsdcapital/zsh-doppler.git ~/.oh-my-zsh/custom/plugins/zsh-doppler
   ```

2. **Enable** by adding `zsh-doppler` to your plugins in `~/.zshrc`:
   ```bash
   plugins=(git zsh-doppler)
   ```

3. **Add to your prompt**:
   ```bash
   PROMPT='${DOPPLER_PROMPT_INFO} %~ $ '   # Left side
   # or
   RPROMPT='${DOPPLER_PROMPT_INFO}'        # Right side
   ```

4. **Reload** your shell:
   ```bash
   source ~/.zshrc
   ```

5. **Configure Doppler** in your project directory:
   ```bash
   doppler setup
   ```

Now your prompt shows `[project/config]` with environment-aware colors! 🎉

**Powerlevel10k users**: Run `doppler_p10k_setup` after installation for p10k-specific instructions.

## Requirements

- Zsh
- [Doppler CLI](https://docs.doppler.com/docs/install-cli) (optional, for directory-based configuration)
- Environment variables `DOPPLER_PROJECT` and `DOPPLER_CONFIG` (automatically set by `doppler run`) or directory-based Doppler configuration

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

### npm

```bash
npm install -g @lsdcapital/zsh-doppler
```

Then add to your `~/.zshrc`:
```bash
source "$(npm root -g)/@lsdcapital/zsh-doppler/zsh-doppler.plugin.zsh"
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

### Standard Zsh Prompts

Add `${DOPPLER_PROMPT_INFO}` to your `PROMPT` or `RPROMPT`:

```bash
# Left prompt
PROMPT='${DOPPLER_PROMPT_INFO} %~ $ '

# Right prompt
RPROMPT='${DOPPLER_PROMPT_INFO}'

# With existing elements
PROMPT='%F{green}%n@%m%f ${DOPPLER_PROMPT_INFO}%F{blue}%~%f $ '
```

### Powerlevel10k

Run the setup helper to add the `doppler` segment:
```bash
doppler_p10k_setup
```

Then add `doppler` to your prompt elements in `~/.p10k.zsh`:
```bash
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  doppler  # Add here
  status
  # ... other elements
)
```

### Example Output

```
[myproject/dev] ~/code/myapp $
```

Colors change automatically based on environment: dev (green), staging (yellow), prod (red).

## Configuration

Customize the plugin behavior with these environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `DOPPLER_PROMPT_ENABLED` | `true` | Enable/disable the plugin |
| `DOPPLER_PROMPT_PREFIX` | `[` | Text before Doppler info |
| `DOPPLER_PROMPT_SUFFIX` | `]` | Text after Doppler info |
| `DOPPLER_PROMPT_SEPARATOR` | `/` | Separator between project and config |
| `DOPPLER_PROMPT_FORMAT` | `%project%separator%config` | Format template |
| `DOPPLER_PROMPT_COLOR` | `cyan` | Color name (fallback) |
| `DOPPLER_COLOR_DEV` | `green` | Color for dev environments |
| `DOPPLER_COLOR_STAGING` | `yellow` | Color for staging environments |
| `DOPPLER_COLOR_PROD` | `red` | Color for production environments |
| `DOPPLER_COLOR_DEFAULT` | `cyan` | Color for unknown environments |
| `DOPPLER_P10K_AUTO_ADD` | `false` | Auto-add to p10k right prompt |

### Environment Pattern Matching

Colors are automatically assigned based on config name patterns (case-insensitive):

| Color | Patterns | Examples |
|-------|----------|----------|
| Green (dev) | `dev*`, `development*`, `local*` | `dev`, `dev-us`, `development`, `local` |
| Yellow (staging) | `stag*`, `staging*`, `test*`, `uat*`, `qa*` | `staging`, `stg`, `test`, `uat`, `qa` |
| Red (prod) | `prod*`, `production*`, `live*`, `prd*` | `prod`, `production`, `prd`, `live` |
| Cyan (default) | `ci*`, `sandbox*`, and everything else | `ci`, `sandbox`, `demo`, `preview` |

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

### Examples

```bash
# Minimal config-only display
export DOPPLER_PROMPT_FORMAT="%config"
export DOPPLER_PROMPT_PREFIX="env:"
export DOPPLER_PROMPT_SUFFIX=" "
# Output: env:dev

# Custom separators
export DOPPLER_PROMPT_PREFIX="("
export DOPPLER_PROMPT_SUFFIX=")"
export DOPPLER_PROMPT_SEPARATOR=" → "
# Output: (myproject → dev)

# Custom environment colors
export DOPPLER_COLOR_DEV="blue"
export DOPPLER_COLOR_PROD="magenta"
```

### Format Template

The `DOPPLER_PROMPT_FORMAT` variable supports these placeholders:

- `%project` - Doppler project name
- `%config` - Doppler config name
- `%separator` - The separator character/string

## Performance

The plugin is designed for minimal prompt latency:

### Caching Architecture
The plugin uses a `precmd` hook to populate `$DOPPLER_PROMPT_INFO` once per command, avoiding file I/O on every keystroke. This means:
- Use `${DOPPLER_PROMPT_INFO}` in prompts (cached, instant)
- Avoid `$(doppler_prompt_info)` (executes on every redraw)

### Data Sources
1. **Environment variables** (fastest): When using `doppler run`, reads `$DOPPLER_PROJECT` and `$DOPPLER_CONFIG` directly
2. **YAML file**: When configured via `doppler setup`, reads `~/.doppler/.doppler.yaml` using fast awk-based parsing

The plugin never calls the Doppler CLI during prompt rendering, ensuring consistent performance regardless of network or API conditions.

## Troubleshooting

### Plugin Not Showing

1. **Test the plugin**:
   ```bash
   doppler_prompt_test    # Check Doppler CLI and configuration
   doppler_prompt_config  # View current plugin settings
   ```

2. **Verify Doppler setup**:
   ```bash
   doppler configure      # Check directory configuration
   doppler --version      # Ensure CLI is installed
   ```

3. **Check prompt substitution** is enabled:
   ```bash
   setopt prompt_subst
   ```

### Performance Issues

- Ensure you're using `${DOPPLER_PROMPT_INFO}` (cached) not `$(doppler_prompt_info)` (executes every keystroke)
- Verify `~/.doppler/.doppler.yaml` file exists and is readable (created by `doppler setup`)
- Check YAML parsing: `cat ~/.doppler/.doppler.yaml | grep $(pwd)` to verify directory config exists

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
- Linux (Zsh 5.1+)
- Doppler CLI 3.0+

**Note**: Requires Zsh 5.1+ due to use of `${var:l}` lowercase parameter expansion.

## Testing

The plugin includes a comprehensive test suite with color logic, prompt formatting, configuration, and performance regression detection.

### Running Tests

```bash
pnpm install  # Install dependencies
pnpm test     # Run all tests
pnpm run test:coverage  # With coverage report
```

Tests execute actual Zsh functions to ensure real-world compatibility. See test files in `tests/` for implementation details.

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Run the test suite: `pnpm test`
5. Test with different Zsh configurations
6. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Related Projects

- [Doppler CLI](https://github.com/DopplerHQ/cli) - Official Doppler command-line tool
- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) - Framework for managing Zsh configuration

## Support

- 🐛 [Report issues](https://github.com/lsdcapital/zsh-doppler/issues)
- 📖 [Doppler Documentation](https://docs.doppler.com)
- 💬 [Doppler Community](https://doppler.com/community)