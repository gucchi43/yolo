//
//  CalendarWeekView.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/02/28.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB
import SwiftDate

class CalendarWeekView: UIView, WeekCalendarDateViewDelegate {
    var selectedButton: UIButton!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, date: NSDate) {
        super.init(frame:frame)
        startSetUpDays(date)
    }

    //setUpDaysの前に呼ぶ（真ん中の週だけgetLogColorを呼び出す）
    func startSetUpDays(date:NSDate) {
        setUpDays(date)
        if date.yearForWeekOfYear == CalendarManager.currentDate.yearForWeekOfYear && date.weekOfYear == CalendarManager.currentDate.weekOfYear {
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
        let daySize = CGSize(width: Int(frame.size.width / 7.0), height: Int(frame.size.width / 7.0))

        //今日を含む週の先頭（日曜日）の日にちをゲット
        // dayViewをaddする
        for i in 0 ..< 7 {
            let x = i * Int(daySize.width)
            let frame = CGRect(origin: CGPoint(x: x, y: 0), size: daySize)
            let dayView = CalendarSwiftDateView(frame: frame, date: date + i.days)
            dayView.delegate = self
            self.addSubview(dayView)
        }
    }

    //LogViewの日にちごとの色を決める実行部分２(week版)
    func getLogColorDate(date: NSDate) {
        let logNumber: Int
        if logManager.sharedSingleton.logTitleToggle == true{
            logNumber = logManager.sharedSingleton.tabLogNumber
        }else {
            logNumber = logManager.sharedSingleton.logNumber
        }
        let logUser = logManager.sharedSingleton.logUser
        let calendarLogCollerManager = CalendarLogCollerManager()
        let logColorQuery: NCMBQuery
        if logUser == NCMBUser.currentUser(){
            print("user情報 in weekVC(自分のログの時)", logUser.userName)
            //weekLogColorDateはuserを引数に取らない場合userにはNCMBUser.currentUser()が自動で入る
            logColorQuery = calendarLogCollerManager.weekLogColorDate(date, logNumber: logNumber)
        }else {
            print("user情報 in weekVC(自分のログじゃない時)", logUser.userName)
            logColorQuery = calendarLogCollerManager.weekLogColorDate(date, logNumber: logNumber, user: logUser)
        }

        let logUserName = logUser.userName
        let weekKeyArray = CalendarManager.getWeekNumber(CalendarManager.currentDate)
        let weekKey = String(weekKeyArray[0]) + String(weekKeyArray[1])
        let key = String(logNumber) + logUserName + weekKey

        switch logNumber {
        case 0: //自分の時
            print("myWeekLogColorCache", CalendarLogColorCache.sharedSingleton.myWeekLogColorCache)
            if let cashLogColorArray = CalendarLogColorCache.sharedSingleton.myWeekLogColorCache.objectForKey(key) as? [String]{
                print("cashLogColorArray", cashLogColorArray)
                self.setLogDateTag(cashLogColorArray, logNumber: logNumber)
            }else {
                manyLogColorQueryLoad(logColorQuery, logNumber: logNumber)
            }
        default: //自分の時以外
            print("otherWeekLogColorCache", CalendarLogColorCache.sharedSingleton.otherWeekLogColorCache)
            if let cashLogColorArray = CalendarLogColorCache.sharedSingleton.otherWeekLogColorCache.objectForKey(key) as? [String]{
                print("cashLogColorArray", cashLogColorArray)
                self.setLogDateTag(cashLogColorArray, logNumber: logNumber)
                manyLogColorQueryLoad(logColorQuery, logNumber: logNumber)
            }else {
                manyLogColorQueryLoad(logColorQuery, logNumber: logNumber)
            }
        }
    }

    //logColorのQueryを非同期で読み込む
    func manyLogColorQueryLoad(query: NCMBQuery, logNumber: Int){
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if objects != nil{
                    for object in objects {
                        let logColorArray = object.objectForKey("logDateTag") as! [String]
                        self.saveLogColorCashArray(logColorArray, logNumber: logNumber)
                        self.setLogDateTag(logColorArray, logNumber: logNumber)
                    }
                }else {
                    print("今月の投稿はまだない")
                }

            }
        }

    }

    //logColorのキャッシュを保存
    func saveLogColorCashArray(logColorArray: [String], logNumber: Int) {
        let logUserName = logManager.sharedSingleton.logUser.userName
        let weekKeyArray = CalendarManager.getWeekNumber(CalendarManager.currentDate)
        let weekKey = String(weekKeyArray[0]) + String(weekKeyArray[1])
        let key = String(logNumber) + logUserName + weekKey
        switch logNumber {
        case 0:
            CalendarLogColorCache.sharedSingleton.updateMyWeekLogColorCache(logColorArray, key: key)
        default:
            CalendarLogColorCache.sharedSingleton.updateotherWeekLogColorCache(logColorArray, key: key)
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
                    dayView.selectDateColor(dayColor)
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


