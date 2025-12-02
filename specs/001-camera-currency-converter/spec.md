# Feature Specification: Real-Time Camera-Based Currency Converter

**Feature Branch**: `001-camera-currency-converter`
**Created**: 2025-12-02
**Status**: Draft
**Input**: User description: Create a real-time camera-based currency converter that helps travelers instantly understand foreign prices in TWD by pointing their phone camera at price tags and menus.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Traveler Converts Price Tag at Foreign Merchant (Priority: P1)

A Taiwanese traveler walking through a Japanese department store needs to quickly understand if a 3,500 JPY price tag is reasonable. They open the app, point the camera at the price, and see the TWD equivalent instantly overlaid on the screen.

**Why this priority**: This is the core MVP use case—converting visible prices in real-time directly solves the traveler's pain point of manual entry and app switching. Without this, the app has no value.

**Independent Test**: Can be fully tested by: (1) Opening app with camera permission, (2) Pointing at a price tag with clear numbers, (3) Verifying overlay displays correct conversion in <500ms, (4) Confirming accuracy >85% on well-lit images.

**Acceptance Scenarios**:

1. **Given** user has configured currency and exchange rate, **When** user points camera at a price tag with visible numbers, **Then** app detects numbers within 500ms and displays converted TWD price overlaid on screen
2. **Given** camera is pointed at a price tag, **When** numbers are in focus and well-lit, **Then** detection accuracy is >85%
3. **Given** conversion is displayed, **When** user moves camera away, **Then** overlay disappears cleanly without UI artifacts
4. **Given** multiple prices are visible (e.g., menu with multiple items), **When** user taps a specific detected number, **Then** app highlights that number and shows its conversion

---

### User Story 2 - Configure Exchange Rate Before Using App (Priority: P1)

Before the traveler can use the converter, they must first enter the current exchange rate. They open the app and see a settings screen where they can enter the foreign currency name (e.g., "JPY") and the exchange rate (e.g., 0.22 TWD per JPY).

**Why this priority**: This is a hard blocker—without exchange rate configuration, the app cannot produce any conversions. Users must complete this before accessing any camera features.

**Independent Test**: Can be fully tested by: (1) Launching app, (2) Entering currency name and exchange rate in settings, (3) Validating input fields reject invalid values, (4) Confirming settings persist after app restart, (5) Verifying "Start Scan" button enables only after valid input.

**Acceptance Scenarios**:

1. **Given** app is launched, **When** user opens settings view, **Then** form shows empty currency name field and exchange rate field
2. **Given** user enters an exchange rate (e.g., 0.22), **When** exchange rate is in valid range (0.0001–10000), **Then** field accepts value and "Start Scan" button becomes enabled
3. **Given** user enters invalid data, **When** exchange rate is ≤0 or >10000, or currency name is empty, **Then** error message displays and "Start Scan" button remains disabled
4. **Given** user enters valid settings and clicks "Start Scan", **When** camera view loads, **Then** settings are persisted and camera initializes with camera permission request
5. **Given** user has previously entered settings, **When** app is restarted, **Then** settings are restored from storage and form shows previously entered values

---

### User Story 3 - View Conversion History & Quick Reference (Priority: P2)

After converting several prices throughout the day, the traveler wants a quick reference of what they've converted. They can tap a history button to see a list of recent conversions (original price, converted amount, timestamp) and optionally copy them for reference.

**Why this priority**: P2 because it adds user convenience but is not critical for the MVP. The core conversion works without history. However, it becomes valuable after users start using the app regularly.

**Independent Test**: Can be fully tested by: (1) Performing 5+ conversions, (2) Opening history view, (3) Verifying all conversions appear with correct values and timestamps, (4) Testing copy functionality, (5) Clearing history and confirming it resets.

**Acceptance Scenarios**:

1. **Given** user has performed conversions, **When** user taps history button, **Then** view displays list of recent conversions (last 50 maximum) sorted by most recent first
2. **Given** history view is open, **When** user taps a conversion entry, **Then** app displays original price, converted amount, exchange rate used, and timestamp
3. **Given** user wants to reference a conversion, **When** user taps copy button on an entry, **Then** converted amount is copied to clipboard and confirmation appears
4. **Given** history grows over time, **When** history exceeds 50 entries, **Then** oldest entries are automatically removed

---

### Edge Cases

