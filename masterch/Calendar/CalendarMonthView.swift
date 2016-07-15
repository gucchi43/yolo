//
//  CalendarMonthView.swift
//  CrossCalendarSample
//
//  Created by Eisuke Sato on 2016/02/19.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit
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
    
    //LogViewの日にちごとの色を決める実行部分２
    func getLogColorDate(date: NSDate) {
        let calendarLogCollerManager = CalendarLogCollerManager()
        let logNumber = logManager.sharedSingleton.logNumber
        let logUser = logManager.sharedSingleton.logUser
        let logColorQuery: NCMBQuery
//        let logVC = LogViewController()
//        let user = logVC.user
        if logUser == NCMBUser.currentUser(){
            print("user情報 in monthVC", logUser.userName)
            //weekLogColorDateはuserを引数に取らない場合userにはNCMBUser.currentUser()が自動で入る
            logColorQuery = calendarLogCollerManager.monthLogColorDate(date, logNumber: logNumber)
        }else {
            print("user情報 in monthVC", logUser.userName)
            logColorQuery = calendarLogCollerManager.monthLogColorDate(date, logNumber: logNumber, user: logUser)
        }
        logColorQuery.findObjectsInBackgroundWithBlock({(objects, error) in
            if let error = error {
                print("getLogColorError", error.localizedDescription)
            }else{
                if objects != nil {
                    print("今月の投稿",date, objects)
                    // 色乗せ処理
                    for object in objects {
                        let logDate = object.objectForKey("logDate") as! String
                        let logColor: String?
                        if logManager.sharedSingleton.logNumber == 0 {
                            print("自分の投稿の時の色のせ")
                            //範囲: 自分のログを見る時
                            if object.objectForKey("secretColor") as? String != nil {
                                //カギ付き投稿を含んだ色の入ったフィールド
                                logColor = object.objectForKey("secretColor") as? String
                            }else {
                                //カギ付き投稿を含んでない色の入ったフィールド（ここを通るのは、secretColorを作る前のDateの場合）
                                logColor = object.objectForKey("dateColor") as? String
                            }
                        }else {
                            //範囲: それ意外(フォロー、特定のユーザーetc)
                            print("フォローなどの自分じゃない時の色のせ")
                            logColor = object.objectForKey("dateColor") as? String
                        }
                        let logDateTag = Int(logDate.stringByReplacingOccurrencesOfString("/", withString: ""))!
                        if let dayView = self.viewWithTag(logDateTag) as? CalendarSwiftDateView {
                            dayView.selectDateColor(logColor!)
                        }
                    }
                }else{
                    print("今月の投稿はまだない")
                }
            }
        })
    }
    
    func updateDayViewSelectedStatus() {
        let subViews:[UIView] = self.subviews as [UIView]
        for view in subViews {
            if view.isKindOfClass(CalendarSwiftDateView) {
                let dateView = view as! CalendarSwiftDateView
                if dateView.date == CalendarManager.currentDate {
                    dateView.dayButton.layer.borderColor = UIColor.grayColor().CGColor
                    dateView.dayButton.titleLabel?.font = UIFont.systemFontOfSize(15)
                    print(dateView.date)
                } else {
                    dateView.dayButton.layer.borderColor = UIColor.clearColor().CGColor
                    dateView.dayButton.titleLabel?.font = UIFont.systemFontOfSize(10)

                }
            }
        }
    }
}
