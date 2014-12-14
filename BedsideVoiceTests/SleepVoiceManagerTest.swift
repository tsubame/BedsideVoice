//
//  SleepVoiceManagerTest.swift
//  BedsideVoice
//
//  Created by hideki on 2014/12/11.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import XCTest

class SleepVoiceManagerTest: XCTestCase {

    var _sut = SleepVoiceManager()
    
    override func setUp() {
        super.setUp()
        _sut = SleepVoiceManager()
        _sut.setCharaName("雫")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPause() {
        var expectation = self.expectationWithDescription("")
        //var wait = self.expectationForNotification("sceneEnded", object: nil, handler: nil)
        
        _sut.playNextScene()
        delay(0.01, {
                self._sut.pause()
        })
        
        delay(0.05, {
                self._sut.resume()
                expectation.fulfill()
                XCTAssertFalse(self._sut.hasError(), "エラーがないこと")
        })
        
        self.waitForExpectationsWithTimeout(0.1, handler: nil)
    }
    
    func testPlayNextScene() {
        var expectation = self.expectationWithDescription("")
        //var wait = self.expectationForNotification("sceneEnded", object: nil, handler: nil)
        
        _sut.playNextScene()
        delay(0.1, {
                XCTAssertFalse(self._sut.hasError(), "エラーがないこと")
            expectation.fulfill()
        })

        self.waitForExpectationsWithTimeout(0.2, handler: nil)
    }
    
    func testSelectVoicesScene1() {
        for i in 0...1 {
            _sut = SleepVoiceManager()
            _sut.selectVoicesScene1()
            XCTAssertFalse(_sut.hasError(), "エラーがないこと")
            println(_sut._files)
            println(_sut._faces)
            println(_sut._texts)
        }
    }
    
    func testGetJsonForScene() {
        var json = _sut.getJsonForScene(1)
        XCTAssertFalse(_sut.hasError(), "エラーがないこと")
        //XCTAssertNotNil(json)
        //println(json)
        json = _sut.getJsonForScene(999)
        XCTAssertTrue(_sut.hasError(), "エラーがあること")
        //println(json)
    }

    /*
    func testGetJsonFromFile() {
        var json = _sut.getJsonFromFile("charA_greeting")
        XCTAssertFalse(_sut.hasError(), "エラーがないこと")
        //XCTAssertNotNil(json, "")
        //println(json)
        json = _sut.getJsonFromFile("存在しないjsonファイル")
        XCTAssertTrue(_sut.hasError(), "エラーがあること")
        
        json = _sut.getJsonFromFile("書式ミス")
        XCTAssertTrue(_sut.hasError(), "エラーがあること")
        //println(json)
    }*/

    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
*/
}
