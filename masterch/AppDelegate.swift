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
import Crashlytics
import TwitterKit
import SwiftDate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let applicationkey = "d49ceb9e63bd3cf555c8aa7c339ea105b71fa00ed1e6517dec8172beef10c553"
    let clientkey = "ba1432ddcd33638afa4075ab527183c5e0a056e6a0441342be264dc8dd50fdd6"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        //********** SDKの初期化 **********
        /** NCMB連携 **/
        NCMB.setApplicationKey(applicationkey, clientKey: clientkey)


        //        NCMBTwitterUtils.initializeWithConsumerKey("BC5FOGIUpi7cPUnuG9JUgtnwD", consumerSecret: "1GBwujSqH10INkqiaPfhO6IyncFc30CrwT8TNHUChgm1zV0dXq")

        NCMBTwitterUtils.initializeWithConsumerKey("TrXvBgug4dQvHd8OBhtCDe4u5", consumerSecret: "EwTwn9kg9hpzihQNWxn0Uo6OEnmJbUOebHayJBNt9jfqrZmAlR")

        /** Fabric連携 **/
        let consumerKey = "TrXvBgug4dQvHd8OBhtCDe4u5"
        let consumerSecret = "EwTwn9kg9hpzihQNWxn0Uo6OEnmJbUOebHayJBNt9jfqrZmAlR"
        Twitter.sharedInstance().startWithConsumerKey(consumerKey, consumerSecret: consumerSecret)
        //        Fabric.with([Twitter.sharedInstance()])
        Fabric.with([Twitter.self, Crashlytics.self])


//        /** Facebook連携 **/
//        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        //---------NavigationBarのデザイン関係----------
        //NavigationBarの色を設定（背景、タイトル、アイテム）
        UINavigationBar.appearance().barTintColor = ColorManager.sharedSingleton.accsentColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()

        //        push通知の設定
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
            application.registerForRemoteNotifications()
        }
        // アプリが起動していない時にpush通知が届き、push通知から起動した場合(ローカルプッシュ通知)
        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            localPushRecieve(application, notification: notification)
        }
        // アプリが起動していない時にpush通知が届き、push通知から起動した場合(リモートプッシュ通知)
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            let category = remoteNotification.objectForKey("category") as! String
            switch category {
            case "like":
                print("リモートプッシュ通知受け取り: like")
                let userSettingValue = remoteNotification.objectForKey("userSettingValue") as? NSDictionary
                let reciveInfo = userSettingValue?.objectForKey("post") as? NCMBObject
                let pushM = pushManager()
                pushM.recivePushToLike(reciveInfo!)
            case "follow":
                print("リモートプッシュ通知受け取り: follow")
                let userSettingValue = remoteNotification.objectForKey("userSettingValue") as? NSDictionary
                let reciveInfo = userSettingValue?.objectForKey("user") as? NCMBUser
                let pushM = pushManager()
                pushM.recivePushToLike(reciveInfo!)
            case "comment":
                print("リモートプッシュ通知受け取り: comment")
                let userSettingValue = remoteNotification.objectForKey("userSettingValue") as? NSDictionary
                let reciveInfo = userSettingValue?.objectForKey("post") as? NCMBObject
                let pushM = pushManager()
                pushM.recivePushToLike(reciveInfo!)
            default:
                break
            }
            print("Remote Notification \(remoteNotification)")
        }

        // アプリアイコンのバッジをリセット
        print("前ｒ: アイコンのバッジ数", application.applicationIconBadgeNumber)
        application.applicationIconBadgeNumber = 0
        print("後: アイコンのバッジ数", application.applicationIconBadgeNumber)

        let storyboard:UIStoryboard =  UIStoryboard(name: "Main",bundle:nil)
        var viewController:UIViewController
        let user = NCMBUser.currentUser()
        
        //表示するビューコントローラーを指定
        if user != nil {
            print("appDelegate by ログイン済み")
            print("ユーザー情報: \(NCMBUser.currentUser())")
            //ユーザー情報を取ってくる
            user.fetchInBackgroundWithBlock({ (error: NSError!) -> Void in
                if error == nil {
                    self.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("firstViewController") as UIViewController
                    if let tabvc = self.window!.rootViewController as? UITabBarController  {
                        tabvc.selectedIndex = 0 // 0 が一番左のタブ (0＝Log画面)
                    }
                }else {
                    print("error: \(error)")
                    let virginViewController = storyboard.instantiateViewControllerWithIdentifier("virginViewController") as UIViewController
                    self.window?.rootViewController = virginViewController
                }
            })
        } else {
            print("appDelegate by ログインしてない")
            viewController = storyboard.instantiateViewControllerWithIdentifier("virginViewController") as UIViewController
            window?.rootViewController = viewController
        }

        /** Facebook連携 **/
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    //****** プッシュ通知設定 初め ******

//    デバイストークン取得時の処理
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = NCMBInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock(nil)
    }

    //ローカルプッシュ受信
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("起動中に受け取ったローカルプッシュ通知: " + notification.description)
        switch application.applicationState {
        case .Active:
            print("アプリ起動中にプッシュ通知受信（トースト表示を出す予定）")
        // アプリが起動している時に受信
        case .Inactive:
        // アプリがバックグラウンドで起動している時に通知タッチでフォアグラウンドに
            localPushRecieve(application, notification: notification)
        default:
            print(application.applicationState)
            break
        }

        //アプリがactive状態じゃない時だけローカルプッシュを受け取る
    }

    //ローカルプッシュ受信後のアクション
    func localPushRecieve(application: UIApplication, notification: UILocalNotification) {
        if let userInfo = notification.userInfo {
            switch userInfo["notifyId"] as? String {
            case .Some("logre"):
                print("logre")
                pushReciveToSubmit()

            //別ファイルに書いているがエラるためひとまずコメントアウト
                //                let pushM = pushManager()
            //                pushM.recivePushToLogToDay()

            default:
                break
            }
            // バッジをリセット
            application.applicationIconBadgeNumber = 0
            // 通知領域からこの通知を削除
            application.cancelLocalNotification(notification)
        }
    }

    func pushReciveToSubmit () {
        let submitSB = UIStoryboard(name: "Submit", bundle: nil)
        let submitVC = submitSB.instantiateViewControllerWithIdentifier("Submit") as! SubmitViewController
        self.window?.rootViewController!.presentViewController(submitVC, animated: true, completion: nil)
        if let tabvc = self.window!.rootViewController as? UITabBarController  {
            tabvc.selectedIndex = 0 // 0 が一番左のタブ (0＝Log画面)
        }
    }

    //リモートプッシュ受信
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        //アプリがactiveか、じゃないか
        if application.applicationState != UIApplicationState.Active{//activeじゃない
            print("非active中にリモートプッシュ通知: " + userInfo.description)
        }else {//active
            print("active中に受け取ったリモートプッシュ通知: " + userInfo.description)
        }
    }

    //アプリ終了時に呼ばれる
    func applicationDidEnterBackground(application: UIApplication) {
        let pushM = pushManager()
        pushM.pushToLogToDay(application)
    }

    //****** プッシュ通知設定 終わり ******

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    //アプリがバックグラウンドからactiveになる度に呼ばれる
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    //アプリが起動する度に呼ばれる
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        /** 追加① **/
        FBSDKAppEvents.activateApp()
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /** 追加③ **/
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
}


