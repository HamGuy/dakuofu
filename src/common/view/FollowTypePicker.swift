//
//  FollowTypePicker.swift
//  dakuofu
//
//  Created by HamGuy on 9/7/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import SnapKit


class FollowTypePicker: NSObject {
    fileprivate var optionList:OptionList
    fileprivate var containder:UIView
    fileprivate var currentFollowType:Int = -1
    
    fileprivate override init() {
        self.optionList = OptionList(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 220))
        self.containder = UIView(frame: CGRect.zero)
        super.init()
        self.setup()
    }
    
    convenience init(dissMissBlock:((_ followType:Int)->Void)?) {
        self.init()
        self.dismissBlcok = dissMissBlock
    }
    
    var dismissBlcok:((_ followType:Int)->Void)?
    
    func setup(){
        containder.width = kScreenWidth
        containder.height = 220 + 44
        containder.backgroundColor = UIColor.appBackgroundColor
        
        let cancelButton = UIButton(frame: CGRect(x: 10, y: 0, width: 60, height: 44))
        cancelButton.setTitleColor(UIColor.appMinorColor, for: UIControlState())
        cancelButton.setTitle("取消", for: UIControlState())
//        cancelButton.contentMode = .Left
        cancelButton.titleLabel!.font = UIFont.systemFont(ofSize: 15)
        cancelButton.addTarget( self, action: #selector(FollowTypePicker.cancel(_:)), for: .touchUpInside)
        
        let okButton = UIButton(frame: CGRect(x: kScreenWidth - 60-10, y: 0, width: 60, height: 44))
        okButton.setTitleColor(UIColor.appMainColor, for: UIControlState())
        okButton.setTitle("确定", for: UIControlState())
        okButton.titleLabel!.font = UIFont.systemFont(ofSize: 15)
//        okButton.contentMode = .Right
        okButton.addTarget( self, action: #selector(FollowTypePicker.ok(_:)), for: .touchUpInside)
        
        let titleLel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        titleLel.centerX = containder.centerX
        titleLel.backgroundColor = UIColor.appBackgroundColor
        titleLel.textColor = UIColor.appMinorColor
        titleLel.font = UIFont.systemFont(ofSize: 16)
        titleLel.textAlignment = .center
        titleLel.text = "选择关注类型"
        
        containder.addSubview(cancelButton)
        containder.addSubview(okButton)
        containder.addSubview(titleLel)

        
        optionList.y = 44
        containder.addSubview(optionList)
        
        optionList.delegate = self
    }
    
    func show(){
        optionList.reloadData(allFollowTypeText,selected: UserContext.sharedContext.followType)
        PopContiner.showWithView(containder, animationDuration: 0.5, tapToDissmiss: false, completion: nil, cancelBlock: nil)
    }
    
    @IBAction func cancel(_ sender:UIButton!){
        PopContiner.dissmiss()
    }
 
    @IBAction func ok(_ sender:UIButton!){
        PopContiner.dissmiss { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismissBlcok?(strongSelf.currentFollowType)
        }
    }
}

extension FollowTypePicker: OptionListDelegate{
    func didSelectOption(_ optionIndex: Int, optionList: OptionList) {
        currentFollowType = optionIndex
        if UserContext.sharedContext.hadLogin{
            UserContext.sharedContext.followType = optionIndex
        }
    }
}
