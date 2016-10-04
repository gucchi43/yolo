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
    var logColorCashDic = [String: [String]]()

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
        print("logColorCashDic", logColorCashDic)
        if let cashLogColorArray = logColorCashDic[key]{
            print("cashLogColorArray", cashLogColorArray)
            self.setLogDateTag(cashLogColorArray, logNumber: logNumber)
        }else {
            //Queryを非同期で読み込み
            manyLogColorQueryLoad(logColorQuery, logNumber: logNumber)
        }
    }

    //    func singleLogColorQueryLoad(query: NCMBQuery) {
    //        query.findObjectsInBackgroundWithBlock({(objects, error) in
    //            if let error = error{
    //                print("getLogColorerrorr", error.localizedDescription)
    //            }else{
    //                if objects != nil{
    //                    print("チェック、今月の投稿", objects)
    //                    // 色乗せ処理
    //                    for object in objects {
    //                        let logDate = object.objectForKey("logDate") as! String
    //                        let logColor: String?
    //                        let logNumber: Int
    //                        if logManager.sharedSingleton.logTitleToggle == true{
    //                            logNumber = logManager.sharedSingleton.tabLogNumber
    //                        }else {
    //                            logNumber = logManager.sharedSingleton.logNumber
    //                        }
    //                        if logNumber == 0 {
    //                            print("自分の投稿の時の色のせ")
    //                            //範囲: 自分のログを見る時
    //                            if object.objectForKey("secretColor") as? String != nil {
    //                                //カギ付き投稿を含んだ色の入ったフィールド
    //                                logColor = object.objectForKey("secretColor") as? String
    //                            }else {
    //                                //カギ付き投稿を含んでない色の入ったフィールド（ここを通るのは、secretColorを作る前のDateの場合）
    //                                logColor = object.objectForKey("dateColor") as? String
    //                            }
    //                        }else {
    //                            //範囲: それ意外(フォロー、特定のユーザーetc)
    //                            print("フォローなどの自分じゃない時の色のせ")
    //                            logColor = object.objectForKey("dateColor") as? String
    //                        }
    //                        let logDateTag = Int(logDate.stringByReplacingOccurrencesOfString("/", withString: ""))!
    //                        if let dayView = self.viewWithTag(logDateTag) as? CalendarSwiftDateView {
    //                            dayView.selectDateColor(logColor!)
    //                        }
    //                    }
    //                }else{
    //                    print("今週の投稿はまだない")
    //                }
    //            }
    //        })
    //    }

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

    func saveLogColorCashArray(logColorArray: [String], logNumber: Int) {
        let logUserName = logManager.sharedSingleton.logUser.userName
        let weekKeyArray = CalendarManager.getWeekNumber(CalendarManager.currentDate)
        let weekKey = String(weekKeyArray[0]) + String(weekKeyArray[1])
        let key = String(logNumber) + logUserName + weekKey
        logColorCashDic[key] = logColorArray
    }

    func setLogDateTag (logColorArray: [String], logNumber: Int) {
        for logColorObject in logColorArray {
            let logColorObjectArray = logColorObject.componentsSeparatedByString("&")
            print("logColorObjectArray", logColorObjectArray)
            let dayViewTag = Int(logColorObjectArray[0])
            let dayColor = logColorObjectArray[1]
            if let dayView = self.viewWithTag(dayViewTag!) as? CalendarSwiftDateView {
                if logNumber == 1 { //複数人のためアイコンを１つに統一
                    dayView.selectDateColor("d")
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


