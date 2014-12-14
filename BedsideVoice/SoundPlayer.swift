//
//  SoundPlayer.swift
//  TamiTami
//
//  Created by hideki on 2014/11/02.
//  Copyright (c) 2014年 hideki. All rights reserved.
//

import Foundation
import AVFoundation

enum SoundPlayerErrorCode:Int {
    case NoError
    case FileNotFound
}

public class SoundPlayer: NSObject, AVAudioPlayerDelegate {

    // 音声再生用
    //var _voicePlayer: AVAudioPlayer?
    
    // BGM再生用
    var _bgmPlayer: AVAudioPlayer?
    // 複数音声再生用キュー
    var _queuePlayer: AVQueuePlayer?
    // 音声再生用
    var _voicePlayer: AVAudioPlayer?
    
    // SE再生用
    var _sePlayers = [AVAudioPlayer]()
    // 無音再生用
    var _nosoundPlayer: AVAudioPlayer?
    
    // 複数のボイスを連続再生する際のキュー
    var _voiceQue = [String]()
    
    // エラーメッセージ
    var _errorMessage: String = ""
    // エラーコード
    var _errorCode: SoundPlayerErrorCode = SoundPlayerErrorCode.NoError
    
    // 音量
    var _voiceVolume: Float = 1.0
    //
    var _bgmVolume: Float   = 0.05
    //
    var _seVolume: Float    = 0.5
    
    // 音声ファイルの拡張子が無い場合に付ける拡張子
    let SOUND_SUFFIXES = [".mp3", ".m4a", ".wav", ".aiff"]
    
    // 無音用サウンド
    let NOSOUND_FILE = "無音"

    

    
    
    override init() {
        super.init()
    }
    
    
    // 音声のボリューム設定
    func setVoiceVolume(volume: Float) {
        _voiceVolume = volume
    }
    
    // 音楽のボリューム設定
    func setBgmVolume(volume: Float) {
        _bgmVolume = volume
    }
    
    // SEのボリューム設定
    func setSeVolume(volume: Float) {
        _seVolume = volume
    }
    
    // 単一の音声を再生
    func playVoice(fileName: String) {
        _voicePlayer = makeAudioPlayer(fileName)
        if _voicePlayer == nil {
            audioPlayerDidFinishPlaying(_voicePlayer, successfully: false)
            return
        }
        
        _voicePlayer?.delegate = self
        _voicePlayer?.volume = _voiceVolume
        _voicePlayer?.meteringEnabled = true
        _voicePlayer?.play()
    }
    
    // 複数の音声を連続再生 音声間の間隔を開けない
    func playVoices(files: [String]) {
        println("次の音声を再生します。 \(files)")
        _voiceQue = files
        var file = _voiceQue.removeAtIndex(0)
        playVoice(file)
    }
    
