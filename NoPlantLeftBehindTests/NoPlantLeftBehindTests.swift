//
//  NoPlantLeftBehindTests.swift
//  NoPlantLeftBehindTests
//
//  Created by Kenneth Jones on 10/14/20.
//

import XCTest
@testable import NoPlantLeftBehind

class NoPlantLeftBehindTests: XCTestCase {

    let plantController = PlantController()
    let plant = Plant(nickname: "Groot", species: "Tree", h2oFrequency: 2, lastWatered: Date(timeIntervalSince1970: 2), timesWatered: 0, imageData: UIImage(named: "blackplant")!.pngData())

    func testSendPlantToServerWithExpectation() {
        let didFinish = expectation(description: "didFinish")

        plantController.sendPlantToServer(plant: plant) { result in
            XCTAssertTrue(result == .success(true))
            didFinish.fulfill()
        }
        wait(for: [didFinish], timeout: 5)
    }

    func testDeletePlantFromServer() {
        let didFinish = expectation(description: "didFinish")

        plantController.deletePlantFromServer(plant) { (result) in
            XCTAssertTrue(result == .success(true))
            didFinish.fulfill()
        }
        wait(for: [didFinish], timeout: 5)
    }

}
