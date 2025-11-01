# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-05

### Added

#### Core Functionality
- Display Doppler project and configuration in Zsh prompts
- Support for environment variables (`DOPPLER_PROJECT`, `DOPPLER_CONFIG`, `DOPPLER_ENVIRONMENT`)
- Fast YAML file parsing from `~/.doppler/.doppler.yaml` using awk (~8ms)
- Automatic environment-based color coding:
  - Green for development environments
  - Yellow for staging/test/UAT
  - Red for production
  - Cyan for other environments
- Customizable prompt format with prefix, suffix, and separator options
- Nine configuration environment variables for full customization

#### Powerlevel10k Integration
- Custom segment function `prompt_doppler()` using p10k segment API
- Instant prompt support via `instant_prompt_doppler()`
- Dynamic foreground colors based on environment
- Auto-configuration helper `doppler_p10k_setup()` for easy setup
- Full theming support with Powerlevel10k-specific variables

#### Performance Optimizations
- Precmd hook caching system to prevent file I/O on every keystroke
- Stores prompt info in `$DOPPLER_PROMPT_INFO` variable
- Environment variable reading: ~13ms
- YAML file reading: ~8ms average
- No CLI calls in normal operation for optimal performance

#### Developer Experience
- Helper functions for testing and debugging:
  - `doppler_prompt_test` - Test Doppler connectivity
  - `doppler_prompt_config` - View current configuration
  - `doppler_p10k_check` - Check Powerlevel10k setup status
  - `_doppler_cache_clear` - Clear prompt cache
- Graceful error handling and fallbacks
- Clear status messages and troubleshooting support

#### Installation & Compatibility
- Support for multiple plugin managers:
  - Oh My Zsh
  - Zinit
  - Zplug
  - Antigen
  - Prezto
  - Standalone installation
- Works with or without Oh My Zsh
- Compatible with standard Zsh and Powerlevel10k prompts

#### Testing & Quality
- Comprehensive test suite with 30+ tests using Vitest
- 11 test files covering all functionality:
  - Color determination logic
  - Prompt formatting
  - YAML file parsing
  - Configuration handling
  - Performance testing
- Performance regression detection with baseline system:
  - Tracks p50, p95, p99 percentiles
  - Fails on >50% degradation
  - Warns on >20% degradation
  - Detects performance improvements
- GitHub Actions CI/CD pipeline testing on Node.js 18, 20, and 22
- Coverage reporting

#### Documentation
- Comprehensive README with:
  - Installation instructions for all major plugin managers
  - Detailed Powerlevel10k setup guide
  - Configuration reference table
  - Usage examples (minimalist, detailed, right-side prompt)
  - Troubleshooting section
  - Performance characteristics
  - Testing instructions
- MIT License
- Developer documentation in CLAUDE.md

### Technical Details
- Written in pure Zsh with minimal dependencies
- Uses awk for fast YAML parsing (no external parsers needed)
- Proper function namespacing with `_doppler_` prefix
- Environment variable-based configuration (no config files required)
- Precmd hook for efficient caching

### Project Infrastructure
- Package metadata in package.json
- pnpm workspace configuration
- Vitest test framework configuration
- Git repository with .gitignore
- CI/CD with GitHub Actions
- Performance baseline tracking system

[1.0.0]: https://github.com/lsdcapital/zsh-doppler/releases/tag/v1.0.0
