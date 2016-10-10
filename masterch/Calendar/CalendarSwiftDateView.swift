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
    let logFollowImage = UIImage(named: "logFollow")
    let logNomalImage = UIImage(named: "logNormal")

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
        dayButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        //dayButtonを丸くしている
        //        dayButton.layer.cornerRadius = CGFloat(w / 2)
        dayButton.layer.cornerRadius = CGFloat(w / 10)
        dayButton.layer.borderColor = UIColor.clearColor().CGColor
        dayButton.layer.borderWidth = 3

        //日にちの数字を左上にするとこ
        self.changeDefaultDayButton(dayButton)

        dayButton.addTarget(self, action: #selector(CalendarSwiftDateView.onTapCalendarDayButton(_:)), forControlEvents: .TouchUpInside)

        if date == CalendarManager.currentDate {
            self.changeSelectDayButton(dayButton)
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
    func changeSelectDayButton(button: UIButton){
        dayButton.layer.borderColor = UIColor.grayColor().CGColor
        dayButton.titleLabel?.font = UIFont.systemFontOfSize(24)
        dayButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        dayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
    }

    func changeDefaultDayButton(button: UIButton){
        dayButton.layer.borderColor = UIColor.clearColor().CGColor
        dayButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        dayButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
        dayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        dayButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
    }

    //その日の色を、決定する
    func selectDateColor(dateColor: String){
        self.dayButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)

        let frame = self.dayButton.frame
        let backLabel = UILabel(frame: frame)
        backLabel.textAlignment = NSTextAlignment.Center
        backLabel.font = UIFont.systemFontOfSize(42)
        backLabel.alpha = 0.7

        switch dateColor {
        case "?":
            self.dayButton.setBackgroundImage(logNomalImage , forState: .Normal)
        default:
            backLabel.text = dateColor
            self.dayButton.setBackgroundImage(backLabel.toImage() , forState: .Normal)
        }
    }
}




