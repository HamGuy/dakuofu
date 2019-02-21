//
//  SettingViewController.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import SnapKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier("setting"))
        
        
        let logoutButton = RoundedButton(type: .Custom)
        logoutButton.frame = CGRect(x: 0, y: 0, width: 120, height: 48)
        logoutButton.borderColor = UIColor.appMainColor
        logoutButton.normalBgColor = UIColor.whiteColor()
        logoutButton.borderWidth = 0.5
        logoutButton.cornerRadius = 24
        logoutButton.setTitle("退出", forState: UIControlState.Normal)
        logoutButton.setTitleColor(UIColor.appMainColor, forState: .Normal)
        logoutButton.addTarget(self, action: #selector(SettingViewController.logOut(_:)), forControlEvents: .TouchUpInside)
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//         tableView.tableFooterView =  footerView
    }
    
    @IBAction func logOut(sw:UISwitch){
        
    }
    
    @IBAction func switchChanged(sw:UISwitch){
        
    }
    
    
}

extension SettingViewController: UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(UITableViewCell.reuseIdentifier("setting"))
        if cell == nil{
            cell = UITableViewCell(style: .Value1, reuseIdentifier: UITableViewCell.reuseIdentifier("setting"))
            cell?.textLabel?.textColor = UIColor.appMinorColor
        }
        
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        switch indexPath.section {
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
                cell?.detailTextLabel?.text = allFollowTypes[UserContext.sharedContext.followType]
                cell?.detailTextLabel?.textColor = UIColor.appMinorColor
            }
        case 3:
            cell?.imageView?.image = UIImage(named: "findpwd" )
            cell?.textLabel?.text = "找回密码"
        default:
            break
            
        }
        
        if indexPath.section == 1{
            let sw = UISwitch(frame: CGRect(x: 150, y: 0, width: 0, height: 0))
            cell?.accessoryView = sw
            sw.addTarget(self, action: #selector(SettingViewController.switchChanged(_:)), forControlEvents: .ValueChanged)
        }else{
            cell?.accessoryView = nil
        }
        
        cell?.layoutSubviews()
        return cell!
    }
}

extension SettingViewController: UITableViewDelegate{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0:
            if let sb = storyboard{
                let vc = sb.instantiateViewControllerWithIdentifier("userInfoController")
                navigationController?.pushViewController(vc, animated: true)
            }
        case 2:
//            let controller = CategoryViewController()
//            navigationController?.pushViewController(controller, animated: true)
            //
            let cell = tableView.dequeueReusableCellWithIdentifier(UITableViewCell.reuseIdentifier("setting"), forIndexPath: indexPath)
            let picker = FollowTypePicker { followType in
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            picker.show()
        case 3:
            if let sb = storyboard{
                let vc = sb.instantiateViewControllerWithIdentifier("modifyPassowrdController")
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
    }
}

