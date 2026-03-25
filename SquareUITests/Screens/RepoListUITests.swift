//
//  RepoListUITests.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//

import XCTest
@testable import Square
final class RepoListUITests: XCTestCase {
    //MARK: properties
    private var app: XCUIApplication! = nil
    //MARK: test lifecycle
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    //MARK: test cases

    
    func test_whenAppLaunches_thenRepoListTableIsVisible() {
           app.launch()

           let table = app.tables.firstMatch
           XCTAssertTrue(table.waitForExistence(timeout: 5), "Repo list table should be visible after launch")
       }

       func test_whenAppLaunches_thenRepoListIsNotEmpty() {
           app.launch()

           let table = app.tables.firstMatch
           XCTAssertTrue(table.waitForExistence(timeout: 5))

           let firstCell = table.cells.firstMatch
           XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "At least one repo cell should be visible")
       }

       // MARK: - Navigation

      

       // MARK: - Scrolling

       func test_whenUserScrollsDown_thenTableRespondsToScroll() {
           app.launch()

           let table = app.tables.firstMatch
           XCTAssertTrue(table.waitForExistence(timeout: 5))

           table.swipeUp()

           XCTAssertTrue(table.exists, "Table should still exist after scrolling")
       }

}
