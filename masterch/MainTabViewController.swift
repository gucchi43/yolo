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
                let modalVC = storyboard.instantiateViewControllerWithIdentifier("Submit")
                currentVC.presentViewController(modalVC, animated: true, completion: nil)
            }
            return false
        }
        return true
    }

}