    func playVoicesOrg(files: [String]) {
        _queuePlayer = makeAVQuePlayer(files)

        // 全ての再生終了時に実行
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: _queuePlayer?.items().last, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            
            self._queuePlayer?.removeAllItems()
            // 通知発行
            NSNotificationCenter.defaultCenter().postNotificationName("voicePlayEnded", object: nil)
        })
        
        _queuePlayer?.volume = _voiceVolume
        _queuePlayer?.play()
        
        println("次の音声を再生します。 \(files)")
    }
    
    // 音声レベルを取得
    func getVoiceLevel() -> Float {
        _voicePlayer?.updateMeters()
        var cTmp = _voicePlayer?.numberOfChannels
        var channels = cTmp!
        
        var tmp = self._voicePlayer?.averagePowerForChannel(0)
        var avLevel = tmp! +  160.0
        
        return avLevel
    }
    
    // 口パク用 音声レベルが一定以上かを判定
    func isTalkingVoiceLevel(threshold: Float = 130.0) -> Bool {
        var level = getVoiceLevel()
        if threshold < level {
            return true
        }
        
        return false
    }
    
    // 音声の停止
    func stopVoice() {
        if _queuePlayer != nil {
            _queuePlayer?.pause()
            _queuePlayer?.removeAllItems()
        }
    }
    
    // 音声を一時停止
    func pauseVoice() {
        println("音声を一時停止します")
        
        if _queuePlayer != nil {
            _queuePlayer?.pause()
        }
    }
    
    // 音声を一時停止から再開
    func resumeVoice() {
        println("音声を再開します")
        
        if _queuePlayer != nil {
            _queuePlayer?.play()
        }
    }
    
    // 音声が再生中か
    func isVoicePlaying() -> Bool{
        /*
        if _queuePlayer == nil {
            return false
        }
        
        var itemCount: Int? = _queuePlayer?.items().count
        if itemCount != nil {
            if 0 < itemCount! {
                return true
            }
        }
        return false
        */
        if _voicePlayer == nil {
            return false
        }
        if 0 < _voiceQue.count {
            return true
        }
        
        let isPlaying = _voicePlayer?.playing
        
        return isPlaying!
    }
    
    
    // 音楽の再生 ファイル名のみ指定
    func playBgm(fileName: String) {
        playBgm(fileName, volume: _bgmVolume)
    }
    
    // 音楽の再生 ファイル名、音量を指定
    func playBgm(fileName: String, volume: Float) {
        playBgm(fileName, volume: volume, numberOfLoops: 999)
    }
    
    // 音楽の再生 ファイル名、音量、繰り返し回数を指定
    func playBgm(fileName: String, volume: Float, numberOfLoops: Int) {
        if isBgmPlaying() {
            println("　BGM再生中のため、停止します")
            _bgmPlayer?.stop()
        }
        
        _bgmPlayer = makeAudioPlayer(fileName)
        if _errorCode != SoundPlayerErrorCode.NoError {
            return
        }
        
        _bgmPlayer?.numberOfLoops = numberOfLoops
        _bgmPlayer?.volume = volume
        //_bgmPlayer?.prepareToPlay()
        println("　BGMを再生します: " + fileName)
        _bgmPlayer?.play()
    }
    
    // 音楽が再生中か
    func isBgmPlaying() -> Bool {
        if _bgmPlayer? == nil {
            return false
        }
        
        let isPlaying = _bgmPlayer?.playing
        
        return isPlaying!
    }
    
    // 音楽の再生
    func stopBgm() {
        if (_bgmPlayer?.playing != nil) {
            println("　BGMを停止します")
            _bgmPlayer?.stop()
        }
    }

    
    // SEの再生 ファイル名を指定
    func playSE(fileName: String) {
        playSE(fileName, volume: _seVolume)
    }
    
    // SEの再生 ファイル名、音量を指定
    func playSE(fileName: String, volume: Float) {
        let sePlayer = makeAudioPlayer(fileName)
        if _errorCode != SoundPlayerErrorCode.NoError {
            return
        }
        
        // SEの配列から再生中でないものを削除
        if !_sePlayers.isEmpty {
            for var i = _sePlayers.count - 1; 0 <= i ; i-- {
                if !_sePlayers[i].playing {
                    _sePlayers.removeAtIndex(i)
                    //println("SEを配列から削除しました インデックス:\(i)")
                }
            }
        }
        // 配列に追加
        _sePlayers.append(sePlayer!)
        //println("SEを配列に追加しました インデックス:\(_sePlayers.count - 1)")

        // SE再生
        sePlayer?.numberOfLoops = 0
        sePlayer?.currentTime = 0
        sePlayer?.volume = volume
        sePlayer?.prepareToPlay()
        sePlayer?.play()
    }
    
    // 無音ファイルを再生
    func playNoSound() {
        _nosoundPlayer = makeAudioPlayer(NOSOUND_FILE)
        
        if !(_nosoundPlayer?.playing != nil) {
            _nosoundPlayer?.numberOfLoops = 2000
            _nosoundPlayer?.currentTime   = 0
            _nosoundPlayer?.volume = 0.01
            _nosoundPlayer?.play()
        }
    }
    
    // 無音ファイルを停止
    func stopNoSound() {
        if (_nosoundPlayer?.playing != nil) {
            _nosoundPlayer?.stop()
        }
    }
    
    
    // 音声を連続で再生 音声間の間隔を開ける
    func playVoicesWithGap(files: [String], gap: Double) {
        _queuePlayer = makeAVQuePlayer(files)
        if _errorCode != SoundPlayerErrorCode.NoError {
            return
        }
        
        // オブザーバー登録 1ファイルの再生が終了するごとに呼ばれる
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            self.playNextVoiceAfterGap(gap)
        })
        
        _queuePlayer?.volume = _voiceVolume
        //_queuePlayer?.actionAtItemEnd = AVPlayerActionAtItemEnd.Advance
        _queuePlayer?.play()
    }
    
    // キュー内の音声を再生し終えたことを通知
    func postNotifVoicePlayEnded() {
        println("音声の再生が全部終了")
        self._queuePlayer?.removeAllItems()
        NSNotificationCenter.defaultCenter().postNotificationName("voicePlayEnded", object: nil)
    }
    
    // ギャップ演出用 キューが1つ進むごとに呼ばれる
    func playNextVoiceAfterGap(gap: Double) {
        println("キュー内の音声の再生が1つ終了。\(gap)秒、間隔をあけます")
        // 一時停止
        _queuePlayer?.pause()
        
        var dispatch = DispatchUtil()
        // 一定秒後に再生を再開
        dispatch.after(gap, {
            self._queuePlayer?.play()
            
            if self._queuePlayer?.currentItem == nil {
                self.postNotifVoicePlayEnded()
            }
        })
    }

    var timer: NSTimer?
    var tl = 0.0
    var ti = 0.05
    
    func getAudioLevel(fileName: String) {
        var error: NSError?
        //AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error)
        _voicePlayer = makeAudioPlayer(fileName)
        _voicePlayer?.meteringEnabled = true
        _voicePlayer?.play()

        //println(_bgmPlayer?.numberOfChannels)
        
        //_queuePlayer?.
        
        timer = NSTimer.scheduledTimerWithTimeInterval(ti, target: self, selector: "monitorVoiceLevel:", userInfo: nil, repeats: true)
        
        delay(21.0, {
            self.timer?.invalidate()
            self.timer = nil
        })
    }
    
    func monitorVoiceLevel(timer: NSTimer) {
        self._voicePlayer?.updateMeters()
        var cTmp = _voicePlayer?.numberOfChannels
        var channels = cTmp!
        
        var tmp = self._voicePlayer?.averagePowerForChannel(0)
        var avLevelL = tmp! +  160.0
        tmp = self._voicePlayer?.averagePowerForChannel(1)
        var avLevelR = tmp! +  160.0
        
        var threshold: Float = 130.0
        
        if avLevelL < threshold && avLevelR < threshold {
            println("L: \(avLevelL) R: \(avLevelR) ========= ")
        } else {
            println("L: \(avLevelL) R: \(avLevelR) ")
        }
        
        tl += ti

        /*
        for i in 0..<channels {
            var tmp = self._voicePlayer?.peakPowerForChannel(i)
            var avLevel = tmp! +  160.0
            println("ch\(i): \(avLevel)")
        }*/
    }
    
    
    // エラーメッセージを返す
    func getErrorMessage() -> String? {
        return _errorMessage
    }
    
    // エラーコードを返す
    func getErrorCode() -> SoundPlayerErrorCode {
        return _errorCode
    }
    
    // ファイル名に拡張子を補う
    func supplySuffix(fileName: String) -> String {
        // 拡張子があるか？
        var loc = (fileName as NSString).rangeOfString(".").location
        if loc == NSNotFound {
            for suffix in SOUND_SUFFIXES {
                var fileNameWithSuffix = fileName + suffix
                var path = NSBundle.mainBundle().pathForResource(fileNameWithSuffix, ofType: "")
                
                if path != nil {
                    //println("拡張子" + suffix + "を追加しました")
                    return fileNameWithSuffix
                }
            }
        }
        
        return fileName
    }
    
    // ファイル名を受け取り、AVAudioPlayerのインスタンスを返す。
    func makeAudioPlayer(res:String) -> AVAudioPlayer? {
        // 拡張子を補う
        let fileName = supplySuffix(res)
        
        // ファイルがなければnilを返す
        var path = NSBundle.mainBundle().pathForResource(fileName, ofType: "")
        if path == nil {
            _errorCode = SoundPlayerErrorCode.FileNotFound
            _errorMessage += "=== error! === ファイルがありません！: " + fileName + "\n"
            println(_errorMessage)

            return nil
        }
        //_errorCode = SoundPlayerErrorCode.NoError
        //_errorMessage = nil
        let url  = NSURL.fileURLWithPath(path!)

        return AVAudioPlayer(contentsOfURL: url, error: nil)
    }
    
    // ファイル名の配列を受け取り、AVQueuePlayerのインスタンスを返す。
    func makeAVQuePlayer(files:[String]) -> AVQueuePlayer? {
        var items = [AVPlayerItem]()
        _errorCode    = SoundPlayerErrorCode.NoError
        //_errorMessage = ""
        
        for fileName in files {
            // 拡張子を補う
            var fullFileName = supplySuffix(fileName)
            
            // ファイルがなければnilを返す
            var path = NSBundle.mainBundle().pathForResource(fullFileName, ofType: "")
            if path == nil {
                _errorCode = SoundPlayerErrorCode.FileNotFound
                _errorMessage += "=== error! === ファイルがありません！: " + fileName + "\n"
                println(_errorMessage)
                
                continue
                //return nil
            }

            let url  = NSURL.fileURLWithPath(path!)
            let item = AVPlayerItem(URL: url)
            items.append(item)
        }
        
        return AVQueuePlayer(items: items)
    }
    
    //===========================================================
    // AVAudioPlayerDelegate
    //===========================================================
    
    public func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("audioPlayerDidFinishPlaying.")
        if _voicePlayer == player {
            if _voiceQue.count == 0 {
                println("ボイスキューの再生が終わりました。")
                NSNotificationCenter.defaultCenter().postNotificationName("voicePlayEnded", object: nil)
            } else {
                var file = _voiceQue.removeAtIndex(0)
                playVoice(file)
            }
        }
    }
    
}