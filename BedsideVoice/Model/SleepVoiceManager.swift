//
//  SleepVoiceManager.swift
//  BedsideVoice
//
//  Created by hideki on 2014/12/07.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import Foundation
import UIKit
class SleepVoiceManager: NSObject {

    // ランダムイベントのキーの接頭辞
    let RANDOM_EVENTS_KEY_PREFIX = "r"
    
    // キャラクター
    var _charName = ""
    // 添い寝ボイスのどの段階か　セリフの大きなくくりごとに1増やす
    var _scene: Int = 0
    
    // 音声のテキストの配列
    var _texts = [String]()
    // ファイルネームの配列
    var _files: [[String]] = [[String]]()
    // それぞれの音声の時の表情
    var _faces = [String]()
    
    // 呼び出し元クラスの画像
    var _imageView: UIImageView?
    
    // 音声再生用
    var _soundPlayer = SoundPlayer()
    // jsonファイル読み込み用
    var _jsonReader = JsonReader()
    
    // エラー
    var _hasError = false
    // エラーメッセージ
    var _errorMessage: String?
    
    
    
    override init() {
        super.init()
        _charName = DEFAULT_CHARACTER
    }
    
    // 再生前の準備
    func prepareForPlayScene() {
        _files = [[String]]()
        _texts = [String]()
        _faces = [String]()
        if _scene == 0 {
            //NSNotificationCenter.defaultCenter().removeObserver(self)
            //NSNotificationCenter.defaultCenter().addObserver(self, selector: "playNextVoice:", name: "voicePlayEnded", object: nil)
            var nc :NSNotificationCenter = NSNotificationCenter.defaultCenter()
            nc.addObserverForName("voicePlayEnded", object: nil, queue: nil, usingBlock: {
                (notification: NSNotification!) in
                self.playNextVoice()
            })
            nc.addObserverForName("sceneEnded", object: nil, queue: nil, usingBlock: {
                (notification: NSNotification!) in
                self.playNextScene()
            })
        }
        
        _hasError = false
        _errorMessage = nil
    }
    
    // 最初から再生
    func play() {
        _scene = 0
        
        playNextScene() 
    }
    
    // 一時停止
    func pause() {
        _soundPlayer.pauseVoice()
    }
    
    // 再開
    func resume() {
        _soundPlayer.resumeVoice()
    }
    
    // 次のシーンを再生
    func playNextScene() {
        prepareForPlayScene()
        _scene++
        
        switch _scene {
            case 1:
                selectVoicesScene1()
                playNextVoice()
                break
            default:
                NSNotificationCenter.defaultCenter().removeObserver(self)
                break
        }
    }
    
    func playNextVoice() {
        println(_files)
        if _files.count == 0 {
            println("シーンの音声をすべて再生しました")
            NSNotificationCenter.defaultCenter().postNotificationName("sceneEnded", object: nil)
            return
        }
        
        var files: [String] = _files.removeAtIndex(0)
        var text = _texts.removeAtIndex(0)
        println(text)

        
        _soundPlayer.playVoices(files)
    }
    
    // シーン1の音声をファイルから選ぶ
    func selectVoicesScene1() {
        // ファイルからJsonデータを取得
        var json = getJsonForScene(1)
        if _hasError {
            return
        }
        
        // ランダムイベントの音声を取得
        getRandomEventVoicesFromJson(json!, scene: 1)
    }
    
    // 該当シーンのファイルからJsonデータを取得
    func getJsonForScene(scene: Int) -> JSON? {
        // ファイルからJsonデータを取得
        let fileName = "\(_charName)_添い寝_scene\(scene)"
        let json = _jsonReader.getJsonFromFile(fileName)
        
        // エラー処理
        if _jsonReader.hasError() {
            _hasError = true
            _errorMessage = _jsonReader.getErrorMessage()
        }
        
        return json
    }
    
    // ランダムイベントの音声を取得
    func getRandomEventVoicesFromJson(json: JSON, scene: Int){
        // ランダムイベントに該当する箇所のキーとデータを取り出す
        var targetValues = [String: JSON]()
        var targetKeys   = [String]()

        for (key: String, value: JSON) in json.dictionaryValue! {
            if isRandEvent(key) {
                targetValues[key] = value
                targetKeys.append(key)
            }
        }
        
        // ランダムでキーを選択
        var index = rand(targetKeys.count)
        var selectedKey = targetKeys[index]
        // 該当キーのテキスト配列を取り出す
        var texts = targetValues[selectedKey]?.arrayValue
        if texts == nil {
            _hasError = true
            _errorMessage = "=== Error === おそらく書式エラーだと思われます"
            println(_errorMessage)
            return
        }
        
        // インスタンス変数へ値をセット
        setInstanceVar(scene, key: selectedKey, texts: texts!)
    }
    
