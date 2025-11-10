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
 * Kill any orphaned zsh processes running our plugin
 * This is a safety net for cleanup - following Vitest best practices of
 * letting the framework handle lifecycle but adding safety nets for child processes
 */
export function killTestProcesses() {
  try {
    // Kill any zsh processes running our plugin that might have been orphaned
    execSync('pkill -f "zsh.*doppler.plugin.zsh" 2>/dev/null || true', {
      stdio: 'ignore',
      timeout: 1000
    })
  } catch (e) {
    // Ignore errors - processes may not exist or already be killed
  }
}

/**
 * Setup process cleanup handlers
 * Following Vitest best practices: let the framework handle process lifecycle,
 * but add safety nets for child processes that might be orphaned
 */
function setupProcessCleanup() {
  // Handle normal process exit
  process.on('exit', () => {
    killTestProcesses()
  })

  // Handle Ctrl+C
  process.on('SIGINT', () => {
    killTestProcesses()
    process.exit(130) // Standard exit code for SIGINT
  })

  // Handle termination signal
  process.on('SIGTERM', () => {
    killTestProcesses()
    process.exit(143) // Standard exit code for SIGTERM
  })
}

// Initialize cleanup handlers
setupProcessCleanup()