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

    var calendarTitle: String!

//    var calendarTitle = String(CalendarManager.currentDate.year) + "/" + String(CalendarManager.currentDate.month)
    
    class func setCurrentDate() {
        print("setCurrentDate 呼び出し")
        let japanGMTDifference = 9.hours
        let japanaToday = NSDate() + japanGMTDifference
        let today = NSDate()
//        let japan = Region(calendarName: .Japanese, timeZoneName: .AsiaTokyo, localeName: .Japanese)
        
        CalendarManager.currentDate = today
        print("currentDate: ", CalendarManager.currentDate)
    }
    

    //カレンダーの何月何日のタイトルを作る
    class func selectLabel() -> String {
        let formatter = NSDateFormatter()
        // M=0なし（M月=1月）, MM=0あり（MM月=01月）
//        formatter.dateFormat = "yyyy年M月"
        formatter.dateFormat = "yyyy / M"
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

//    //その日の月の"yyyy/MM/+6day"を取る(week用)
//    class func getDateWeekOfMax(date: NSDate) -> String {
//        let maxDate = date + 6.days
//        let formatter = NSDateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd"
//        let logDate = formatter.stringFromDate(maxDate)
//        print("検索側logDate", logDate)
//        return logDate
//    }
//    
//    //その日の月の"yyyy/MM/-6day"を取る(week用)
//    class func getDateWeekOfMin(date: NSDate) -> String {
//        let minDate = date - 6.days
//        let formatter = NSDateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd"
//        let logDate = formatter.stringFromDate(minDate)
//        print("検索側logDate", logDate)
//        return logDate
//    }

    //その日の年と、１年の何週目かを配列で返す(week用)
    class func getWeekNumber(date: NSDate) -> [Int] {
        let weekNumber = date.weekOfYear //1~53のなかから１つの数字(1年の中の何週目か)
        let year = date.year
        let yearAndWeekNumberArray = [year, weekNumber]
        return yearAndWeekNumberArray
    }
    
    //選択した日にちの00:00:00のNSDateをゲット（その日のタイムライン絞るのに使用）
    //引数無しの場合currentDateが使われる（LogViewなどから使われる）
    //引数ありの場合（LookBackから使われる）
    class func FilterDateStart(targetDate: NSDate = CalendarManager.currentDate) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let formatDate = formatter.dateFromString(String(targetDate.year) + "/" +
            String(targetDate.month) + "/" +
            String(targetDate.day) + " 00:00:00")
        
        print("FilterDateStart", currentDate)
        return formatDate!
    }
    
    //選択した日にちの23:59:59のNSDateをゲット（その日のタイムライン絞るのに使用）
    //引数無しの場合currentDateが使われる（LogViewなどから使われる）
    //引数ありの場合（LookBackから使われる）
    class func FilterDateEnd(targetDate: NSDate = CalendarManager.currentDate) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let formatDate = formatter.dateFromString(String(targetDate.year) + "/" +
            String(targetDate.month) + "/" +
            String(targetDate.day) + " 23:59:59")
        
        print("FilterDateEnd", currentDate)
        return formatDate!
    }
}




