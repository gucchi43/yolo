//
//  CalendarWeekView.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/02/28.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SwiftDate

class CalendarWeekView: UIView, WeekCalendarDateViewDelegate {
    var selectedDay: UIButton?
    var logColorArray: NSArray?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, date: NSDate) {
        super.init(frame:frame)
        startSetUpDays(date)
    }
    
    //setUpDaysの前に呼ぶ（真ん中の週だけgetLogColorを呼び出す）
    func startSetUpDays(date:NSDate) {
        if date.yearForWeekOfYear == CalendarManager.currentDate.yearForWeekOfYear && date.weekOfYear == CalendarManager.currentDate.weekOfYear{
            print("getLogColor呼び出し週", date)
            getLogColorDate(date)
            setUpDays(date)
        }else {
            print("getLogColor呼び出しなし")
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
        
        //今日を含む週の先頭（日曜日）の日にちをゲット
        // dayViewをaddする
        for var i = 0; i < 7; i++ {
            let x = i * Int(daySize.width)
            let frame = CGRect(origin: CGPoint(x: x, y: 0), size: daySize)
            
            if let array = self.logColorArray{ //logColorがあった場合(真ん中の月のみ)
                let dayView = CalendarSwiftDateView(frame: frame, date: date + i.days, array: array)
                dayView.delegate = self
                self.addSubview(dayView)
            }else {//logColorがない場合(真ん中の月以外)
                let dayView = CalendarSwiftDateView(frame: frame, date: date + i.days)
                dayView.delegate = self
                self.addSubview(dayView)
            }

        }
    }
    
    //LogViewの日にちごとの色を決める実行部分２
    func getLogColorDate(date: NSDate) {
        let myLogColorQuery: NCMBQuery = NCMBQuery(className: "LogColor") // 自分の投稿クエリ
        myLogColorQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        myLogColorQuery.whereKey("logDate", greaterThanOrEqualTo: CalendarManager.getDateWeekOfMin(date))
        myLogColorQuery.whereKey("logDate", lessThanOrEqualTo: CalendarManager.getDateWeekOfMax(date))
        myLogColorQuery.orderByAscending("logDate")
        myLogColorQuery.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if let error = error{
                print("getLogColorerrorr", error.localizedDescription)
                self.setUpDays(date)
            }else{
                if objects != nil{
                    self.logColorArray = objects
                    print("今週の投稿",date, self.logColorArray)
                    self.setUpDays(date)
                }else{
                    print("今月の投稿はまだない")
                    self.setUpDays(date)
                }
            }
        })
    }

    

    
    //日にち押すと
    func updateDayViewSelectedStatus() {
        let subViews:[UIView] = self.subviews as [UIView]
        for view in subViews {
            if view.isKindOfClass(CalendarSwiftDateView) {
                let dateView = view as! CalendarSwiftDateView
                if dateView.date == CalendarManager.currentDate {
                    dateView.dayButton.layer.borderColor = UIColor.grayColor().CGColor
                    dateView.dayButton.titleLabel?.font = UIFont.systemFontOfSize(15)
//                    dateView.dayButton.backgroundColor = UIColor.yellowColor()
//                    dateView.dayButton.selected = true
//                    print("true")
                    print(dateView.date)
                } else {
                    dateView.dayButton.layer.borderColor = UIColor.clearColor().CGColor
                    dateView.dayButton.titleLabel?.font = UIFont.systemFontOfSize(10)
//                    dateView.dayButton.backgroundColor = UIColor.clearColor()
//                    dateView.dayButton.selected = false
//                    print("false")
                }
            }
        }
        
    }
}


