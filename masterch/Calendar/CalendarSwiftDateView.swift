//
//  CalendarSwiftDateView.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/02/28.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SwiftDate

protocol WeekCalendarDateViewDelegate {
    func updateDayViewSelectedStatus()
}

class CalendarSwiftDateView: UIView{
    var date: NSDate!
    var delegate: WeekCalendarDateViewDelegate?
    var dayButton: UIButton!
    var selectedButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, date: NSDate)  {
        super.init(frame: frame)
        print("ここにきてるdateは？→", date)
        self.date = date
        
        let w = Int((UIScreen.mainScreen().bounds.size.width) / 7)
        let h = 30
        
        dayButton = UIButton(frame: CGRect(x: 0, y: 0, width: w, height: w))
        dayButton.setTitle(String(format: "%02d", date.day), forState: UIControlState.Normal)
        dayButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        dayButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
        dayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        dayButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        dayButton.addTarget(self, action: "onTapCalendarDayButton:", forControlEvents: .TouchUpInside)
        print("day", date.day, "weekday", date.weekday)

//        CalendarManager.postedDate(date)
        if date.year == NSDate().year && date.month  == NSDate().month{
            print("month用（一ヶ月分出る筈）")
            self.postedDate(date)
        }
        
        if date.year == NSDate().year && date.weekOfYear == NSDate().weekOfYear{
            print("weeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeek用（一週間分出る筈）")
            self.postedDate(date)
        }

        if date == CalendarManager.currentDate {
            //            dayButton.selected = true
            dayButton.backgroundColor = UIColor.yellowColor()
            print(date)
        }
        if date.year == NSDate().year && date.month == NSDate().month && date.day == NSDate().day{
            //今日だけ黒
                    dayButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        } else if date.weekday == 1 {
            //日曜日は赤
            dayButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        } else if date.weekday == 7 {
            //土曜日は青
            dayButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
//        } else if date < NSDate(){
//            //過去はオレンジ
//            dayButton.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
//        } else if date > NSDate(){
//            //未来は水色
//            dayButton.setTitleColor(UIColor.cyanColor(), forState: UIControlState.Normal)
        } else {
            //普通はグレー
            dayButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        }
        self.addSubview(dayButton)
    }
        
    func onTapCalendarDayButton(sender: UIButton) {
        CalendarManager.currentDate = date
        if let delegate = delegate {
            delegate.updateDayViewSelectedStatus()
            let n = NSNotification(name: "didSelectDayView", object: self, userInfo: nil)
            NSNotificationCenter.defaultCenter().postNotification(n)
        }
    }
    
    func postedDate(date: NSDate) {
        //        自分の投稿だけを表示するQueryを発行
        let myPostQuery: NCMBQuery = NCMBQuery(className: "Post")
        myPostQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        myPostQuery.whereKey("postDate", greaterThanOrEqualTo: self.FirstFilterDateStart(date))
        myPostQuery.whereKey("postDate", lessThanOrEqualTo: self.FirstFilterDateEnd(date))
        print("postedDate読み込み時", date)
        myPostQuery.getFirstObjectInBackgroundWithBlock { (objects, error) -> Void in
            if objects == nil {
//                    投稿0件
                    print("投稿0件")
                }else {
//                    投稿あり
                    print("投稿あり")
                    self.dayButton.backgroundColor =  UIColor.orangeColor()
                }
            }
    }
    
    //その日にちの00:00:00のNSDateをゲット（そのの範囲を決めるため）
    func FirstFilterDateStart(date: NSDate) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let formatDate = formatter.dateFromString(String(date.year) + "/" +
            String(date.month) + "/" +
            String(date.day) + " 00:00:00")
        
        print("FilterDateStart", date)
        return formatDate!
    }
    
    //その日にちの23:59:59のNSDateをゲット（そのの範囲を決めるため）
    func FirstFilterDateEnd(date: NSDate) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let formatDate = formatter.dateFromString(String(date.year) + "/" +
            String(date.month) + "/" +
            String(date.day) + " 23:59:59")
        
        print("FilterDateEnd", date)
        return formatDate!
    }
    
}

