import { describe, it, expect, afterEach, afterAll } from 'vitest'
import { execZshCommand, cleanupProcesses, killTestProcesses } from './helpers.js'

describe('Powerlevel10k Support', () => {
  afterEach(() => {
    cleanupProcesses()
  })

  afterAll(() => {
    cleanupProcesses()
    killTestProcesses()
  })

  it('should render a p10k segment using the p10k segment API', () => {
    const result = execZshCommand(`
      function p10k() { print -r -- "$*" }
      DOPPLER_PROJECT="test-project" \
      DOPPLER_CONFIG="dev" \
      prompt_doppler
    `)

    expect(result.stdout).toContain('segment')
    expect(result.stdout).toContain('-f 2')
    expect(result.stdout).toContain('-b none')
    expect(result.stdout).toContain('-i 🔐')
    expect(result.stdout).toContain('-t [test-project/dev]')
  })

  it('should respect p10k-specific format, prefix, and suffix', () => {
    const result = execZshCommand(`
      function p10k() { print -r -- "$*" }
      POWERLEVEL9K_DOPPLER_PREFIX=""
      POWERLEVEL9K_DOPPLER_SUFFIX=""
      POWERLEVEL9K_DOPPLER_FORMAT="%config@%project"
      DOPPLER_PROJECT="test-project" \
      DOPPLER_CONFIG="production" \
      prompt_doppler
    `)

    expect(result.stdout).toContain('-f 1')
    expect(result.stdout).toContain('-t production@test-project')
  })

  it('should print p10k setup instructions when p10k is detected', () => {
    const result = execZshCommand(`
      function p10k() { : }
      doppler_p10k_setup
    `)

    expect(result.exitCode).toBe(0)
    expect(result.stdout).toContain('Powerlevel10k Doppler Segment Setup')
    expect(result.stdout).toContain('POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS')
  })
})
