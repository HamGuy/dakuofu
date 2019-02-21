//
//  FilterButton.swift
//  dakuofu
//
//  Created by HamGuy on 9/2/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

protocol  OptionListDelegate{
    func didSelectOption(_ optionIndex: Int, optionList:OptionList)
}

class OptionList: UIView{
    var delegate: OptionListDelegate?
    let tableView:UITableView
    fileprivate var datas:[String] = []
    var seletedIndex = -1
    fileprivate var previousCellIndexPath: IndexPath?
    
    override init(frame:CGRect){
        tableView = UITableView(frame: CGRect(origin: CGPoint.zero,size:frame.size), style: .plain)
        super.init(frame: frame)
        self.setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        super.init(coder: aDecoder)
    }
    
    fileprivate func setUp(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
//        tableView.separatorInset = UIEdgeInsetsZero
        tableView.register(OptionListItemCell.nib(), forCellReuseIdentifier: OptionListItemCell.reuseIdentifier())
        tableView.rowHeight = 44
        addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func reloadData(_ data: [String], selected: Int = -1){
        datas = data
        seletedIndex = selected
        tableView.reloadData()
    }
}

extension OptionList: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: OptionListItemCell.reuseIdentifier()) as? OptionListItemCell
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: OptionListItemCell.reuseIdentifier()) as? OptionListItemCell
            cell?.selectedBackgroundView?.backgroundColor = UIColor.appBackgroundColor
            cell?.backgroundView?.backgroundColor = UIColor.appBackgroundColor
            cell?.contentView.backgroundColor = UIColor.appBackgroundColor
        }
        cell?.titleLabel.text = datas[(indexPath as NSIndexPath).row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if seletedIndex == (indexPath as NSIndexPath).row{
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
}

extension OptionList: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        seletedIndex = (indexPath as NSIndexPath).row
        delegate?.didSelectOption((indexPath as NSIndexPath).row, optionList: self)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
}
