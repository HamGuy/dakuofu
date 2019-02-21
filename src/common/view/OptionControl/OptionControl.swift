//
//  FilterControl.swift
//  dakuofu
//
//  Created by HamGuy on 9/2/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import SnapKit


protocol OptionControlDataSource {
    func numberOfOptions() -> Int
    func optionItemAtIndex(_ index: Int) -> OptionItem?
}

protocol OptionControlDelegate {
    func didSelectOptionAtIndex(_ index: Int, optionItem: OptionItem, optionControl: OptionControl)
}

class OptionControl: UIView {
    fileprivate var previousControl:OptionButton?
    fileprivate lazy var optionList:OptionList = {
        let theListView =  OptionList(frame: CGRect(x: self.x, y: self.bottom, width: self.width, height: 0))
        theListView.delegate = self
        return theListView
    }()
    fileprivate lazy var bgView:UIView = {
        let bg = UIView(frame: CGRect(x: 0, y: self.bottom, width: self.width, height: kScreenHeight-self.bottom))
        bg.backgroundColor = UIColor.black
        bg.alpha = 0.0
        bg.isOpaque = false
        bg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OptionControl.bgTapped(_:))))
        return bg
    }()
    
     var dataSource: OptionControlDataSource?
     var delegate: OptionControlDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        hg_addBottomBorder(UIColor.appContentSeperatorColor, thickness: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hg_addBottomBorder(UIColor.appContentSeperatorColor, thickness: 0.5)
    }
    
    
    func reload(_ optionIndex: Int = 0, itemIndex: Int = -1){
        
        self.removeAllSubviews()
        if let theDataSource = dataSource{
            let optionWidth = width/(CGFloat)(theDataSource.numberOfOptions())
            for i in 0...theDataSource.numberOfOptions(){
                if let optionItem = theDataSource.optionItemAtIndex(i){
                    let x = optionWidth * CGFloat(i)
                    let control = OptionButton(frame: CGRect(x: x, y: 0, width: optionWidth, height: height))
                    control.textLabel.text = optionItem.defultIndex == -1 ? optionItem.title : optionItem.datSources[optionItem.defultIndex]
                    control.iconView.image = UIImage(named: optionItem.iconName)
                    addSubview(control)
                    
                    control.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(self.snp_left).offset(x)
                        make.top.equalTo(self.snp_top).offset(0)
                        make.width.equalTo(optionWidth)
                        make.height.equalTo(height)
                    })
                    
                    control.tag = i
                    control.addTarget(self, action: #selector(OptionControl.optionTapped(_:)), for: .touchUpInside)
                }
            }
            
            if let defautOption = theDataSource.optionItemAtIndex(optionIndex){
                optionList.reloadData(defautOption.datSources,selected: 2)
            }
        }
    }
    
    @IBAction func optionTapped(_ sender:OptionButton){
        let sameControl = sender == previousControl
        let block = { [weak self] in
            guard let strongSelf = self else { return }
            
            let index = sender.tag
            sender.isHighlight = true
            if let theDatasource = strongSelf.dataSource, let optionItem = theDatasource.optionItemAtIndex(index){
                strongSelf.optionList.tag  = index
                strongSelf.optionList.reloadData(optionItem.datSources,selected: optionItem.defultIndex)
                strongSelf.animateControl(true, completion: {
                    strongSelf.previousControl = sender
                })
            }
        }
        
        if let oldControl = previousControl{
            oldControl.isHighlight = !oldControl.isHighlight
            optionList.tag = oldControl.tag
            animateControl(oldControl.isHighlight, completion: {
                if sameControl{
//                    self.previousControl = nil
                }else{
                    block();
                }
            })
        }else{
            block()
        }
        
    }
    
    @IBAction func bgTapped(_ gesture:UIGestureRecognizer){
        hideCurrentOption()
    }
    
    fileprivate func hideCurrentOption(_ completion: (()->Void)? = nil){
        if let ctl = previousControl{
            ctl.isHighlight = false
            self.animateControl(false, completion: {
                if let block = completion{
                    block()
                }else{
                    self.previousControl = nil
                }
            })
        }
    }
    
    fileprivate func animateControl(_ show: Bool, completion:(()->Void)?){
        if show{
            optionList.height = 0
            superview?.addSubview(bgView)
            superview?.addSubview(optionList)
            let rows = optionList.tableView.numberOfRows(inSection: 0)
            let tableviewHeight = rows > 5 ? 5 * optionList.tableView.rowHeight : CGFloat(rows) * optionList.tableView.rowHeight
            
            UIView.animate(withDuration: 0.3, animations: {
                self.optionList.height = tableviewHeight
                self.bgView.alpha = 0.3
                }, completion: { finish in
                    completion?()
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.optionList.height = 0
                self.bgView.alpha = 0
                }, completion: { finished in
                    self.optionList.removeFromSuperview()
                    self.bgView.removeFromSuperview()
                    completion?()
            })
        }
    }
}

extension OptionControl: OptionListDelegate{
    func didSelectOption(_ optionIndex: Int, optionList: OptionList) {
        self.previousControl?.textLabel.textColor = UIColor.appMainColor
        hideCurrentOption {[weak self] in
            guard let strongSelf = self, let theDatasource = self?.dataSource, let optionItem = theDatasource.optionItemAtIndex(optionList.tag) else{ return }
            
            strongSelf.previousControl?.textLabel.text = optionItem.datSources[optionIndex]
            strongSelf.delegate?.didSelectOptionAtIndex(optionIndex, optionItem: optionItem , optionControl: strongSelf)
        }
    }
}


class OptionButton: UIControl {
    let textLabel:UILabel
    let iconView:UIImageView
    fileprivate var _shouldHighlight = false
    
    var isHighlight: Bool{
        get{
            return _shouldHighlight
        }
        set{
            _shouldHighlight = newValue
            UIView.animate(withDuration: 0.3, animations: {
                self.iconView.transform = CGAffineTransform(rotationAngle: CGFloat(newValue ? M_PI : 0))
                self.textLabel.textColor = UIColor.appMainColor //: UIColor.appGrayColor
            }) 
        }
    }
    
    override init(frame: CGRect) {
        textLabel = UILabel(frame: CGRect(x: 20, y: 8, width: frame.size.width - 46, height: 44.0))
        iconView = UIImageView(frame:CGRect(x: textLabel.right + 16, y: 15, width: 15, height: 15))
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        textLabel = UILabel(frame: CGRect(x: 20, y: 8, width: 0, height: 44.0))
        iconView = UIImageView(frame:CGRect(x: textLabel.right + 16, y: 15, width: 15, height: 15))
        super.init(coder: aDecoder)
        setUp()
    }
    
    fileprivate func setUp(){
        textLabel.backgroundColor = UIColor.clear
        textLabel.textColor = UIColor.appGrayColor
        textLabel.font = UIFont.systemFont(ofSize: 15.0)
        addSubview(textLabel)
        
        textLabel.snp_makeConstraints { (make) in
            make.left.equalTo(self.snp_left).offset(20)
            make.top.equalTo(self.snp_top).offset(0)
            make.width.equalTo(width - 46)
            make.height.equalTo(44)
        }

        addSubview(iconView)
        iconView.snp_makeConstraints { (make) in
            make.left.equalTo(textLabel.snp_right).offset(16)
            make.top.equalTo(textLabel.snp_top).offset(14.5)
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
    }
}

