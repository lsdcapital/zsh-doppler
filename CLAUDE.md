# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Essential Commands

This project uses **pnpm** as the package manager (note: `pnpm-lock.yaml` is present):

```bash
# Run all tests
pnpm test

# Run tests with coverage
pnpm run test:coverage

# Run performance tests only
pnpm run test:perf

# View performance baseline summary
pnpm run perf:baseline

# Run specific test files
pnpm vitest tests/yaml-approach.test.js
```

## Architecture Overview

This is a Zsh plugin that displays Doppler (secrets management) project/config information in shell prompts. The core architecture consists of:

### Main Plugin File
- `zsh-doppler.plugin.zsh` - Single-file plugin with all functionality

### Key Functions and Data Flow

1. **`_doppler_get_info()`** - Core data retrieval function that checks in priority order:
   - Environment variables (`DOPPLER_PROJECT` + `DOPPLER_CONFIG`/`DOPPLER_ENVIRONMENT`)
   - `~/.doppler/.doppler.yaml` file parsing (current directory-based config)
   - Returns `project:config` format or failure

2. **`doppler_prompt_info()`** - Main prompt function that:
   - Calls `_doppler_get_info()`
   - Applies color logic via `_doppler_get_color()`
   - Formats output via `_doppler_format_prompt()`
   - Returns colored prompt string

3. **`prompt_doppler()`** - Powerlevel10k segment function using `p10k segment` API

### Color System
Environment-based color mapping:
- `dev*/development*/local*` → green
- `stag*/staging*/test*/uat*` → yellow
- `prod*/production*/live*` → red
- Everything else → cyan (default)

### Configuration Variables
Plugin uses environment variables with conditional defaults:
- `DOPPLER_PROMPT_ENABLED` (true)
- `DOPPLER_PROMPT_PREFIX` ([)
- `DOPPLER_PROMPT_SUFFIX` (])
- `DOPPLER_PROMPT_FORMAT` (%project%separator%config)

## Testing Architecture

### Test Structure
- **Vitest-based** with Node.js environment
- **Zsh integration tests** via `execZshCommand()` helper in `tests/helpers.js`
- **Performance baseline system** tracks regression with percentile metrics

### Key Test Files
- `yaml-approach.test.js` - Tests YAML file parsing and directory-based config
- `performance-baseline.test.js` - Regression detection with statistical baselines
- `color-determination.test.js` - Environment-based color logic
- `prompt-formatting.test.js` - Output formatting and display

### Performance Testing
- Uses `tests/baseline-manager.js` for performance regression detection
- Tracks p50/p95/p99 percentiles from multiple samples
- Fails tests if performance degrades >50%, warns at >20%

### Test Dependencies
Tests are self-contained and do not require any external configuration:
- Test directories are created dynamically in `tests/test-dirs/`
- A test YAML file is generated from `tests/fixtures/test-doppler.yaml`
- Tests use `DOPPLER_YAML_PATH` environment variable to point to the test YAML

## Key Implementation Details

### YAML Parsing Approach
Uses `awk` for fast YAML parsing instead of CLI calls:
```bash
awk -v dir="$current_dir" '
  $0 ~ "^[[:space:]]*" dir ":" {found=1}
  found && /enclave.project:/ {project=$2}
  found && /enclave.config:/ {config=$2; print project ":" config; exit}
' "$doppler_yaml"
```

### Powerlevel10k Integration
- Provides custom segment via `prompt_doppler()` function
- Supports instant prompt via `instant_prompt_doppler()` (env vars only)
- Uses `p10k segment` API with dynamic foreground colors

### Performance Characteristics
- Environment variables: ~13ms (fastest)
- YAML file reading: ~8ms (normal usage)
- **No CLI fallback** (removed for performance - only env vars and YAML)

## Recent Changes

### Performance Optimization (Critical)
**Problem**: Using `$(doppler_prompt_info)` in prompts causes the function to execute on EVERY prompt redraw, including every keystroke, backspace, and cursor movement.

**Solution**: Implemented caching via precmd hook:
- `_doppler_precmd()` runs once per command and populates `$DOPPLER_PROMPT_INFO`
- Use `${DOPPLER_PROMPT_INFO}` instead of `$(doppler_prompt_info)` in prompts
- Eliminates file I/O on keystrokes, dramatically improving typing responsiveness

### CLI Fallback Removal
The CLI fallback (`doppler configure --json`) was removed from `_doppler_get_info()` for performance reasons. The plugin now only uses:
1. Environment variables (doppler run sessions)
2. YAML file parsing (directory-based configuration)

This means the plugin will only show information when explicitly configured via `doppler setup` or when running under `doppler run`.