- What happens when the camera cannot focus or is pointed at a blurry surface? Display "Unable to detect numbers—ensure good lighting and focus"
- What happens if user points camera at non-price text (e.g., a product code or barcode)? Detection may occur but accuracy is not guaranteed; user can manually dismiss false positives
- What happens if the detected number is missing decimal places (e.g., "3500" instead of "3500.00")? Assume the last two digits are cents; allow user to manually adjust if needed
- What happens if the app loses camera permission mid-use? Stop detection, show permission error, and guide user to Settings to re-enable
- What happens if the device has extremely low battery (<5%)? Show warning banner and allow continued use but recommend charging soon
- What happens if user switches exchange rate mid-conversion? Apply new rate immediately to all subsequent detections; display notification that rate changed

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a settings screen on first launch with fields for currency name (max 20 characters) and exchange rate (decimal, range 0.0001–10000)
- **FR-002**: System MUST validate exchange rate input: must be >0 and ≤10000; currency name cannot be empty
- **FR-003**: System MUST persist settings to UserDefaults and restore them on app restart
- **FR-004**: System MUST enable "Start Scan" button only when both currency name and exchange rate are valid
- **FR-005**: System MUST request camera permission on first camera access; show permission-denied message if denied
- **FR-006**: System MUST capture camera frames at 5–8 FPS and process them for number detection
- **FR-007**: System MUST detect numeric patterns in camera frames using Vision framework (OCR) with accuracy >85% for well-lit, focused content
- **FR-008**: System MUST calculate converted price: detected_price × exchange_rate with result rounded to 2 decimal places
- **FR-009**: System MUST display converted price overlaid on the detected number location in real-time (<500ms latency)
- **FR-010**: System MUST allow user to tap detected numbers to highlight/focus on a specific conversion
- **FR-011**: System MUST store conversion records (original price, converted amount, exchange rate, timestamp) locally
- **FR-012**: System MUST display history view with up to 50 most recent conversions, sorted by timestamp descending
- **FR-013**: System MUST support copy-to-clipboard for converted amounts in history
- **FR-014**: System MUST handle app backgrounding gracefully: pause processing on background, resume on foreground

### Key Entities

- **CurrencySettings**: Represents user-configured currency (name: String, exchangeRate: Decimal). Validates that exchangeRate is >0 and ≤10000, and name is non-empty.
- **ConversionRecord**: Represents a single detected and converted price (originalPrice: Decimal, convertedAmount: Decimal, currencyName: String, exchangeRate: Decimal, timestamp: Date). Persisted to local storage.
- **DetectedNumber**: Represents a number detected in a camera frame (value: Decimal, boundingBox: CGRect, confidence: Double). Ephemeral—exists only during camera processing.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Recognition accuracy is >85% for clear, well-lit price numbers (verified via test image set with ground truth)
- **SC-002**: Detection latency is <500ms from frame capture to overlay display (measured via internal timing logs)
- **SC-003**: Camera processing runs at 5–8 FPS sustained over 5+ minutes of continuous use (verified via frame counter in debug view)
- **SC-004**: Battery drain during continuous camera use is <15% per hour (verified via device battery log or manual measurement)
- **SC-005**: Users can configure settings and begin scanning within 30 seconds of app launch
- **SC-006**: Conversion calculations produce correct results: original_price × exchange_rate = converted_amount (100% of unit test cases pass)
- **SC-007**: Settings persist across app restarts (100% of integration test cases pass)
- **SC-008**: History records at least 50 conversions without data loss or UI lag
- **SC-009**: >75% overall test coverage; 100% coverage of critical paths (currency conversion, number parsing, coordinate transformation)
- **SC-010**: App launches and camera initializes in <3 seconds on target device (iPhone 12 or newer)

---

## Assumptions

1. **Exchange Rate Stability**: Assumed the user will manually update exchange rates when rates change significantly (no automatic rate fetching from external APIs in MVP).
2. **Number Format**: Assumed detected numbers are in standard Arabic numerals (0–9) with optional decimal point and common currency symbols (e.g., $, ¥, €). Chinese numerals are not supported in MVP.
3. **Lighting Conditions**: Assumed users will use the app in daylight or well-lit indoor environments; performance in low-light is not guaranteed.
4. **Device Capability**: Assumed target device has a modern camera capable of 1080p+ video and sufficient CPU/GPU for real-time Vision processing.
5. **Precision**: Assumed 2 decimal places are sufficient for converted prices; no rounding beyond standard banker's rounding.
6. **User Responsibility**: Assumed users verify conversions visually and will not rely solely on the app for financial accuracy; app is for quick reference, not audited calculations.
7. **iOS Platform**: Assumed iOS-native development is required; no cross-platform compatibility or Android support in MVP.
8. **Localization**: Assumed Traditional Chinese (zh-TW) is the primary UI language; English fallback is not included in MVP.

---

## Dependencies & Constraints

- **External Dependencies**: None (all functionality uses built-in iOS frameworks: AVFoundation, Vision, SwiftUI, UIKit, UserDefaults)
- **Platform Dependencies**: iOS 15.0+, requires device with camera and motion processor for real-time performance
- **Data Dependencies**: No external APIs or databases; all data stored locally on device
- **Performance Constraints**: Must meet frame rate, latency, and battery targets as specified in Success Criteria
- **Security**: No sensitive financial or personal data transmitted; all calculations local to device
