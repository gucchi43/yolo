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
    
    //いいねしたNotificationのデータを削除する
    func deletelikeNotification(user: NCMBUser, post: NCMBObject, postHeader: String){
        let notificationObject = NCMBObject(className: "Notification")
        notificationObject.setObject(user, forKey: "ownerUser")
        notificationObject.setObject("like", forKey: "type")
        notificationObject.setObject(NCMBUser.currentUser(), forKey: "actionUser")
        let postRelation: NCMBRelation = NCMBRelation(className: notificationObject, key: "post")
        postRelation.addObject(post)
        notificationObject.setObject(postHeader, forKey: "postHeader")
        notificationObject.deleteEventually ({ (error) -> Void in
            if let error = error {
                print("error", error.localizedDescription)
            }else {
                print("like: Notificationへの削除成功")
            }
        })
    }
    
    
    //---------------フォロー---------------
    
    //フォローしたことを通知画面のデータに保存
    func followNotification(user: NCMBUser){
        let notificationObject = NCMBObject(className: "Notification")
        notificationObject.setObject(user, forKey: "ownerUser")
        notificationObject.setObject("follow", forKey: "type")
        notificationObject.setObject(NCMBUser.currentUser(), forKey: "actionUser")
        notificationObject.setObject(nil, forKey: "post")
        notificationObject.saveEventually({ (error) -> Void in
            if let error = error {
                print("error", error.localizedDescription)
            }else {
                print("follow: Notificationへの保存成功")
            }
        })
    }
    
    //フォローしたNotificationのデータを削除する
    func deleteFollowNotification(user: NCMBUser){
        let notificationObject = NCMBObject(className: "Notification")
        notificationObject.setObject(user, forKey: "ownerUser")
        notificationObject.setObject("follow", forKey: "type")
        notificationObject.setObject(NCMBUser.currentUser(), forKey: "actionUser")
        notificationObject.setObject(nil, forKey: "post")
        notificationObject.saveEventually({ (error) -> Void in
            if let error = error {
                print("error", error.localizedDescription)
            }else {
                print("follow: Notificationへの保存成功")
            }
        })
    }
    
    
    //---------------コメント---------------
    
    //commentしたことを通知画面のデータに保存
    func commentNotification(user: NCMBUser, post: NCMBObject, postHeader: String){
        let notificationObject = NCMBObject(className: "Notification")
        notificationObject.setObject(user, forKey: "ownerUser")
        notificationObject.setObject("comment", forKey: "type")
        notificationObject.setObject(NCMBUser.currentUser(), forKey: "actionUser")
        let postRelation: NCMBRelation = NCMBRelation(className: notificationObject, key: "post")
        postRelation.addObject(post)
        notificationObject.setObject(postHeader, forKey: "postHeader")
        notificationObject.deleteEventually({ (error) -> Void in
            if let error = error {
                print("error", error.localizedDescription)
            }else {
                print("comment: Notificationへの保存成功")
            }
        })

    }
    
    //コメントしたNotificationのデータを削除する
    func deleteCommentNotification(user: NCMBUser, post: NCMBObject, postHeader: String){
        let notificationObject = NCMBObject(className: "Notification")
        notificationObject.setObject(user, forKey: "ownerUser")
        notificationObject.setObject("comment", forKey: "type")
        notificationObject.setObject(NCMBUser.currentUser(), forKey: "actionUser")
        let postRelation: NCMBRelation = NCMBRelation(className: notificationObject, key: "post")
        postRelation.addObject(post)
        notificationObject.setObject(postHeader, forKey: "postHeader")
        notificationObject.deleteEventually({ (error) -> Void in
            if let error = error {
                print("error", error.localizedDescription)
            }else {
                print("comment: Notificationへの保存成功")
            }
        })
        
    }


}
