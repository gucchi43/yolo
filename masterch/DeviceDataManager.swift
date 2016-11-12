//
//  DeviceDataManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/10/27.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import Photos


final class DeviceDataManager {
    private init() {
    }
    static let sharedSingleton = DeviceDataManager()

    var PicDayDic = [String: [String]]()
    var PicDayWeekDic = [String: [String]]()
//    var PicOneDayAssetArray = [String : [String : UIImage]]()
    var PicOneDayAssetArray = [PHAsset]()
    var PicOneDayImageArray = [UIImage]()

    //カメラロールへのアクセスのチェック
    func checkConnectCameraRoll() -> Bool{
        var status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.Authorized{
            print("status == PHAuthorizationStatusAuthorized")
            // Access has been granted.
            return true
        } else if status == PHAuthorizationStatus.Denied {
            print("status == PHAuthorizationStatusDenied")
            // Access has been denied.
            return false
        } else if status == PHAuthorizationStatus.NotDetermined {
            print("status == PHAuthorizationStatusNotDetermined")
            // Access has not been determined.
            return false
        } else if status == PHAuthorizationStatus.Restricted {
            print("status == PHAuthorizationStatusRestricted")
            // Restricted access - normally won't happen.
            return false
        }else {
            return false
        }
    }


}
