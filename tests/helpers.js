import { execSync, spawn } from 'child_process'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'
import { readFileSync, writeFileSync, mkdirSync } from 'fs'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const repoRoot = join(__dirname, '..')
const pluginPath = join(repoRoot, 'zsh-doppler.plugin.zsh')
const testYamlTemplatePath = join(__dirname, 'fixtures', 'test-doppler.yaml')
const testYamlPath = join(__dirname, 'fixtures', 'test-doppler-resolved.yaml')
const testDirsPath = join(__dirname, 'test-dirs')

// Track active processes for cleanup
const activeProcesses = new Set()

/**
 * Setup test environment: create test directories and generate resolved YAML file
 */
export function setupTestEnvironment() {
  // Create test directories
  const testDirs = ['dev', 'prod', 'staging', 'custom', 'local', 'uat']
  testDirs.forEach(dir => {
    const dirPath = join(testDirsPath, dir)
    mkdirSync(dirPath, { recursive: true })
  })

  // Read template YAML and replace REPO_ROOT with actual path
  const template = readFileSync(testYamlTemplatePath, 'utf8')
  const resolvedYaml = template.replace(/REPO_ROOT/g, repoRoot)

  // Write resolved YAML file
  writeFileSync(testYamlPath, resolvedYaml)
}

/**
 * Execute a zsh function from the plugin and return the result
 */
export function execZshFunction(functionName, ...args) {
  const command = `
    source "${pluginPath}"
    ${functionName} ${args.map(arg => `"${arg}"`).join(' ')}
  `

  try {
    const result = execSync(`zsh -c '${command}'`, {
      encoding: 'utf8',
      timeout: 5000,
      killSignal: 'SIGTERM',
      env: {
        ...process.env,
        DOPPLER_YAML_PATH: testYamlPath
      }
    })
    return result.trim()
  } catch (error) {
    if (error.status === 1) {
      // Function returned exit code 1 (expected for some cases)
      return null
    }
    // Ensure process cleanup on error
    if (error.signal) {
      console.warn(`Process killed with signal: ${error.signal}`)
    }
    throw error
  }
}

/**
 * Execute a zsh command and return both stdout and exit code
 */
export function execZshCommand(command) {
  try {
    const result = execSync(`zsh -c 'source "${pluginPath}"; ${command}'`, {
      encoding: 'utf8',
      timeout: 5000,
      killSignal: 'SIGTERM',
      env: {
        ...process.env,
        DOPPLER_YAML_PATH: testYamlPath
      }
    })
    return { stdout: result.trim(), exitCode: 0 }
  } catch (error) {
    // Ensure process cleanup on error
    if (error.signal) {
      console.warn(`Process killed with signal: ${error.signal}`)
    }
    return {
      stdout: error.stdout ? error.stdout.trim() : '',
      exitCode: error.status || 1
    }
  }
}

/**
 * Mock environment variables for testing
 */
export function withEnvVars(envVars, testFn) {
  const originalEnv = { ...process.env }

  // Set test environment variables
  Object.assign(process.env, envVars)

  try {
    return testFn()
  } finally {
    // Restore original environment
    process.env = originalEnv
  }
}

/**
 * Clean up any hanging processes
 */
export function cleanupProcesses() {
  for (const proc of activeProcesses) {
    try {
      if (!proc.killed) {
        proc.kill('SIGTERM')
        // Force kill after 1 second if still alive
        setTimeout(() => {
          if (!proc.killed) {
            proc.kill('SIGKILL')
          }
        }, 1000)
      }
    } catch (error) {
      // Process might already be dead
    }
  }
  activeProcesses.clear()
}

/**
 * Kill any processes that might be related to our tests
 * NOTE: We don't aggressively kill processes here because:
 * 1. execSync already has timeout + SIGTERM handling (5s timeout in execZshCommand/execZshFunction)
 * 2. Killing "vitest" would kill the test runner itself
 * 3. Killing "zsh.*doppler" can kill active test processes
 */
export function killTestProcesses() {
  // Disabled aggressive process cleanup - let execSync timeouts handle it
  // If orphaned processes become an issue, we should track PIDs explicitly
  // instead of using pkill patterns
}

/**
 * Setup process cleanup handlers
 * NOTE: Disabled automatic cleanup handlers as they can interfere with vitest's
 * own process management and cause deadlocks during test runner exit.
 * Test files explicitly call cleanupProcesses() in afterEach/afterAll hooks instead.
 */
function setupProcessCleanup() {
  // Disabled - let vitest handle process lifecycle
  // Tests use explicit cleanup in afterEach/afterAll hooks
}

// Initialize cleanup handlers (currently disabled)
setupProcessCleanup()