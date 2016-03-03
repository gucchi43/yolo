//
//  CalendarManager.swift
//  CrossCalendarSample
//
//  Created by Eisuke Sato on 2016/02/19.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit
import SwiftDate

class CalendarManager: NSObject {
    
    static let sharedInstance: CalendarManager = CalendarManager()
    static var todayDate = NSDate()
    static var currentDate: NSDate!
    static var selectedDate: NSDate!
    
    var currentYear = 0
    var currentMonth = 0
    var currentDay = 0
    var currentWeek = 0
    
    
    //今日の、「年」「月」「日にちをとる」
    //今日の"yyyy/MM/dd"とって、要素ごとに分割
    func setCurrentDate() {
        print("setCurrentDate 呼び出し")
        let dateFormatter:NSDateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy/MM/dd";
        let dateString:String = dateFormatter.stringFromDate(NSDate());
        var dates:[String] = dateString.componentsSeparatedByString("/")
        let today = NSDate()
        print("今日", NSDate())
        CalendarManager.selectedDate = today
        
        currentYear  = Int(dates[0])!
        currentMonth = Int(dates[1])!
        currentWeek = today.firstDayOfWeek()!
        currentDay = Int(dates[2])!

        print(today.weekday)
        switch today.weekday{
        case 1:
            CalendarManager.currentDate = today
            print("日曜")
        case 2:
            CalendarManager.currentDate = today - 1.days
            print("月曜")
        case 3:
            CalendarManager.currentDate = today - 2.days
            print("火曜")
        case 4:
            CalendarManager.currentDate = today - 3.days
            print("水曜")
        case 5:
            CalendarManager.currentDate = today - 4.days
            print("木曜")
        case 6:
            CalendarManager.currentDate = today - 5.days
            print("金曜")
        case 7:
            CalendarManager.currentDate = today - 6.days
            print("土曜")
        default:
            print("これはあかんで")
        }
        print(CalendarManager.currentDate)
    }
    
    //曜日の取得
    class func getWeekDay(year:Int, month:Int, day:Int) -> Int {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy/MM/dd";
        let date = dateFormatter.dateFromString(String(format:"%04d/%02d/%02d", year, month, day));
        if let date = date {
            let calendar = NSCalendar.currentCalendar()
            let dateComp = calendar.components(NSCalendarUnit.Weekday, fromDate: date)
            return dateComp.weekday;
        }
        return 0
    }
    
    //その月の最終日の取得
    class func getLastDay(var year: Int, var month: Int) -> Int {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy/MM/dd";
        
        if month == 12 {
            month = 0
            year++
        }
        
        let targetDate = dateFormatter.dateFromString(String(format:"%04d/%02d/01", year, month + 1));
        if let targetDate = targetDate {
            //月初から一日前を計算し、月末の日付を取得
            let orgDate = NSDate(timeInterval:(24 * 60 * 60) * (-1), sinceDate: targetDate)
            let str = dateFormatter.stringFromDate(orgDate)
            //lastPathComponentを利用するのは目的として違う気も。。
            return Int((str as NSString).lastPathComponent)!;
        }
        return 0
    }
    
    //第何週の取得
    class func getWeek(year: Int, month: Int, day: Int) -> Int {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy/MM/dd";
        let date = dateFormatter.dateFromString(String(format:"%04d/%02d/%02d", year, month, day));
        if let date = date {
            let calendar = NSCalendar.currentCalendar()
            let dateComp = calendar.components(NSCalendarUnit.WeekOfMonth, fromDate: date)
            return dateComp.weekOfMonth;
        }
        return 0
    }
    
    class func getNextYearAndMonth () -> (year: Int, month: Int){
        var next_year:Int = CalendarManager.sharedInstance.currentYear
        var next_month:Int = CalendarManager.sharedInstance.currentMonth + 1
        if next_month > 12 {
            next_month=1
            next_year++
        }
        return (next_year,next_month)
    }
    
    class func getPrevYearAndMonth () -> (year: Int, month: Int){
        var prev_year:Int = CalendarManager.sharedInstance.currentYear
        var prev_month:Int = CalendarManager.sharedInstance.currentMonth - 1
        if prev_month == 0 {
            prev_month = 12
            prev_year--
        }
        return (prev_year,prev_month)
    }
    
    class func getNextYear () -> (year: Int, month: Int){
        return (CalendarManager.sharedInstance.currentYear + 1, CalendarManager.sharedInstance.currentMonth)
    }
    
    class func getLastYear () -> (year: Int, month: Int){
        return (CalendarManager.sharedInstance.currentYear - 1, CalendarManager.sharedInstance.currentMonth)
    }
}
