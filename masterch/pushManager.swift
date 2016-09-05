//
//  pushManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/08/01.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB
import SwiftDate

class pushManager: NSObject {

    var window: UIWindow?

    //いいねした時のプッシュ通知（post、受けるuser）
    func pushToLike(user: NCMBUser, post: NCMBObject, postText: String) {
        let push: NCMBPush = NCMBPush()
        let data : NSDictionary = ["contentAvailable":NSNumber(bool: false),
                                   "badgeIncrementFlag": NSNumber(bool: true),
                                   "sound": "default"]
        push.setData(data as [NSObject : AnyObject])

        let installationQuery = NCMBInstallation.query()
        installationQuery.whereKey("userObjectId", equalTo: user.objectId)
        push.setSearchCondition(installationQuery)

        push.setMessage("あなたのログが" + NCMBUser.currentUser().userName + "にいいねされたお😍" + "\n" + "「" + postText + "」")
        push.setUserSettingValue(["type": "like", "user" : user, "post": post])
        push.setBadgeIncrementFlag(true)
        push.setImmediateDeliveryFlag(true)
        push.setPushToIOS(true)

        push.sendPushInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("likeプッシュ通知送信")
                let TBManager = TabBadgeManager()
                TBManager.setTabBadg(user)
            }
        }
    }

    //コメントした時のプッシュ通知（post、受けるuser）
    func pushToComment(user: NCMBUser, post: NCMBObject, postText: String, commentText: String) {
        let push: NCMBPush = NCMBPush()
        let data : NSDictionary = ["contentAvailable":NSNumber(bool: false),
                                   "badgeIncrementFlag": NSNumber(bool: true),
                                   "sound": "default"]
        push.setData(data as [NSObject : AnyObject])

        let installationQuery = NCMBInstallation.query()
        installationQuery.whereKey("userObjectId", equalTo: user.objectId)
        push.setSearchCondition(installationQuery)

        push.setMessage("あなたのログに" + NCMBUser.currentUser().userName + "からコメントがきたお😆" + "\n" + commentText + "\n" + "「" + postText + "」")
        push.setUserSettingValue(["type": "comment", "user" : user, "post": post])
        push.setBadgeIncrementFlag(true)
        push.setImmediateDeliveryFlag(true)
        push.setPushToIOS(true)
        push.sendPushInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("commnetプッシュ通知送信")
                let TBManager = TabBadgeManager()
                TBManager.setTabBadg(user)
            }
        }
    }

    //フォローした時のプッシュ通知（受けるuser）
    func pushToFollow(user: NCMBUser) {
        print("push通知user", user)
        print("push通知userObjectId", user.objectId)
        let push: NCMBPush = NCMBPush()
        let data : NSDictionary = ["contentAvailable":NSNumber(bool: false),
                                   "badgeIncrementFlag": NSNumber(bool: true),
                                   "sound": "default"]
        push.setData(data as [NSObject : AnyObject])

        let installationQuery = NCMBInstallation.query()
        installationQuery.whereKey("userObjectId", equalTo: user.objectId)
        push.setSearchCondition(installationQuery)

        push.setMessage(NCMBUser.currentUser().userName + "にフォローされたお😏")
        push.setCategory("follow")
        push.setUserSettingValue(["type": "follow", "user" : user])
        push.setBadgeIncrementFlag(true)
        push.setImmediateDeliveryFlag(true)
        push.setPushToIOS(true)
        push.sendPushInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("followプッシュ通知送信")
                let TBManager = TabBadgeManager()
                TBManager.setTabBadg(user)
            }
        }
    }

    //1ヶ月前に投稿があった時のプッシュ通知（受けるuser）
    func pushToMonthkAgoPost() {
        let push: NCMBPush = NCMBPush()
        let data : NSDictionary = ["contentAvailable":NSNumber(bool: false),
                                   "badgeIncrementFlag": NSNumber(bool: true),
                                   "sound": "default"]
        push.setData(data as [NSObject : AnyObject])

        let installationQuery = NCMBInstallation.query()
        installationQuery.whereKey("userObjectId", equalTo: NCMBUser.currentUser().objectId)
        push.setSearchCondition(installationQuery)

        push.setMessage("タタタターン! 一ヶ月前にこんなログをしていたお")
        push.setImmediateDeliveryFlag(true)
        push.setPushToIOS(true)
        push.sendPushInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("backPostプッシュ通知送信")
            }
        }
    }

    //1年前に投稿があった時のプッシュ通知（受けるuser）
    func pushToYearAgoPost() {
        let push: NCMBPush = NCMBPush()
        let data : NSDictionary = ["contentAvailable":NSNumber(bool: false),
                                   "badgeIncrementFlag": NSNumber(bool: true),
                                   "sound": "default"]

        push.setData(data as [NSObject : AnyObject])

        let installationQuery = NCMBInstallation.query()
        installationQuery.whereKey("userObjectId", equalTo: NCMBUser.currentUser().objectId)
        push.setSearchCondition(installationQuery)

        push.setMessage("パパパパーン! 一年前にこんなログをしていたお")
        push.setImmediateDeliveryFlag(true)
        push.setPushToIOS(true)
        push.sendPushInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("backPostプッシュ通知送信")
            }
        }
    }

    //ローカル通知
    //今日のログを残そうのプッシュ通知
    func pushToLogToDay(application: UIApplication) {

        // ローカルpush設定
        // 登録済みのスケジュールをすべてリセット
        application.cancelAllLocalNotifications()

        var notification = UILocalNotification()
        notification.alertAction = "アプリに戻る"
        notification.alertBody = "今日はどんな１日だった？今日の出来事をログっちゃおう😇"
        notification.timeZone = NSTimeZone.defaultTimeZone()

        //今の時間から毎日21時にアラート出すカレンダーを設定する
        let now = NSDate()
        print(now)
        let calendar = NSCalendar(identifier: NSCalendarIdentifierJapanese)
        let comps:NSDateComponents = calendar!.components([NSCalendarUnit.Year, .Month, .Day], fromDate: now)
        comps.calendar = calendar
        comps.hour = 21

        if now.compare(comps.date!) != .OrderedAscending {
            comps.day += 1
        }
        let now2 = comps.date
        print(now2!)
        notification.fireDate = now2
        notification.repeatInterval = NSCalendarUnit.Day
        
        notification.soundName = UILocalNotificationDefaultSoundName
        // アイコンバッジに1を表示
        notification.applicationIconBadgeNumber = 1
        // あとのためにIdを割り振っておく
        notification.userInfo = ["notifyId": "logre"]
        application.scheduleLocalNotification(notification)

    }

    func recivePushToLike(postId: String) {
        let post = NCMBObject(className: "post")
        post.objectId = postId
        post.fetchInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("likeプッシュ受け取り成功")
                let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
                    print("like受け取り後の遷移成功")
                    tabBarController.selectedIndex = 3
                    let notificationNVC = tabBarController.viewControllers![3] as! UINavigationController
                    tabBarController.selectedViewController = notificationNVC
                    notificationNVC.popToRootViewControllerAnimated(false)
                    notificationNVC
                    let notificationVC = notificationNVC.viewControllers[0] as! NotificationTableViewController
                    notificationVC.selectedObject = post
                    notificationVC.performSegueWithIdentifier("toPostDetailVC", sender: nil)

                }else {
                    print("like受け取り後の遷移失敗")
                }
            }
        }
    }

    func recivePushToFollow(userId: String) {
        let user = NCMBUser()
        user.objectId = userId
        user.fetchInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("followプッシュ受け取り成功")
                let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
                    print("follow受け取り後の遷移成功")
                    tabBarController.selectedIndex = 3
                    let notificationNVC = tabBarController.viewControllers![3] as! UINavigationController
                    tabBarController.selectedViewController = notificationNVC
                    notificationNVC.popToRootViewControllerAnimated(false)
                    notificationNVC
                    let notificationVC = notificationNVC.viewControllers[0] as! NotificationTableViewController
                    notificationVC.selectedUser = user
                    notificationVC.performSegueWithIdentifier("toAccountVC", sender: nil)

                }else {
                    print("follow受け取り後のレシーブ後の遷移失敗")
                }
            }
        }
    }

    func recivePushToComment(postId: String) {
        let post = NCMBObject(className: "post")
        post.objectId = postId
        post.fetchInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("commentプッシュ受け取り成功")
                let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
                    print("follow受け取り後の遷移成功")
                    tabBarController.selectedIndex = 3
                    let notificationNVC = tabBarController.viewControllers![3] as! UINavigationController
                    tabBarController.selectedViewController = notificationNVC
                    notificationNVC.popToRootViewControllerAnimated(false)
                    notificationNVC
                    let notificationVC = notificationNVC.viewControllers[0] as! NotificationTableViewController
                    notificationVC.selectedObject = post
                    notificationVC.performSegueWithIdentifier("toPostDetailVC", sender: nil)

                }else {
                    print("comment受け取り後のレシーブ後の遷移失敗")
                }
            }
        }
    }


    func recivePushToLogToDay () {
        let submitSB = UIStoryboard(name: "Submit", bundle: nil)
        let submitVC = submitSB.instantiateViewControllerWithIdentifier("Submit") as! SubmitViewController
        self.window?.rootViewController!.presentViewController(submitVC, animated: true, completion: nil)
        if let tabvc = self.window!.rootViewController as? UITabBarController  {
            tabvc.selectedIndex = 0 // 0 が一番左のタブ (0＝Log画面)
        }
    }
}

