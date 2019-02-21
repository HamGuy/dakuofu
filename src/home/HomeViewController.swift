//
//  HomeViewController.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController {

    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var headerContainer:UIView!
    @IBOutlet weak var buttonContainer:UIView!
    @IBOutlet weak var categoryItemWidthCostraint:NSLayoutConstraint!
    
    fileprivate lazy var resultListController: ResultListViewController = {
        let vc = ResultListViewController(style: .grouped)
        vc.showHeader = true
        vc.enableLoadMore = false
        vc.delegate = self
        return vc
    }()
    
    var request: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let bg = UIImage(named: "searchbg")?.resizableImage(withCapInsets: UIEdgeInsets(top:20, left: 20, bottom: 20, right: 20))
        searchBar.setBackgroundImage(bg, for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        searchBar.setImage(UIImage(named: "SearchIcon"), for: UISearchBarIcon.search, state: UIControlState())
        searchBar.setImage(UIImage(named: "close"), for: UISearchBarIcon.clear, state: UIControlState())
        
        headerContainer.removeFromSuperview()
        
        
        addChildViewController(resultListController)
        view.addSubview(resultListController.view)
        resultListController.view.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(self.view)
        })
        
        resultListController.tableView.tableHeaderView = headerContainer
        
        headerContainer.snp_makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.width.equalTo(self.resultListController.tableView.width)
            make.height.equalTo(190)
        }
        
        buttonContainer.hg_addTopBorder(UIColor.appContentSeperatorColor, thickness: 0.5)
        buttonContainer.hg_addBottomBorder(UIColor.appContentSeperatorColor, thickness: 0.5)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.loginSuccess(_:)), name: NSNotification.Name(rawValue: kLoginSuccessNotification), object: nil)
     
        if UserContext.sharedContext.hadLogin{
            loadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        categoryItemWidthCostraint.constant = view.width/5.0
    }
    
    @IBAction func categoryButtonClicked(_ sender:UIButton!){
        let tag = sender.tag
        var followtype: FollowType!
        switch tag {
        case 0:
            followtype = .car
        case 1:
            followtype = .hourse
        case 2:
            followtype = .asserts
        case 3:
            followtype = .project
        case 4:
            followtype = .land
        default:
            break
        }
        let categoryController = CategoryViewController(followtype: followtype)
        navigationController?.pushViewController(categoryController, animated: true)
    }
    
}

extension HomeViewController{
    fileprivate func loadData(){
        startLoading()
        let api = BidApi.SearchBid(searchType: .type, type: .car)
        request = hg_request(api, completion: {[weak self] response in
            self?.request = nil
            self?.stopLoading()
            switch response{
            case .fail(let error):
                ToastView.showWithMessage("获取数据失败: \(error)")
            case .success(let tuple):
                self?.resultListController.reloadDatas(tuple.0)
                //                ToastView.showWithMessage("注册成功")
                break;
            }
        })
    }
    
    func loginSuccess(_ notification:Notification){
        loadData()
    }
}

extension HomeViewController: UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        debugPrint("ceshi")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.length==0{
            searchBar.endEditing(true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        let controller = SearchResultViewController(keyword: searchBar.text!)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}

extension HomeViewController: ResultListViewControllerDelegate{
    func refesh(_ resultListController: ResultListViewController) {
        loadData()
    }
    
    func loadMore(_ resultListController: ResultListViewController) {
        
    }
}
