//
//  TalkManagerTest.swift
//  EarClerics
//
//  Created by hideki on 2014/12/05.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import UIKit
import XCTest
//import EarClerics
import Foundation

class TalkManagerTest: XCTestCase {
    
    var _sut = TalkManager()
    

    
    override func setUp() {
        super.setUp()
        _sut = TalkManager()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /*
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }*/
    
    func testGetGreetingMsg() {
        _sut.getGreetingMsg()
        XCTAssertFalse(_sut.hasError(), "エラーでないこと")
        XCTAssertNotEqual(_sut._fileNames.count, 0, "0件以上の結果が帰ってくること")
        //println(_sut._fileNames)
        //println(_sut._messages)
        //println(_sut._faces)
    }
    
    
    func testGetGreetingMsgFromTimestr() {
        let greetingKeys = ["早朝", "朝", "昼", "夜", "深夜"]
        
        for key in greetingKeys {
            _sut.getGreetingMsgFromTimestr(key)
            XCTAssertFalse(_sut.hasError(), "エラーでないこと")
            XCTAssertNotEqual(_sut._fileNames.count, 0, "0件以上の結果が帰ってくること")
            //println(_sut._fileNames)
            //println(_sut._messages)
            //println(_sut._faces)
            // ファイルの存在確認もしたい
        }
    }
    

    func testGetTimeStrFromDate() {
        let cal   = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        let flags = NSCalendarUnit.HourCalendarUnit
        
        var dateComps = cal.components(flags, fromDate: NSDate())
        var date: NSDate = cal.dateFromComponents(dateComps)!
        var res = ""
        
        for hour in 4...6 {
            dateComps.hour = hour
            date = cal.dateFromComponents(dateComps)!
            res  = _sut.getTimeStrFromDate(date)
            XCTAssertEqual(res, "早朝", "早朝であること")
        }
        
        for hour in 7...11 {
            dateComps.hour = hour
            date = cal.dateFromComponents(dateComps)!
            res  = _sut.getTimeStrFromDate(date)
            XCTAssertEqual(res, "朝", "朝であること")
        }
        
        for hour in 12...17 {
            dateComps.hour = hour
            date = cal.dateFromComponents(dateComps)!
            res  = _sut.getTimeStrFromDate(date)
            XCTAssertEqual(res, "昼", "昼であること")
        }
        
        for hour in 18...22 {
            dateComps.hour = hour
            date = cal.dateFromComponents(dateComps)!
            res  = _sut.getTimeStrFromDate(date)
            XCTAssertEqual(res, "夜", "夜であること")
        }
        
        for hour in 23...24 {
            dateComps.hour = hour
            date = cal.dateFromComponents(dateComps)!
            res  = _sut.getTimeStrFromDate(date)
            XCTAssertEqual(res, "深夜", "深夜であること")
        }
        
        for hour in 0...3 {
            dateComps.hour = hour
            date = cal.dateFromComponents(dateComps)!
            res  = _sut.getTimeStrFromDate(date)
            XCTAssertEqual(res, "深夜", "深夜であること")
        }
    }
    
    /*
    // Jsonファイルの構文のチェック
    func testCheckJsonSyntax() {
        
    }*/
    
    
}
