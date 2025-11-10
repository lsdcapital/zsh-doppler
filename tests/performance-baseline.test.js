import { describe, it, expect, afterEach, afterAll } from 'vitest'
import { execZshCommand, cleanupProcesses, killTestProcesses } from './helpers.js'
import { BaselineManager } from './baseline-manager.js'

describe('Performance Baseline Tests', () => {
  // Cleanup after each test to prevent process accumulation
  afterEach(() => {
    cleanupProcesses()
  })

  // Final cleanup after all tests
  afterAll(() => {
    cleanupProcesses()
    killTestProcesses()
  })
  const baseline = new BaselineManager()

  // Helper function to run multiple samples and return durations
  async function measureFunction(command, samples = 5) {
    const durations = []

    for (let i = 0; i < samples; i++) {
      const start = Date.now()
      execZshCommand(command)
      const duration = Date.now() - start
      durations.push(duration)
    }

    return durations
  }

  describe('Core Performance Metrics', () => {
    it('should measure _doppler_get_info YAML read performance', async () => {
      const yamlCommand = `
        cd /tmp/test-doppler 2>/dev/null || true
        _doppler_get_info
      `

      const durations = await measureFunction(yamlCommand, 5)
      const comparison = baseline.compareMetric('_doppler_get_info_yaml', durations)

      console.log(comparison.message)

      // Performance test based on baseline
      if (comparison.status === 'fail') {
        expect.fail(comparison.message)
      } else if (comparison.status === 'warning') {
        console.warn('⚠️ Performance warning:', comparison.message)
      }

      // Fallback threshold if no baseline
      if (comparison.status === 'no_baseline') {
        expect(comparison.current.p95).toBeLessThan(20) // Fallback: YAML read should be < 20ms
      }
    })

    it('should measure environment variable performance', async () => {
      const envCommand = `
        DOPPLER_PROJECT="test-project"
        DOPPLER_CONFIG="dev"
        doppler_prompt_info
      `

      const durations = await measureFunction(envCommand, 10)
      const comparison = baseline.compareMetric('doppler_prompt_info_env_vars', durations)

      console.log(comparison.message)

      if (comparison.status === 'fail') {
        expect.fail(comparison.message)
      } else if (comparison.status === 'warning') {
        console.warn('⚠️ Performance warning:', comparison.message)
      }

      // Fallback threshold if no baseline
      if (comparison.status === 'no_baseline') {
        expect(comparison.current.p95).toBeLessThan(100) // Fallback: env vars should be < 100ms
      }
    })

    it('should measure color determination performance', async () => {
      const testCases = ['dev', 'staging', 'production', 'custom-env']
      const allDurations = []

      for (const config of testCases) {
        const durations = await measureFunction(`_doppler_get_color "${config}"`, 3)
        allDurations.push(...durations)
      }

      const comparison = baseline.compareMetric('color_determination', allDurations)

      console.log(comparison.message)

      if (comparison.status === 'fail') {
        expect.fail(comparison.message)
      } else if (comparison.status === 'warning') {
        console.warn('⚠️ Performance warning:', comparison.message)
      }

      // Fallback threshold if no baseline
      if (comparison.status === 'no_baseline') {
        expect(comparison.current.p95).toBeLessThan(50) // Fallback: color detection should be < 50ms
      }
    })

    it('should measure prompt formatting performance', async () => {
      const durations = await measureFunction('_doppler_format_prompt "long-project-name:very-long-environment-name"', 5)
      const comparison = baseline.compareMetric('prompt_formatting', durations)

      console.log(comparison.message)

      if (comparison.status === 'fail') {
        expect.fail(comparison.message)
      } else if (comparison.status === 'warning') {
        console.warn('⚠️ Performance warning:', comparison.message)
      }

      // Fallback threshold if no baseline
      if (comparison.status === 'no_baseline') {
        expect(comparison.current.p95).toBeLessThan(50) // Fallback: formatting should be < 50ms
      }
    })
  })

  describe('Load Testing', () => {
    it('should measure load test performance', async () => {
      const iterations = 10
      const durations = []

      for (let i = 0; i < iterations; i++) {
        const start = Date.now()

        const command = `
          DOPPLER_PROJECT="test-project-${i}"
          DOPPLER_CONFIG="env-${i}"
          doppler_prompt_info
        `

        execZshCommand(command)
        const duration = Date.now() - start
        durations.push(duration)
      }

      const comparison = baseline.compareMetric('load_test_average', durations)

      console.log(comparison.message)

      if (comparison.status === 'fail') {
        expect.fail(comparison.message)
      } else if (comparison.status === 'warning') {
        console.warn('⚠️ Performance warning:', comparison.message)
      }

      // Fallback threshold if no baseline
      if (comparison.status === 'no_baseline') {
        const avgDuration = durations.reduce((a, b) => a + b, 0) / durations.length
        expect(avgDuration).toBeLessThan(200) // Fallback: load test average should be < 200ms
      }
    })
  })


  describe('Performance Summary', () => {
    it('should print performance summary', () => {
      console.log('\n' + '='.repeat(60))
      baseline.printSummary()
      console.log('='.repeat(60) + '\n')
      expect(true).toBe(true) // Always pass, this is just for reporting
    })
  })
})