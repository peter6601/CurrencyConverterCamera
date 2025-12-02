# Data Model: Real-Time Camera-Based Currency Converter

**Date**: 2025-12-02
**Phase**: Phase 1 (Design)
**Feature**: 001-camera-currency-converter

---

## Entity Definitions

### 1. CurrencySettings

**Purpose**: Stores user-configured currency and exchange rate for conversion calculations.

**Fields**:
- `currencyName: String` — Foreign currency name (e.g., "JPY", "USD", "EUR")
  - Constraints: max 20 characters, non-empty
  - Type: User-editable TextField input

- `exchangeRate: Decimal` — Exchange rate (foreign currency → TWD)
  - Constraints: 0.0001 ≤ rate ≤ 10000
  - Example: 0.22 (1 JPY = 0.22 TWD)
  - Type: Decimal for financial precision
  - Validation: Must be > 0

- `lastUpdated: Date` (optional)
  - Timestamp when settings were last modified
  - Used for UI display and export

**Computed Properties**:
- `isValid() -> Bool`: Returns true if both currencyName is non-empty AND exchangeRate in valid range

**Validation Rules**:
- currencyName: Cannot be empty; must be ≤20 characters
- exchangeRate: Must be > 0 AND ≤ 10000
- If either validation fails, `isValid()` returns false and UI disables "Start Scan" button

