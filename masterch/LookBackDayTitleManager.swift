//
//  LookBackDayTitleManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/10/07.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB
import SwiftDate

class LookBackDayTitleManager: NSObject {
    func getWeekAgoDayTitle (date: NSDate = NSDate(), agoInt: Int) -> String {
        let agoDay = date - agoInt.weeks
        let agoString = agoDay.toString(DateFormat.Custom("yyyy/MM/dd"))!

        return agoString
    }

    func getMonthAgoDayTitle (date: NSDate = NSDate(), agoInt: Int) -> String {
        let agoDay = date - agoInt.months
        let agoString = agoDay.toString(DateFormat.Custom("yyyy/MM/dd"))!

        return agoString
    }

    func getYearAgoDayTitle (date: NSDate = NSDate(), agoInt: Int) -> String {
        let agoDay = date - agoInt.years
        let agoString = agoDay.toString(DateFormat.Custom("yyyy/MM/dd"))!

        return agoString
    }    
}