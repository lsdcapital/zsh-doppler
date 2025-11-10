import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['tests/**/*.test.js'],
    // Process management settings - ensure only one worker process
    maxWorkers: 1,
    pool: 'forks',
    poolOptions: {
      forks: {
        singleFork: true
      }
    },
    // Timeout settings
    testTimeout: 10000,
    teardownTimeout: 3000,
    // Ensure proper cleanup
    sequence: {
      concurrent: false
    },
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