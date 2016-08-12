//
//  TabBadgeManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/08/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class TabBadgeManager: NSObject {
    var window: UIWindow?

    func setTabBadg(user: NCMBUser) {
        user.incrementKey("tabBadge")
        user.saveEventually { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("タブバーのバッジ数データ更新成功(+1)")
            }
        }
    }

}
