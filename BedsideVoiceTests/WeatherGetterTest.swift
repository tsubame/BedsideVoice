//
//  WeatherGetterTest.swift
//  BedsideVoice
//
//  Created by hideki on 2014/12/06.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import UIKit
import XCTest

class WeatherGetterTest: XCTestCase {

    var _sut = WeatherGetter()
    
    override func setUp() {
        super.setUp()
        _sut = WeatherGetter()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetWeatherOfTokyo() {
        // This is an example of a functional test case.
        //XCTAssert(true, "Pass")
        var w = _sut.getWeatherOfTokyo()
        XCTAssertFalse(_sut.hasError(), "エラーがないこと")
        
        if w["minTemp"] == nil {
            println("minTempがないよ")
        }

        if w["maxTemp"] == nil {
            println("maxTempがないよ")
        }
        
        if w["currentTemp"] == nil {
            println("currentTempがないよ")
        }
        
        if w["currentWeather"] == nil {
            println("currentWeatherがないよ")
        }
        
        println(w.count)
    }


}
