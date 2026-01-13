import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['tests/**/*.test.js'],
    // Process management settings - ensure only one worker process
    maxWorkers: 1,
    isolate: false,
    pool: 'forks',
    // Timeout settings
    testTimeout: 10000,
    teardownTimeout: 5000, // Increased from 3s to allow proper cleanup of child processes
    // Ensure proper cleanup
    sequence: {
      concurrent: false
    },
    // Reporters - hanging-process helps debug zombie processes
    reporters: ['default', 'hanging-process'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'tests/',
        'vitest.config.js'
      ]
    }
  }
})