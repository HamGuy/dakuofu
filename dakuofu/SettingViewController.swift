//
//  SettingViewController.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

class SettingViewController: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    
    var request: Request?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier("setting"))
        
        
        let logoutButton = RoundedButton(type: .custom)
        logoutButton.frame = CGRect(x: 0, y: 0, width: 120, height: 48)
        logoutButton.borderColor = UIColor.appMainColor
        logoutButton.normalBgColor = UIColor.white
        logoutButton.borderWidth = 0.5
        logoutButton.cornerRadius = 24
        logoutButton.setTitle("退出", for: UIControlState())
        logoutButton.setTitleColor(UIColor.appMainColor, for: UIControlState())
        logoutButton.addTarget(self, action: #selector(SettingViewController.logOut(_:)), for: .touchUpInside)
    
        tableView.tableFooterView = logoutButton
        logoutButton.snp_makeConstraints { (make) in
            make.width.equalTo(178.5)
            make.height.equalTo(48)
            make.centerX.equalTo(tableView)
            make.bottom.equalTo(tableView.contentSize.height)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//         tableView.tableFooterView =  footerView
    }
    
    @IBAction func logOut(_ sender:UIButton){
        UserContext.sharedContext.logOut()
        showLoginController()
    }
    
    @IBAction func switchChanged(_ sw:UISwitch){
        if sw.isOn != UserContext.sharedContext.allowPush{
            startLoading()
            let api = UserApi.ModifyInfo(id: UserContext.sharedContext.userId!, fileds: ["allowPush":sw.isOn])
            request = hg_request(api, completion: { [weak self] response in
                self?.request = nil
                self?.stopLoading()
                switch response{
                case .fail(let error):
                    ToastView.showWithMessage("修改失败: \(error)")
                case .success(let info):
                    UserContext.sharedContext.update(info)
                    ToastView.showWithMessage("修改成功")
                    break;
                }
                })
        }
        
    }
    
    fileprivate func showLoginController(){
        if let app = UIApplication.shared.delegate as? AppDelegate, let sb = storyboard{
            let tabController = sb.instantiateViewController(withIdentifier: "loginController")
            app.window?.rootViewController = tabController
        }
    }
    
}

extension SettingViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier("setting"))
        if cell == nil{
            cell = UITableViewCell(style: .value1, reuseIdentifier: UITableViewCell.reuseIdentifier("setting"))
            cell?.textLabel?.textColor = UIColor.appMinorColor
        }
        
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        switch (indexPath as NSIndexPath).section {
        case 0:
            cell?.imageView?.image = UIImage(named: "personnalInfo")
            cell?.textLabel?.text = "个人信息"
        case 1:
            cell?.imageView?.image = UIImage(named: "push")
            cell?.textLabel?.text = "接收推送"
        case 2:
            cell?.imageView?.image = UIImage(named: "follow.png")
            cell?.textLabel?.text = "我的关注"
            if UserContext.sharedContext.followType != -1 {
                cell?.detailTextLabel?.text = allFollowTypeText[UserContext.sharedContext.followType]
                cell?.detailTextLabel?.textColor = UIColor.appMinorColor
            }
        case 3:
            cell?.imageView?.image = UIImage(named: "findpwd" )
            cell?.textLabel?.text = "修改密码"
        default:
            break
            
        }
        
        if (indexPath as NSIndexPath).section == 1{
            let sw = UISwitch(frame: CGRect(x: 150, y: 0, width: 0, height: 0))
            cell?.accessoryView = sw
            sw.addTarget(self, action: #selector(SettingViewController.switchChanged(_:)), for: .valueChanged)
            sw.isOn = UserContext.sharedContext.allowPush
        }else{
            cell?.accessoryView = nil
        }
        
        cell?.layoutSubviews()
        return cell!
    }
}

extension SettingViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath as NSIndexPath).section {
        case 0:
            if let sb = storyboard{
                let vc = sb.instantiateViewController(withIdentifier: "userInfoController")
                navigationController?.pushViewController(vc, animated: true)
            }
        case 2:
//            let cell = tableView.dequeueReusableCellWithIdentifier(UITableViewCell.reuseIdentifier("setting"), forIndexPath: indexPath)
            let picker = FollowTypePicker { followType in
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            picker.show()
        case 3:
            if let sb = storyboard{
                let vc = sb.instantiateViewController(withIdentifier: "modifyPassowrdController")
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
    }
}

