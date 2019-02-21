//
//  ResultListViewController.swift
//  dakuofu
//
//  Created by HamGuy on 9/8/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol ResultListViewControllerDelegate {
    func refesh(_ resultListController: ResultListViewController)
    func loadMore(_ resultListController: ResultListViewController)
}

class ResultListViewController: UITableViewController {

    var deleteAble = false
    var showTag = true
    var enableRefesh = true
    var enableLoadMore = true
    var showHeader = false
    
    var customRefreshControl: RefeshControl?
    var delegate: ResultListViewControllerDelegate?
    
    fileprivate var allCorporeItems:[CorporeItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        self.clearsSelectionOnViewWillAppear = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(CorporeItemCell.nib(), forCellReuseIdentifier: CorporeItemCell.reuseIdentifier())
        tableView.sectionFooterHeight = 0.01
        
        tableView.emptyDataSetSource = self
        tableView.tableHeaderView = UIView()
    }

    func reloadDatas(_ datas:[CorporeItem], append :Bool = false, offset:CGFloat = -64){
        if !append{
            allCorporeItems = datas
        }else{
            allCorporeItems.append(contentsOf: datas)
        }
        if let _ = delegate , customRefreshControl == nil{
            if enableRefesh && enableLoadMore{
            customRefreshControl = RefeshControl(scrollView: tableView, refreshBlock: { [weak self] in
                
                self?.refresh()
                }, loadmoreBlock: {[weak self] in
                    self?.loadMore()
                })
            }else if enableRefesh && !enableLoadMore{
                customRefreshControl = RefeshControl(scrollView: tableView, refreshBlock: { [weak self] in
                    self?.refresh()
                })
            }
            customRefreshControl?.setTopOffset(offset);
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allCorporeItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CorporeItemCell.reuseIdentifier(), for: indexPath) as! CorporeItemCell
        let item  = allCorporeItems[(indexPath as NSIndexPath).row]
        cell.titleLabel.text = item.title
        cell.priceLabel.text = "¥ \(item.price)"
        cell.tagButton.isHidden = !showTag
        if let images = item.bidImages , images.count > 0{
            cell.thumbinalView.kf_setImageWithURL(URL(string: images[0]), placeholderImage: UIImage(named: "imageholder"))
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
 
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return deleteAble
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let corporeItem = allCorporeItems[(indexPath as NSIndexPath).row]
            FavoriteContext.sharedContext.deleteObject(corporeItem)
            if let allObjects = FavoriteContext.sharedContext.persistentObject as? [CorporeItem]{
                var ids:[String] = []
                for obj in allObjects{
                    ids.append("\(obj.id)")
                }
                let api = BidApi.RemoveFavorites(ids: ids)
                api.sendRequest({ (success) in
                    DispatchQueue.main.async(execute: {
                        if success{
                            ToastView.showWithMessage("移除收藏成功")
                            self.allCorporeItems.remove(at: (indexPath as NSIndexPath).row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }else{
                            ToastView.showWithMessage("移除收藏失败")
                        }
                    })
                })
            }
            
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let topController = UIApplication.topViewController(){
            if let sb = topController.storyboard{
                let detailController = sb.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
                detailController.corporeItem = allCorporeItems[(indexPath as NSIndexPath).row]
                if let parentVc = parent{
                    parentVc.navigationController?.pushViewController(detailController, animated: true)
                }else{
                    navigationController?.pushViewController(detailController, animated: true)
            }
            }else{
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let detailController = sb.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
                detailController.corporeItem = allCorporeItems[(indexPath as NSIndexPath).row]
                topController.navigationController?.pushViewController(detailController, animated: true)
            }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !showHeader{
            return nil
        }
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 50))
        header.backgroundColor = UIColor.appBackgroundColor
        
        
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: header.width-30, height: 49))
        label.text = "最新推荐"
        label.textColor = UIColor.appMainColor
        label.backgroundColor = UIColor.appBackgroundColor
        label.font = UIFont.boldSystemFont(ofSize: 17)
        
        let line = UIView(frame: header.bounds)
        line.height = 0.5
        line.backgroundColor = UIColor.appContentSeperatorColor
        
        header.addSubview(label)
        header.addSubview(line)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return showHeader ? 50 : 0.01
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    fileprivate func loadMore(){
        delegate?.loadMore(self)
        customRefreshControl?.endLoadingmore()
    }
    
    fileprivate func refresh(){
        delegate?.refesh(self)
        customRefreshControl?.endRefreshing()
    }
    
}

extension ResultListViewController: DZNEmptyDataSetSource{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "暂无数据"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
}

