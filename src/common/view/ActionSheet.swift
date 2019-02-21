//
//  ActionSheet.swift
//  Aspirin
//
//  Created by HamGuy on 11/17/15.
//
//

import UIKit

@objc protocol ActionSheetDelegate: NSObjectProtocol {
    func actionSheetDidClickedItemAtIndex(_ actionSheet: ActionSheet, index:Int)
}

enum ActionItemType:Int{
    case normal
    case destrutive
    case cancel
}

struct ActionItem {
    let title:String
    let type:ActionItemType
    let action:()->()
}

class ActionSheet: UIView {
    fileprivate weak var actionSheetDelegate:ActionSheetDelegate?
    fileprivate var actionSheetTitle:String?
    fileprivate var actionItemTitles:[String]! //actionTitles, tag is start from 1 to actionTitles' count, order is from bottom To top
    fileprivate var actionCacelTitle:String! //cancel button, tag is 0
    fileprivate var highlightButtonIndexes:[Int]? //indexes should highlight
    fileprivate lazy var urlButtonIndex: Int = 100  // url 跳转索引起点
    
    var highlightColor = UIColor.appMainColor
    var normalColor = UIColor.black
    var separatorColor = UIColor.appContentSeperatorColor
    
    class func actionSheetWithTitle(_ title:String?,itemTitles:[String],delegate:ActionSheetDelegate,highlightButtonIndexes:[Int]? = nil,canceItemTitle:String? = "取消")->ActionSheet{
        return ActionSheet(title: title, itemTitles: itemTitles, delegate: delegate,highlightButtonIndexes: highlightButtonIndexes,canceItemTitle: canceItemTitle)
    }
    
    init(title:String?,itemTitles:[String],delegate:ActionSheetDelegate,highlightButtonIndexes:[Int]? = nil,canceItemTitle:String? = "取消"){
        self.actionSheetDelegate = delegate
        self.actionSheetTitle = title
        self.actionItemTitles = itemTitles
        self.actionCacelTitle = canceItemTitle
        self.highlightButtonIndexes = highlightButtonIndexes
        super.init(frame: CGRect.zero)
        self.setUp()
    }
    
    init(title:String?, itemTitles: [String], delegate: ActionSheetDelegate,highlightButtonIndexes: [Int]? = nil, hightlightColor: UIColor, canceItemTitle:String? = "取消") {
        self.actionSheetDelegate = delegate
        self.actionSheetTitle = title
        self.actionItemTitles = itemTitles
        self.actionCacelTitle = canceItemTitle
        self.highlightButtonIndexes = highlightButtonIndexes
        self.highlightColor = hightlightColor
        super.init(frame: CGRect.zero)
        self.setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }
    
    
}

extension ActionSheet{
    // MARK: - Public
    internal func show(){
        self.show(animationDuration: 0.3, tapToDissmiss: true, completion: nil)
    }
    
    internal func show(animationDuration duration: CGFloat, tapToDissmiss: Bool, completion: (() -> Void)?){
        PopContiner.showWithView(self, animationDuration: duration, tapToDissmiss: tapToDissmiss, completion: completion)
    }
    
    // MARK: - Private
    func setUp(){
        
        let containerView = UIView(frame: UIScreen.main.bounds)
        containerView.backgroundColor = UIColor(decRed: 233, decGreen: 233, decBlue: 233)
        containerView.height = 0
        
        let buttonWidth = containerView.width
        let buttonHeight:CGFloat = 45.0
        var labelHeight:CGFloat = 35.0
        
        if let theTitle = self.actionSheetTitle{
            let titleLabel = UILabel(frame: CGRect(x: 15, y: 15, width: buttonWidth-30, height: labelHeight))
            let attribute: (lineSpace:CGFloat,font:UIFont) = (lineSpace:0,font:UIFont.systemFont(ofSize: 14.0))
            let attributedTitle = theTitle.hg_AttributedString(attribute)
            titleLabel.textColor = UIColor(decRed: 51, decGreen: 51, decBlue: 51)
            titleLabel.attributedText = attributedTitle
            titleLabel.accessibilityLabel = theTitle
            titleLabel.backgroundColor = UIColor.white
            titleLabel.numberOfLines = 0
            
            let textSize = theTitle.hg_AttributedStringSize(attribute, limitedSize: CGSize(width: titleLabel.width, height: 1000))
            labelHeight = max(ceil(textSize.height),35.0)
            titleLabel.height = labelHeight
            
            titleLabel.textAlignment = labelHeight == 35 ? .center : .left
            
            let labelContainerView = UIView(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: labelHeight + 30))
            labelContainerView.backgroundColor = UIColor.white
            labelContainerView.addSubview(titleLabel)
            
            containerView.addSubview(labelContainerView)
            
            let line = UIView(frame: labelContainerView.bounds)
            line.height = 0.5
            line.backgroundColor = self.separatorColor
            line.top = labelContainerView.height - 0.5
            containerView.addSubview(line)
        }
        
        
        var btnY:CGFloat = 0
        
        // item buttons
        print(self.actionItemTitles)
        for titleIndex in 0...self.actionItemTitles.count-1{
            var shouldHighlight = false
            let buttonTitle = self.actionItemTitles[titleIndex]
            
            if self.highlightButtonIndexes != nil{
                shouldHighlight = self.highlightButtonIndexes!.contains(titleIndex)
            }
            
            let itemButton = self.itemButtonWithTitle(buttonTitle: buttonTitle, shouldHight: shouldHighlight)
            if buttonTitle.hasPrefix("前往：") {
                itemButton.tag = urlButtonIndex  // 特殊约定：Url 跳转型按钮，索引从 100 开始
                urlButtonIndex += 1
            } else {
                itemButton.tag = titleIndex + 1
            }
            
            if actionSheetTitle != nil {
                btnY =  buttonHeight * CGFloat(titleIndex) + (actionCacelTitle == nil ? 0 : labelHeight + 30)
            } else {
                btnY =  buttonHeight * CGFloat(titleIndex)
            }
            
            itemButton.frame = CGRect(x: 0, y: btnY, width: buttonWidth, height: buttonHeight)
            itemButton.hg_addBottomBorder(self.separatorColor, thickness: 0.5)
            containerView.addSubview(itemButton)
        }
        
        
        //cancel button
        let cancelButton = itemButtonWithTitle(buttonTitle: self.actionCacelTitle, shouldHight: false)
        cancelButton.frame = CGRect(x: 0, y: btnY + buttonHeight + 5, width: buttonWidth, height: buttonHeight)
        cancelButton.tag = 0
        containerView.addSubview(cancelButton)
        
        //set height
        containerView.height = cancelButton.bottom
        self.frame = containerView.bounds
        self.addSubview(containerView)
    }
    
    func itemButtonWithTitle(buttonTitle btnTitle:String,shouldHight:Bool)->UIButton{
        let button = UIButton(type: .custom)
        button.setTitle(btnTitle, for: UIControlState())
        button.setTitleColor(shouldHight ? self.highlightColor : self.normalColor, for: UIControlState())
        button.addTarget(self, action: #selector(ActionSheet.itemButtonclicked(_:)), for: UIControlEvents.touchUpInside)
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }
    
    @IBAction func itemButtonclicked(_ button:UIButton!){
        PopContiner.dissmiss { () -> Void in
            self.actionSheetDelegate?.actionSheetDidClickedItemAtIndex(self, index: button.tag)
        }
    }
}
