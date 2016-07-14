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

    let logGoodImage = UIImage(named: "logGood")
    let logBadImage = UIImage(named: "logBad")

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, date: NSDate)  {
        super.init(frame: frame)
        self.date = date
        self.tag = Int(date.toString(DateFormat.Custom("yyyyMMdd"))!)!
        let w = Int((UIScreen.mainScreen().bounds.size.width) / 7) - 6
        
        dayButton = UIButton(frame: CGRect(x: 3, y: 3, width: w, height: w))
        dayButton.setTitle(String(format: "%02d", date.day), forState: UIControlState.Normal)
        dayButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        //dayButtonを丸くしている
//        dayButton.layer.cornerRadius = CGFloat(w / 2)
        dayButton.layer.cornerRadius = CGFloat(w / 10)
        dayButton.layer.borderColor = UIColor.clearColor().CGColor
        dayButton.layer.borderWidth = 3
        
        //日にちの数字を左上にするとこ
//        dayButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
//        dayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
//        dayButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        dayButton.addTarget(self, action: #selector(CalendarSwiftDateView.onTapCalendarDayButton(_:)), forControlEvents: .TouchUpInside)
        
        if date == CalendarManager.currentDate {
            dayButton.layer.borderColor = UIColor.grayColor().CGColor
            dayButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        }

        if date.year == NSDate().year && date.month == NSDate().month && date.day == NSDate().day{
            //今日だけ黒
            dayButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//        } else if date.weekday == 1 {
//            //日曜日は赤
//            dayButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
//        } else if date.weekday == 7 {
//            //土曜日は青
//            dayButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
//            //        } else if date < NSDate(){
//            //            //過去はオレンジ
//            //            dayButton.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
//            //        } else if date > NSDate(){
//            //            //未来は水色
//            //            dayButton.setTitleColor(UIColor.cyanColor(), forState: UIControlState.Normal)
        } else {
            //普通はダークグレー
            dayButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
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
        self.dayButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        switch dateColor {
        case "good" :
            self.dayButton.setBackgroundImage(logGoodImage, forState: .Normal)
        case "bad" :
            self.dayButton.setBackgroundImage(logBadImage, forState: .Normal)

        case "red" :
//            self.dayButton.backgroundColor =  UIColor.redColor()
        self.dayButton.setBackgroundImage(logGoodImage, forState: .Normal)
        case "yellow" :
//            self.dayButton.backgroundColor =  UIColor.yellowColor()
            self.dayButton.setBackgroundImage(logGoodImage, forState: .Normal)
        case "pink" :
//            self.dayButton.backgroundColor =  UIColor.magentaColor()
            self.dayButton.setBackgroundImage(logGoodImage, forState: .Normal)
        case "blue" :
//            self.dayButton.backgroundColor =  UIColor.blueColor()
        self.dayButton.setBackgroundImage(logBadImage, forState: .Normal)
        case "green" :
//            self.dayButton.backgroundColor =  UIColor.greenColor()
            self.dayButton.setBackgroundImage(logBadImage, forState: .Normal)
        case "gray" :
//            self.dayButton.backgroundColor =  UIColor.darkGrayColor()
            self.dayButton.setBackgroundImage(logBadImage, forState: .Normal)
        default :
            self.dayButton.backgroundColor =  UIColor.lightGrayColor()
        }
    }
}
    