**Persistence**:
- Storage: UserDefaults
- Format: Codable (Swift's automatic JSON serialization)
- Key: `"currencySettings"`
- Restore on app launch: Yes, pre-populate form with previous values
- Lifetime: Persistent across app restarts, updated only when user explicitly changes values

**Example Usage**:
```swift
let settings = CurrencySettings(
    currencyName: "JPY",
    exchangeRate: Decimal(string: "0.22")!,
    lastUpdated: Date()
)

if settings.isValid {
    // Enable "Start Scan" button
} else {
    // Show error message
}
```

---

### 2. ConversionRecord

**Purpose**: Stores history of detected and converted prices for user reference.

**Fields**:
- `id: UUID` — Unique identifier
  - Auto-generated on creation
  - Used for deduplication if needed

- `originalPrice: Decimal` — Price detected from camera (in foreign currency)
  - Example: 3500 (JPY)
  - Precision: 2 decimal places

- `convertedAmount: Decimal` — Converted price to TWD
  - Calculation: originalPrice × exchangeRate
  - Example: 770.00 (TWD)
  - Precision: 2 decimal places, banker's rounding

- `currencyName: String` — Currency name at time of conversion (snapshot)
  - Reason for snapshot: Preserve original rate even if user changes settings
  - Example: "JPY"

- `exchangeRate: Decimal` — Exchange rate used for this conversion (snapshot)
  - Reason for snapshot: Display which rate was used
  - Example: 0.22

- `timestamp: Date` — When conversion was detected and recorded
  - Format: ISO 8601 (serialized as string in JSON)
  - Used for sorting (most recent first)

**Relationships**:
- Created from: CurrencySettings (currencyName and exchangeRate copied at time of detection)
- Associated with: User's device history (one device = one history file)

**Persistence**:
- Storage: FileManager (JSON file in app's Documents directory)
- Format: Codable array: `[ConversionRecord]`
- File path: `Documents/conversion_history.json`
- File structure:
  ```json
  [
    {
      "id": "550E8400-E29B-41D4-A716-446655440000",
      "originalPrice": 3500,
      "convertedAmount": 770.00,
      "currencyName": "JPY",
      "exchangeRate": 0.22,
      "timestamp": "2025-12-02T14:30:00Z"
    },
    ...
  ]
  ```

**Retention Policy**:
- Keep most recent 50 records
- Auto-prune oldest records when count exceeds 50
- On app launch: Load full history, keep only 50 most recent

**Computed Properties**:
- `formattedAmount() -> String`: Returns TWD symbol + amount (e.g., "NT$ 770.00")
- `formattedOriginalPrice() -> String`: Returns currency + amount (e.g., "JPY 3500")
- `formattedTimestamp() -> String`: Relative time (e.g., "2 minutes ago") or absolute time (e.g., "14:30")

**Example Usage**:
```swift
let record = ConversionRecord(
    id: UUID(),
    originalPrice: Decimal(3500),
    convertedAmount: Decimal(770.00),
    currencyName: "JPY",
    exchangeRate: Decimal(0.22),
    timestamp: Date()
)

// Later: retrieve from storage
let history = try StorageService.loadHistory() // Returns [ConversionRecord], most recent first
history.forEach { print($0.formattedAmount()) } // "NT$ 770.00", etc.
```

---

### 3. DetectedNumber

**Purpose**: Ephemeral representation of a number detected in a camera frame (for overlay rendering).

**Fields**:
- `value: Decimal` — The detected numeric value
  - Example: 3500
  - Source: Vision framework text recognition
  - Precision: May be Integer or Decimal; standardized to Decimal

- `boundingBox: CGRect` — Screen coordinates where number was detected
  - `origin`: Top-left corner (x, y)
  - `size`: Width and height
  - Used for: Overlay positioning (draw converted price at this location)
  - Coordinate system: Vision framework normalized (0.0–1.0), needs conversion to screen coords

- `confidence: Double` — Vision framework confidence score (0.0–1.0)
  - 1.0 = high confidence, 0.0 = low confidence
  - Filtering: Display overlay only if confidence > 0.5 (tunable threshold)
  - Used for: Accuracy measurement and debugging

**Lifetime**:
- Created during: Each frame processing (Vision detection)
- Destroyed after: Frame is processed and overlay rendered (typically 33–200ms per frame)
- Scope: Single frame only; not persisted
- Memory: Transient, no permanent storage

**Relationships**:
- Source: VisionService (detects text from camera frame)
- Used by: CameraViewModel (decides which numbers to overlay)
- Converted to: ConversionRecord (when user confirms detection or time-based auto-save)

**Example Usage**:
```swift
// From Vision detection
let detectedNumbers: [DetectedNumber] = visionService.detectNumbers(in: frame)

detectedNumbers.forEach { number in
    // Render overlay at boundingBox location
    if number.confidence > 0.5 {
        overlayView.addNumber(
            value: number.value,
            at: screenCoordinates(from: number.boundingBox),
            confidence: number.confidence
        )
    }
}

// If user taps overlay, convert to ConversionRecord
let record = ConversionRecord(
    id: UUID(),
    originalPrice: detectedNumbers[selectedIndex].value,
    convertedAmount: detectedNumbers[selectedIndex].value * currentExchangeRate,
    ...
)
```

---

## Database Schema (FileManager JSON)

### File Structure
**File**: `Documents/conversion_history.json`
**Format**: JSON array of ConversionRecord objects

```json
[
  {
    "id": "550E8400-E29B-41D4-A716-446655440000",
    "originalPrice": "3500",
    "convertedAmount": "770.00",
    "currencyName": "JPY",
    "exchangeRate": "0.22",
    "timestamp": "2025-12-02T14:30:00Z"
  },
  {
    "id": "6BA7B810-9DAD-11D1-80B4-00C04FD430C8",
    "originalPrice": "25.99",
    "convertedAmount": "815.00",
    "currencyName": "USD",
    "exchangeRate": "31.35",
    "timestamp": "2025-12-02T15:15:00Z"
  }
]
```

### Serialization
- Numbers serialized as strings (Decimal → String → JSON, then parsed back on deserialization)
- Dates serialized as ISO 8601 strings (Date → String → JSON)
- Standard Codable implementation handles serialization/deserialization

### Read Operations
1. App launch: Load full file, parse JSON, keep most recent 50 records
2. History view: Read from in-memory array (loaded at startup)
3. Copy to clipboard: Read single record, extract convertedAmount

### Write Operations
1. After number detection: Append new record to array
2. Retention policy: If array > 50 records, remove oldest (sort by timestamp, delete tail)
3. Write to disk: Serialize array to JSON, atomic write to file

### Backup & Recovery
- On app launch: If file corrupted (invalid JSON), delete and start fresh
- No cloud backup: All data local to device only
- User export: History can be copied to clipboard or shared as JSON (future enhancement)

---

## Relationships & Dependencies

### CurrencySettings → ConversionRecord
- When detection occurs, CurrencySettings (currencyName, exchangeRate) are copied into ConversionRecord
- Snapshot strategy: Preserves historical rate even if user changes settings later
- Reason: User can track what rate was used for each conversion

### CurrencySettings → CameraViewModel
- CameraViewModel reads current settings on each frame processing
- Updates overlay conversion display in real-time
- Listener: Use Combine @Published property to subscribe to settings changes

### DetectedNumber → ConversionRecord
- When number is detected and user confirms, DetectedNumber is converted to ConversionRecord
- Extracted fields: originalPrice, boundingBox (discarded after display)
- Added fields: id, convertedAmount, currencyName, exchangeRate (from current settings), timestamp

### StorageService (dependency)
```swift
protocol StorageService {
    func saveCurrencySettings(_ settings: CurrencySettings) throws
    func loadCurrencySettings() -> CurrencySettings?

    func addConversionRecord(_ record: ConversionRecord) throws
    func loadConversionHistory() -> [ConversionRecord] // Most recent first
    func clearHistory() throws
}
```

---

## Validation & Constraints

### CurrencySettings Validation
```swift
struct CurrencySettings: Codable {
    var currencyName: String
    var exchangeRate: Decimal

    func validate() throws {
        guard !currencyName.isEmpty else {
            throw ValidationError.emptyCurrencyName
        }
        guard currencyName.count <= 20 else {
            throw ValidationError.currencyNameTooLong
        }
        guard exchangeRate > 0 else {
            throw ValidationError.rateNotPositive
        }
        guard exchangeRate <= 10000 else {
            throw ValidationError.rateTooLarge
        }
    }

    var isValid: Bool {
        (try? validate()) != nil
    }
}
```

### ConversionRecord Validation
- No explicit validation needed (all fields derived from validated CurrencySettings or Vision detection)
- Implicit constraints: originalPrice and convertedAmount must be > 0 (enforced by business logic)

### DetectedNumber Validation
- Confidence must be in range [0.0, 1.0]
- BoundingBox coordinates must be normalized (0.0–1.0) or converted to screen space
- Value must be parseable as Decimal

---

## State Transitions & Lifecycle

### CurrencySettings Lifecycle
```
[App Launch]
    ↓
[Load from UserDefaults]
    ↓
[Display in SettingsView]
    ↓
[User edits fields] ← User confirms valid input → [Save to UserDefaults]
    ↓
[Used in all subsequent detections]
    ↓
[App Background/Killed]
    ↓
[Persisted in UserDefaults]
```

### ConversionRecord Lifecycle
```
[Vision detects number] → [Create DetectedNumber]
    ↓
[CameraViewModel receives DetectedNumber]
    ↓
[Calculate conversion using current CurrencySettings]
    ↓
[Create ConversionRecord] → [Auto-append to history]
    ↓
[Write to FileManager] → [Prune if count > 50]
    ↓
[Display in HistoryView] ← User taps to view/copy
    ↓
[Persisted until auto-pruned or user clears history]
```

### DetectedNumber Lifecycle
```
[Frame captured from AVCaptureSession]
    ↓
[Vision processes frame]
    ↓
[Create DetectedNumber objects]
    ↓
[CameraViewModel decides: display overlay?]
    ↓
[OverlayView renders at boundingBox location]
    ↓
[User moves camera or next frame arrives]
    ↓
[DetectedNumber discarded] ← Memory freed
```

---

## Type Definitions (Swift)

```swift
// Models/CurrencySettings.swift
import Foundation

struct CurrencySettings: Codable, Equatable {
    var currencyName: String
    var exchangeRate: Decimal
    var lastUpdated: Date = Date()

    enum CodingKeys: String, CodingKey {
        case currencyName, exchangeRate, lastUpdated
    }

    var isValid: Bool {
        !currencyName.isEmpty &&
        currencyName.count <= 20 &&
        exchangeRate > 0 &&
        exchangeRate <= 10000
    }
}

// Models/ConversionRecord.swift
import Foundation

struct ConversionRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var originalPrice: Decimal
    var convertedAmount: Decimal
    var currencyName: String
    var exchangeRate: Decimal
    var timestamp: Date = Date()

    var formattedAmount: String {
        return String(format: "NT$ %.2f", NSDecimalNumber(decimal: convertedAmount).doubleValue)
    }

    var formattedOriginalPrice: String {
        return "\(currencyName) \(originalPrice)"
    }
}

// Models/DetectedNumber.swift
import Foundation
import CoreGraphics

struct DetectedNumber {
    var value: Decimal
    var boundingBox: CGRect
    var confidence: Double

    init(value: Decimal, boundingBox: CGRect, confidence: Double) {
        self.value = value
        self.boundingBox = boundingBox
        self.confidence = confidence
    }
}
```

---

## Testing Strategy

### Unit Tests
- **CurrencySettingsTests**: Validation logic (valid/invalid inputs)
- **ConversionRecordTests**: Formatting functions, Codable serialization
- **DetectedNumberTests**: Constructor, property access

### Integration Tests
- **StorageServiceTests**: Save/load CurrencySettings via UserDefaults
- **HistoryStorageTests**: Save/load ConversionRecord array, retention policy (keep 50 most recent)
- **CodableTests**: JSON serialization/deserialization with edge cases (Decimal precision, Date format)

### Accuracy Tests
- **VisionServiceTests**: Load test images, compare detected values vs. ground truth, measure accuracy %

---

## Schema Evolution (Future)

If future versions need to add fields:

1. **CurrencySettings** (potential additions):
   - `preferredFormat: String` (e.g., "TWD 770.00" vs "NT$ 770.00")
   - `autoUpdateRate: Bool` (if external API added)

2. **ConversionRecord** (potential additions):
   - `imageSnapshot: Data` (attach screenshot of detected number)
   - `userConfirmed: Bool` (track if user manually verified)
   - `notes: String` (user annotations)

3. **Migration strategy**:
   - Add optional fields with default values (backward compatible)
   - On load, if field missing, use default
   - On save, write new format
   - After few releases, make fields required (breaking change, increment MAJOR version)

