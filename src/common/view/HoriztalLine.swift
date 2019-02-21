//
//  HoriztalLine.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit


let positionTag = 1 // default 0 move down

class HoriztalLine: UIView{
    override func layoutSubviews(){
        super.layoutSubviews()
        if UIScreen.main.scale == 1.0{
            return
        }
        
        if height == 0.5{
            return
        }
        
        if height < 0.5{
            height = 0.5
        }else{
            let offset = height - 0.5
            y = self.tag == positionTag ? y : y + offset
            height = 0.5
        }
    }
}
