//
//  DetailViewController.swift
//  dakuofu
//
//  Created by HamGuy on 9/7/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import SKPhotoBrowser

class DetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var priceLabel:UILabel!
    @IBOutlet weak var phoneLabel:UILabel!
    @IBOutlet weak var addressLabel:UILabel!
    @IBOutlet weak var descriptionLabel:UILabel!
    @IBOutlet weak var descriptionLabelHeightContraint:NSLayoutConstraint!
    @IBOutlet weak var imageContainer:UIView!
    @IBOutlet weak var imageContainerHeightContraint:NSLayoutConstraint!
    
    fileprivate var photos:[SKPhoto] = []
    
    fileprivate lazy var carouselView: CarouselView = {
        let cv = CarouselView(frame: CGRect(x:0,y:0,width: kScreenWidth,height:kScreenWidth*0.75), carouselViewTapBlock: {[weak self] carouselView, index in
            if let strongSelf = self , index < strongSelf.photos.count{
                let photo = strongSelf.photos[index]
                let broswer = SKPhotoBrowser(photos: strongSelf.photos)
                strongSelf.navigationController?.pushViewController(broswer, animated: true)
            }
            
        })
        cv.placeHolderImage = UIImage(named: "imageholder")
        cv.backgroundColor = UIColor.appBackgroundColor
        return cv
    }()
    var corporeItem: CorporeItem!
    var request: Request?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidesBottomBarWhenPushed = true
    }
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        title = "标的详情"
        
        let status = FavoriteContext.sharedContext.containsObject(corporeItem) ? "已收藏" : "收藏"
        
        hg_AddRightBarButtonItemText(status, action: #selector(DetailViewController.addOrRemoceFavorite(_:)))
        
        imageContainerHeightContraint.constant = kScreenWidth * 0.75
        
        imageContainer.addSubview(self.carouselView)
        carouselView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.imageContainer)
        }
        if let _ = corporeItem, let images = corporeItem.bidImages{
            
            for image in images{
                let skp = SKPhoto.photoWithImageURL(image)
                photos.append(skp)
            }
            
            carouselView.reload(images)
            titleLabel.text = corporeItem.title
            priceLabel.text = "¥ \(corporeItem.price)"
            addressLabel.text = corporeItem.address
            phoneLabel.text = corporeItem.telephone
            
            if let velue = corporeItem.descriptionValue{
                let attributedString = velue.hg_AttributedString((lineSpace: 5.0, font: UIFont.systemFont(ofSize: 15)))
                let attributedStringSize = velue.hg_AttributedStringSize((lineSpace: 5.0, font: UIFont.systemFont(ofSize: 15)),  limitedSize: CGSize(width: kScreenWidth-30, height: 1000))
                descriptionLabel.attributedText = attributedString
                descriptionLabelHeightContraint.constant = attributedStringSize.height
            }
        }
    }
    
    func addOrRemoceFavorite(_ barButtonItem:UIBarButtonItem){
        if barButtonItem.title == "收藏"{
            FavoriteContext.sharedContext.insertObject(corporeItem)
            let api = BidApi.AddFavorite(id: "\(corporeItem.id)")
            startLoading()
            api.sendRequest({ [weak self] success in
                self?.stopLoading()
                DispatchQueue.main.async(execute: { 
                    if success{
                        ToastView.showWithMessage("添加收藏成功")
                        barButtonItem.title = "已收藏"
                    }else{
                        ToastView.showWithMessage("添加收藏失败")
                    }
                })

                })
            }else{
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
                            barButtonItem.title = "收藏"
                        }else{
                            ToastView.showWithMessage("移除收藏失败")
                        }
                    })
                })
            }
        }
    }
    
    @IBAction func makeAdial(_ sender:UIButton){
        if let tel = phoneLabel.text, let url = URL(string: "telprompt://"+tel){
            UIApplication.shared.openURL(url)
        }
    }
}