    // インスタンス変数に値をセット
    func setInstanceVar(scene: Int, key: String, texts: [JSON]) {
        
        for i in 0..<texts.count {
            var dict = [String: String]()
            // ファイル番号を取得 01から始まる2桁の文字列
            var fileNum = i + 1
            var numStr = "\(fileNum)"
            if fileNum < 10 {
                numStr = "0\(fileNum)"
            }
            // ファイル名
            var file = "\(_charName)_s\(scene)_\(key)_\(numStr)"
            var text = texts[i].stringValue!
            var face = getFaceFromTextWithTag(&text)
            var files = getVoiceFilesFromTextWithName(&text, file: file)
            
            _files.append(files)
            _texts.append(text)
            _faces.append(face)
        }
    }
    
    //　名前付きテキストからボイスファイルの配列を取得。ついでにテキストからタグ削除
    func getVoiceFilesFromTextWithName(inout text: String, file: String) -> [String] {
        var files = [String]()
        let pattern: String = "【名前.+?】"
        
        //　【名前 ...】の部分を正規表現で検索
        var tagMatch = (text as NSString).rangeOfString(pattern, options: .RegularExpressionSearch)
        if 0 < tagMatch.length {
            let tagStr   = (text as NSString).substringWithRange(tagMatch) as NSString
            // 番号を取得して名前ファイル名を決定
            let numMatch = tagStr.rangeOfString("\\d+", options: .RegularExpressionSearch)
            let numStr   = tagStr.substringWithRange(numMatch)
// ↓の部分は設定情報から取得する必要あり
    var name = "お兄様"
            var nameFile = "\(_charName)_name_\(name)_\(numStr)"

            if tagMatch.location == 0 {
                files.append(nameFile)
                files.append(file)
            } else {
                files.append(file)
                files.append(nameFile)
            }
            
            // タグ内の括弧部分だけをテキストに反映
            var nameStrMatch = tagStr.rangeOfString("\\(.+\\)", options: .RegularExpressionSearch)
            if 0 < nameStrMatch.length {
                // 括弧の中身を取得
                var nameStrWithPar = tagStr.substringWithRange(nameStrMatch)
                var nameStr = (nameStrWithPar as NSString).substringWithRange(NSRange(location: 1, length: nameStrWithPar.utf16Count - 2))
                text = text.stringByReplacingOccurrencesOfString(tagStr, withString: nameStr, options: nil, range: nil)
            }
        } else {
            files.append(file)
        }
        
        return files
    }
    
    // テキストから【表情:】タグを取り出して文字列で返す
    func getFaceFromTextWithTag(inout text: String) -> String {
        var face = "通"
        if 0 < _faces.count {
            face = _faces[_faces.count - 1]
        }
        let pattern: String = "【表情[^】]+?】"
        //　【表情 ...】の部分を正規表現で検索
        var tagMatch = (text as NSString).rangeOfString(pattern, options: .RegularExpressionSearch)
        if 0 < tagMatch.length {
            let tagStr = (text as NSString).substringWithRange(tagMatch) as NSString
            // 表情: の後を取得
            face = tagStr.substringWithRange(NSRange(location: 4, length: 1))
            // タグ削除
            text = text.stringByReplacingOccurrencesOfString(tagStr, withString: "", options: nil, range: nil)
        }
        
        return face
    }
    
    // 音声テキストの配列から辞書型の配列を返す
    func voiceTextToDict(scene: Int, key: String, texts: [JSON]) -> [[String: String]] {
        var voiceDicts = [[String: String]]()
        
        for i in 0..<texts.count {
            var dict = [String: String]()
            // 数字を2桁の文字列に
            var num = i + 1
            var numStr = "\(num)"
            if num < 10 {
                numStr = "0\(num)"
            }
            // ファイル名
            dict["file"] = "\(_charName)_s\(scene)_\(key)_\(numStr)"
            dict["text"] = texts[i].stringValue!
            dict["face"] = "通"
            
            voiceDicts.append(dict)
        }
        
        return voiceDicts
    }
    
    // ランダムイベントのキーかどうかを判定
    func isRandEvent(key: String) -> Bool {
        // キーの接頭辞1文字を取り出す
        var prefix = (key as NSString).substringToIndex(RANDOM_EVENTS_KEY_PREFIX.utf16Count)
        
        if prefix == RANDOM_EVENTS_KEY_PREFIX {
            return true
        }
        
        return false
    }
    
    
    
    
    // 呼び名付きのボイスを再生
    func playVoiceWithName(files: [String]) {
        
    }
    
    // キャラ名を設定
    func setCharaName(chara: String) {
        _charName = chara
    }
    
    // エラー
    func hasError() -> Bool {
        return _hasError
    }
    
    func getNextVoice() {
        
    }
    
    func buildVoice() {
        
    }
    
    func buildVoicePhase1() {
        
    }
    
    
    func buildVoiceAboutSound() {
    
    }
    
    deinit {
        //println("observer開放")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}