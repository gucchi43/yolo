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
        //選択した日を含む月のdateと、選択した日を含む週のdate
        if date.year == CalendarManager.currentDate.year && date.month == CalendarManager.currentDate.month || date.year == CalendarManager.currentDate.year && date.weekOfYear == CalendarManager.currentDate.weekOfYear{
            //※初回起動時のみ、月（５ヶ月）と週（３週）分を読み込む、以降は、月のみor週のみ
            self.whetherLogColler(date)
        }

        if date == CalendarManager.currentDate {
            dayButton.layer.borderColor = UIColor.grayColor().CGColor
            dayButton.layer.borderWidth = 3
            dayButton.titleLabel?.font = UIFont.systemFontOfSize(15)
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
        
    //LogViewの日にちごとの色を決める実行部分
    func whetherLogColler(date: NSDate) {
        let myLogCollerQuery: NCMBQuery = NCMBQuery(className: "LogColler") // 自分の投稿クエリ
        myLogCollerQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        myLogCollerQuery.whereKey("logDate", equalTo: getLogYearMonthDate(date))
        myLogCollerQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if let error = error{
                print(error.localizedDescription)
            }else {
                if object != nil {//投稿あり
                    print("投稿ありありありあり", date)
                    let dateColler = object.objectForKey("dateColler") as! String
                    self.selectDateColler(dateColler)
                }else {//投稿なし
                    print("投稿なし", date)
                }
            }
        }
    }
    
    //その日の"yyyy/MM/dd"を取る()
    func getLogYearMonthDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let logDate = formatter.stringFromDate(date)
        print("検索側logDate", logDate)
        return logDate
    }
    
    //その日の色を、決定する
    func selectDateColler(dateColler: String){
        switch dateColler {
        case "red" :
            self.dayButton.backgroundColor =  UIColor.redColor()
        case "blue" :
            self.dayButton.backgroundColor =  UIColor.blueColor()
        default :
            self.dayButton.backgroundColor =  UIColor.orangeColor()
        }
    }
    
    
//    //以前の判断に使っていたメソッド（オレンジ時代）
//    func postedDate(date: NSDate) {
//        //        自分の投稿だけを表示するQueryを発行
//        let myPostQuery: NCMBQuery = NCMBQuery(className: "Post")
//        myPostQuery.whereKey("user", equalTo: NCMBUser.currentUser())
//        myPostQuery.whereKey("postDate", greaterThanOrEqualTo: self.FirstFilterDateStart(date))
//        myPostQuery.whereKey("postDate", lessThanOrEqualTo: self.FirstFilterDateEnd(date))
//        print("postedDate読み込み時", date)
//        myPostQuery.getFirstObjectInBackgroundWithBlock { (objects, error) -> Void in
//            if objects != nil {//投稿0件
//                print("投稿あり")
//                self.dayButton.backgroundColor =  UIColor.orangeColor()
//            }else {//投稿あり
//                print("投稿なし")
//            }
//        }
//    }
    
//    //その日にちの00:00:00のNSDateをゲット（そのの範囲を決めるため）
//    func FirstFilterDateStart(date: NSDate) -> NSDate {
//        let formatter = NSDateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
//        
//        let formatDate = formatter.dateFromString(String(date.year) + "/" +
//            String(date.month) + "/" +
//            String(date.day) + " 00:00:00")
//        
//        print("FilterDateStart", date)
//        return formatDate!
//    }
//    
//    //その日にちの23:59:59のNSDateをゲット（そのの範囲を決めるため）
//    func FirstFilterDateEnd(date: NSDate) -> NSDate {
//        let formatter = NSDateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
//        
//        let formatDate = formatter.dateFromString(String(date.year) + "/" +
//            String(date.month) + "/" +
//            String(date.day) + " 23:59:59")
//        
//        print("FilterDateEnd", date)
//        return formatDate!
//    }
}

