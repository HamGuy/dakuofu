//
//  SearchResultViewController.swift
//  dakuofu
//
//  Created by HamGuy on 9/8/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import Alamofire

class SearchResultViewController: UIViewController {

    var currentKeyword: String = ""
    var followType: FollowType?
    var sortType: SortType?
    
    fileprivate lazy var resultListController: ResultListViewController = {
        let vc = ResultListViewController(style: .grouped)
        vc.delegate = self
        vc.showHeader = false
        return vc
    }()
    
    fileprivate var nextPage: Int = 0
    fileprivate var readEnd: Bool = false
    fileprivate var request:Request?
    
    convenience init(keyword: String,followType: FollowType? = nil, sorttype: SortType? = nil){
        self.init(nibName: nil, bundle: nil)
        self.currentKeyword = keyword
        self.followType = followType
        self.sortType = sorttype
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "搜索结果"
        self.edgesForExtendedLayout = UIRectEdge()
        
        let searchView = SearchView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 90))
        searchView.delegate = self
        
        if currentKeyword.length>0{
            searchView.searchBar.text = currentKeyword
        }
        
        addChildViewController(resultListController)
        view.addSubview(resultListController.view)
        resultListController.view.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(view)
        })
        
        resultListController.tableView.tableHeaderView = searchView
        
        loadData(nextPage)
    }

}

extension SearchResultViewController{
    fileprivate func loadData(_ page:Int){
        request?.cancel()
        startLoading()
        let api = BidApi.SearchBid(searchType: .keyword, type: followType, page: page, size: 10, sort: sortType,keyword: currentKeyword)
        request = hg_request(api, completion: { [weak self] response in
            self?.request = nil
            self?.stopLoading()
            switch response{
            case .fail(let error):
                ToastView.showWithMessage("获取数据失败: \(error)")
            case .success(let tuple):
                self?.readEnd = tuple.1
                self?.resultListController.reloadDatas(tuple.0,append: self?.nextPage != 0, offset: 0)
                break;
            }
            })
    }
}

extension SearchResultViewController: ResultListViewControllerDelegate{
    
    func refesh(_ resultListController: ResultListViewController) {
        nextPage = 0
        loadData(nextPage)
    }
    
    func loadMore(_ resultListController: ResultListViewController) {
        if !self.readEnd{
            nextPage += 1
            loadData(nextPage)
        }
    }
}


extension SearchResultViewController: SearchViewDelegate{
    func searchKeyword(_ keyword: String, searchView: SearchView) {
        self.currentKeyword = keyword
        nextPage = 0
        loadData(nextPage)
    }
    
    func cancelSearch(_ searchView: SearchView) {
        
    }
}
