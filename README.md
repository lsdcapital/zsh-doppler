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
| `DOPPLER_PROMPT_COLOR` | `cyan` | Color name (fallback) |
| `DOPPLER_COLOR_DEV` | `green` | Color for dev environments |
| `DOPPLER_COLOR_STAGING` | `yellow` | Color for staging environments |
| `DOPPLER_COLOR_PROD` | `red` | Color for production environments |
| `DOPPLER_COLOR_DEFAULT` | `cyan` | Color for unknown environments |
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

# Custom environment colors
export DOPPLER_COLOR_DEV="blue"       # Custom dev color
export DOPPLER_COLOR_PROD="magenta"   # Custom prod color

```

### Format Template

The `DOPPLER_PROMPT_FORMAT` variable supports these placeholders:

- `%project` - Doppler project name
- `%config` - Doppler config name
- `%separator` - The separator character/string

## Performance

The plugin is optimized for speed:

### Environment Variables (Fastest)
When using `doppler run`, environment variables are read directly (~13ms).

### YAML File Reading (Fast)
When not using `doppler run`, the plugin reads from `~/.doppler/.doppler.yaml` (~8ms average).

### Performance Characteristics
- **Environment variables**: ~13ms (during `doppler run` sessions)
- **YAML file reading**: ~8ms (normal shell usage)

The plugin uses fast awk-based YAML parsing instead of CLI calls for optimal performance. No caching is needed since the YAML approach is already faster than any cache solution.

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

### Clear Cache
```bash
_doppler_cache_clear
```
Manually clears the cache. Useful for troubleshooting or when you want to force a fresh lookup.

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
- Check if Doppler CLI is responding slowly: `time doppler configure --json`
- Verify `~/.doppler/.doppler.yaml` file exists and is readable

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

## Testing

This plugin includes a comprehensive test suite using [Vitest](https://vitest.dev/). The tests verify color determination logic, prompt formatting, configuration handling, and Doppler integration.

### Prerequisites

- Node.js 18+
- pnpm
- Zsh (for integration tests)

### Running Tests

```bash
# Install dependencies
npm install

# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode (for development)
npx vitest

# Run performance tests only
npm run test:perf

# Check performance against baseline
npm run perf:check

# View current baseline
npm run perf:baseline
```

### Test Structure

- `tests/color-determination.test.js` - Tests environment-based color logic
- `tests/prompt-formatting.test.js` - Tests prompt formatting and display functions
- `tests/doppler-info.test.js` - Tests Doppler configuration parsing
- `tests/configuration.test.js` - Tests plugin configuration and helpers
- `tests/performance.test.js` - Basic performance tests with fixed thresholds
- `tests/performance-baseline.test.js` - **Regression detection** with baseline comparison
- `tests/yaml-approach.test.js` - YAML file reading functionality and performance validation

### Performance Regression Detection

The plugin includes a sophisticated baseline system to catch performance regressions:

- **Baseline tracking**: Stores expected performance metrics (p50, p95, p99)
- **Regression detection**: Fails tests if performance degrades >50%, warns at >20%
- **Improvement detection**: Celebrates when performance gets better 🚀
- **Statistical analysis**: Uses percentiles from multiple samples for accuracy

**Performance Status Indicators:**
- ✅ Performance within baseline tolerance
- ⚠️ Performance 20-50% slower than baseline (warning)
- ❌ Performance >50% slower than baseline (failure)
- 🚀 Performance better than baseline (improvement!)

The tests execute actual Zsh functions by sourcing the plugin file, ensuring real-world compatibility.

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Run the test suite: `npm test`
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