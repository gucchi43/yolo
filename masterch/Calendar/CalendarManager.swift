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
    
    class func setCurrentDate() {
        print("setCurrentDate 呼び出し")
        let today = NSDate()
        print("今日", NSDate())
        CalendarManager.currentDate = today
        print("currentDate: ", CalendarManager.currentDate)

        print(today.weekday)
    }
}
