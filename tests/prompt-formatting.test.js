import { describe, it, expect, beforeEach, afterEach, afterAll } from 'vitest'
import { execZshFunction, execZshCommand, cleanupProcesses, killTestProcesses } from './helpers.js'

describe('Prompt Formatting', () => {
  // Cleanup after each test to prevent process accumulation
  afterEach(() => {
    cleanupProcesses()
  })

  // Final cleanup after all tests
  afterAll(() => {
    cleanupProcesses()
    killTestProcesses()
  })
  describe('_doppler_format_prompt', () => {
    it('should format project and config with default separator', () => {
      const result = execZshFunction('_doppler_format_prompt', 'myproject:dev')
      expect(result).toBe('myproject/dev')
    })

    it('should handle different separators', () => {
      // Test with custom separator
      const command = 'DOPPLER_PROMPT_SEPARATOR="-" _doppler_format_prompt "myproject:staging"'
      const result = execZshCommand(command)
      expect(result.stdout).toBe('myproject-staging')
    })

    it('should handle custom format templates', () => {
      // Test with custom format
      const command = 'DOPPLER_PROMPT_FORMAT="%config@%project" _doppler_format_prompt "myproject:prod"'
      const result = execZshCommand(command)
      expect(result.stdout).toBe('prod@myproject')
    })

    it('should handle project-only format', () => {
      const command = 'DOPPLER_PROMPT_FORMAT="%project" _doppler_format_prompt "myproject:dev"'
      const result = execZshCommand(command)
      expect(result.stdout).toBe('myproject')
    })

    it('should handle config-only format', () => {
      const command = 'DOPPLER_PROMPT_FORMAT="%config" _doppler_format_prompt "myproject:staging"'
      const result = execZshCommand(command)
      expect(result.stdout).toBe('staging')
    })
  })

  describe('doppler_prompt_info', () => {
    it('should return empty when plugin is disabled', () => {
      const command = 'DOPPLER_PROMPT_ENABLED=false doppler_prompt_info'
      const result = execZshCommand(command)
      expect(result.stdout).toBe('')
    })

    it('should return empty when no doppler info available', () => {
      // Test in environment without doppler configuration
      const result = execZshCommand('doppler_prompt_info')
      expect(result.stdout).toBe('')
    })

    it('should format prompt with colors when doppler info is available', () => {
      // Mock environment variables to simulate doppler run session
      const command = `
        DOPPLER_PROJECT="test-project" \\
        DOPPLER_CONFIG="dev" \\
        doppler_prompt_info
      `
      const result = execZshCommand(command)
      expect(result.stdout).toBe('%F{green}[test-project/dev]%f')
    })

    it('should use custom colors for different environments', () => {
      // Test production environment
      const command = `
        DOPPLER_PROJECT="test-project" \\
        DOPPLER_CONFIG="production" \\
        doppler_prompt_info
      `
      const result = execZshCommand(command)
      expect(result.stdout).toBe('%F{red}[test-project/production]%f')
    })

    it('should use custom prefix and suffix', () => {
      const command = `
        DOPPLER_PROJECT="test-project" \\
        DOPPLER_CONFIG="staging" \\
        DOPPLER_PROMPT_PREFIX="(" \\
        DOPPLER_PROMPT_SUFFIX=")" \\
        doppler_prompt_info
      `
      const result = execZshCommand(command)
      expect(result.stdout).toBe('%F{yellow}(test-project/staging)%f')
    })
  })
})