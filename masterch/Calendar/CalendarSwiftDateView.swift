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
    
    init(frame: CGRect, date: NSDate, array: NSArray = [])  {
        super.init(frame: frame)
        print("ここにきてるdateは？→", date)
        self.date = date
        
        let w = Int((UIScreen.mainScreen().bounds.size.width) / 7)
        let h = 30
        
        dayButton = UIButton(frame: CGRect(x: 0, y: 0, width: w, height: w))
        dayButton.setTitle(String(format: "%02d", date.day), forState: UIControlState.Normal)
        dayButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        dayButton.layer.cornerRadius = CGFloat(w/2)
        dayButton.layer.borderColor = UIColor.clearColor().CGColor
        dayButton.layer.borderWidth = 3
        
        //日にちの数字を左上にするとこ
//        dayButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
//        dayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
//        dayButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        dayButton.addTarget(self, action: "onTapCalendarDayButton:", forControlEvents: .TouchUpInside)
        print("day", date.day, "weekday", date.weekday)

        //投稿があったかを調べる
        
        if date == CalendarManager.currentDate {
            dayButton.layer.borderColor = UIColor.grayColor().CGColor
            dayButton.layer.borderWidth = 3
            dayButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        }
        
        if array != []{
            print("投稿があったあああああああああああああああ", date, array)
            mutchArraytoLogDate(date, array: array)
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
    
    func mutchArraytoLogDate(date: NSDate, array: NSArray) {
        searchMutchLogColorDate(date)//その日の"yyyy/MM/dd"
        let mutchObject = array.filter { array -> Bool in
            let logDateArray = array.objectForKey("logDate") as! String
            if logDateArray == searchMutchLogColorDate(date){
                //投稿があった日
                let logColor = array.objectForKey("dateColor") as! String
                print("logColorあるんじゃないのおおおおおおおおおおおおおお", logColor)
                selectDateColor(logColor)
                return true
            }else{
                //投稿がなかった日
                return false
            }
        }
    }
        
    
    
    //その日の"yyyy/MM/dd"
    func searchMutchLogColorDate(date: NSDate) -> String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let logDate = formatter.stringFromDate(date)
        return logDate
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
    



