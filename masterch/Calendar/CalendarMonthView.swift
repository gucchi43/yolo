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
        startsetUpDays(date)
    }
    
    //setUpDaysの前に呼ぶ（真ん中の月だけgetLogColorを呼び出す）
    func startsetUpDays(date:NSDate) {
        if date.year == CalendarManager.currentDate.year && date.month == CalendarManager.currentDate.month{
            print("getLogColor呼び出し月")
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
        let lastDay = date.monthDays
        
        for var i = 0; i < lastDay; i++ {
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
        let myLogColorQuery: NCMBQuery = NCMBQuery(className: "LogColor") // 自分の投稿クエリ
        myLogColorQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        myLogColorQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))
        myLogColorQuery.orderByAscending("logDate")
        myLogColorQuery.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if let error = error{
                print("getLogColorerrorr", error.localizedDescription)
                self.setUpDays(date)
            }else{
                if objects != nil{
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
//                    dateView.dayButton.backgroundColor = UIColor.yellowColor()
//                    dateView.dayButton.selected = true
//                    print("true")
                    print(dateView.date)
                } else {
                    dateView.dayButton.layer.borderColor = UIColor.clearColor().CGColor
                    dateView.dayButton.titleLabel?.font = UIFont.systemFontOfSize(10)
//                    dateView.dayButton.selected = false
//                    print("false")
                }
            }
        }
    }
}
