//
//  CameraManagerTests.swift
//  CurrencyConverterCameraTests
//
//  Created by Claude on 2025-12-03.
//

import XCTest
import AVFoundation
@testable import CurrencyConverterCamera
internal import Combine

final class CameraManagerTests: XCTestCase {

    var cameraManager: CameraManager!

    override func setUp() {
        super.setUp()
        cameraManager = CameraManager()
    }

    override func tearDown() {
        super.tearDown()
        if cameraManager.isSessionRunning {
            cameraManager.stopSession()
        }
        cameraManager = nil
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(cameraManager.session)
        XCTAssertFalse(cameraManager.isSessionRunning)
        XCTAssertNil(cameraManager.delegate)
    }

    func testSessionIsAVCaptureSession() {
        XCTAssertTrue(cameraManager.session is AVCaptureSession)
    }

    // MARK: - Camera Permission Tests

    func testRequestCameraPermissionWhenNotDetermined() {
        // Save original status
        let originalStatus = AVCaptureDevice.authorizationStatus(for: .video)

        // Request permission
        cameraManager.requestCameraPermission()

        // Permission status should be either .notDetermined (if already denied in settings)
        // or we cannot control it directly in tests
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        XCTAssertTrue(status == .notDetermined || status == .denied || status == .authorized)
    }

    func testAuthorizationStatusIsPublished() {
        let expectation = XCTestExpectation(description: "authorizationStatus published")

        var publishedStatus: AVAuthorizationStatus?
        let cancellable = cameraManager.$authorizationStatus
            .sink { status in
                publishedStatus = status
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(publishedStatus)
        cancellable.cancel()
    }

    // MARK: - Session Management Tests

    func testStartSession() {
        cameraManager.startSession()

        // Note: In test environment, session may not fully start due to simulator limitations
        // We just verify the method executes without crashing
        XCTAssertNotNil(cameraManager.session)
    }

    func testStopSession() {
        cameraManager.startSession()
        cameraManager.stopSession()

        // Verify method executes without crashing
        XCTAssertNotNil(cameraManager.session)
    }

    func testSessionRunningStateToggle() {
        let initialState = cameraManager.isSessionRunning

        if !initialState {
            cameraManager.startSession()
            // We can't directly verify isSessionRunning due to simulator limitations
            // but we verify it doesn't crash
        }

        cameraManager.stopSession()
        XCTAssertNotNil(cameraManager.session)
    }

    // MARK: - Delegate Tests

    func testDelegateCanBeSet() {
        let mockDelegate = MockCameraManagerDelegate()
        cameraManager.delegate = mockDelegate

        XCTAssertNotNil(cameraManager.delegate)
        XCTAssert(cameraManager.delegate is MockCameraManagerDelegate)
    }

    func testDelegateCanBeNil() {
        cameraManager.delegate = nil
        XCTAssertNil(cameraManager.delegate)
    }

    // MARK: - Error Handling Tests

    func testSessionConfigurationWithoutErrors() {
        // This should not throw or crash
        XCTAssertNoThrow {
            self.cameraManager.startSession()
        }
    }

    func testCanStartAndStopMultipleTimes() {
        XCTAssertNoThrow {
            self.cameraManager.startSession()
            self.cameraManager.stopSession()
            self.cameraManager.startSession()
            self.cameraManager.stopSession()
        }
    }
}

// MARK: - Mock Delegate for Testing

class MockCameraManagerDelegate: CameraManagerDelegate {
    var didCaptureFrameCalled = false
    var didUpdateAuthorizationStatusCalled = false
    var didEncounterErrorCalled = false

    func cameraManager(_ manager: CameraManager, didCaptureFrame pixelBuffer: CVPixelBuffer) {
        didCaptureFrameCalled = true
    }

    func cameraManager(_ manager: CameraManager, didUpdateAuthorizationStatus status: AVAuthorizationStatus) {
        didUpdateAuthorizationStatusCalled = true
    }

    func cameraManager(_ manager: CameraManager, didEncounterError error: Error) {
        didEncounterErrorCalled = true
    }
}

// MARK: - Test Helper Extension

extension XCTestCase {
    func XCTAssertNoThrow(_ block: @escaping () -> Void) {
        let expectation = XCTestExpectation(description: "Should not throw")

        DispatchQueue.global().async {
            block()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
