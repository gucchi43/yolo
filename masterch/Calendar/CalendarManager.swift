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
    
    static var testDate = NSDate()
    static var currentDate: NSDate!
    
    var calendarTitle = String(CalendarManager.currentDate.year) + "/" + String(CalendarManager.currentDate.month)
    
    class func setCurrentDate() {
        print("setCurrentDate 呼び出し")
        let japanGMTDifference = 9.hours
        let japanaToday = NSDate() + japanGMTDifference
        let today = NSDate()
        let lialeToday = NSDate()
//        let japan = Region(calendarName: .Japanese, timeZoneName: .AsiaTokyo, localeName: .Japanese)
        
        CalendarManager.currentDate = today
        CalendarManager.testDate = lialeToday
        print("currentDate: ", CalendarManager.currentDate)
    }
    

    //カレンダーの何月何日のタイトルを作る
    class func selectLabel() -> String {
        let formatter = NSDateFormatter()
        // M=0なし（M月=1月）, MM=0あり（MM月=01月）
        formatter.dateFormat = "yyyy年M月"
        let calendarTitle :String = formatter.stringFromDate(CalendarManager.currentDate)
        return calendarTitle
    }
    
    //その日の月の"yyyy/MM"を取る(month用)
    class func getDateYearAndMonth(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM"
        let logDate = formatter.stringFromDate(date)
        print("検索側logDate", logDate)
        return logDate
    }
    
    //その日の月の"yyyy/MM/+6day"を取る(week用)
    class func getDateWeekOfMax(date: NSDate) -> String {
        let maxDate = date + 6.days
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let logDate = formatter.stringFromDate(maxDate)
        print("検索側logDate", logDate)
        return logDate
    }
    
    //その日の月の"yyyy/MM/-6day"を取る(week用)
    class func getDateWeekOfMin(date: NSDate) -> String {
        let minDate = date - 6.days
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let logDate = formatter.stringFromDate(minDate)
        print("検索側logDate", logDate)
        return logDate
    }
    
    //選択した日にちの00:00:00のNSDateをゲット（その日のタイムライン絞るのに使用）
    class func FilterDateStart() -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let formatDate = formatter.dateFromString(String(CalendarManager.currentDate.year) + "/" +
            String(CalendarManager.currentDate.month) + "/" +
            String(CalendarManager.currentDate.day) + " 00:00:00")
        
        print("FilterDateStart", currentDate)
        return formatDate!
    }
    
    //選択した日にちの23:59:59のNSDateをゲット（その日のタイムライン絞るのに使用）
    class func FilterDateEnd() -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let formatDate = formatter.dateFromString(String(CalendarManager.currentDate.year) + "/" +
            String(CalendarManager.currentDate.month) + "/" +
            String(CalendarManager.currentDate.day) + " 23:59:59")
        
        print("FilterDateEnd", currentDate)
        return formatDate!
    }
}




