import { describe, it, expect, beforeAll, afterEach, afterAll } from 'vitest'
import { execZshCommand, cleanupProcesses, killTestProcesses, setupTestEnvironment } from './helpers.js'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const repoRoot = join(__dirname, '..')
const testDirsPath = join(__dirname, 'test-dirs')

describe('YAML-based Doppler Info', () => {
  // Setup test environment before all tests
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
  describe('YAML file reading', () => {
    it('should read doppler info from test YAML file', () => {
      const testDir = join(testDirsPath, 'dev')
      const command = `
        cd "${testDir}"
        _doppler_get_info
      `
      const result = execZshCommand(command)
      expect(result.stdout).toBe('test-project:dev')
    })

    it('should work faster than CLI approach', async () => {
      // Test YAML approach speed
      const testDir = join(testDirsPath, 'dev')
      const yamlCommand = `
        cd "${testDir}"
        _doppler_get_info
      `

      const start = Date.now()
      const result = execZshCommand(yamlCommand)
      const duration = Date.now() - start

      expect(result.stdout).toBe('test-project:dev')
      expect(duration).toBeLessThan(50) // Should be much faster than CLI
    })

    it('should return empty if YAML file does not exist and no env vars set', () => {
      const testDir = join(testDirsPath, 'dev')
      const command = `
        # Use a non-existent YAML file path
        export DOPPLER_YAML_PATH="/nonexistent/path.yaml"
        cd "${testDir}"
        _doppler_get_info
      `

      const result = execZshCommand(command)
      // Should return empty since CLI fallback was removed
      expect(result.stdout).toBe('')
      expect(result.exitCode).toBe(1)
    })

    it('should handle directories not in YAML file gracefully', () => {
      const nonExistentDir = join(testDirsPath, 'nonexistent')
      const command = `
        mkdir -p "${nonExistentDir}" && cd "${nonExistentDir}"
        _doppler_get_info || echo "no-config"
      `

      const result = execZshCommand(command)
      expect(result.stdout).toBe('no-config')
    })
  })

  describe('Integration with prompt functions', () => {
    it('should work with doppler_prompt_info', () => {
      const testDir = join(testDirsPath, 'dev')
      const command = `
        cd "${testDir}"
        doppler_prompt_info
      `

      const result = execZshCommand(command)
      expect(result.stdout).toMatch(/test-project.*dev/)
      expect(result.stdout).toContain('%F{green}') // Should be green for dev
    })

    it('should work with different environment colors', () => {
      const prodDir = join(testDirsPath, 'prod')
      const stagingDir = join(testDirsPath, 'staging')

      const prodCommand = `cd "${prodDir}" && doppler_prompt_info`
      const stagingCommand = `cd "${stagingDir}" && doppler_prompt_info`

      const prodResult = execZshCommand(prodCommand)
      const stagingResult = execZshCommand(stagingCommand)

      // Prod should be red, staging should be yellow
      expect(prodResult.stdout).toContain('%F{red}')
      expect(stagingResult.stdout).toContain('%F{yellow}')
    })
  })

  describe('Performance characteristics', () => {
    it('should be consistently fast across multiple calls', () => {
      const testDir = join(testDirsPath, 'dev')
      const durations = []

      for (let i = 0; i < 10; i++) {
        const start = Date.now()
        const result = execZshCommand(`cd "${testDir}" && _doppler_get_info`)
        const duration = Date.now() - start
        durations.push(duration)

        expect(result.stdout).toBe('test-project:dev')
      }

      // All calls should be fast
      const maxDuration = Math.max(...durations)
      const avgDuration = durations.reduce((a, b) => a + b, 0) / durations.length

      console.log(`YAML approach: avg=${avgDuration.toFixed(1)}ms, max=${maxDuration}ms`)
      expect(maxDuration).toBeLessThan(100) // No call should take more than 100ms
      expect(avgDuration).toBeLessThan(50)   // Average should be under 50ms
    })
  })
})