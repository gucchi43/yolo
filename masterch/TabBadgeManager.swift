//
//  TabBadgeManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/08/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB

class TabBadgeManager: NSObject {
//    var window: UIWindow?

    //タブにバッジを１付与する（サーバー上のデータ）
    func setTabBadg(user: NCMBUser) {
        let oldcurrentUserId = NCMBUser.currentUser()
        user.incrementKey("tabBadge")
        user.saveEventually { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("タブバーのバッジ数データ更新成功(+1)")
                print("一時的にcurrentUserがフォロー先Userになってる", NCMBUser.currentUser())
                //currentUserが変わっているので戻す
                oldcurrentUserId.saveInBackgroundWithBlock({ (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }else {
                        print("currentUserをフォロー先ユーザーからログインしているUserに戻す", NCMBUser.currentUser())
                    }
                })
            }
        }
    }

    //タブのバッジ数をリセットする（サーバー上のデータ）
    func resetTabBadge(user: NCMBUser){
        user.setObject(0, forKey: "tabBadge")
        user.saveEventually({ (error) in
            if let error = error{
                print(error.localizedDescription)
            }else {
                print("tabBadgeデータを0にリセット")
            }
        })
    }

    func getTabBadgeNumberQuery() -> NCMBQuery{
        let notificationQuery: NCMBQuery = NCMBQuery(className: "Notification")
        notificationQuery.whereKey("ownerUser", equalTo: NCMBUser.currentUser())
        notificationQuery.whereKey("readToggle", equalTo: 0)
        
        return notificationQuery
    }
}
