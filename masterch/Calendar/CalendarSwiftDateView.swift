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
    var dateColorArray: [NSArray]?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, date: NSDate)  {
        super.init(frame: frame)
        self.date = date
        self.tag = Int(date.toString(DateFormat.Custom("yyyyMMdd"))!)!
        let w = Int((UIScreen.mainScreen().bounds.size.width) / 7) - 5
        
        dayButton = UIButton(frame: CGRect(x: 5, y: 5, width: w, height: w))
        dayButton.setTitle(String(format: "%02d", date.day), forState: UIControlState.Normal)
        dayButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        dayButton.layer.cornerRadius = CGFloat(w / 2)
        dayButton.layer.borderColor = UIColor.clearColor().CGColor
        dayButton.layer.borderWidth = 3
        
        //日にちの数字を左上にするとこ
//        dayButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
//        dayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
//        dayButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        dayButton.addTarget(self, action: "onTapCalendarDayButton:", forControlEvents: .TouchUpInside)
        
        if date == CalendarManager.currentDate {
            dayButton.layer.borderColor = UIColor.grayColor().CGColor
            dayButton.titleLabel?.font = UIFont.systemFontOfSize(15)
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
    
    //その日の色を、決定する
    func selectDateColor(dateColor: String){
        self.dayButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        switch dateColor {
        case "red" :
            self.dayButton.backgroundColor =  UIColor.redColor()
        case "yellow" :
            self.dayButton.backgroundColor =  UIColor.yellowColor()
        case "pink" :
            self.dayButton.backgroundColor =  UIColor.magentaColor()
        case "blue" :
            self.dayButton.backgroundColor =  UIColor.blueColor()
        case "green" :
            self.dayButton.backgroundColor =  UIColor.greenColor()
        case "gray" :
            self.dayButton.backgroundColor =  UIColor.darkGrayColor()
        default :
            self.dayButton.backgroundColor =  UIColor.lightGrayColor()
        }
    }
}
    



