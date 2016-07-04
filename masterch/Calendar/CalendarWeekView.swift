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
    
    //LogViewの日にちごとの色を決める実行部分２
    func getLogColorDate(date: NSDate) {
        let colorManager = CalendarLogCollerManager()
        let logNumber = logManager.sharedSingleton.logNumber
        let logColorQuery = colorManager.weekLogColorDate(date, logNumber: logNumber)
        logColorQuery.findObjectsInBackgroundWithBlock({(objects, error) in
            if let error = error{
                print("getLogColorerrorr", error.localizedDescription)
            }else{
                if objects != nil{
                    print("今週の投稿",date, objects)
                    // 色乗せ処理
                    for object in objects {
                        let logDate = object.objectForKey("logDate") as! String
                        let logColor = object.objectForKey("dateColor") as! String
                        let logDateTag = Int(logDate.stringByReplacingOccurrencesOfString("/", withString: ""))!
                        if let dayView = self.viewWithTag(logDateTag) as? CalendarSwiftDateView {
                            dayView.selectDateColor(logColor)
                        }
                    }
                }else{
                    print("今月の投稿はまだない")
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
                    print(dateView.date)
                } else {
                    dateView.dayButton.layer.borderColor = UIColor.clearColor().CGColor
                    dateView.dayButton.titleLabel?.font = UIFont.systemFontOfSize(10)
                }
            }
        }
    }
}


