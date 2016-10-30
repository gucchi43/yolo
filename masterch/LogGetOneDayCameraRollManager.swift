//
//  LogGetOneDayCameraRollManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/10/27.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import Photos
import SwiftDate

class LogGetOneDayCameraRollManager: NSObject {

    func getOnePicData(date: NSDate) {
        //その日のカメラロールの画像を取得する。
        let fromDate = self.filterDateStart(date)
        let toDate = self.filterDateEnd(date)
        // オプションを指定してフェッチします
        let fetchOption = PHFetchOptions()
        fetchOption.predicate = NSPredicate(format: "(creationDate >= %@) and (creationDate) < %@", fromDate, toDate)
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        print("fetchOption : ",fetchOption.description)
        var assets:PHFetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOption)
        print(assets.debugDescription)
        print("fromDate, assetsのカウント : ",fromDate, assets.count)
        assets.enumerateObjectsUsingBlock({ obj, idx, stop in

            if obj is PHAsset
            {
                let asset:PHAsset = obj as! PHAsset
                self.setAssetArry(asset)
            }
        })
    }

    func setAssetArry(asset: PHAsset) {
        DeviceDataManager.sharedSingleton.PicOneDayAssetArray.removeAll()
        DeviceDataManager.sharedSingleton.PicOneDayAssetArray.append(asset)
    }

//    func assetToImage(asset: PHAsset) {
//        let manager: PHImageManager = PHImageManager()
//        manager.requestImageForAsset(asset,
//                                     targetSize: CGSizeMake(500, 500),
//                                     contentMode: .AspectFill,
//                                     options: nil) { (image, info) -> Void in
//                                        // 取得したimageをUIImageViewなどで表示する
////                                        PicDataArray.sharedSingleton.PicOneDayImageArray.append(image!)
//        }
//    }

    //選択した日にちの00:00:00のNSDateをゲット（その日のタイムライン絞るのに使用）
    //引数無しの場合currentDateが使われる（LogViewなどから使われる）
    //引数ありの場合（LookBackから使われる）
    func filterDateStart(targetDate: NSDate) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!  // 24時間表示対策
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)

        let formatDate = formatter.dateFromString(String(targetDate.year) + "/" +
            String(targetDate.month) + "/" +
            String(targetDate.day) + " 00:00:00")!

        print("FilterDateStart", formatDate)
        return formatDate
    }

    //選択した日にちの23:59:59のNSDateをゲット（その日のタイムライン絞るのに使用）
    //引数無しの場合currentDateが使われる（LogViewなどから使われる）
    //引数ありの場合（LookBackから使われる）
    func filterDateEnd(targetDate: NSDate) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!  // 24時間表示対策
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)

        let formatDate = formatter.dateFromString(String(targetDate.year) + "/" +
            String(targetDate.month) + "/" +
            String(targetDate.day) + " 23:59:59")!

        print("FilterDateEnd", formatDate)
        return formatDate
    }

    func getMonthPicData(date: NSDate) {
        //その日のカメラロールの画像を取得する。
        let fromDate = self.filterMonthStart(date)
        let toDate = self.filterMonthEnd(date)
        // オプションを指定してフェッチします
        let fetchOption = PHFetchOptions()
        fetchOption.predicate = NSPredicate(format: "(creationDate >= %@) and (creationDate) < %@", fromDate, toDate)
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        print("fetchOption : ",fetchOption.description)
        var assets:PHFetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOption)
        print(assets.debugDescription)
        print("fromDate, assetsのカウント : ",fromDate, assets.count)
        assets.enumerateObjectsUsingBlock({ obj, idx, stop in

            if obj is PHAsset
            {
                let asset:PHAsset = obj as! PHAsset
                let keyString = (asset.creationDate!.toString(DateFormat.Custom("yyyy/MM")))!
                let dateString = (asset.creationDate!.toString(DateFormat.Custom("yyyyMMdd")))! + "&p"
                let keyWeekString = (asset.creationDate!.toString(DateFormat.Custom("yyyy")))! + String(asset.creationDate!.weekOfYear)

                self.setPicArrayData(keyString, dateString: dateString)
//                self.setPicWeekArrayData(keyWeekString, dateString: dateString)
            }
        })
    }

    //月別にその日写真があったかのDictionary
    //[yyyy/MM : yyyyMMddp, yyyyMMddp, yyyyMMddp, ...]
    func setPicArrayData(keyString: String, dateString: String) {
        //                        let dayString = created_at.substringToIndex(created_at.startIndex.advancedBy(3))

        if DeviceDataManager.sharedSingleton.PicDayDic[keyString]?.isEmpty == false { //keyがあるか？ value = [String]のはず
            //keyがあった時
            if (DeviceDataManager.sharedSingleton.PicDayDic[keyString]! as [String]).last != dateString { //valuesの中の最後が追加するStringと同じか？
                //Stringが違う時
                let newValues = DeviceDataManager.sharedSingleton.PicDayDic[keyString]! as [String] + [dateString]
                DeviceDataManager.sharedSingleton.PicDayDic.updateValue(newValues, forKey: keyString)
            }else {
                //Stringが同じ時
                print("もうこのValuesは追加されている")
            }
        } else {
            //keyがなかった時
            DeviceDataManager.sharedSingleton.PicDayDic.updateValue([dateString], forKey: keyString)
        }
    }

    //選択した日の月の初日の00:00:00のNSDateをゲット（その日のタイムライン絞るのに使用）
    //引数無しの場合currentDateが使われる（LogViewなどから使われる）
    //引数ありの場合（LookBackから使われる）
    func filterMonthStart(targetDate: NSDate) -> NSDate {

        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!  // 24時間表示対策
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)

        let formatDate = formatter.dateFromString(String(targetDate.year) + "/" +
            String(targetDate.month) + "/" +
            "01" + " 00:00:00")!

        print("FilterDateStart", formatDate)
        return formatDate
    }

    //選択した日にちの月の終日の23:59:59のNSDateをゲット（その日のタイムライン絞るのに使用）
    //引数無しの場合currentDateが使われる（LogViewなどから使われる）
    //引数ありの場合（LookBackから使われる）
    func filterMonthEnd(targetDate: NSDate) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!  // 24時間表示対策
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)

        let formatDate = formatter.dateFromString(String(targetDate.year) + "/" +
            String(targetDate.month) + "/" +
            String(targetDate.monthDays) + " 23:59:59")!

        print("FilterDateEnd", formatDate)
        return formatDate
    }
}

