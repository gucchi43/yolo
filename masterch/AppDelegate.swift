//
//  AppDelegate.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/01/31.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
//import NCMB
import Fabric
import TwitterKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let applicationkey = "d49ceb9e63bd3cf555c8aa7c339ea105b71fa00ed1e6517dec8172beef10c553"
    let clientkey = "ba1432ddcd33638afa4075ab527183c5e0a056e6a0441342be264dc8dd50fdd6"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Override point for customization after application launch.
        //********** SDKの初期化 **********
        NCMB.setApplicationKey(applicationkey, clientKey: clientkey)
        
//        NCMBTwitterUtils.initializeWithConsumerKey("BC5FOGIUpi7cPUnuG9JUgtnwD", consumerSecret: "1GBwujSqH10INkqiaPfhO6IyncFc30CrwT8TNHUChgm1zV0dXq")
        
        NCMBTwitterUtils.initializeWithConsumerKey("2qY7CYrPfZrvSo8AcMZwMify9", consumerSecret: "qLBkQ9ATbpz8Ym6pWcNqRrzINceW0IaszxYWLFy46Zjy9O3VQc")
        
        let storyboard:UIStoryboard =  UIStoryboard(name: "Main",bundle:nil)
        var viewController:UIViewController
        let user = NCMBUser.currentUser()
        
        /** Fabric連携 **/
        let consumerKey = "2qY7CYrPfZrvSo8AcMZwMify9"
        let consumerSecret = "qLBkQ9ATbpz8Ym6pWcNqRrzINceW0IaszxYWLFy46Zjy9O3VQc"
        Twitter.sharedInstance().startWithConsumerKey(consumerKey, consumerSecret: consumerSecret)
//        Fabric.with([Twitter.sharedInstance()])
        Fabric.with([Twitter()])
        
        
        /** Facebook連携 **/
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //表示するビューコントローラーを指定
        if user != nil {
            print("appDelegate by ログイン済み")
            print("ユーザー情報: \(NCMBUser.currentUser())")
            //ユーザー情報を取ってくる
            user.fetchInBackgroundWithBlock({ (error: NSError!) -> Void in
                if error == nil {
                    let firsrtViewController :UIViewController
                    firsrtViewController = storyboard.instantiateViewControllerWithIdentifier("firstViewController") as UIViewController
                    self.window?.rootViewController = firsrtViewController
                    if let tabvc = self.window!.rootViewController as? UITabBarController  {
                        tabvc.selectedIndex = 2 // 0 が一番左のタブ (２＝Log画面)
                    }
                }else {
                    print("error: \(error)")
                }
            })
        } else {
            print("appDelegate by ログインしてない")
            viewController = storyboard.instantiateViewControllerWithIdentifier("virginViewController") as UIViewController
            window?.rootViewController = viewController
        }
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        /** 追加① **/
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /** 追加③ **/
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }


}

