//
//  pushManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/08/01.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class pushManager: NSObject {

    //いいねした時のプッシュ通知（post、受けるuser）
    func pushToLike(user: NCMBUser, postText: String) {
        let push: NCMBPush = NCMBPush()
        let data : NSDictionary = ["contentAvailable":NSNumber(bool: false),
                                   "badgeIncrementFlag": NSNumber(bool: true),
                                   "sound": "default"]
//        let testQuery: NCMBQuery = NCMBQuery(className: "Notification")
//        testQuery.whereKey("type", equalTo: "like")
//        testQuery.whereKey("actionUser", equalTo: NCMBUser.currentUser())
//        testQuery.whereKey("ownerUser", equalTo: user)

        push.setData(data as [NSObject : AnyObject])
        push.setMessage("あなたのログに" + NCMBUser.currentUser().userName + "にいいねされたお" + postText)
        push.setImmediateDeliveryFlag(true)
        push.setPushToIOS(true)
        push.sendPushInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("likeプッシュ通知送信")
            }
        }
    }

    //コメントした時のプッシュ通知（post、受けるuser）
    func pushToComment(user: NCMBUser, postText: String) {
        let push: NCMBPush = NCMBPush()
        let data : NSDictionary = ["contentAvailable":NSNumber(bool: false),
                                   "badgeIncrementFlag": NSNumber(bool: true),
                                   "sound": "default"]

        push.setData(data as [NSObject : AnyObject])
        push.setMessage("あなたのログに" + NCMBUser.currentUser().userName + "がコメントしたお" + postText)
        push.setImmediateDeliveryFlag(true)
        push.setPushToIOS(true)
        push.sendPushInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("commnetプッシュ通知送信")
            }
        }
    }

    //フォローした時のプッシュ通知（受けるuser）
    func pushToFollow(user: NCMBUser) {
        let push: NCMBPush = NCMBPush()
        let data : NSDictionary = ["contentAvailable":NSNumber(bool: false),
                                   "badgeIncrementFlag": NSNumber(bool: true),
                                   "sound": "default"]

        push.setData(data as [NSObject : AnyObject])
        push.setMessage(NCMBUser.currentUser().userName + "にフォローされたお")
        push.setImmediateDeliveryFlag(true)
        push.setPushToIOS(true)
        push.sendPushInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("followプッシュ通知送信")
            }
        }
    }

    //1ヶ月前に投稿があった時のプッシュ通知（受けるuser）
    func pushToMonthkAgoPost(user: NCMBUser) {
        let push: NCMBPush = NCMBPush()
        let data : NSDictionary = ["contentAvailable":NSNumber(bool: false),
                                   "badgeIncrementFlag": NSNumber(bool: true),
                                   "sound": "default"]

        push.setData(data as [NSObject : AnyObject])
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
    func pushToYearAgoPost(user: NCMBUser) {
        let push: NCMBPush = NCMBPush()
        let data : NSDictionary = ["contentAvailable":NSNumber(bool: false),
                                   "badgeIncrementFlag": NSNumber(bool: true),
                                   "sound": "default"]

        push.setData(data as [NSObject : AnyObject])
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

    //今日のログを残そうのプッシュ通知
    func pushToLogToDay(user: NCMBUser) {
        let push: NCMBPush = NCMBPush()
        let data : NSDictionary = ["contentAvailable":NSNumber(bool: false),
                                   "badgeIncrementFlag": NSNumber(bool: true),
                                   "sound": "default"]
        
        push.setData(data as [NSObject : AnyObject])
        push.setMessage("今日はどんな1日だった？思い出をログっちゃおう")
        push.setImmediateDeliveryFlag(true)
        push.setPushToIOS(true)
        push.sendPushInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("logreプッシュ通知送信")
            }
        }
    }


}
