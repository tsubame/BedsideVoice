//
//  Constants.swift
//  定数定義用ファイル
//
//  Created by hideki on 2014/11/03.
//  Copyright (c) 2014年 hideki. All rights reserved.
//

// キャラクター
let CHARACTERS    = []
// デフォルトで選択されているキャラクター
let DEFAULT_CHARACTER = "雫"



// BGMのボリューム
let DEFAULT_BGM_VOLUME: Float = 0.05
// SEのボリューム
let DEFAULT_SE_VOLUME: Float = 0.5
// 音声のボリューム
let DEFAULT_VOICE_VOLUME: Float = 1.0


// モーニングコール中にBGMを流すか
//let PlAYS_BGM_IN_MN = true
//// モーニングコールのBGM
//let BGM_IN_MN = "loop_02.mp3"


// 無音用サウンド
let NOSOUND_FILE = "無音"// "autumn"//"nosound.mp3"

// ローカル通知音
//let ALARM_NOTIF_SOUND = ""
// ローカル通知メッセージ
//let ALARM_NOTIF_BODY  = "起きる時間です"
// ローカル通知アクション
//let ALARM_NOTIF_ACTION = "起動"

//　デフォルトの着信音
//let DEFAULT_RINGTONE = "着信音.mp3"
//let DEFAULT_CALL_SOUND = "着信音.mp3"
// 電話に出る音
//let RESPOND_PHONE_SE = "電話ピッ.mp3"
// 着信音のボリューム
//let DEFAULT_RINGTONE_VOLUME: Float = 0.8
// 着信音の繰り返し回数
//let RINGTONE_LOOP_COUNT = 30

//===========================================================
// トップレベルで使える関数
//===========================================================

import Foundation

// Double型を指定できる dispatch_after   etc. delay(2.0, {})

func delay(delay:Double, closure:()->()) {
/*
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
*/
}

// 乱数取得
func rand(num: Int) -> Int {
    var result:Int
    result = Int(arc4random() % UInt32(num))
    return result
}

