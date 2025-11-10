import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const baselineFile = path.join(__dirname, 'performance-baseline.json')

export class BaselineManager {
  constructor() {
    this.baseline = this.loadBaseline()
  }

  loadBaseline() {
    try {
      const data = fs.readFileSync(baselineFile, 'utf8')
      return JSON.parse(data)
    } catch (error) {
      console.warn('Could not load baseline file:', error.message)
      return null
    }
  }

  saveBaseline(baseline) {
    try {
      fs.writeFileSync(baselineFile, JSON.stringify(baseline, null, 2))
      console.log('✅ Baseline saved successfully')
    } catch (error) {
      console.error('❌ Failed to save baseline:', error.message)
      throw error
    }
  }

  // Calculate percentiles from an array of values
  calculatePercentiles(values) {
    const sorted = [...values].sort((a, b) => a - b)
    const len = sorted.length

    return {
      p50: sorted[Math.floor(len * 0.5)],
      p95: sorted[Math.floor(len * 0.95)],
      p99: sorted[Math.floor(len * 0.99)],
      samples: len
    }
  }

  // Record a new baseline metric
  recordMetric(metricName, values, description, unit = 'ms') {
    if (!this.baseline) {
      this.baseline = {
        version: '1.0',
        timestamp: new Date().toISOString(),
        environment: {
          node: process.version,
          platform: process.platform
        },
        tolerance: {
          warning_threshold: 0.20,
          failure_threshold: 0.50
        },
        metrics: {}
      }
    }

    const stats = this.calculatePercentiles(values)
    this.baseline.metrics[metricName] = {
      description,
      unit,
      ...stats
    }

    console.log(`📊 Recorded ${metricName}: p50=${stats.p50}${unit}, p95=${stats.p95}${unit}, p99=${stats.p99}${unit}`)
  }

  // Compare current performance against baseline
  compareMetric(metricName, currentValues) {
    if (!this.baseline || !this.baseline.metrics[metricName]) {
      console.warn(`⚠️  No baseline found for ${metricName}`)
      return { status: 'no_baseline', current: this.calculatePercentiles(currentValues) }
    }

    const baseline = this.baseline.metrics[metricName]
    const current = this.calculatePercentiles(currentValues)
    const warningThreshold = this.baseline.tolerance.warning_threshold
    const failureThreshold = this.baseline.tolerance.failure_threshold

    // Compare p95 values (most reliable for performance testing)
    const baselineValue = baseline.p95
    const currentValue = current.p95
    const changeRatio = (currentValue - baselineValue) / baselineValue

    let status = 'pass'
    let message = `✅ ${metricName}: ${currentValue}${baseline.unit} (baseline: ${baselineValue}${baseline.unit})`

    if (changeRatio > failureThreshold) {
      status = 'fail'
      message = `❌ ${metricName}: ${currentValue}${baseline.unit} vs baseline ${baselineValue}${baseline.unit} (+${(changeRatio * 100).toFixed(1)}% REGRESSION)`
    } else if (changeRatio > warningThreshold) {
      status = 'warning'
      message = `⚠️  ${metricName}: ${currentValue}${baseline.unit} vs baseline ${baselineValue}${baseline.unit} (+${(changeRatio * 100).toFixed(1)}% slower)`
    } else if (changeRatio < -0.1) {
      message = `🚀 ${metricName}: ${currentValue}${baseline.unit} vs baseline ${baselineValue}${baseline.unit} (${(Math.abs(changeRatio) * 100).toFixed(1)}% FASTER!)`
    }

    return {
      status,
      message,
      changeRatio,
      baseline: baseline,
      current: current
    }
  }

  // Update the baseline timestamp
  updateTimestamp() {
    if (this.baseline) {
      this.baseline.timestamp = new Date().toISOString()
    }
  }

  // Print a summary of all metrics
  printSummary() {
    if (!this.baseline) {
      console.log('No baseline available')
      return
    }

    console.log('\n📈 Performance Baseline Summary:')
    console.log(`Updated: ${this.baseline.timestamp}`)
    console.log(`Environment: Node ${this.baseline.environment.node} on ${this.baseline.environment.platform}`)
    console.log('')

    Object.entries(this.baseline.metrics).forEach(([name, metric]) => {
      console.log(`${name}: p50=${metric.p50}${metric.unit}, p95=${metric.p95}${metric.unit}, p99=${metric.p99}${metric.unit}`)
      console.log(`  ${metric.description}`)
    })
  }
}

// CLI interface
if (import.meta.url === `file://${process.argv[1]}`) {
  const manager = new BaselineManager()
  const command = process.argv[2]

  switch (command) {
    case 'summary':
      manager.printSummary()
      break
    case 'record':
      // Example: node baseline-manager.js record test_metric 100,200,150
      const metricName = process.argv[3]
      const values = process.argv[4]?.split(',').map(Number)
      const description = process.argv[5] || 'Test metric'

      if (metricName && values) {
        manager.recordMetric(metricName, values, description)
        manager.updateTimestamp()
        manager.saveBaseline(manager.baseline)
      } else {
        console.log('Usage: node baseline-manager.js record <metric_name> <comma_separated_values> [description]')
      }
      break
    default:
      console.log('Usage: node baseline-manager.js [summary|record]')
  }
}