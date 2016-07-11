//
//  MainTabBarController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/07/02.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {

        if viewController is SubmitDummyViewController {

            if let currentVC = self.selectedViewController {
                let storyboard = UIStoryboard(name: "Submit", bundle: nil)
                let modalVC = storyboard.instantiateViewControllerWithIdentifier("Submit") as? SubmitViewController
                //選択しているタブが０番目（logVC）の場合、選択している日付を受け渡す
                if self.selectedIndex as Int == 0{
                    modalVC?.postDate = CalendarManager.currentDate
                    modalVC?.postPickerDate = CalendarManager.currentDate
//                    modalVC?.delegate = LogViewController()

                }else {
                    print("何番目",self.selectedIndex as Int)
                }
                currentVC.presentViewController(modalVC!, animated: true, completion: nil)
            }
            return false
        }
        return true
    }

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
//        if selectedIndex as Int == 0{
//            print("selectedIndex as Int",selectedIndex as Int)
//            logManager.sharedSingleton.logNumber = 0
//            logManager.sharedSingleton.logUser = NCMBUser.currentUser()
//        }else {
//            print("selectedIndex as Int",selectedIndex as Int)
//        }

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
        case 3://投稿
            print("tag ID = 3")
        case 4://通知
            print("tag ID = 4")
        case 5://アカウント
            print("tag ID = 5")
            logManager.sharedSingleton.logTitleToggle = false
        default:
            print("tag ID = デフォルトじゃいぼけい", item.tag)
        }
    }

}
