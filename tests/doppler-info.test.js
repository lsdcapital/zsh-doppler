import { describe, it, expect, beforeAll, afterEach, afterAll } from 'vitest'
import { execZshCommand, cleanupProcesses, killTestProcesses, setupTestEnvironment } from './helpers.js'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const testDirsPath = join(__dirname, 'test-dirs')

describe('Doppler Info Retrieval', () => {
  // Setup test environment before tests
  beforeAll(() => {
    setupTestEnvironment()
  })

  // Cleanup after each test to prevent process accumulation
  afterEach(() => {
    cleanupProcesses()
  })

  // Final cleanup after all tests
  afterAll(() => {
    cleanupProcesses()
    killTestProcesses()
  })

  describe('_doppler_get_info', () => {
    it('should prioritize environment variables from doppler run', () => {
      const command = `
        DOPPLER_PROJECT="env-project" \\
        DOPPLER_CONFIG="env-config" \\
        _doppler_get_info
      `
      const result = execZshCommand(command)
      expect(result.stdout).toBe('env-project:env-config')
    })

    it('should use DOPPLER_ENVIRONMENT when DOPPLER_CONFIG is not set', () => {
      const command = `
        DOPPLER_PROJECT="env-project" \\
        DOPPLER_ENVIRONMENT="env-environment" \\
        _doppler_get_info
      `
      const result = execZshCommand(command)
      expect(result.stdout).toBe('env-project:env-environment')
    })

    it('should prefer DOPPLER_CONFIG over DOPPLER_ENVIRONMENT', () => {
      const command = `
        DOPPLER_PROJECT="env-project" \\
        DOPPLER_CONFIG="config-value" \\
        DOPPLER_ENVIRONMENT="env-value" \\
        _doppler_get_info
      `
      const result = execZshCommand(command)
      expect(result.stdout).toBe('env-project:config-value')
    })

    it('should return error when no doppler info available', () => {
      // Test in clean environment
      const command = `
        unset DOPPLER_PROJECT DOPPLER_CONFIG DOPPLER_ENVIRONMENT
        cd /tmp
        _doppler_get_info
      `
      const result = execZshCommand(command)
      expect(result.exitCode).toBe(1)
      expect(result.stdout).toBe('')
    })

    it('should return error when only project is set', () => {
      const command = `
        DOPPLER_PROJECT="test-project" \\
        unset DOPPLER_CONFIG DOPPLER_ENVIRONMENT
        cd /tmp
        _doppler_get_info
      `
      const result = execZshCommand(command)
      expect(result.exitCode).toBe(1)
    })

    it('should return error when only config is set', () => {
      const command = `
        DOPPLER_CONFIG="test-config" \\
        unset DOPPLER_PROJECT DOPPLER_ENVIRONMENT
        cd /tmp
        _doppler_get_info
      `
      const result = execZshCommand(command)
      expect(result.exitCode).toBe(1)
    })
  })

  describe('Integration with real doppler configuration', () => {
    // These tests use the test YAML configuration
    it('should read from YAML file when in configured directory', () => {
      const devDir = join(testDirsPath, 'dev')
      const command = `
        cd "${devDir}" 2>/dev/null || true
        _doppler_get_info
      `
      const result = execZshCommand(command)
      expect(result.stdout).toBe('test-project:dev')
    })
  })
})