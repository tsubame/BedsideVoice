//
//  SoundPlayerTest.swift
//  EarClerics
//
//  Created by hideki on 2014/12/01.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import UIKit
import XCTest

class SoundPlayerTest: XCTestCase {
    
    var _soundPlayer = SoundPlayer()
    var _errorCode: SoundPlayerErrorCode = SoundPlayerErrorCode.NoError

    var _dispatch = DispatchUtil()
    
    override func setUp() {
        super.setUp()
        _soundPlayer = SoundPlayer()
        _errorCode = SoundPlayerErrorCode.NoError
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func voicePlayEnded() {
        println("ボイスの再生が終わったって通知来たよー＼(^o^)／")
    }
    
    func testGetAudioLevel() {
        var file = "testVoice2"
        var expectation = self.expectationWithDescription("")
        self._soundPlayer.getAudioLevel(file)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(24 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })
        
        /*
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
        expectation.fulfill()
        })*/
        self.waitForExpectationsWithTimeout(25.2, handler: nil)
    }
    
    // 複数のボイスを連続再生
    func testPlayVoices() {
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "voicePlayEnded", name: "voicePlayEnded", object: nil)
        
        var files = ["name01", "voice01", "voice02"]
        //var expectation = self.expectationWithDescription("")
        var wait = self.expectationForNotification("voicePlayEnded", object: nil, handler: nil)
        
        //_soundPlayer._voiceVolume = 0
        _soundPlayer.playVoices(files)
        //_soundPlayer.playVoicesOrg(files)
        XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
        
        delay(0.2, {
            //expectation.fulfill()
        })

