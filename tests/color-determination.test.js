import { describe, it, expect, afterEach, afterAll } from 'vitest'
import { execZshFunction, cleanupProcesses, killTestProcesses } from './helpers.js'

describe('Color Determination', () => {
  // Cleanup after each test to prevent process accumulation
  afterEach(() => {
    cleanupProcesses()
  })

  // Final cleanup after all tests
  afterAll(() => {
    cleanupProcesses()
    killTestProcesses()
  })
  describe('_doppler_get_color', () => {
    it('should return green for dev environments', () => {
      expect(execZshFunction('_doppler_get_color', 'dev')).toBe('green')
      expect(execZshFunction('_doppler_get_color', 'development')).toBe('green')
      expect(execZshFunction('_doppler_get_color', 'dev_personal')).toBe('green')
      expect(execZshFunction('_doppler_get_color', 'local')).toBe('green')
      expect(execZshFunction('_doppler_get_color', 'DEV')).toBe('green') // uppercase
    })

    it('should return yellow for staging environments', () => {
      expect(execZshFunction('_doppler_get_color', 'staging')).toBe('yellow')
      expect(execZshFunction('_doppler_get_color', 'stag')).toBe('yellow')
      expect(execZshFunction('_doppler_get_color', 'test')).toBe('yellow')
      expect(execZshFunction('_doppler_get_color', 'uat')).toBe('yellow')
      expect(execZshFunction('_doppler_get_color', 'STAGING')).toBe('yellow') // uppercase
    })

    it('should return red for production environments', () => {
      expect(execZshFunction('_doppler_get_color', 'prod')).toBe('red')
      expect(execZshFunction('_doppler_get_color', 'production')).toBe('red')
      expect(execZshFunction('_doppler_get_color', 'live')).toBe('red')
      expect(execZshFunction('_doppler_get_color', 'PROD')).toBe('red') // uppercase
    })

    it('should return cyan for unknown environments', () => {
      expect(execZshFunction('_doppler_get_color', 'unknown')).toBe('cyan')
      expect(execZshFunction('_doppler_get_color', 'custom')).toBe('cyan')
      expect(execZshFunction('_doppler_get_color', 'api')).toBe('cyan')
      expect(execZshFunction('_doppler_get_color', '')).toBe('cyan') // empty string
    })
  })

  describe('_doppler_get_p10k_color', () => {
    it('should convert color names to P10k color codes', () => {
      expect(execZshFunction('_doppler_get_p10k_color', 'green')).toBe('2')
      expect(execZshFunction('_doppler_get_p10k_color', 'yellow')).toBe('3')
      expect(execZshFunction('_doppler_get_p10k_color', 'red')).toBe('1')
      expect(execZshFunction('_doppler_get_p10k_color', 'cyan')).toBe('6')
      expect(execZshFunction('_doppler_get_p10k_color', 'blue')).toBe('4')
      expect(execZshFunction('_doppler_get_p10k_color', 'magenta')).toBe('5')
      expect(execZshFunction('_doppler_get_p10k_color', 'white')).toBe('7')
    })

    it('should pass through numeric colors unchanged', () => {
      expect(execZshFunction('_doppler_get_p10k_color', '51')).toBe('51')
      expect(execZshFunction('_doppler_get_p10k_color', '123')).toBe('123')
    })

    it('should pass through unknown color names unchanged', () => {
      expect(execZshFunction('_doppler_get_p10k_color', 'purple')).toBe('purple')
      expect(execZshFunction('_doppler_get_p10k_color', 'custom')).toBe('custom')
    })
  })
})