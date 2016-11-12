//
//  ConnectCameraRollViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/11/12.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB
import Photos
import SVProgressHUD

class ConnectCameraRollViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.Authorized{
            print("status == PHAuthorizationStatusAuthorized")
            // Access has been granted.

        } else if status == PHAuthorizationStatus.Denied {
            print("status == PHAuthorizationStatusDenied")
            // Access has been denied.

        } else if status == PHAuthorizationStatus.NotDetermined {
            print("status == PHAuthorizationStatusNotDetermined")
            // Access has not been determined.
//            PHPhotoLibrary.requestAuthorization({ (status) in
//                if (status == PHAuthorizationStatusAuthorized) {
//                    // Access has been granted.
//                }
//                else {
//                    // Access has been denied.
//                }
//            })
        } else if status == PHAuthorizationStatus.Restricted {
            print("status == PHAuthorizationStatusRestricted")
            // Restricted access - normally won't happen.
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    @IBAction func tapSkipButton(sender: AnyObject) {
        print("スキップボタンタップ")
    }
    @IBAction func tapConnectCameraRollButton(sender: AnyObject) {
        PHPhotoLibrary.requestAuthorization({ (status) in
            if (status == PHAuthorizationStatus.Authorized) {
                // Access has been granted.
                print("カメラロール連携許可した！")
                self.changeUserStatusToConectCameraRool()
            }
            else {
                // Access has been denied.
                print("カメラロール連携を許可しなかった")
            }
        })
    }

    func getCameraRoll () {
        //カメラロールのLogArrayを全てゲット
        let logGetOneDayCameraRollManager = LogGetOneDayCameraRollManager()
        logGetOneDayCameraRollManager.getAllPicDic()
    }

    func changeUserStatusToConectCameraRool() {

//        SVProgressHUDMaskType.Clear
        SVProgressHUD.showWithStatus("カメラロール読み込み中")

        getCameraRoll()
        SVProgressHUD.dismiss()
        goNextViewController()

//        if let user = NCMBUser.currentUser() {
//            SVProgressHUD.showWithStatus("カメラロール読み込み中")
//            user.setObject(true, forKey: "cameraRoolLink")
//            user.saveInBackgroundWithBlock({ (error) in
//                if let error = error {
//                    print("cameraRoolLinkのリンクに失敗")
//                    SVProgressHUD.showErrorWithStatus("連携失敗…")
//                }else {
//                    print("cameraRoolLinkのリンク成功")
//                    getCameraRoll()
//                    SVProgressHUD.showSuccessWithStatus("連携成功!!")
//                }
//            })
//        }else {
//            print("カレントユーザーがない")
//        }
    }

    func goNextViewController() {
        self.performSegueWithIdentifier("toMainView", sender: self)
    }
}
