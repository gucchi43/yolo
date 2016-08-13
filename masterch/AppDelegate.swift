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

        // アプリアイコンのバッジをリセット
        print("前ｒ: アイコンのバッジ数", application.applicationIconBadgeNumber)
        application.applicationIconBadgeNumber = 0
        print("後: アイコンのバッジ数", application.applicationIconBadgeNumber)

        //push通知の設定のおまじない（通知許可を取る）
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
            application.registerForRemoteNotifications()
        }

        //(ローカルプッシュ通知)アプリが起動していない時にpush通知が届き、push通知から起動した場合
        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            localPushRecieve(application, notification: notification)
        }
        //(リモートプッシュ通知)アプリが起動していない時にpush通知が届き、push通知から起動した場合
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            //アイコンバッジ数をリセット(Niftyのデータベース側)
            NCMBAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            //タブバーにバッジを設置
            if let tabBarController = self.window?.rootViewController as? UITabBarController {
                if NCMBUser.currentUser().objectForKey("tabBadge") as? Int > 0{
                    let tabBadgeNumber = NCMBUser.currentUser().objectForKey("tabBadge") as! Int
                    tabBarController.tabBar.items![3].badgeValue = String(tabBadgeNumber)
                }
            }
            let payload : [NSObject : AnyObject] = launchOptions!["UIApplicationLaunchOptionsRemoteNotificationKey"] as! [NSObject : AnyObject]
            let type = payload["type"] as! String
            switch type {
            case "like":
                print("リモートプッシュ通知受け取り: like")
                let post = payload["post"] as? NSDictionary
                let postObjectId = post!.objectForKey("objectId") as! String
                let pushM = pushManager()
                pushM.recivePushToLike(postObjectId)
            case "follow":
                print("リモートプッシュ通知受け取り: follow")
                let user = payload["user"] as! NSDictionary
                let userObjectId = user.objectForKey("objectId") as! String
                let pushM = pushManager()
                pushM.recivePushToFollow(userObjectId)
            case "comment":
                print("リモートプッシュ通知受け取り: comment")
                let post = payload["post"] as? NSDictionary
                let postObjectId = post!.objectForKey("objectId") as! String
                let pushM = pushManager()
                pushM.recivePushToComment(postObjectId)
            default:
                break
            }
            print("Remote Notification \(remoteNotification)")
        }

        //(プッシュ通知無し) 最初に表示するViewを切り替える（ログイン済み or 未ログイン）
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
                    let firstVC = storyboard.instantiateViewControllerWithIdentifier("firstVC") as UIViewController
                    self.window?.rootViewController = firstVC
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

//                別ファイルに書いているがエラるためひとまずコメントアウト
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
        //バッジをリセット
        NCMBAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        //タブバーにバッジを設置
        if let tabBarController = self.window?.rootViewController as? UITabBarController {
            print("タブバー表示時のカレントユーザー", NCMBUser.currentUser().userName)
            if NCMBUser.currentUser().objectForKey("tabBadge") as? Int > 0{
                let tabBadgeNumber = NCMBUser.currentUser().objectForKey("tabBadge") as! Int
                print("tabBadgeNumber", tabBadgeNumber)
                tabBarController.tabBar.items![3].badgeValue = String(tabBadgeNumber)
            }
        }
        //アプリがactiveか、じゃないか
        switch application.applicationState {
        case .Inactive:
            print("非active中にリモートプッシュ通知: " + userInfo.description)
            let user = userInfo["user"] as? NSDictionary
            let userName = user?.objectForKey("className") as! String
            let objectId = user?.objectForKey("objectId") as! String
            print("user\(user)")
            print("userName\(userName)")
            print("objectId\(objectId)")
            let type = userInfo["type"] as! String
            print("type", type)
                switch type {
                case "like":
                    print("リモートプッシュ通知受け取り: like")
                    let post = userInfo["post"] as? NSDictionary
                    let postObjectId = post!.objectForKey("objectId") as! String
                    let pushM = pushManager()
                    pushM.recivePushToLike(postObjectId)
                case "follow":
                    print("リモートプッシュ通知受け取り: follow")
                    let user = userInfo["user"] as! NSDictionary
                    let userObjectId = user.objectForKey("objectId") as! String
                    let pushM = pushManager()
                    pushM.recivePushToFollow(userObjectId)
                case "comment":
                    print("リモートプッシュ通知受け取り: comment")
                    let post = userInfo["post"] as? NSDictionary
                    let postObjectId = post!.objectForKey("objectId") as! String
                    let pushM = pushManager()
                    pushM.recivePushToComment(postObjectId)
                default:
                    break
                }
        case .Active:
            print("active中に受け取ったリモートプッシュ通知: " + userInfo.description)
        default:
            break
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
        //表示上のアプリアイコンバッジリセット
        //バッジ数をリセット
        application.applicationIconBadgeNumber = 0
        //サーバー上のアプリアイコンバッジリセット
        let userInstallation = NCMBInstallation.currentInstallation()
        userInstallation.badge = 0
        userInstallation.saveInBackgroundWithBlock { (error) in
            if let error = error {
                //データベース内でのバッジ数リセット
                print(error.localizedDescription)
            }else {
                print("userInstallation.badge", userInstallation.badge)
            }
        }
        //タブバーにバッジを設置
        if let tabBarController = self.window?.rootViewController as? UITabBarController {
            if NCMBUser.currentUser().objectForKey("tabBadge") as? Int > 0{
                let tabBadgeNumber = NCMBUser.currentUser().objectForKey("tabBadge") as! Int
                tabBarController.tabBar.items![3].badgeValue = String(tabBadgeNumber)
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /** 追加③ **/
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
}


