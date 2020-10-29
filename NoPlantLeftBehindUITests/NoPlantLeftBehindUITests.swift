//
//  NoPlantLeftBehindUITests.swift
//  NoPlantLeftBehindUITests
//
//  Created by Kenneth Jones on 10/14/20.
//

import XCTest

class NoPlantLeftBehindUITests: XCTestCase {
    
    let app = XCUIApplication()

    func testCreateNewPlant() throws {
        app.launch()

        app.navigationBars["My Plants"].buttons["Add"].tap()

        XCTAssert(app.textFields["Plant Nickname"].exists)

        let plantNicknameTextField = app.textFields["Plant Nickname"]
        plantNicknameTextField.tap()
        plantNicknameTextField.typeText("Mr Planty")

        XCTAssert(app.textFields["Plant Species (optional)"].exists)

        let plantSpeciesOptionalTextField = app.textFields["Plant Species (optional)"]
        plantSpeciesOptionalTextField.tap()
        plantSpeciesOptionalTextField.typeText("Tumbleweed")

        XCTAssert(app.textFields["Watering Frequency (in days)"].exists)

        let wateringFrequencyInDaysTextField = app.textFields["Watering Frequency (in days)"]
        wateringFrequencyInDaysTextField.tap()
        wateringFrequencyInDaysTextField.typeText("2")

        app.staticTexts["Add Photo"].tap()
        app.scrollViews.otherElements.images["Photo, August 08, 2012, 12:52 PM"].tap()
        app.navigationBars["Add New Plant"].buttons["Save"].tap()
    }
    
    func testDeletePlant() throws {
        app.launch()

        app.navigationBars["My Plants"].buttons["Add"].tap()

        XCTAssert(app.textFields["Plant Nickname"].exists)

        let plantNicknameTextField = app.textFields["Plant Nickname"]
        plantNicknameTextField.tap()
        plantNicknameTextField.typeText("Mr Planty")

        XCTAssert(app.textFields["Plant Species (optional)"].exists)

        let plantSpeciesOptionalTextField = app.textFields["Plant Species (optional)"]
        plantSpeciesOptionalTextField.tap()
        plantSpeciesOptionalTextField.typeText("Tumbleweed")

        XCTAssert(app.textFields["Watering Frequency (in days)"].exists)

        let wateringFrequencyInDaysTextField = app.textFields["Watering Frequency (in days)"]
        wateringFrequencyInDaysTextField.tap()
        wateringFrequencyInDaysTextField.typeText("2")

        app.staticTexts["Add Photo"].tap()
        app.scrollViews.otherElements.images["Photo, August 08, 2012, 12:52 PM"].tap()
        app.navigationBars["Add New Plant"].buttons["Save"].tap()

        let plants = app.tables.cells
        plants.element(boundBy: 0).swipeLeft()
        plants.element(boundBy: 0).buttons["Delete"].tap()
    }
}
