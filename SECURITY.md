# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Security Considerations

This plugin is designed with security in mind, particularly given its use in secrets management contexts:

### What This Plugin Does

- **Reads environment variables**: `DOPPLER_PROJECT`, `DOPPLER_CONFIG`, `DOPPLER_ENVIRONMENT`
- **Reads YAML file**: `~/.doppler/.doppler.yaml` (Doppler CLI configuration)
- **Displays information**: Shows project and config names in shell prompts

### What This Plugin Does NOT Do

- **Does not access secrets**: Only reads project/config names, never secret values
- **Does not make network requests**: All data is read locally
- **Does not execute Doppler CLI**: Removed for performance; only reads files
- **Does not modify files**: Read-only operations only
- **Does not store data**: No caching to disk, only in-memory shell variables

### Security Best Practices

1. **Review before installing**: As with any shell plugin, review the source code
2. **Keep updated**: Use the latest version for any security fixes
3. **Verify source**: Only install from official repository

## Reporting a Vulnerability

If you discover a security vulnerability in this plugin:

1. **Do NOT open a public issue**
2. **Email the maintainer directly** at stef@lsd.capital
3. **Include details**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 1 week
- **Fix timeline**: Depends on severity, typically within 2 weeks for critical issues

### Disclosure Policy

- We follow responsible disclosure practices
- Security fixes will be released as soon as practical
- Credit will be given to reporters (unless anonymity is requested)
