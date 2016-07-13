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

        //-------タブバーのデザイン------
        //タブバーのボタンを選択した時の色を設定
        self.tabBar.tintColor = ColorManager.sharedSingleton.mainColor()
        //Submitのボタンだけデフォルトで色付きでのせるためオリジナルの画像を表示
        let submitTabButton = self.tabBar.items![2]
        submitTabButton.image = UIImage(named: "tabSubmit")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    }

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if viewController is SubmitDummyViewController {
            if let selectedViewController = self.selectedViewController {
                let storyboard = UIStoryboard(name: "Submit", bundle: nil)
                let submitViewController = storyboard.instantiateViewControllerWithIdentifier("Submit") as! SubmitViewController
                
                //選択しているタブが0番目（LogViewController）の場合、選択している日付を受け渡す
                if self.selectedIndex as Int == 0 {
                    let navigation = selectedViewController as! UINavigationController
                    submitViewController.delegate = navigation.topViewController as! LogViewController
                    submitViewController.postDate = CalendarManager.currentDate
                    submitViewController.postPickerDate = CalendarManager.currentDate
                }else {
                    print("何番目",self.selectedIndex as Int)
                }
                selectedViewController.presentViewController(submitViewController, animated: true, completion: nil)
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
