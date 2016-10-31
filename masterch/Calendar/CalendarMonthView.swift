//
//  CalendarMonthView.swift
//  CrossCalendarSample
//
//  Created by Eisuke Sato on 2016/02/19.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit
import NCMB
import SwiftDate

class CalendarMonthView: UIView, WeekCalendarDateViewDelegate {
    var selectedButton: UIButton!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, date: NSDate) {
        super.init(frame:frame)
        startSetUpDays(date)
    }

    //setUpDaysの前に呼ぶ（真ん中の月だけgetLogColorを呼び出す）
    func startSetUpDays(date:NSDate) {
        setUpDays(date)
        if date.year == CalendarManager.currentDate.year && date.month == CalendarManager.currentDate.month {
            getLogColorDate(date)
        }
    }

    func setUpDays(date: NSDate) {
        // 既にセットされてるdayViewの削除
        let subViews:[UIView] = self.subviews as [UIView]
        for view in subViews {
            if view.isKindOfClass(CalendarSwiftDateView) {
                view.removeFromSuperview()
            }
        }

        let dayViewSize = CGSize(width: Int(frame.size.width / 7.0), height: Int(frame.size.width / 7.0))
        let lastDay = date.monthDays

        for i in 0 ..< lastDay {
            let mDate = date + i.days
            let week = mDate.weekOfMonth  // 何週目か
            let x = (mDate.weekday - 1) * Int(dayViewSize.width)  // 曜日ごとにxの位置をずらす
            let y = (week - 1) * Int(dayViewSize.height)  // 週毎にyの位置をずらす
            let frame = CGRect(origin: CGPoint(x: x, y: y), size: dayViewSize)// frameの確定
            let dayView = CalendarSwiftDateView(frame: frame, date: mDate)
            dayView.delegate = self
            self.addSubview(dayView)
        }
    }

    //LogViewの日にちごとの色を決める実行部分(month版)
    func getLogColorDate(date: NSDate) {
        //logNumberの決定(プルダウンがあるか、ないかで変わる)
        let logNumber: Int
        if logManager.sharedSingleton.logTitleToggle == true{
            logNumber = logManager.sharedSingleton.tabLogNumber
        }else {
            logNumber = logManager.sharedSingleton.logNumber
        }

        //Queryの作成
        let logUser = logManager.sharedSingleton.logUser
        let calendarLogCollerManager = CalendarLogCollerManager()
        let logColorQuery: NCMBQuery
        if logUser == NCMBUser.currentUser(){
            print("user情報 in monthVC(自分のログの時)", logUser.userName)
            //monthLogColorDateはuserを引数に取らない場合userにはNCMBUser.currentUser()が自動で入る
            logColorQuery = calendarLogCollerManager.monthLogColorDate(date, logNumber: logNumber)
        }else {
            print("user情報 in monthVC(自分のログじゃない時)", logUser.userName)
            logColorQuery = calendarLogCollerManager.monthLogColorDate(date, logNumber: logNumber, user: logUser)
        }

        //キャッシュがあったらそれ読み込み、なかったらQueryロード
        let logUserName = logUser.userName
        let monthKey = CalendarManager.getDateYearAndMonth(date)
        let key = String(logNumber) + logUserName + String(monthKey)
        switch logNumber {
        case 0: //自分の時
            print("myMonthLogColorCache", CalendarLogColorCache.sharedSingleton.myMonthLogColorCache)
            if let cashLogColorArray = CalendarLogColorCache.sharedSingleton.myMonthLogColorCache.objectForKey(key) as? [String] {
                print("cashLogColorArray", cashLogColorArray)
                self.setLogDateTag(cashLogColorArray, logNumber: logNumber)
            }
            else {
                let getCameraRollArrayManager = LogGetOneDayCameraRollManager()
                //カメラロールアイコンのデータをシングルトンに持つ
                getCameraRollArrayManager.getMonthPicData(date)
                //カメラロールのアイコン載せる処理
//                cameraRollArrayLoad(date)
                manyLogColorQueryLoad(logColorQuery, logNumber: logNumber)
            }
        default: //自分の時以外
            print("otherMonthLogColorCache", CalendarLogColorCache.sharedSingleton.otherMonthLogColorCache)
            if let cashLogColorArray = CalendarLogColorCache.sharedSingleton.otherMonthLogColorCache.objectForKey(key) as? [String]{
                print("cashLogColorArray", cashLogColorArray)
                self.setLogDateTag(cashLogColorArray, logNumber: logNumber)
                manyLogColorQueryLoad(logColorQuery, logNumber: logNumber)
            }else {
                manyLogColorQueryLoad(logColorQuery, logNumber: logNumber)
            }
        }
    }

    func cameraRollArrayLoad(date: NSDate) {
        let keyString = (date.toString(DateFormat.Custom("yyyy/MM")))!
        if let objects = DeviceDataManager.sharedSingleton.PicDayDic[keyString] {
                self.setLogDateTag(objects, logNumber: 0)
        }

    }

    //logColorのQueryを非同期で読み込む
    func manyLogColorQueryLoad(query: NCMBQuery, logNumber: Int){
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if objects != nil && objects.isEmpty == false{
                    for object in objects {
                        let logColorArray = object.objectForKey("logDateTag") as! [String]
                        if logNumber == 0 {
                            let keyString = (CalendarManager.currentDate.toString(DateFormat.Custom("yyyy/MM")))!
                            if let cameraRollArray = DeviceDataManager.sharedSingleton.PicDayDic[keyString]{
                                self.cameraRollArrayLoad(CalendarManager.currentDate)
                                self.setLogDateTag(logColorArray, logNumber: logNumber)
                                self.saveTotalCasheArray(logNumber, ncmbArray: logColorArray, cameraRollArray: cameraRollArray)
                            }else {
                                self.setLogDateTag(logColorArray, logNumber: logNumber)
                                self.saveTotalCasheArray(logNumber, ncmbArray: logColorArray)
                            }
                        }else {
                            self.setLogDateTag(logColorArray, logNumber: logNumber)
                            self.saveLogColorCashArray(logColorArray, logNumber: logNumber)
                        }
                    }
                }else {
                    print("今月のNCMBの投稿はまだない")
                    if logNumber == 0 {
                        let keyString = (CalendarManager.currentDate.toString(DateFormat.Custom("yyyy/MM")))!
                        if let cameraRollArray = DeviceDataManager.sharedSingleton.PicDayDic[keyString]{
                            self.cameraRollArrayLoad(CalendarManager.currentDate)
                            self.saveTotalCasheArray(logNumber, cameraRollArray: cameraRollArray)
                        }else {
                            self.saveTotalCasheArray(logNumber)
                        }
                    }else {
//                        self.saveLogColorCashArray(logColorArray, logNumber: logNumber)
//                        self.setLogDateTag(logColorArray, logNumber: logNumber)
                    }

                }
            }
        }
    }

    func saveTotalCasheArray(logNumaber : Int, ncmbArray: [String] = [], cameraRollArray: [String] = []) {
        if logNumaber == 0{
            print("ncmbArray", ncmbArray)
            print("cameraRollArray", cameraRollArray)

            var dateStartInt = Int((CalendarManager.currentDate.toString(DateFormat.Custom("yyyyMM")))! + "01")!
            let lastDays = CalendarManager.currentDate.monthDays
            var totalArray = [String]()
            for i in 1...lastDays{
                let cameraValue = cameraRollArray.filter { $0.containsString(String(dateStartInt)) ==  true }
                let ncmbValue = ncmbArray.filter { $0.containsString(String(dateStartInt)) ==  true }
                print("dateStartInt, ncmbValue : ",dateStartInt, ncmbValue)

                if cameraValue.isEmpty == true {
                    if ncmbValue.isEmpty == true {
                        //カメラ無し、NCMBなし
                        //何も追加しない
                        print("カメラ無し、NCMB無し", dateStartInt)
                    }else {
                        //カメラ無し、NCMBあり
                        //NCMBそのまま追加
                        print("カメラ無し、NCMBあり = NCMB表示", dateStartInt)
                        totalArray.append(ncmbValue.first!)
                    }
                }else {
                    if ncmbValue.isEmpty == true {
                        //カメラあり、NCMBなし
                        //カメラそのまま追加
                        print("カメラあり、NCMB無し = カメラ表示", dateStartInt)
                        totalArray.append(cameraValue.first!)
                    }else{
                        //カメラあり、NCあり
                        //カメラとNCMB合成
                        print("カメラあり、NCMBあり = NCMB表示", dateStartInt)
                        totalArray.append(ncmbValue.first! + "&p")
                    }
                }
                dateStartInt += 1
            }
//            setLogDateTag(totalArray, logNumber: 0)
            saveLogColorCashArray(totalArray, logNumber: 0)
        }
    }

    //logColorのキャッシュを保存
    func saveLogColorCashArray(logColorArray: [String], logNumber: Int) {
        let logUserName = logManager.sharedSingleton.logUser.userName
        let monthKey = CalendarManager.getDateYearAndMonth(CalendarManager.currentDate)
        let key = String(logNumber) + logUserName + String(monthKey)
        switch logNumber {
        case 0:
            CalendarLogColorCache.sharedSingleton.updateMyMonthLogLogColorCache(logColorArray, key: key)
        default:
            CalendarLogColorCache.sharedSingleton.updateOtherMonthLogColorCache(logColorArray, key: key)
        }
    }

    //logColorの配列から日付ごとにアイコンを配置していく
    func setLogDateTag (logColorArray: [String], logNumber: Int) {
        for logColorObject in logColorArray {
            let logColorObjectArray = logColorObject.componentsSeparatedByString("&")
            print("logColorObjectArray", logColorObjectArray)
            let dayViewTag = Int(logColorObjectArray[0])
            let dayColor = logColorObjectArray[1]
            if let dayView = self.viewWithTag(dayViewTag!) as? CalendarSwiftDateView {
                if logNumber == 1 { //複数人のためアイコンを１つに統一
                    dayView.selectDateColor("😎")
                }else {
                    if dayColor == "p" {
                        dayView.selectDateColor("📸")
                    }else {
                        dayView.selectDateColor(dayColor)
                    }
                }
            }
        }
    }

    //日にち押すと
    func updateDayViewSelectedStatus() {
        let subViews:[UIView] = self.subviews as [UIView]
        for view in subViews {
            if view.isKindOfClass(CalendarSwiftDateView) {
                let dateView = view as! CalendarSwiftDateView
                if dateView.date == CalendarManager.currentDate {
                    dateView.changeSelectDayButton(dateView.dayButton)
                    print(dateView.date)
                } else {
                    dateView.changeDefaultDayButton(dateView.dayButton)

                }
            }
        }
    }
}
