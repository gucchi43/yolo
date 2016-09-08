//
//  CalendarLogCollerManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/20.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB

//monthの時
class CalendarLogCollerManager: NSObject {

//    var user: NCMBUser? = NCMBUser.currentUser()
    //LogViewの日にちごとの色を決める実行部分２ (month)
    func monthLogColorDate(date: NSDate, logNumber: Int, user: NCMBUser = NCMBUser.currentUser()) -> NCMBQuery {
        print("monthLogColorDate: date", date)
        print("monthLogColorDate: user", user)
        print("monthLogColorDate: logNumber", logNumber)
        //クエリ作成
        let logColorQuery: NCMBQuery = NCMBQuery(className: "LogColor") // LogCollerのクエリ
        let logColorArrayQuery: NCMBQuery = NCMBQuery(className: "TestColorDic")

        switch logNumber { //絞っていくよーーーーーーーーーーーーー
        case 0:
            //自分のみ
//            logColorQuery.whereKey("user", equalTo: NCMBUser.currentUser())
//            logColorQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))
//            logColorQuery.orderByAscending("logDate")
//
//            return logColorQuery

            logColorArrayQuery.whereKey("user", equalTo: NCMBUser.currentUser())
            logColorArrayQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))

            return logColorArrayQuery

//        case 1:
//            //フォローのみ
//            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
//            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
//            //これはなに？
////            relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "LogColor"))
//            logColorQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
//            logColorQuery.whereKeyExists("dateColor")
//            logColorQuery.whereKey("user", notEqualTo: NCMBUser.currentUser()) //自分で自分をフォローしていた場合自分を外す
//            logColorQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))
//            logColorQuery.orderByAscending("logDate")
//            print("チェックしなきゃlogColorQuery", logColorQuery)

        case 1:
            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
            logColorArrayQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
            logColorArrayQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))

            return logColorArrayQuery
        case 2:
            //特定のアカウントのみ
//            logColorQuery.whereKey("user", equalTo: user)
//            logColorQuery.whereKeyExists("dateColor")
//            logColorQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))
//            logColorQuery.orderByAscending("logDate")

            logColorArrayQuery.whereKey("user", equalTo: user)
            logColorArrayQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))

            return logColorArrayQuery

        default:
            //オール
//            logColorQuery.whereKey("user", equalTo: NCMBUser.currentUser())
//            logColorQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))
//            logColorQuery.orderByAscending("logDate")
//
//            return logColorQuery

            logColorArrayQuery.whereKey("user", equalTo: user)
            logColorArrayQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))

            return logColorArrayQuery
        }

        //共通のクエリの範囲指定、順番と日にちの範囲指定
        //        logColorQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))
        //        logColorQuery.orderByAscending("logDate")

//        return logColorQuery

    }
}


//weekの時
extension CalendarLogCollerManager{
    //LogViewの日にちごとの色を決める実行部分２ (week)
    func weekLogColorDate(date: NSDate, logNumber: Int, user: NCMBUser = NCMBUser.currentUser()) -> NCMBQuery {
        print("weekLogColorDate: date", date)
        print("weekLogColorDate: user", user)
        print("weekLogColorDate: logNumber", logNumber)

        //クエリの作成
        let logColorQuery: NCMBQuery = NCMBQuery(className: "LogColor") // LogCollerのクエリ
        let logColorArrayQuery: NCMBQuery = NCMBQuery(className: "TestWeekColorDic")

        let yearAndWeekNumberArray = CalendarManager.getWeekNumber(date)
        let year = yearAndWeekNumberArray[0]
        let weekOfYear = yearAndWeekNumberArray[1]

        switch logNumber { //絞っていくよーーーーーーーーーーーーー
        case 0:
            //特定のuserのみ
//            logColorQuery.whereKey("user", equalTo: NCMBUser.currentUser())
//            logColorQuery.whereKey("logDate", greaterThanOrEqualTo: CalendarManager.getDateWeekOfMin(date))
//            logColorQuery.whereKey("logDate", lessThanOrEqualTo: CalendarManager.getDateWeekOfMax(date))
//            logColorQuery.orderByAscending("logDate")
//
//            return logColorQuery

            logColorArrayQuery.whereKey("user", equalTo: NCMBUser.currentUser())
            logColorArrayQuery.whereKey("year", equalTo: year)
            logColorArrayQuery.whereKey("weekOfYear", equalTo: weekOfYear)

            return logColorArrayQuery


//        case 1:
//            //フォローのみ
//            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
//            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
//            //これはなに？
////            relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "LogColor"))
//            logColorQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
//            logColorQuery.whereKey("user", notEqualTo: NCMBUser.currentUser()) //自分で自分をフォローしていた場合自分を外す
//            logColorQuery.whereKey("logDate", greaterThanOrEqualTo: CalendarManager.getDateWeekOfMin(date))
//            logColorQuery.whereKey("logDate", lessThanOrEqualTo: CalendarManager.getDateWeekOfMax(date))
//            logColorQuery.orderByAscending("logDate")


        case 1:
            //フォローのみ
            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
            logColorArrayQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
            logColorArrayQuery.whereKey("year", equalTo: year)
            logColorArrayQuery.whereKey("weekOfYear", equalTo: weekOfYear)

            return logColorArrayQuery


        case 2:
            //特定のアカウントのみ
//            logColorQuery.whereKey("user", equalTo: user)
//            logColorQuery.whereKey("logDate", greaterThanOrEqualTo: CalendarManager.getDateWeekOfMin(date))
//            logColorQuery.whereKey("logDate", lessThanOrEqualTo: CalendarManager.getDateWeekOfMax(date))
//            logColorQuery.orderByAscending("logDate")
//
//            return logColorQuery

            logColorArrayQuery.whereKey("user", equalTo: user)
            logColorArrayQuery.whereKey("year", equalTo: year)
            logColorArrayQuery.whereKey("weekOfYear", equalTo: weekOfYear)

            return logColorArrayQuery

        default:
            //オール
//            logColorQuery.whereKey("user", equalTo: NCMBUser.currentUser())
//            logColorQuery.whereKey("logDate", greaterThanOrEqualTo: CalendarManager.getDateWeekOfMin(date))
//            logColorQuery.whereKey("logDate", lessThanOrEqualTo: CalendarManager.getDateWeekOfMax(date))
//            logColorQuery.orderByAscending("logDate")
//
//            return logColorQuery

            logColorArrayQuery.whereKey("user", equalTo: NCMBUser.currentUser())
            logColorArrayQuery.whereKey("year", equalTo: year)
            logColorArrayQuery.whereKey("weekOfYear", equalTo: weekOfYear)

            return logColorArrayQuery

        }

        ////共通のクエリの範囲指定、順番と日にちの範囲指定
//        logColorQuery.whereKey("logDate", greaterThanOrEqualTo: CalendarManager.getDateWeekOfMin(date))
//        logColorQuery.whereKey("logDate", lessThanOrEqualTo: CalendarManager.getDateWeekOfMax(date))
//        logColorQuery.orderByAscending("logDate")

//        return logColorQuery
    }



}
