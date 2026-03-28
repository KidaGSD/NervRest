# CSV Real Data Integration — Minimal Working Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Load real WESAD participant HR CSV data into the existing demo pipeline so the app displays real human biometric curves instead of synthetic noise.

**Architecture:** Create a `CSVHeartRateLoader` utility that parses the existing CSV files, derive HRV (SDNN) from successive HR intervals using a sliding window, and inject the resulting `[BiometricReading]` into the existing `SimulatedBiometricProvider` as an alternative data source. No new providers, no protocol changes — just a new data path into the existing system.

**Tech Stack:** Swift, Foundation, existing `BiometricReading` model, existing `SimulatedBiometricProvider`

**Reference file:** `/Users/huangjunda/Downloads/dataprocessing.swift` — contains `CSVLoader` and scoring logic to adapt from.

---

### Task 0: Add CSV files to Xcode bundle resources

**Files:**
- Modify: `NervRest/NervRest.xcodeproj/project.pbxproj` (via Xcode)

The CSV files exist on disk at `NervRest/NervRest/Data/` but are **not** in the Xcode project's "Copy Bundle Resources" build phase. `Bundle.main.url(forResource:)` will return nil unless they are added.

- [ ] **Step 1: Add CSVs to Xcode target**

In Xcode: File → Add Files to "NervRest" → select `Participant1_HR.csv` and `Participant3_HR.csv` → check "Add to targets: NervRest" → Add.

Alternatively, drag both files from the Data/ folder in the Xcode navigator onto the NervRest target, ensuring "Copy items if needed" is unchecked (files already in place) and target membership is checked.

- [ ] **Step 2: Verify bundle inclusion**

Build the project. Then confirm:
```swift
// In a playground or temporary test:
Bundle.main.url(forResource: "Participant1_HR", withExtension: "csv") != nil // must be true
```

- [ ] **Step 3: Commit**

```bash
git add NervRest/NervRest.xcodeproj/project.pbxproj
git commit -m "chore: add Participant CSV files to Xcode bundle resources"
```

---

### Task 1: CSV Loader

**Files:**
- Create: `NervRest/NervRest/Data/CSVHeartRateLoader.swift`

- [ ] **Step 1: Create CSVHeartRateLoader**

Parses CSV format: line 0 = unix timestamp, line 1 = sampling rate (Hz), lines 2+ = HR BPM values. Returns `[Double]`.

```swift
import Foundation

struct CSVHeartRateLoader {

    /// Load HR values from a bundled CSV file.
    /// - Parameters:
    ///   - fileName: Resource name without extension (e.g. "Participant1_HR")
    ///   - maxMinutes: Cap the data length (nil = all data)
    /// - Returns: Array of HR BPM values at the file's sampling rate
    static func load(fileName: String, maxMinutes: Double? = nil) -> [Double] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "csv") else {
            print("[CSVHeartRateLoader] File not found: \(fileName).csv")
            return []
        }

        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("[CSVHeartRateLoader] Could not read: \(fileName).csv")
            return []
        }

        let lines = content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard lines.count >= 3 else { return [] }

        let samplingRate = Double(lines[1]) ?? 1.0
        let hrValues = lines.dropFirst(2).compactMap { Double($0) }

        if let maxMinutes {
            let maxSamples = Int(maxMinutes * 60.0 * samplingRate)
            return Array(hrValues.prefix(maxSamples))
        }
        return hrValues
    }

    /// Derive HRV (SDNN approximation) from HR array using a sliding window.
    /// Converts HR → RR intervals (60/HR in ms), then computes SDNN over window.
    static func deriveHRV(from hrValues: [Double], at index: Int, windowSize: Int = 30) -> Double {
        let start = max(0, index - windowSize + 1)
        let end = min(index, hrValues.count - 1)
        guard start <= end else { return 50.0 }

        let window = hrValues[start...end]
        let rrIntervals = window.map { 60_000.0 / max($0, 40.0) } // ms

        let mean = rrIntervals.reduce(0, +) / Double(rrIntervals.count)
        let variance = rrIntervals.map { ($0 - mean) * ($0 - mean) }.reduce(0, +) / Double(rrIntervals.count)
        return sqrt(variance) // SDNN in ms
    }

    /// Convert raw HR array into BiometricReading array with derived HRV.
    /// Downsamples from 1Hz to one reading per `sampleEveryNSeconds`.
    static func toBiometricReadings(
        hrValues: [Double],
        startDate: Date? = nil,
        sampleEveryNSeconds: Int = 60
    ) -> [BiometricReading] {
        guard !hrValues.isEmpty else { return [] }

        let base = startDate ?? Calendar.current.date(
            bySettingHour: 19, minute: 0, second: 0, of: Date()
        )!

        var readings: [BiometricReading] = []
        var i = 0
        while i < hrValues.count {
            let hr = hrValues[i]
            let hrv = deriveHRV(from: hrValues, at: i)
            let timestamp = base.addingTimeInterval(TimeInterval(i))

            readings.append(BiometricReading(
                id: UUID(),
                timestamp: timestamp,
                heartRate: hr,
                hrvSDNN: hrv,
                respiratoryRate: estimateRespiratoryRate(hr: hr)
            ))

            i += sampleEveryNSeconds
        }
        return readings
    }

    /// Simple respiratory rate estimate from HR (rough physiological correlation).
    private static func estimateRespiratoryRate(hr: Double) -> Double {
        // Resting: ~14 breaths/min at HR 60-70, scales up with HR
        return 12.0 + (hr - 60.0) * 0.1
    }
}
```