        self.waitForExpectationsWithTimeout(0.4, handler: nil)
    }
    
    func testPlayVoicesNoFile() {
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "voicePlayEnded", name: "voicePlayEnded", object: nil)
        
        var files = ["存在しないファイル", "voice01"]
        var expectation = self.expectationWithDescription("")
        //var wait = self.expectationForNotification("voicePlayEnded", object: nil, handler: nil)
        
        //_soundPlayer._voiceVolume = 0
        _soundPlayer.playVoices(files)
        XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.FileNotFound, "エラーがあること")
        
        delay(4.0, {
            expectation.fulfill()
        })
        
        /*
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
        expectation.fulfill()
        })*/
        self.waitForExpectationsWithTimeout(5.2, handler: nil)
    }
    
    /*
    // 間隔をあけてボイスを再生
    func testPlayVoicesWithGap() {
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "voicePlayEnded", name: "voicePlayEnded", object: nil)
        
        var files = ["name01", "voice01", "voice02"]
        var expectation = self.expectationWithDescription("fetch posts")
        
        //_soundPlayer._voiceVolume = 0
        _soundPlayer.playVoicesWithGap(files, gap: 1.0)
        
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(10.5 * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), {
                XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
                expectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(11.0, handler: nil)
    }
    
    // 間隔をあけてボイスを再生 エラー
    func testPlayVoicesWithGapError() {
        var files = ["name01", "存在しないファイル", "voice02"]
        var expectation = self.expectationWithDescription("fetch posts")
        
        _soundPlayer.playVoicesWithGap(files, gap: 2.0)
        
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(0.5 * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), {
                XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.FileNotFound, "エラーがあること")
                expectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(1.0, handler: nil)
    }*/
    
    // 音楽が再生中か
    func testIsBgmPlaying() {
        /*
        var res = _soundPlayer.isBgmPlaying()
        XCTAssertFalse(res, "falseであること")
        
        var fileName = "きらきら星"
        _soundPlayer.playBgm(fileName, volume: 0)
        res = _soundPlayer.isBgmPlaying()
        XCTAssertTrue(res, "trueであること")
        
        _soundPlayer.stopBgm()
        res = _soundPlayer.isBgmPlaying()
        XCTAssertFalse(res, "falseであること")
*/
    }
    
    // 音声が再生中か
    func testIsVoicePlaying() {
        
        //var expectation = self.expectationWithDescription("fetch posts")
        
        XCTAssertFalse(_soundPlayer.isVoicePlaying(), "falseであること")
        
        var fileName = "name01"
        _soundPlayer.playVoice(fileName)
        XCTAssertTrue(_soundPlayer.isVoicePlaying(), "trueであること")
  
        _dispatch.after(0.5, closure: {
            self._soundPlayer.stopVoice()
            XCTAssertFalse(self._soundPlayer.isVoicePlaying(), "falseであること")
            
            var files = ["name01", "voice01"]
            self._soundPlayer.playVoices(files)
            XCTAssertTrue(self._soundPlayer.isVoicePlaying(), "trueであること")
            self._soundPlayer.stopVoice()
            XCTAssertFalse(self._soundPlayer.isVoicePlaying(), "falseであること")
            self._soundPlayer._voiceVolume = 0
            self._soundPlayer.playVoices(files)
        })
        
        _dispatch.after(0.9, closure: {
            //XCTAssertFalse(self._soundPlayer.isVoicePlaying(), "falseであること")
            //expectation.fulfill()
        })
        
        //self.waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testPlayVoice() {
        var nc :NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.addObserverForName("audioPlayerDidFinishPlaying", object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            println("audioPlayerDidFinishPlaying.")
        })
        
        var expectation = self.expectationWithDescription("fetch posts")
        
        var fileName = "name04"
        //_soundPlayer.setVoiceVolume(0)
        _soundPlayer.playVoice(fileName)
        XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.FileNotFound, "エラーがあること")
        
        fileName = "voice02"
        _soundPlayer.playVoice(fileName)
        XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
        
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(), {
                XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
                var fileName = "voice01"
                self._soundPlayer.playVoice(fileName)
                XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
        })
        
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(), {
                XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
                
                expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testStopVoice() {
        var expectation = self.expectationWithDescription("")
        
        var fileName = "voice02"
        _soundPlayer._voiceVolume = 0
        _soundPlayer.playVoice(fileName)
        XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
        
        _dispatch.delay(0.5, closure: {
            self._soundPlayer.stopVoice()
            XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
            fileName = "voice01"
            self._soundPlayer.playVoice(fileName)
        })
        
        _dispatch.delay(0.5, closure: {
            self._soundPlayer.stopVoice()
            XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testResumeVoice() {
        var expectation = self.expectationWithDescription("")
        
        var fileName = "voice02"
        _soundPlayer._voiceVolume = 0
        _soundPlayer.playVoice(fileName)
        XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
        
        _dispatch.delay(0.5, closure: {
            self._soundPlayer.pauseVoice()
            XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
        })
        
        _dispatch.delay(0.8, closure: {
            self._soundPlayer.resumeVoice()
            XCTAssertEqual(self._soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
        })
        
        _dispatch.delay(0.9, closure: {
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    // 音楽再生
    func testPlayBgm() {
        var fileName = "きらきら星"
        _soundPlayer.playBgm(fileName)
        XCTAssertEqual(_soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
        NSThread.sleepForTimeInterval(0.2)
        
        fileName = "存在しないファイル"
        _soundPlayer.playBgm(fileName)
        XCTAssertEqual(_soundPlayer.getErrorCode(), SoundPlayerErrorCode.FileNotFound, "ファイルがないこと")
        NSThread.sleepForTimeInterval(0.2)
        
        fileName = "きらきら星"
        _soundPlayer.playBgm(fileName)
        XCTAssertEqual(_soundPlayer.getErrorCode(), SoundPlayerErrorCode.NoError, "エラーがないこと")
        NSThread.sleepForTimeInterval(0.2)
    }

    /*
    func testPlayVoice() {
        var fileName = "メールが届いています"
        _soundPlayer.playVoice(fileName, volume: 0)
        NSThread.sleepForTimeInterval(0.2)
        
        fileName = "存在しないファイル"
        _soundPlayer.playVoice(fileName)
        fileName = "メールが届いています"
        _soundPlayer.playVoice(fileName, volume: 0)
        NSThread.sleepForTimeInterval(0.2)
        
        XCTAssert(true)
    }
    
    func testPlaySE() {
        var fileName = "風鈴"
        _soundPlayer.playSE(fileName, volume: 0)
        
        for i in 0...4 {
            fileName = "ころん"
            _soundPlayer.playSE(fileName, volume: 0)
            NSThread.sleepForTimeInterval(0.1)
        }
        
        fileName = "存在しないファイル"
        _soundPlayer.playSE(fileName)
        
        XCTAssert(true)
    }
    
    */
    /*
    func testExample() {
    var _soundPlayer = SoundPlayer()
    // This is an example of a functional test case.
    XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock() {
    // Put the code you want to measure the time of here.
    }
    }*/
    
}
