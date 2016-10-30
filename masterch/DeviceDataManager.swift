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
}
