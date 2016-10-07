//
//  CalendarLogColorCache.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/10/04.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class CalendarLogColorCache {
    private init() {
    }
    static let sharedSingleton = CalendarLogColorCache()
    
    var myMonthLogColorCache = NSCache()
    var myWeekLogColorCache = NSCache()
    var otherMonthLogColorCache = NSCache()
    var otherWeekLogColorCache = NSCache()

    func updateMyMonthLogLogColorCache(array: [String], key: String) {
        myMonthLogColorCache.countLimit = 12
        myMonthLogColorCache.setObject(array, forKey: key)
        print("updateMyMonthLogLogColorCache呼び出し,array: Key", array, ":", key )
    }

    func updateMyWeekLogColorCache(array: [String], key: String) {
        myWeekLogColorCache.countLimit = 60
        myWeekLogColorCache.setObject(array, forKey: key)
        print("updateMyWeekLogColorCache呼び出し,array: Key", array, ":", key )
    }

    func updateOtherMonthLogColorCache(array: [String], key: String) {
        otherMonthLogColorCache.countLimit = 12
        otherMonthLogColorCache.setObject(array, forKey: key)
        print("updateOtherMonthLogColorCache呼び出し,array: Key", array, ":", key )
    }

    func updateotherWeekLogColorCache(array: [String], key: String) {
        otherWeekLogColorCache.countLimit = 60
        otherWeekLogColorCache.setObject(array, forKey: key)
        print("updateotherWeekLogColorCache呼び出し,array: Key", array, ":", key )
    }

}

