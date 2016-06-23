//
//  NotificationManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/15.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class NotificationManager: NSObject {
    


    //---------------いいね---------------
    
    //いいねしたことを通知画面のデータに保存
    func likeNotification(user: NCMBUser, post: NCMBObject, postHeader: String){
        let notificationObject = NCMBObject(className: "Notification")
        notificationObject.setObject(user, forKey: "ownerUser")
        notificationObject.setObject("like", forKey: "type")
        notificationObject.setObject(NCMBUser.currentUser(), forKey: "actionUser")
        let postRelation: NCMBRelation = NCMBRelation(className: notificationObject, key: "post")
        postRelation.addObject(post)
        notificationObject.setObject(postHeader, forKey: "postHeader")
        notificationObject.saveEventually({ (error) -> Void in
            if let error = error {
                print("error", error.localizedDescription)
            }else {
                print("like: Notificationへの保存成功")
            }
        })
    }
    
    func deletelikeNotification(user: NCMBUser, post: NCMBObject){
        let query = NCMBQuery(className: "Notification")
        query.whereKey("ownerUser", equalTo: user)
        query.whereKey("type", equalTo: "like")
        query.whereKey("actionUser", equalTo: NCMBUser.currentUser())
        query.whereKey("postId", equalTo: post.objectId)
        query.getFirstObjectInBackgroundWithBlock { (object, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("オブジェクト", object)
                print("objectId", object.objectId)
                print("object", object)
                object.deleteEventually({ (error) in
                    if let error = error {
                        print("error", error.localizedDescription)
                        print("notificationObject", object)
                    }else {
                        
                        print("follow: Notificationへの削除成功")
                    }
                })
            }
        }
    }
    
    //---------------フォロー---------------
    
    //フォローしたことを通知画面のデータに保存
    func followNotification(user: NCMBUser){
        let notificationObject = NCMBObject(className: "Notification")
        notificationObject.setObject(user, forKey: "ownerUser")
        notificationObject.setObject("follow", forKey: "type")
        notificationObject.setObject(NCMBUser.currentUser(), forKey: "actionUser")
        notificationObject.setObject(nil, forKey: "postId")
        notificationObject.setObject(nil, forKey: "post")
        notificationObject.saveEventually({ (error) -> Void in
            if let error = error {
                print("error", error.localizedDescription)
            }else {
                print("follow: Notificationへの保存成功")
                print("notificationObject", notificationObject)
            }
        })
    }
    
    
    func deleteFollowNotification(user: NCMBUser){
        let query = NCMBQuery(className: "Notification")
        query.whereKey("ownerUser", equalTo: user)
        query.whereKey("type", equalTo: "follow")
        query.whereKey("actionUser", equalTo: NCMBUser.currentUser())
        query.whereKey("post", equalTo: nil)
        query.getFirstObjectInBackgroundWithBlock { (object, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("オブジェクト", object)
                print("objectId", object.objectId)
                print("object", object)
                object.deleteEventually({ (error) in
                    if let error = error {
                        print("error", error.localizedDescription)
                        print("notificationObject", object)
                    }else {
                        
                        print("follow: Notificationへの削除成功")
//                        print("notificationObject", object)
                    }
                })
            }
        }
    }
    
    
//    //フォローしたNotificationのデータを削除する(これじゃだめだった、一応参考に残す)
//    func deleteFollowNotification(user: NCMBUser){
//        let notificationObject = NCMBObject(className: "Notification")
//        notificationObject.setObject(user, forKey: "ownerUser")
//        notificationObject.setObject("follow", forKey: "type")
//        notificationObject.setObject(NCMBUser.currentUser(), forKey: "actionUser")
//        notificationObject.setObject(nil, forKey: "post")
//        notificationObject.deleteEventually({ (error) -> Void in
//            if let error = error {
//                print("error", error.localizedDescription)
//            }else {
//                
//                print("follow: Notificationへの削除成功")
//                print("notificationObject", notificationObject)
//            }
//        })
//    }
    
    
    //---------------コメント---------------
    
    //commentしたことを通知画面のデータに保存
    func commentNotification(user: NCMBUser, post: NCMBObject, postHeader: String){
        let notificationObject = NCMBObject(className: "Notification")
        notificationObject.setObject(user, forKey: "ownerUser")
        notificationObject.setObject("comment", forKey: "type")
        notificationObject.setObject(NCMBUser.currentUser(), forKey: "actionUser")
        notificationObject.setObject(post.objectId, forKey: "postId")
        let postRelation: NCMBRelation = NCMBRelation(className: notificationObject, key: "post")
        postRelation.addObject(post)
        notificationObject.setObject(postHeader, forKey: "postHeader")
        notificationObject.saveEventually({ (error) -> Void in
            if let error = error {
                print("error", error.localizedDescription)
            }else {
                print("comment: Notificationへの保存成功")
            }
        })

    }
    
    //コメントしたNotificationのデータを削除する
    func deleteCommentNotification(user: NCMBUser, post: NCMBObject){
        let notificationObject = NCMBObject(className: "Notification")
        notificationObject.setObject(user, forKey: "ownerUser")
        notificationObject.setObject("comment", forKey: "type")
        notificationObject.setObject(NCMBUser.currentUser(), forKey: "actionUser")
        notificationObject.setObject(post.objectId, forKey: "postId")
        notificationObject.deleteEventually({ (error) -> Void in
            if let error = error {
                print("error", error.localizedDescription)
            }else {
                print("comment: Notificationへの削除成功")
            }
        })
        
    }


}
