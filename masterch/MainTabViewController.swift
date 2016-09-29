//
//  MainTabBarController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/07/02.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB

class MainTabViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        //-------タブバーのデザイン------
        //タブバーのボタンを選択した時の色を設定
        self.tabBar.tintColor = ColorManager.sharedSingleton.mainColor()

    }

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        //押したタブ(item)にbadgeがあった場合、アプリ上、データベース上共にリセットする
        if item.badgeValue != nil{
            item.badgeValue = nil
        }

        switch item.tag {
        case 1://ログ
            print("tag ID = 1")
//            logManager.sharedSingleton.logUser = NCMBUser.currentUser()
            logManager.sharedSingleton.logNumber = 0
            logManager.sharedSingleton.logTitleToggle = true
        case 2://検索
            print("tag ID = 2")
//            logManager.sharedSingleton.logNumber = 2
            logManager.sharedSingleton.logTitleToggle = false
        case 3://タイムトリップ
            print("tag ID = 3")
        case 4://通知
            print("tag ID = 4")
            logManager.sharedSingleton.logTitleToggle = false
        case 5://アカウント
            print("tag ID = 5")
            logManager.sharedSingleton.logTitleToggle = false
        default:
            print("tag ID = デフォルトじゃいぼけい", item.tag)
        }
    }
}
