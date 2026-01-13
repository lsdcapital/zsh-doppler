import { describe, it, expect, afterEach, afterAll } from 'vitest'
import { execZshFunction, execZshCommand, cleanupProcesses, killTestProcesses } from './helpers.js'

describe('Production Warning', () => {
  // Cleanup after each test to prevent process accumulation
  afterEach(() => {
    cleanupProcesses()
  })

  // Final cleanup after all tests
  afterAll(() => {
    cleanupProcesses()
    killTestProcesses()
  })

  describe('_doppler_is_production', () => {
    it('should return true for prod environments', () => {
      // The function returns exit code 0 (success) for production patterns
      const result = execZshCommand('_doppler_is_production "prod" && echo "true" || echo "false"')
      expect(result.stdout).toBe('true')
    })

    it('should detect various production patterns', () => {
      const prodPatterns = ['prod', 'production', 'live', 'prd', 'prd-us', 'prod-eu']
      for (const pattern of prodPatterns) {
        const result = execZshCommand(`_doppler_is_production "${pattern}" && echo "true" || echo "false"`)
        expect(result.stdout).toBe('true')
      }
    })

    it('should be case-insensitive', () => {
      const patterns = ['PROD', 'Production', 'LIVE', 'PRD']
      for (const pattern of patterns) {
        const result = execZshCommand(`_doppler_is_production "${pattern}" && echo "true" || echo "false"`)
        expect(result.stdout).toBe('true')
      }
    })

    it('should return false for non-prod environments', () => {
      const nonProdPatterns = ['dev', 'staging', 'test', 'qa', 'sandbox', 'ci', 'local']
      for (const pattern of nonProdPatterns) {
        const result = execZshCommand(`_doppler_is_production "${pattern}" && echo "true" || echo "false"`)
        expect(result.stdout).toBe('false')
      }
    })
  })

  describe('_doppler_show_prod_warning', () => {
    it('should output warning when enabled', () => {
      const result = execZshCommand('DOPPLER_PROD_WARNING=true; _doppler_show_prod_warning "myproject" "prod"')
      expect(result.stdout).toContain('PRODUCTION ENVIRONMENT')
      expect(result.stdout).toContain('myproject/prod')
    })

    it('should not output warning when disabled', () => {
      const result = execZshCommand('DOPPLER_PROD_WARNING=false; _doppler_show_prod_warning "myproject" "prod"')
      expect(result.stdout).toBe('')
    })

    it('should use custom message when configured', () => {
      const result = execZshCommand('DOPPLER_PROD_WARNING=true; DOPPLER_PROD_WARNING_MESSAGE="DANGER ZONE"; _doppler_show_prod_warning "myproject" "prod"')
      expect(result.stdout).toContain('DANGER ZONE')
    })
  })
})
