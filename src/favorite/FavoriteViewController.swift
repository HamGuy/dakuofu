//
//  FavoriteViewController.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import Alamofire

class FavoriteViewController: UIViewController {

    fileprivate lazy var resultListController: ResultListViewController = {
        let vc = ResultListViewController(style: .plain)
        vc.delegate = self
        vc.deleteAble = true
        vc.enableLoadMore = false
        vc.showHeader = false
        return vc
    }()
    
    var request: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.addChildViewController(resultListController)
        self.view.addSubview(resultListController.view)
        resultListController.view.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(self.view)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         loadData(0)
    }
    
    fileprivate func loadData(_ page:Int){
        startLoading()
        let api = BidApi.FavoriteBids(id: UserContext.sharedContext.userId!)
        request = hg_request(api, completion: { [weak self] response in
            self?.request = nil
            self?.stopLoading()
            switch response{
            case .fail(let error):
                ToastView.showWithMessage("获取数据失败: \(error)")
            case .success(let tuple):
                if tuple.0.count > 0{
                    FavoriteContext.sharedContext.favotiteBids = tuple.0
                    self?.resultListController.reloadDatas(tuple.0)
                }else{
                    ToastView.showWithMessage("暂无数据")
                }
                break;
            }
        })
    }
}

extension FavoriteViewController: ResultListViewControllerDelegate{
    func refesh(_ resultListController: ResultListViewController) {
        loadData(0)
    }
    
    func loadMore(_ resultListController: ResultListViewController){
        
    }
}
