//
//  LookBackQueryManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/09/30.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB
import SwiftDate

class LookBackQueryManager: NSObject {
    func getOneWeekAgoQuery() -> NCMBQuery{
        //自分のみ
        let oneWeekAgoDay = NSDate() - 1.weeks
        print("oneWeekAgoDay", oneWeekAgoDay)
        let postQuery: NCMBQuery = NCMBQuery(className: "Post")
        postQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        postQuery.orderByAscending("postDate") // cellの並べ方(朝→夜)
        postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart(oneWeekAgoDay))
        postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd(oneWeekAgoDay))
        postQuery.includeKey("user")

        return postQuery
    }

    func getOneMonthAgoQuery() -> NCMBQuery{
        //自分のみ
        let oneMonthAgoDay = NSDate() - 1.months
        print("oneWeekAgoDay", oneMonthAgoDay)
        let postQuery: NCMBQuery = NCMBQuery(className: "Post")
        postQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        postQuery.orderByAscending("postDate") // cellの並べ方(朝→夜)
        postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart(oneMonthAgoDay))
        postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd(oneMonthAgoDay))
        postQuery.includeKey("user")

        return postQuery
    }

    func getOneYearAgoQuery() -> NCMBQuery{
        //自分のみ
        let oneYearAgoDay = NSDate() - 1.years
        print("oneWeekAgoDay", oneYearAgoDay)
        let postQuery: NCMBQuery = NCMBQuery(className: "Post")
        postQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        postQuery.orderByAscending("postDate") // cellの並べ方(朝→夜)
        postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart(oneYearAgoDay))
        postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd(oneYearAgoDay))
        postQuery.includeKey("user")

        return postQuery
    }
}
