//
//  RoomViewController.swift
//  BedsideVoice
//
//  Created by hideki on 2014/12/18.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import Foundation
import UIKit
class RoomViewController: UIViewController {
    
    var _charImageView: UIImageView?

    var _charFiles = [
        "着物女性_通.png",
        "着物女性_通_e1.png",
        "着物女性_通_e2.png"
    ]
    
    var _ripSyncFiles = [
        "着物女性_通.png",
        //"着物女性_通_m1.png",
        "着物女性_通_m2.png"
    ]
    
    var _winkTimer: NSTimer?
    let _winkTimerInterval = 0.5
    let _winkMinInterval   = 3.0
    var _secondFromLastWink = 0.0
    
    var _ripSyncTimer: NSTimer?
    var _ripSyncFileIndex = 0
    
    var _svm = SleepVoiceManager()
    
    func showChar() {
        _charImageView = makeImageView(CGRectMake(40, 0, 288, 600), image: UIImage(named: _charFiles[0])!)
        self.view.addSubview(_charImageView!)
    }
    
    // UIImageViewの生成
    func makeImageView(frame: CGRect, image: UIImage) -> UIImageView {
        let imageView = UIImageView()
        imageView.frame = frame
        imageView.image = image
        
        return imageView
    }
    
    //
    func startWinkTimer(imageView: UIImageView) {
        //_winkTimer = NSTimer.scheduledTimerWithTimeInterval(ti, target: self, selector: "wink", userInfo: nil, repeats: true)
        _winkTimer = NSTimer.scheduledTimerWithTimeInterval(_winkTimerInterval, target: NSBlockOperation({
            self.wink(imageView)
        }), selector: "main", userInfo: nil, repeats: true)
    }
    
    func wink(imageView: UIImageView) {
        _secondFromLastWink += _winkTimerInterval
        
        let randNum = 6
        
        if _winkMinInterval < _secondFromLastWink {
            //println("ウィンクするか判定")
            
            if _ripSyncTimer != nil {
                //_secondFromLastWink = 0.0
                return
            }
            
            if rand(randNum) == 0 {
                //println("ウィンク処理")
                _secondFromLastWink = 0.0
                imageView.image = UIImage(named: self._charFiles[1])
                delay(0.05, {
                    imageView.image = UIImage(named: self._charFiles[2])
                })
                delay(0.35, {
                    imageView.image = UIImage(named: self._charFiles[1])
                })
                delay(0.4, {
                    imageView.image = UIImage(named: self._charFiles[0])
                })
            }
        }
    }
    
    var _isTalking = false
    
    func ripSync() {
        var sPlayer = _svm._soundPlayer
        var threshold: Float = 120.0
        if _isTalking {
            threshold = 135.0
        }
        if sPlayer.isTalkingVoiceLevel(threshold: threshold) {
            //println("口パク処理")
            var index = 0
            while(true) {
                index = rand(_ripSyncFiles.count)
                if index != _ripSyncFileIndex {
                    break
                } else {
                    if index != 0 {
                        if rand(2) == 0 {
                            //break;
                        }
                    }
                }
            }
            _ripSyncFileIndex = index
            _charImageView?.image = UIImage(named: _ripSyncFiles[index])
            
            _isTalking = true
        } else {
            _charImageView?.image = UIImage(named: _ripSyncFiles[0])
            _isTalking = false
        }
    }
    
    //===========================================================
    // UI
    //===========================================================
    override func viewDidLoad() {
        super.viewDidLoad()

        showChar()
        startWinkTimer(_charImageView!)
        
        NSNotificationCenter.defaultCenter().addObserverForName("voicePlayStarted", object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            if self._ripSyncTimer == nil {
                println("口パク処理スタート")
                self.ripSync()
                self._ripSyncTimer = NSTimer.scheduledTimerWithTimeInterval(0.15, target: self, selector: "ripSync", userInfo: nil, repeats: true)
            }
        })
        NSNotificationCenter.defaultCenter().addObserverForName("voicePlayEnded", object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            println("口パク処理終了")
            self._charImageView?.image = UIImage(named: self._ripSyncFiles[0])
            self._ripSyncTimer?.invalidate()
            self._ripSyncTimer = nil
        })
        _svm.play()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self._ripSyncTimer?.invalidate()
        self._ripSyncTimer = nil
        
        _svm.play()
    }
    
}