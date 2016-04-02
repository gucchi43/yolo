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
        
        dayButton = UIButton(frame: CGRect(x: 0, y: 0, width: w, height: h))
        dayButton.titleLabel?.textAlignment = NSTextAlignment.Center
        dayButton.setTitle(String(format: "%02d", date.day), forState: UIControlState.Normal)
//        dayButton.setTitleColor(UIColor.greenColor(), forState: .Selected)
        dayButton.addTarget(self, action: "onTapCalendarDayButton:", forControlEvents: .TouchUpInside)

        print("day", date.day, "weekday", date.weekday)

        if date == CalendarManager.currentDate {
            //            dayButton.selected = true
            dayButton.backgroundColor = UIColor.yellowColor()
            print(date)
        }
        
        
        if date.day == NSDate().day{
            //今日は黒（※今は同じ日にち全部に反映されている）
            dayButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            print("当日はくろになるはずなんけど")
        } else if date.weekday == 1 {
            //日曜日は赤
            dayButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            print("当日はくろになるはずなんけど")
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
}

