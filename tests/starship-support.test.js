import { describe, it, expect, afterEach, afterAll } from 'vitest'
import { execZshCommand, cleanupProcesses, killTestProcesses } from './helpers.js'

describe('Starship Support', () => {
  afterEach(() => {
    cleanupProcesses()
  })

  afterAll(() => {
    cleanupProcesses()
    killTestProcesses()
  })

  it('should expose plain text output for prompt engines', () => {
    const result = execZshCommand(`
      DOPPLER_PROJECT="test-project" \
      DOPPLER_CONFIG="dev" \
      doppler_prompt_text
    `)

    expect(result.stdout).toBe('[test-project/dev]')
  })

  it('should expose ANSI-colored output for Starship custom modules', () => {
    const result = execZshCommand(`
      DOPPLER_PROJECT="test-project" \
      DOPPLER_CONFIG="dev" \
      doppler_prompt_ansi
    `)

    expect(result.stdout).toBe('\u001b[32m[test-project/dev]\u001b[0m')
  })

  it('should expose the current Doppler color', () => {
    const result = execZshCommand(`
      DOPPLER_PROJECT="test-project" \
      DOPPLER_CONFIG="production" \
      doppler_prompt_color
    `)

    expect(result.stdout).toBe('red')
  })

  it('should cache and export Starship-friendly prompt variables in precmd', () => {
    const result = execZshCommand(`
      export DOPPLER_PROJECT="test-project"
      export DOPPLER_CONFIG="staging"
      _doppler_precmd
      printenv DOPPLER_PROMPT_TEXT
      print -r -- "$DOPPLER_PROMPT_COLOR_CURRENT"
      printenv DOPPLER_PROMPT_ANSI | cat -v
      printenv DOPPLER_PROMPT_STARSHIP | cat -v
    `)

    const lines = result.stdout.split('\n')
    expect(lines[0]).toBe('[test-project/staging]')
    expect(lines[1]).toBe('yellow')
    expect(lines[2]).toBe('^[[33m[test-project/staging]^[[0m')
    expect(lines[3]).toBe('^[[33m[test-project/staging]^[[0m')
  })

  it('should cache plain Starship output when ANSI is disabled', () => {
    const result = execZshCommand(`
      export DOPPLER_STARSHIP_USE_ANSI=false
      export DOPPLER_PROJECT="test-project"
      export DOPPLER_CONFIG="dev"
      _doppler_precmd
      printenv DOPPLER_PROMPT_STARSHIP
    `)

    expect(result.stdout).toBe('[test-project/dev]')
  })

  it('should let doppler_prompt_starship use plain text when ANSI is disabled', () => {
    const result = execZshCommand(`
      DOPPLER_STARSHIP_USE_ANSI=false \
      DOPPLER_PROJECT="test-project" \
      DOPPLER_CONFIG="dev" \
      doppler_prompt_starship
    `)

    expect(result.stdout).toBe('[test-project/dev]')
  })

  it('should print Starship setup instructions', () => {
    const result = execZshCommand('doppler_starship_setup')

    expect(result.stdout).toContain('Starship Doppler Module Setup')
    expect(result.stdout).toContain('[custom.doppler]')
    expect(result.stdout).toContain('DOPPLER_PROMPT_STARSHIP')
  })
})
