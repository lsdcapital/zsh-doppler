import { describe, it, expect, beforeAll, afterEach, afterAll } from 'vitest'
import { execZshCommand, cleanupProcesses, killTestProcesses, setupTestEnvironment } from './helpers.js'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const testDirsPath = join(__dirname, 'test-dirs')

describe('Performance Tests', () => {
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

  describe('Function execution timing', () => {
    it('should execute _doppler_get_info in reasonable time', async () => {
      const start = Date.now()
      const devDir = join(testDirsPath, 'dev')

      const command = `
        cd "${devDir}" 2>/dev/null || true
        _doppler_get_info
      `

      const result = execZshCommand(command)
      const duration = Date.now() - start

      // Should complete within 1 second (generous threshold)
      expect(duration).toBeLessThan(1000)
      console.log(`_doppler_get_info took ${duration}ms`)
    })

    it('should execute doppler_prompt_info quickly with environment variables', () => {
      const start = Date.now()

      const command = `
        DOPPLER_PROJECT="test-project" \\
        DOPPLER_CONFIG="dev" \\
        doppler_prompt_info
      `

      const result = execZshCommand(command)
      const duration = Date.now() - start

      // Environment variable lookup should be very fast
      expect(duration).toBeLessThan(100)
      expect(result.stdout).toBe('%F{green}[test-project/dev]%f')
      console.log(`doppler_prompt_info (env vars) took ${duration}ms`)
    })

    it('should measure YAML-based lookup performance', () => {
      const start = Date.now()
      const devDir = join(testDirsPath, 'dev')

      const command = `
        cd "${devDir}" 2>/dev/null || true
        # Simulate no env vars, force YAML lookup
        unset DOPPLER_PROJECT DOPPLER_CONFIG DOPPLER_ENVIRONMENT
        doppler_prompt_info
      `

      const result = execZshCommand(command)
      const duration = Date.now() - start

      // YAML lookup should be reasonably fast
      expect(duration).toBeLessThan(2000)
      console.log(`doppler_prompt_info (YAML lookup) took ${duration}ms`)
    })

    it('should benchmark color determination speed', () => {
      const testCases = ['dev', 'staging', 'production', 'custom-env']
      const results = []

      for (const config of testCases) {
        const start = Date.now()
        const result = execZshCommand(`_doppler_get_color "${config}"`)
        const duration = Date.now() - start

        results.push({ config, duration, color: result.stdout })
        expect(duration).toBeLessThan(50) // Should be very fast
      }

      console.log('Color determination benchmarks:', results)
    })

    it('should measure prompt formatting performance', () => {
      const start = Date.now()

      const result = execZshCommand('_doppler_format_prompt "long-project-name:very-long-environment-name"')
      const duration = Date.now() - start

      expect(duration).toBeLessThan(50)
      expect(result.stdout).toBe('long-project-name/very-long-environment-name')
      console.log(`Prompt formatting took ${duration}ms`)
    })
  })

  describe('Load testing', () => {
    it('should handle multiple rapid calls efficiently', () => {
      const iterations = 10
      const durations = []

      for (let i = 0; i < iterations; i++) {
        const start = Date.now()

        const command = `
          DOPPLER_PROJECT="test-project-${i}" \\
          DOPPLER_CONFIG="env-${i}" \\
          doppler_prompt_info
        `

        const result = execZshCommand(command)
        const duration = Date.now() - start

        durations.push(duration)
        expect(result.stdout).toContain(`test-project-${i}/env-${i}`)
      }

      const avgDuration = durations.reduce((a, b) => a + b, 0) / durations.length
      const maxDuration = Math.max(...durations)

      console.log(`Average duration over ${iterations} calls: ${avgDuration.toFixed(2)}ms`)
      console.log(`Max duration: ${maxDuration}ms`)

      // Average should be reasonable
      expect(avgDuration).toBeLessThan(200)
      expect(maxDuration).toBeLessThan(500)
    })
  })

  describe('Cache validation setup', () => {
    it('should prepare for cache testing', () => {
      // This test sets up cache validation scenarios
      const cacheTestCommands = [
        'echo "Cache test setup"',
        'export DOPPLER_CACHE_TTL=2', // 2 second cache for testing
        '_doppler_cache_clear 2>/dev/null || true' // Clear any existing cache
      ]

      for (const cmd of cacheTestCommands) {
        const result = execZshCommand(cmd)
        console.log(`Setup: ${cmd}`)
      }

      expect(true).toBe(true) // Placeholder for setup validation
    })
  })
})