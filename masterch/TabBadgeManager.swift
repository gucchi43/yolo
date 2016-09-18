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
    
    //タブのバッジ数をリセットする（サーバー上のデータ）
    //現在("DBのuserクラスの)tabBadgeフィールドはつかってないためコメントアウト
//    func resetTabBadge(user: NCMBUser){
//        user.setObject(0, forKey: "tabBadge")
//        user.saveEventually({ (error) in
//            if let error = error{
//                print(error.localizedDescription)
//            }else {
//                print("tabBadgeデータを0にリセット")
//            }
//        })
//    }

    //Notificationにあるデータの中で未読なものだけ取ってくる
    func getTabBadgeNumberQuery() -> NCMBQuery{
        let notificationQuery: NCMBQuery = NCMBQuery(className: "Notification")
        notificationQuery.whereKey("ownerUser", equalTo: NCMBUser.currentUser())
        notificationQuery.whereKey("readToggle", equalTo: 0)
        
        return notificationQuery
    }
}
