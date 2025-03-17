//
//  TimeLapseAppTests.swift
//  TimeLapseAppTests
//
//  Created by Z1 on 06.03.2025.
//

import XCTest
@testable import TimeLapseApp

final class TimeLapseAppTests: XCTestCase {
    //System under test
    var sut : CameraManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = CameraManager()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
