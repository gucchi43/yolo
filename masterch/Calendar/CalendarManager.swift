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
    
    static var todayDate = NSDate()
    static var currentDate: NSDate!
    
    var calendarTitle = String(CalendarManager.currentDate.year) + "/" + String(CalendarManager.currentDate.month)
    
    class func setCurrentDate() {
        print("setCurrentDate 呼び出し")
        let today = NSDate()
        print("今日", NSDate())
        CalendarManager.currentDate = today
        print("currentDate: ", CalendarManager.currentDate)

        print(today.weekday)
    }
    

    //カレンダーの何月何日のタイトルを作る
    class func selectLabel() -> String {
        let calendarTitle :String = String(CalendarManager.currentDate.year) + "年" + String(CalendarManager.currentDate.month) + "月"
        return calendarTitle
    }
    
    
    //選択した日にちの00:00:00のNSDateをゲット（その日のタイムライン絞るのに使用）
    class func FilterDateStart() -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let formatDate = formatter.dateFromString(String(CalendarManager.currentDate.year) + "/" +
            String(CalendarManager.currentDate.month) + "/" +
            String(CalendarManager.currentDate.day) + " 00:00:00")
        return formatDate!
    }
    
    //選択した日にちの23:59:59のNSDateをゲット（その日のタイムライン絞るのに使用）
    class func FilterDateEnd() -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let formatDate = formatter.dateFromString(String(CalendarManager.currentDate.year) + "/" +
            String(CalendarManager.currentDate.month) + "/" +
            String(CalendarManager.currentDate.day) + " 23:59:59")
        return formatDate!
    }
}




