//
//  UserInfoController.swift
//  dakuofu
//
//  Created by HamGuy on 9/2/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
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


class UserInfoController: UIViewController {
    
    @IBOutlet weak var nameField:UIMaterialTextField!
    @IBOutlet weak var addressField:UIMaterialTextField!
    @IBOutlet weak var commentField:UIMaterialTextField!
    @IBOutlet weak var followButton:UIButton!
    @IBOutlet weak var accountLabel:UILabel!
    @IBOutlet weak var modifyAvatarButton:UIButton!
    @IBOutlet weak var modifyAvatarTipLable:UILabel!
    @IBOutlet weak var avatarView:RoundedButton!
    fileprivate var imagePickerController:UIImagePickerController!
    
    fileprivate var request: Request?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidesBottomBarWhenPushed = true
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        hg_AddRightBarButtonItemText("编辑", action: #selector(UserInfoController.wantEdit(_:)))
        
        view.backgroundColor = UIColor.appBackgroundColor
        if UserContext.sharedContext.followTypeText.length>0{
            followButton.setTitle(UserContext.sharedContext.followTypeText, for: UIControlState())
            followButton.setTitleColor(UIColor.appMinorColor, for: UIControlState())
        }
        
        let context = UserContext.sharedContext
        
        let api = UserApi.GetInfo(value: context.userId! , searchType: .id)
        startLoading()
        request = hg_request(api, completion: { [weak self] response in
            self?.request = nil
            self?.stopLoading()
            switch response{
            case .fail( _):
                ToastView.showWithMessage("获取个人信息失败")
            case .success(let userInfo):
                UserContext.sharedContext.update(userInfo)
                self?.fillUp()
                self?.dismissViewControllerAnimated(true, completion: nil)
                break;
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    func fillUp(){
        nameField.text = UserContext.sharedContext.username ?? ""
        commentField.text = UserContext.sharedContext.remark ?? ""
        addressField.text = UserContext.sharedContext.address ?? ""
        
        followButton.setTitle(UserContext.sharedContext.followTypeText, for: UIControlState())
        
        if let imageUrl = UserContext.sharedContext.avatar{
            avatarView.kf_setImageWithURL(URL(string: imageUrl), forState: .Normal, placeholderImage: UIImage(named: "avatar"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        }

    }
    
    func wantEdit(_ barButtonItem:UIBarButtonItem!) {
        var editMode = false
        if barButtonItem.title == "编辑"{
            barButtonItem.title = "完成"
            editMode = true
        }else{
            barButtonItem.isEnabled = false
            modifyInfoIfNeeded({
                DispatchQueue.main.async(execute: { 
                    barButtonItem.isEnabled = true
                    barButtonItem.title = "编辑"
                })
            })
        }
        
        nameField.isUserInteractionEnabled = editMode
        addressField.isUserInteractionEnabled = editMode
        commentField.isUserInteractionEnabled = editMode
        followButton.isUserInteractionEnabled = editMode
        
        accountLabel.isHidden = editMode
        modifyAvatarTipLable.isHidden = !editMode
        modifyAvatarButton.isHidden = !editMode
    }
    

    @IBAction func wantChangeFollowType(_ sender:UIButton!){
        let picker = FollowTypePicker { index in
            self.followButton.setTitle(allFollowTypeText[index], for: UIControlState())
            self.followButton.setTitleColor(UIColor.appMinorColor, for: UIControlState())
            self.followButton.tag = 1
        }
        picker.show()
    }
    
    @IBAction func changeAvatar(_ sender:UIButton){
        let actionSheet = ActionSheet(title:nil, itemTitles: ["拍照","从相册选择"], delegate: self)
        actionSheet.show()
    }
}

extension UserInfoController: ActionSheetDelegate{
    func actionSheetDidClickedItemAtIndex(_ actionSheet: ActionSheet, index: Int) {
        if  (index != 0) {
            imagePickerController = UIImagePickerController()
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            
            let permissonWarningClosure = { () -> Void in
                self.hg_showAlert("没有权限访问照片或相机", title: "提示", cancelTitle: "取消", cancelBlock: nil, otherTitle: "打开设置", otherBlock: { () -> Void in
                    print(UIApplicationOpenSettingsURLString)
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                })
            }
            
            if index == 1 {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imagePickerController.sourceType = .camera
                    if UIImagePickerController.isCameraDeviceAvailable(.front) {
                        imagePickerController.cameraDevice = .front
                        NotificationCenter.default.addObserver(self, selector: #selector(UserInfoController.cameraChanged(_:)), name: NSNotification.Name(rawValue: "AVCaptureDeviceDidStartRunningNotification"), object: nil)
                    } else {
                        imagePickerController.cameraDevice = .rear
                    }
                    
                } else {
                    permissonWarningClosure()
                    return
                }
            } else {
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    imagePickerController.sourceType = .photoLibrary
                } else {
                    permissonWarningClosure()
                    return
                }
            }
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }

}

extension UserInfoController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "AVCaptureDeviceDidStartRunningNotification"), object: nil)
        let editedImage = cropImageWithInfo(info as [String : AnyObject])
        picker.dismiss(animated: true, completion: nil)
        uploadAvatar(editedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "AVCaptureDeviceDidStartRunningNotification"), object: nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func cameraChanged(_ notification:Notification) {
        print("cameraChanged called")
        self.imagePickerController.cameraViewTransform = CGAffineTransform.identity
        if self.imagePickerController.cameraDevice == .front{
            self.imagePickerController.cameraViewTransform = self.imagePickerController.cameraViewTransform.scaledBy(x: -1, y: 1)
        }
    }
    
    func uploadAvatar(_ editedImage: UIImage){
        if let data =  UIImageJPEGRepresentation(editedImage, 0.85){
            startLoading()
            let api = UserApi.ModifyAvatr(data: data)
            api.sendRequest({ [weak self] (success, picture) in
                DispatchQueue.main.async(execute: { 
                    if success{
                        let api = UserApi.ModifyInfo(id: UserContext.sharedContext.userId!,fileds: ["image":picture!])
                        hg_request(api, completion: { response in
                            self?.stopLoading()
                            switch response{
                            case .fail(_):
                                ToastView.showWithMessage("上传头像失败")
                            case .success(let info):
                                UserContext.sharedContext.update(info)
                                ToastView.showWithMessage("头像修改成功")
                                 self!.avatarView.setImage(editedImage, forState: .Normal)
                            }
                        })
                    }else{
                        self?.stopLoading()
                        ToastView.showWithMessage("上传头像失败")
                    }
                })
            })
        }
    }
    
    fileprivate func cropImageWithInfo(_ mediaInfo: [String : AnyObject]) -> UIImage {
        guard let originalImage = mediaInfo[UIImagePickerControllerOriginalImage] as? UIImage else {
            return UIImage()
        }
        
        let maxSize:CGFloat = 320
        
        let cropRect = mediaInfo[UIImagePickerControllerCropRect] as? NSValue
        var imageSize = originalImage.size
        
        if var theCropRect = cropRect?.cgRectValue {
            
            UIGraphicsBeginImageContext(theCropRect.size)
            let contextRef = UIGraphicsGetCurrentContext()
            
            let imageOrientation = originalImage.imageOrientation
            if imageOrientation == .up {
                contextRef?.translateBy(x: 0, y: imageSize.height);
                contextRef?.scaleBy(x: 1, y: -1);
                
                theCropRect = CGRect(
                    x:theCropRect.origin.x,
                    y:-theCropRect.origin.y,
                    width:theCropRect.size.width,
                    height:theCropRect.size.height
                )
            }
            
            if imageOrientation == .right {
                contextRef?.scaleBy(x: 1.0, y: -1.0);
                contextRef?.rotate(by: CGFloat(-M_PI/2.0));
                
                imageSize = CGSize(width: imageSize.height, height: imageSize.width);
                theCropRect = CGRect(
                    x:theCropRect.origin.y,
                    y:-theCropRect.origin.x,
                    width:theCropRect.size.height,
                    height:theCropRect.size.width
                )
            }
            
            if imageOrientation == .down {
                contextRef?.translateBy(x: imageSize.width, y: 0);
                contextRef?.scaleBy(x: -1,y: 1);
                
                imageSize = CGSize(width: imageSize.height, height: imageSize.width);
                theCropRect = CGRect(
                    x:theCropRect.origin.x,
                    y:-theCropRect.origin.y,
                    width:theCropRect.size.width,
                    height:theCropRect.size.height
                )
            }
            
            contextRef?.translateBy(x: -theCropRect.origin.x, y: -theCropRect.origin.y);
            contextRef?.draw(originalImage.cgImage!, in: CGRect(x: 0,y: 0, width: imageSize.width, height: imageSize.height));
            
            var croppedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if croppedImage?.size.width > maxSize {
                let tmpImage = croppedImage?.hg_ResizeImage(size: CGSize(width: maxSize, height: maxSize))
                croppedImage = tmpImage
            }
            return croppedImage!;
        } else {
            return originalImage
        }
    }
    
    fileprivate func modifyInfoIfNeeded(_ completion:@escaping ()->Void){
        var valuesToModify:[String: AnyObject] = [:]
        let context = UserContext.sharedContext
        if nameField.text != context.realname && nameField.text?.length > 0{
            valuesToModify["realname"] = nameField.text! as AnyObject?
        }
        if addressField.text != context.address && addressField.text?.length > 0{
            valuesToModify["address"] = addressField.text! as AnyObject?
        }
        if commentField.text != context.remark && commentField.text?.length > 0{
            valuesToModify["remark"] = commentField.text! as AnyObject?
        }
        let typeText = followButton.titleLabel?.text
        if typeText != context.followTypeText{
            valuesToModify["followType"] = allFollowTypes[context.followType] as AnyObject?
        }
        
        if valuesToModify.count > 0{
            startLoading()
            let api = UserApi.ModifyInfo(id: context.userId!, fileds: valuesToModify)
            request = hg_request(api, completion: { [weak self] response in
                self?.request = nil
                self?.stopLoading()
                switch response{
                case .fail(let error):
                    ToastView.showWithMessage("修改失败: \(error)")
                case .success(let info):
                    UserContext.sharedContext.update(info)
                    ToastView.showWithMessage("修改成功")
                    completion()
                    break;
                }
            })
        }else{
            completion()
        }
    }
}

