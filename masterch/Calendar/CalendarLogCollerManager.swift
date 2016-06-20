//
//  CalendarLogCollerManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/20.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class CalendarLogCollerManager: NSObject {
    
    //LogViewの日にちごとの色を決める実行部分２ (week)
    func weekLogColorDate(date: NSDate) -> NCMBQuery {
        let logColorQuery: NCMBQuery = NCMBQuery(className: "LogColor") // 自分の投稿クエリ
        logColorQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        logColorQuery.whereKey("logDate", greaterThanOrEqualTo: CalendarManager.getDateWeekOfMin(date))
        logColorQuery.whereKey("logDate", lessThanOrEqualTo: CalendarManager.getDateWeekOfMax(date))
        logColorQuery.orderByAscending("logDate")
        
        return logColorQuery
    }
    
    func monthLogColorDate(date: NSDate) -> NCMBQuery {
        let logColorQuery: NCMBQuery = NCMBQuery(className: "LogColor") // 自分の投稿クエリ
        logColorQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        logColorQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))
        logColorQuery.orderByAscending("logDate")
        
        return logColorQuery
        
    }

}
