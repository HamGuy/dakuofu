//
//  UIButton.swift
//  dakuofu
//
//  Created by HamGuy on 9/1/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

extension UIButton{
    func hg_countDown(_ time:Int,countDownTitle:String? = nil, completion:(()->Void)?){
        backgroundColor = UIColor(decRed: 189, decGreen: 189, decBlue: 189)
        isUserInteractionEnabled = false
        let normalTitle = title(for: UIControlState())
        var countDownTime = time - 1
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        let timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue)
        timer.setTimer(start: DispatchWallTime(time: nil), interval: 1*NSEC_PER_SEC, leeway: 0)
        timer.setEventHandler {
            if countDownTime<=0{
                timer.cancel()
                DispatchQueue.main.async(execute: { [weak self] in
                    self?.setTitle(normalTitle, for: UIControlState())
                    self?.backgroundColor = UIColor.appMainColor
                    self?.isUserInteractionEnabled = true
                    completion?()
                })
            }else{
                let seconds = countDownTime % time;
                DispatchQueue.main.async(execute: {[weak self] in
                    let title = countDownTitle ?? ""
                    self?.setTitle("\(seconds)\(title)", for: UIControlState())
                })
            }
            countDownTime -= 1
        }
        timer.resume();
    }
}
