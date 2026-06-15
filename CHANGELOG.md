# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Replaced the zsh-only `<->` glob in `_doppler_color_to_ansi` with a
  shellcheck-parseable pattern (behavior unchanged), restoring the CI lint job.

### Changed

- Bumped GitHub Actions to v6 (Node 24 runtime) and made the pinned `packageManager`
  field the single source of truth for the pnpm version in CI.

## [1.1.0] - 2026-06-15

### Added

- **Starship support** via cached, exported prompt variables (`DOPPLER_PROMPT_STARSHIP`,
  `DOPPLER_PROMPT_TEXT`, `DOPPLER_PROMPT_ANSI`) and a `doppler_starship_setup` helper that
  prints a ready-to-paste custom module.
- New output functions for non-zsh prompt engines: `doppler_prompt_text` (plain),
  `doppler_prompt_ansi` (ANSI-colored), and `doppler_prompt_color` (color name only).
- `DOPPLER_STARSHIP_USE_ANSI` option (default `true`) to choose between Doppler's dynamic
  ANSI colors and Starship-managed styling.

### Changed

- YAML resolution now **inherits the nearest parent directory scope** instead of requiring
  an exact working-directory match. A subdirectory with its own scope still overrides the
  inherited parent. (As a consequence, the awk parser scans the whole `.doppler.yaml`
  rather than exiting on the first match; negligible for typical files.)
- `_doppler_precmd` now exports only the Starship-facing variables (`DOPPLER_PROMPT_TEXT`,
  `DOPPLER_PROMPT_ANSI`, `DOPPLER_PROMPT_STARSHIP`); `DOPPLER_PROMPT_INFO` and
  `DOPPLER_PROMPT_COLOR_CURRENT` remain plain shell variables to avoid polluting the
  environment of child processes.

## [1.0.1] - 2025-12-30

### Changed

- Moved the package to the `@lsdcapital` npm org and published with provenance.
- Added a Vitest-based test suite and GitHub Actions CI/release pipeline.
- Packaging and metadata fixes in preparation for the first npm release.

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

[Unreleased]: https://github.com/lsdcapital/zsh-doppler/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/lsdcapital/zsh-doppler/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/lsdcapital/zsh-doppler/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/lsdcapital/zsh-doppler/releases/tag/v1.0.0
