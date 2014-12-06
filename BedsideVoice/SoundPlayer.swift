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

public class SoundPlayer: NSObject {

    // 音声再生用
    var _voicePlayer: AVAudioPlayer?
    // BGM再生用
    var _bgmPlayer: AVAudioPlayer?
    // SE再生用
    var _sePlayers = [AVAudioPlayer]()
    // 無音再生用
    var _nosoundPlayer: AVAudioPlayer?
    // エラーメッセージ
    var _errorMessage: String?
    // エラーコード
    var _errorCode: SoundPlayerErrorCode = SoundPlayerErrorCode.NoError
    
    // BGMのボリューム
    let DEFAULT_BGM_VOLUME: Float = 0.05
    // SEのボリューム
    let DEFAULT_SE_VOLUME: Float = 0.5
    // ボイスのボリューム
    let DEFAULT_VOICE_VOLUME: Float = 1.0
    
    // 音声ファイルの拡張子が無い場合に付ける拡張子
    let SOUND_SUFFIXES = [".mp3", ".m4a", ".wav", ".aiff"]
    
    // 無音用サウンド
    let NOSOUND_FILE = "無音"

    override init() {
        super.init()
    }
    
    // 音楽の再生 ファイル名のみ指定
    func playBgm(fileName: String) {
        playBgm(fileName, volume: DEFAULT_BGM_VOLUME)
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
        
    // ボイスの再生 ファイル名を指定
    func playVoice(fileName: String) {
        playVoice(fileName, volume: DEFAULT_VOICE_VOLUME)
    }
    
    // ボイスの再生 ファイル名、音量を指定
    func playVoice(fileName: String, volume: Float) {
        // ボイスが再生中なら停止
        if isVoicePlaying() {
            stopVoice()
        }
        _voicePlayer = makeAudioPlayer(fileName)
        if _errorCode != SoundPlayerErrorCode.NoError {
            return
        }
        _voicePlayer?.numberOfLoops = 0
        _voicePlayer?.volume = volume
        _voicePlayer?.play()
    }
    
    // ボイスの停止
    func stopVoice() {
        if !isVoicePlaying() {
            _voicePlayer?.stop()
        }
    }
    
    // ボイスが再生中か
    func isVoicePlaying() -> Bool{
        if (_voicePlayer?.playing != nil) {
            return true
        }
        
        return false
    }
    
    // SEの再生 ファイル名を指定
    func playSE(fileName: String) {
        playSE(fileName, volume: DEFAULT_SE_VOLUME)
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
            _errorMessage = "=== error! === ファイルがありません！: " + fileName
            println(_errorMessage!)

            return nil
        }
        _errorCode = SoundPlayerErrorCode.NoError
        _errorMessage = nil
        let url  = NSURL.fileURLWithPath(path!)

        return AVAudioPlayer(contentsOfURL: url, error: nil)
    }
}