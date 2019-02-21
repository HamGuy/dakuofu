//
//  AppDelegate.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire
import Fabric
import Crashlytics
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var floatMenu: FloatMenu!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupAppearence()
        IQKeyboardManager.sharedManager().enable = true
        
        application.applicationIconBadgeNumber = 0
        
        let showLoginBlock = {[weak self] in
            guard let strongSelf = self else{
                return
            }
            
            strongSelf.window = UIWindow(frame: UIScreen.main.bounds)
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let loginController = sb.instantiateViewController(withIdentifier: "loginController")
            strongSelf.window?.rootViewController = loginController
            strongSelf.addFloatMenu()
            
            strongSelf.window?.makeKeyAndVisible()
        }
        
        if !UserContext.sharedContext.hadLogin{
            // show login view
            
            NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.addFloatMenu), name: NSNotification.Name(rawValue: kLoginSuccessNotification), object: nil)
            DispatchQueue.main.async(execute: showLoginBlock)
        }else{
            addFloatMenu()
            if let token = UserContext.sharedContext.token , token.expired{
                let api = OAuthApi.RefreshToken()
                hg_request(api, completion: { response in
                    switch response{
                    case .fail( _):
                        showLoginBlock()
                        break;
                    case .success(let token):
                        UserContext.sharedContext.token = token
                    }
                })
            }
            
        }
        
        GeTuiSdk.start(withAppId: gtAppId, appKey: gtAppKey, appSecret: gtAppSecret, delegate: self)
        
        self.registerPushNotification(application)
        
        Fabric.with([Crashlytics.self])
        
        
//        let view = TempView(frame: CGRect(x: 20, y: 300, width: 50, height: 50))
//        view.backgroundColor = UIColor.blueColor()
//        view.layer.zPosition = CGFloat.max
//        window?.addSubview(view)
//        addFloatMenu()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = deviceToken.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        token = token.replacingOccurrences(of: " ", with: "")
        debugPrint("token = \(token)")
        
        GeTuiSdk.registerDeviceToken(token) 
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("register token failed: \(error.description)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        application.applicationIconBadgeNumber = 0
        // handle
        debugPrint("recieved remote notification")
    }
}

extension AppDelegate{
    fileprivate func setupAppearence(){
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        UINavigationBar.appearance().barTintColor = UIColor.appMainColor
        let textAttribute = [NSForegroundColorAttributeName:UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = textAttribute
        UIBarButtonItem.appearance().setTitleTextAttributes(textAttribute, for: UIControlState())
        UINavigationBar.appearance().tintColor = UIColor.white
        
        UITabBar.appearance().tintColor = UIColor.appMainColor
        UIMaterialTextField.appearance().lineColor = UIColor.clear
        UIMaterialTextField.appearance().activeTitleColor = UIColor.appMainColor
        
        UISwitch.appearance().onTintColor = UIColor.appMainColor
    }
    
    fileprivate func registerPushNotification(_ application: UIApplication){
        let settings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(settings)
        UserDefaults.standard.requestedNotifications = true
    }
    
    func addFloatMenu(){
        floatMenu = FloatMenu(image: UIImage(named: "touch")!  , highlightImage: nil, position:  CGPoint(x: 40, y: UIScreen.main.bounds.height - 42))
        
        let menuItem1 = FloatMenuItem(backgroundImage: UIImage(named: "aboutus"), highlightImage: UIImage(named: "close")) { (index, sender) in
            
        }
        
        let menuItem2 = FloatMenuItem(backgroundImage: UIImage(named: "help"), highlightImage: nil) { (index, sender) in
            
        }
        
        let menuItem3 = FloatMenuItem(backgroundImage: UIImage(named: "law"), highlightImage: nil) { (index, sender) in
            
        }
        
        floatMenu.setSubButtons([menuItem1,menuItem2,menuItem3])
        floatMenu.mode = .sickle
        floatMenu.direction = .rightUp
        floatMenu.radius = 120
        floatMenu.positionMode = .touchBorder
        floatMenu.layer.zPosition = CGFloat.greatestFiniteMagnitude
        window?.rootViewController?.view.addSubview(floatMenu)
    }
    

    func removeFloatMenu() {
        floatMenu.isHidden = true
        floatMenu.removeFromSuperview()
        floatMenu = nil
    }
}

extension AppDelegate: GeTuiSdkDelegate{
    func geTuiSdkDidRegisterClient(_ clientId: String!) {
        debugPrint("clientId = \(clientId)")
    }
    
    func geTuiSdkDidOccurError(_ error: NSError!) {
        debugPrint("Getui error: \(error.localizedDescription)")
    }
    
    func geTuiSdkDidSendMessage(_ messageId: String!, result: Int32) {
        // [4-EXT]:发送上行消息结果反馈
        let msg:String = "sendmessage=\(messageId),result=\(result)";
        debugPrint("GeTuiSdk DidSendMessage: \(msg)")
    }
    
    func geTuiSdkDidReceivePayloadData(_ payloadData: Data!, andTaskId taskId: String!, andMsgId msgId: String!, andOffLine offLine: Bool, fromGtAppId appId: String!) {
        
        var payloadMsg = "";
        if((payloadData) != nil) {
            payloadMsg = String.init(data: payloadData, encoding: String.Encoding.utf8)!;
        }
        
        if let json = JSON(rawValue: payloadMsg){
            let item = CorporeItem(json: json)
            if let controller = UIApplication.topViewController(){
                let sb = UIStoryboard(name: "Main", bundle: nil)
                if let detailController = sb.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController{
                    detailController.corporeItem = item
                    controller.navigationController?.pushViewController(detailController, animated: true)
                }

            }
        }
        
        let msg:String = "Receive Payload: \(payloadMsg), taskId:\(taskId), messageId:\(msgId)";
        
        debugPrint("GeTuiSdk DidReceivePayload: \(msg)")
    }
}

class TempView: UIView{
    
}

