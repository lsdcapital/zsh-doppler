# Contributing to zsh-doppler

Thank you for your interest in contributing to zsh-doppler! This document provides guidelines and instructions for contributing.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/zsh-doppler.git
   cd zsh-doppler
   ```
3. **Install dependencies**:
   ```bash
   pnpm install
   ```

## Development Workflow

### Running Tests

```bash
# Run all tests
pnpm test

# Run tests with coverage
pnpm run test:coverage

# Run performance tests only
pnpm run test:perf

# Run a specific test file
pnpm vitest tests/yaml-approach.test.js
```

### Code Style

- Follow existing code patterns in the plugin file
- Use `local` for function-scoped variables
- Prefix internal functions with `_doppler_`
- Add comments for non-obvious logic

### Testing Your Changes

1. **Load the modified plugin** in a new terminal:
   ```bash
   source ./zsh-doppler.plugin.zsh
   ```

2. **Test with helper functions**:
   ```bash
   doppler_prompt_test    # Check overall functionality
   doppler_prompt_config  # View current configuration
   ```

3. **Test with Powerlevel10k** (if applicable):
   ```bash
   doppler_p10k_setup
   ```

## Submitting Changes

### Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** and commit:
   ```bash
   git add .
   git commit -m "Add: brief description of changes"
   ```

3. **Run the test suite**:
   ```bash
   pnpm test
   ```

4. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Open a Pull Request** on GitHub

### Commit Message Guidelines

Use clear, descriptive commit messages:
- `Add: new feature description`
- `Fix: bug description`
- `Update: what was updated`
- `Refactor: what was refactored`
- `Docs: documentation changes`
- `Test: test additions or changes`

### Pull Request Guidelines

- **Title**: Clear, concise summary of changes
- **Description**: Explain what and why, not just how
- **Tests**: Include tests for new functionality
- **Documentation**: Update README if needed

## Types of Contributions

### Bug Reports

Open an issue with:
- Clear description of the bug
- Steps to reproduce
- Expected vs actual behavior
- Zsh version and OS
- Relevant configuration

### Feature Requests

Open an issue with:
- Clear description of the feature
- Use case / motivation
- Proposed implementation (optional)

### Code Contributions

Welcome areas for contribution:
- Bug fixes
- Performance improvements
- New shell framework support
- Documentation improvements
- Test coverage expansion

## Architecture Notes

### Key Files

- `zsh-doppler.plugin.zsh` - Main plugin (single file)
- `tests/helpers.js` - Test utilities
- `tests/*.test.js` - Test files

### Function Naming

- `doppler_*` - Public API functions
- `_doppler_*` - Internal helper functions
- `prompt_doppler` - Powerlevel10k segment

### Testing Approach

- Tests execute actual Zsh via `execZshCommand()`
- Test YAML is generated dynamically in `tests/fixtures/`
- Performance baselines prevent regression

## Questions?

- Open an issue for questions
- Check existing issues for answers
- Read the README for usage information

Thank you for contributing!