- [ ] **Step 2: Verify it compiles**

Run: Xcode build (Cmd+B) or `xcodebuild` for the NervRest target.
Expected: Clean build, no errors.

- [ ] **Step 3: Commit**

```bash
git add NervRest/NervRest/Data/CSVHeartRateLoader.swift
git commit -m "feat: add CSVHeartRateLoader — parse WESAD CSV + derive HRV from HR"
```

---

### Task 2: Wire CSV data into SimulatedBiometricProvider

**Files:**
- Modify: `NervRest/NervRest/Data/Simulated/SimulatedBiometricProvider.swift`

- [ ] **Step 1: Add CSV loading path to `loadData()`**

Add a `participantFileName` property and modify `loadData()` to try CSV first, then WESAD JSON, then synthetic fallback.

In `SimulatedBiometricProvider.swift`, replace the existing `init()` with a single designated init that accepts an optional CSV file name. This ensures `participantFileName` is set **before** `loadData()` runs (avoiding the convenience init timing bug where `loadData()` would fire twice — once with nil):

```swift
// After line 13 (var playbackSpeed):
/// Set to a CSV file name (e.g. "Participant1_HR") to use real data.
var participantFileName: String?

// Replace existing init() with:
init(participantFileName: String? = nil) {
    self.participantFileName = participantFileName
    loadData()
}
```

The default parameter `= nil` preserves all existing call sites (`SimulatedBiometricProvider()` still works).

Replace the `loadData()` method (lines 61-75) with:

```swift
private func loadData() {
    // Priority 1: Real participant CSV data
    if let csvName = participantFileName {
        let hrValues = CSVHeartRateLoader.load(fileName: csvName, maxMinutes: 20)
        if !hrValues.isEmpty {
            storedReadings = CSVHeartRateLoader.toBiometricReadings(
                hrValues: hrValues,
                sampleEveryNSeconds: 60  // 1 reading per minute for demo
            )
            print("[Bio] Loaded \(storedReadings.count) readings from \(csvName).csv")
            return
        }
    }

    // Priority 2: WESAD JSON bundle
    if let url = Bundle.main.url(forResource: "wesad-evening", withExtension: "json"),
       let data = try? Data(contentsOf: url) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([BiometricReading].self, from: data) {
            storedReadings = decoded
            return
        }
    }

    // Priority 3: Synthetic fallback
    storedReadings = Self.generateSyntheticEvening()
}
```

Also update `baseline` to be computed from actual data instead of hardcoded:

