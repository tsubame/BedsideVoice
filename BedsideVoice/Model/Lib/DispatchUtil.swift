//
//  DispatchUtil.swift
//  BedsideVoice
//
//  Created by hideki on 2014/12/10.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import Foundation
class DispatchUtil: NSObject {

    override init() {
        super.init()
    }
    
    func delay(delay:Double, closure:()->()) {
        
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure
        )
    }
    
    // dispatch_afterの改良 秒数にDoubleを指定できる
    func after(delay:Double, closure:()->()) {
        
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure
        )
    }
}