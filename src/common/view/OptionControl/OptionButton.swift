//
//  FilterButton.swift
//  dakuofu
//
//  Created by HamGuy on 9/2/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

struct OptionItem{
    let title: String
    let iconName: String
    let datSources: [String]
    var defultIndex: Int
    let optionType: Int
    
    init(title:String, icon:String, datas:[String], defaultSelectIndex: Int = -1, optionType: Int = 0){
        self.title = title
        self.iconName = icon
        self.datSources = datas
        self.defultIndex = defaultSelectIndex
        self.optionType = optionType
    }
}