```swift
// Replace the hardcoded baseline (line 20) with:
var baseline: BiometricBaseline {
    guard !storedReadings.isEmpty else {
        return BiometricBaseline(restingHR: 64, restingHRV: 55, restingRespiratoryRate: 14)
    }
    let sortedHR = storedReadings.map(\.heartRate).sorted()
    let sortedHRV = storedReadings.map(\.hrvSDNN).sorted()
    let p15Index = Int(Double(sortedHR.count - 1) * 0.15)
    return BiometricBaseline(
        restingHR: sortedHR[p15Index],
        restingHRV: sortedHRV[max(0, sortedHRV.count - 1 - p15Index)],  // high HRV = calm
        restingRespiratoryRate: 14
    )
}
```

Note: This changes `baseline` from a `let` to a computed `var`. The protocol already declares it as `{ get }` so this is compatible.

- [ ] **Step 2: Verify build**

Run: Xcode build.
Expected: Clean build. Demo still works with synthetic data by default (no `participantFileName` set).

- [ ] **Step 3: Commit**

```bash
git add NervRest/NervRest/Data/Simulated/SimulatedBiometricProvider.swift
git commit -m "feat: SimulatedBiometricProvider loads real CSV when participantFileName is set"
```

---

### Task 3: Add participant selector to AppContainer

**Files:**
- Modify: `NervRest/NervRest/AppContainer.swift`

- [ ] **Step 1: Add data source enum and pass to provider**

At top of `AppContainer.swift`, add:

```swift
enum DemoDataSource: String, CaseIterable {
    case synthetic = "Synthetic"
    case participant1 = "Participant 1 (Real)"
    case participant3 = "Participant 3 (Real)"

    var csvFileName: String? {
        switch self {
        case .synthetic: return nil
        case .participant1: return "Participant1_HR"
        case .participant3: return "Participant3_HR"
        }
    }
}
```

Modify `init()` to accept data source:

```swift
@Published var currentDataSource: DemoDataSource = .participant1

init(dataSource: DemoDataSource = .participant1) {
    self.currentDataSource = dataSource

    // Data providers
    let bio: SimulatedBiometricProvider
    if let csvName = dataSource.csvFileName {
        bio = SimulatedBiometricProvider(participantFileName: csvName)
    } else {
        bio = SimulatedBiometricProvider()
    }
    // ... rest unchanged
```

- [ ] **Step 2: Verify build — app now defaults to Participant 1 real data**

Run: Xcode build + run on simulator.
Expected: HomeScreen shows real HR values from Participant 1 CSV when session starts.

- [ ] **Step 3: Commit**

```bash
git add NervRest/NervRest/AppContainer.swift
git commit -m "feat: AppContainer defaults to Participant 1 real HR data"
```

---

### Task 4: Verify end-to-end with real data

- [ ] **Step 1: Build and run on simulator**

Run: Xcode build + run on iPhone simulator.
Expected: App launches, session starts, HomeScreen shows HR values from Participant 1 CSV (expect HR range ~79-106 for P1, higher than synthetic's 66-88).

- [ ] **Step 2: Check console log**

Expected console output: `[Bio] Loaded ~130 readings from Participant1_HR.csv`
If instead you see synthetic fallback, the CSV is not in the bundle (revisit Task 0).

- [ ] **Step 3: Verify intervention triggers**

Start demo session. Watch for arousal score to climb as real HR data plays back. The MismatchDetector and InterventionScheduler should still trigger based on the real HR curve.

---

## Summary

| Task | What | Files | Risk |
|------|------|-------|------|
| 0 | Add CSVs to Xcode bundle | pbxproj (via Xcode) | None — required for runtime |
| 1 | CSV parser + HRV derivation | 1 new file | None — pure utility |
| 2 | Wire CSV into existing provider | 1 modified | Low — fallback to synthetic |
| 3 | Default to real data | 1 modified | Low — enum + init param |
| 4 | End-to-end verification | 0 files | None — verification only |

**Total: 1 new file, 2 modified files, 1 pbxproj change. No protocol changes. No new dependencies. Existing synthetic path preserved as fallback.**
