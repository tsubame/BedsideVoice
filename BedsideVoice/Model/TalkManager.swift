//
//  TalkManager.swift
//  EarClerics
//
//  Created by hideki on 2014/12/05.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import Foundation
class TalkManager: NSObject {

    var _charName: String = "charA"
    
    var _messages  = [String]()
    var _fileNames = [String]()
    var _faces = [String]()
    
    var _hasError = false
    
    // 挨拶の配列の中に入っている文字列の数 2つ
    let VALUECOUNT_IN_GREET = 2
    
    // 挨拶ファイルに付いているファイル名　キャラ名 ＋ ↓ になる
    let GREETING_FILE_SUFFIX = "_greeting"
    
    override init() {
        super.init()
        _hasError = false
        _messages  = [String]()
        _fileNames = [String]()
        _faces = [String]()
    }
    
    // 挨拶
    func greeting() {

    }
    
    // 雑談
    func chat() {
    
    }
    
    //
    func varReset() {
        _hasError = false
        _messages  = [String]()
        _fileNames = [String]()
        _faces = [String]()
    }
    
    // 挨拶データをJsonファイルから取得
    func getGreetingMsg() {
        var timeStr = getTimeStrFromDate(NSDate())
        getGreetingMsgFromTimestr(timeStr)
    }
    
    // 挨拶データをJsonファイルから取得
    func getGreetingMsgFromTimestr(timeStr: String) {
        varReset()
        // JSONデータを取得
        let json = getJsonFromFile()
        // 時間別の挨拶のJSON取得
        var greetingsInTime = json[timeStr].dictionaryValue
        
        if greetingsInTime == nil {
            println("Jsonの書式おかしいかも？(´・ω・`)")
            _hasError = true
            return
        }
        
        // 乱数取得
        var randIndex = rand(greetingsInTime!.count)

        var index = 0
        for (key: String, greetingsJson: JSON) in greetingsInTime! {
            // 挨拶の候補からランダムで選ぶ
            if index == randIndex {
                // 配列に入れる
                appendGreetToArray(greetingsJson, key: key, timeStr: timeStr)
            }
            
            index++
        }
    }
    
    func appendGreetToArray(selectedJson: JSON, key: String, timeStr: String) {
        let selectedGreets: Array = selectedJson.arrayValue!
        // 選択した挨拶を配列に入れる
        for j in 0..<selectedGreets.count {
            var greet = selectedGreets[j]
            var count = greet.arrayValue?.count
            
            if VALUECOUNT_IN_GREET != count! {
                _hasError = true
                println("書式おかしいかも？(´・ω・`)")
                return
            }
            
            var msg  = greet[0].stringValue!
            var face = greet[1].stringValue!
            var fileName = _charName + "_greeting_" + timeStr + "_" + key + "_\(j)"
            _messages.append(msg)
            _faces.append(face)
            _fileNames.append(fileName)
        }
    }
    
    // 構文チェック 1つの挨拶の配列
    func SyntaxCheckInGreeting(greet: JSON) {

    }
    
    func getJsonFromFile() ->JSON {
        // Jsonファイル名設定
        let fileName = _charName + GREETING_FILE_SUFFIX
        
        let path : String = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")!
        let jsonData = NSData(contentsOfFile: path)
        let json = JSON(data: jsonData!)
        
        return json
    }
    
    // 時間をわたして昼とか夜とか返す
    func getTimeStrFromDate(date: NSDate) -> String {
        let flags =
            NSCalendarUnit.YearCalendarUnit |
            NSCalendarUnit.MonthCalendarUnit |
            NSCalendarUnit.DayCalendarUnit |
            NSCalendarUnit.HourCalendarUnit
        
        let cal   = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        let comps = cal.components(flags, fromDate: date)
        
        var hour: Int = comps.hour
//println(hour)
        // 早朝
        if 4 <= hour && hour <= 6 {
            return "早朝"
        } else if 7 <= hour && hour <= 11 {
            return "朝"
        } else if 12 <= hour && hour <= 17 {
            return "昼"
        } else if 18 <= hour && hour <= 22 {
            return "夜"
        } else if 23 <= hour || hour <= 3 {
            return "深夜"
        }
        
        return ""
    }
    
    // 乱数取得
    func rand(num: Int) -> Int {
        var result:Int
        result = Int(arc4random() % UInt32(num))
        return result
    }
    /*
    // 時刻のみを文字列で取り出す
    func getTimeStrFromDate(date: NSDate) -> String {
        let fmt = NSDateFormatter()
        fmt.locale = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
        fmt.dateFormat = "HH:mm"
        var timeStr   = fmt.stringFromDate(date) //"\(comps.hour):\(comps.minute)"
        
        return timeStr
    }*/
    
    // 1分後の時刻を文字列形式で取得　"07:16" 24時は00時に
    func getNextMinuteTimeStr() -> String {
        let flags =
        NSCalendarUnit.YearCalendarUnit |
            NSCalendarUnit.MonthCalendarUnit |
            NSCalendarUnit.DayCalendarUnit |
            NSCalendarUnit.HourCalendarUnit |
            NSCalendarUnit.MinuteCalendarUnit
        let cal   = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        let comps = cal.components(flags, fromDate: NSDate())
        
        var hour   = comps.hour
        var minute = comps.minute + 1
        var minuteStr = "\(minute)"
        
        // 1桁なら0を先頭に
        if minute < 10 {
            minuteStr = "0\(minute)"
            // 1分後が60分の時の処理
        } else if minute == 60 {
            minuteStr = "00"
            if hour != 23 {
                hour++
            } else {
                hour = 0
            }
        }
        
        var hourStr = "\(hour)"
        // 1桁なら0を先頭に
        if hour < 10 {
            hourStr = "0\(hour)"
        }
        
        return "\(hourStr):\(minuteStr)"
    }
    
    // Jsonファイルの構文のチェック
    func testCheckJsonSyntax() {
        /*
        // This is an example of a functional test case.
        //XCTAssert(true, "Pass")
        
        let path : String = NSBundle.mainBundle().pathForResource("greeting", ofType: "json")!
        var jsonData = NSData(contentsOfFile: path)
        let json = JSON(data: jsonData!)
        println(json)
        
        let jsonDict: Dictionary = JSON(data: jsonData!).dictionaryValue!
        println(jsonDict.count)

        if (jsonDict["朝"] != nil) {
            println("朝はある")
        }
        
        if (jsonDict["昼間"] != nil) {

        } else {
            println("昼間はない")
        }
        
        for (key: String, subJson: JSON) in jsonDict {
            //Do something you want
            println(key)
        }

        let jsonArray = JSON(data: jsonData!).arrayValue
        println(jsonArray)
*/
    }
    
    func hasError() -> Bool {
        return _hasError
    }
    
}