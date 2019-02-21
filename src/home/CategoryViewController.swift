//
//  CategoryViewController.swift
//  dakuofu
//
//  Created by HamGuy on 9/3/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import Alamofire

class CategoryViewController: UIViewController {
    
    var optionControl:OptionControl!
    
    fileprivate lazy var resultListController: ResultListViewController = {
        let vc = ResultListViewController(style: .grouped)
        vc.delegate = self
        vc.showHeader = false
        vc.showTag = false
        return vc
    }()
    
    fileprivate var currentType: FollowType!
    fileprivate var sortType:SortType?
    fileprivate var request:Request?
    
    fileprivate var nextPage: Int = 0
    fileprivate var readEnd: Bool = false
    
    
    convenience init(followtype:FollowType){
        self.init(nibName: nil, bundle: nil)
        self.currentType = followtype
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.appBackgroundColor
        title = "分类"
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        optionControl = OptionControl(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44))
        view.addSubview(optionControl)
        
        optionControl.snp_makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        let searchView = SearchView(frame: CGRect(x: 0, y: 60, width: kScreenWidth, height: 90))
        searchView.delegate = self
        
        addChildViewController(resultListController)
        view.addSubview(resultListController.view)
        resultListController.view.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(optionControl.snp_bottom).offset(0)
            make.bottom.equalTo(0)
        })
        
        resultListController.tableView.tableHeaderView = searchView
        
        
        optionControl.delegate = self
        optionControl.dataSource = self
        optionControl.reload()
        
        loadData(nextPage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CategoryViewController{
    fileprivate func loadData(_ page:Int){
        request?.cancel()
        startLoading()
        let api = BidApi.SearchBid(searchType: .type, type: currentType, page: page, size: 10, sort: sortType)
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

extension CategoryViewController: ResultListViewControllerDelegate{
    
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

extension CategoryViewController: OptionControlDataSource{
    func numberOfOptions() -> Int {
        return 3
    }
    
    func optionItemAtIndex(_ index: Int) -> OptionItem? {
        if index == 0{
            var defaultIndex = -1
            if let type = currentType{
                defaultIndex = allFollowTypes.index(of: type.rawValue)!
            }
            return OptionItem(title: "全部分类", icon: "triangle", datas: allFollowTypeText, defaultSelectIndex: defaultIndex)
        }else if index == 1{
            return OptionItem(title: "默认排序", icon: "sort", datas: allSortTypeText , defaultSelectIndex: -1, optionType: 1)
        }else{
            return nil
        }
    }
}

extension CategoryViewController: OptionControlDelegate{
    func didSelectOptionAtIndex(_ index: Int, optionItem: OptionItem, optionControl: OptionControl) {
        if optionItem.optionType == 0{
            currentType = FollowType(rawValue: allFollowTypes[index])
        }else{
            sortType = SortType(rawValue: allSortTypes[index])
        }
        nextPage = 0
        loadData(nextPage)
    }
}

extension CategoryViewController: SearchViewDelegate{
    func searchKeyword(_ keyword: String, searchView: SearchView) {
        let controller = SearchResultViewController(keyword:keyword, followType: currentType, sorttype: sortType)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func cancelSearch(_ searchView: SearchView) {
        
    }
}
