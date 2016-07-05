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
    var logColorArray: NSArray?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, date: NSDate) {
        super.init(frame:frame)
        startSetUpDays(date)
    }
    
    //setUpDaysの前に呼ぶ（真ん中の月だけgetLogColorを呼び出す）
    func startSetUpDays(date:NSDate) {
        if date.year == CalendarManager.currentDate.year && date.month == CalendarManager.currentDate.month{
            print("getLogColor呼び出し月" ,date)
            getLogColorDate(date)
            setUpDays(date)
        }else {
            print("getLogColor呼び出しなし", date)
            setUpDays(date)
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
        let lastDay = date.monthDays
        
        for i in 0 ..< lastDay {
            let mDate = date + i.days
            let week = mDate.weekOfMonth  // 何週目か
            let x = (mDate.weekday - 1) * Int(daySize.width)  // 曜日ごとにxの位置をずらす
            let y = (week - 1) * Int(daySize.height)  // 週毎にyの位置をずらす
            let frame = CGRect(origin: CGPoint(x: x, y: y), size: daySize)// frameの確定
            if let array = self.logColorArray{ //logColorがあった場合(真ん中の月のみ)
                let dayView = CalendarSwiftDateView(frame: frame, date: mDate, array: array)
                dayView.delegate = self
                self.addSubview(dayView)
            }else {//logColorがない場合(真ん中の月以外)
                let dayView = CalendarSwiftDateView(frame: frame, date: mDate)
                dayView.delegate = self
                self.addSubview(dayView)
            }
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
            if let error = error{
                print("getLogColorerrorr", error.localizedDescription)
                self.setUpDays(date)
            }else{
                if objects != nil {
                    self.logColorArray = objects
                    print("今月の投稿",date, self.logColorArray)
                    self.setUpDays(date)
                }else{
                    print("今月の投稿はまだない")
                    self.setUpDays(date)
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
