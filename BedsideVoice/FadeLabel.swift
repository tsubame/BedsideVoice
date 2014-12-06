//
//  FadeLabel.swift
//  EarClerics
//
//  Created by hideki on 2014/11/17.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import Foundation
import UIKit

class FadeLabel: UILabel {
    
    // 次の文字を表示するまでの時間
    let DELAY_TIME = 0.025
    // 1文字がフェードインする時間
    let CHAR_FADE_DURATION = 0.8
    
    // 1文字ずつ表示するためのラベルの配列
    var _charLabels = [UILabel]()
    // ラベルの配列を作成済みか
    var _existsCharLabels = false
    // 行と行の間隔
    var _lineSpace: CGFloat = 4
    
    // メッセージを表示し終わっているか
    var _isMessageEnd = true
    // 表示中のテキストのID　次のテキスト表示時に1増える
    var _textId = 0
    
    
    // 初期化
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.userInteractionEnabled = true
    }
    
    
    // フェードしながらテキストを表示
    func showTextWithFade(text: String) {
        if !_existsCharLabels {
            makeCharLabels()
        }
        // 表示中の文字列を削除
        clearLabelsText()
        if !_isMessageEnd {
            cancelText()
        }
        
        _isMessageEnd = false
        _textId++
        let textID = _textId
        
        // 文字列を分解して文字の配列に
        var chars = stringToChars(text)
        
        for (index, label) in enumerate(_charLabels) {
            if chars.count <= index {
                break
            }
            
            var char = chars[index]
            var delayTime = Double(index) * DELAY_TIME + 0.06
            delay(delayTime, {
                self.showCharWithFade(index, char: char, text: text, textId: textID)
            })
        }
    }
    
    // 1つのラベルに1つの文字をフェード表示
    func showCharWithFade(index: Int, char: Character, text: String, textId: Int) {
        
        var label = _charLabels[index]
        UIView.transitionWithView(label,
            duration: CHAR_FADE_DURATION,
            options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations: {
                if self._textId == textId {
                    label.hidden = false
                    label.text = String(char)
                } else {
                    label.hidden = true
                    label.text = ""
                }
            },
            completion: {
                finished in
                // 文字列の最後を表示、またはラベルの最後まで達したら終了
                if countElements(text) <= index + 1 || self._charLabels.count <= index + 1 {
                    self._isMessageEnd = true
                }
        })
    }
    
    // テキストを文字に分解して配列に
    func stringToChars(text: String) -> Array<Character>{
        var chars = [Character]()
        for ch in text {
            chars.append(ch)
        }
        
        return chars
    }
    
    // ラベルのテキストをすべて消去
    func clearLabelsText() {
        for (index, label) in enumerate(_charLabels) {
            label.hidden = true
            label.text = ""
        }
    }
    
    // テキストの表示をキャンセルする
    func cancelText() {
        //println("canceled.")
        _isMessageEnd = true

        NSThread.sleepForTimeInterval(0.05)
    }
    
    // ラベルの配列を作成
    func makeCharLabels() {
        _existsCharLabels = true
        
        _lineSpace = self.font.pointSize / 3

        // 1行に入る文字数
        let charCountInLine = Int(floor(self.bounds.width / self.font.pointSize))
        
        self.text = ""
        
        for i in 0..<self.numberOfLines  {
            for j in 0..<charCountInLine {
                
                var x = CGFloat(j) * self.font.pointSize
                var y = CGFloat(i) * self.font.pointSize + _lineSpace * CGFloat(i)
                var label = makeLabel(CGPointMake(x, y), text: "■", font: self.font)
                
                _charLabels.append(label)
                self.addSubview(label)
            }
        }
    }
    
    // 1つのラベルを作成
    func makeLabel(pos: CGPoint, text: NSString, font: UIFont) -> UILabel {
        let label = UILabel()
        label.frame = CGRectMake(pos.x, pos.y, 9999, 9999)
        label.text = text
        label.font = font
        label.textAlignment = NSTextAlignment.Center
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        label.sizeToFit()
        
        return label
    }
}