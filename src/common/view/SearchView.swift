//
//  SearchView.swift
//  dakuofu
//
//  Created by HamGuy on 9/8/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol SearchViewDelegate {
    func searchKeyword(_ keyword: String, searchView: SearchView)
    func cancelSearch(_ searchView: SearchView)
}

class SearchView: UIView {
    
    let searchBar = UISearchBar()
    var keyWord: String?{
        didSet{
            if self.keyWord?.length > 0{
                self.searchBar.text = keyWord!
            }
        }
    }
    
    var delegate: SearchViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    
    func setUp(){
        backgroundColor = UIColor.white
        frame.size.height = 90
        searchBar.frame = CGRect(x: 40, y: 23, width: frame.width-80, height: 44)
        let bg = UIImage(named: "searchbg")?.resizableImage(withCapInsets: UIEdgeInsets(top:20, left: 20, bottom: 20, right: 20))
        searchBar.setBackgroundImage(bg, for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        searchBar.setImage(UIImage(named: "SearchIcon"), for: UISearchBarIcon.search, state: UIControlState())
        searchBar.setImage(UIImage(named: "close"), for: UISearchBarIcon.clear, state: UIControlState())
        searchBar.delegate = self
        searchBar.placeholder = "搜索标的物名称地址位置"
        addSubview(searchBar)
        
        searchBar.snp_makeConstraints { (make) in
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.top.equalTo(23)
            make.bottom.equalTo(-23)
        }
        
        hg_addBottomBorder(UIColor.appContentSeperatorColor, thickness: 0.5)
    }
}

extension SearchView: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.length==0{
            searchBar.endEditing(true)
            delegate?.cancelSearch(self)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if searchBar.text?.length>0{
            delegate?.searchKeyword(searchBar.text!, searchView: self)
        }
        
    }
}
