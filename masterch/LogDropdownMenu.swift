//
//  LogDropdownMenu.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/27.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import DropdownMenu

class LogDropdownMenu: LogViewController, DropdownMenuDelegate {

//DropdownMenuDelegateのDelegate
    override func dropdownMenu(dropdownMenu: DropdownMenu, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("DropdownMenu didselect \(indexPath.row) text:\(Dropitems[indexPath.row].title)")
        
        self.selectedRow = indexPath.row
        
        //        if indexPath.row != Dropitems.count - 1 {
        //            //一番上選んだ時
        //            self.selectedRow = indexPath.row
        //        }else {
        //            //それ意外
        //            self.selectedRow = indexPath.row
        //        }
        logManager.sharedSingleton.logNumber = indexPath.row
        let logNumber = logManager.sharedSingleton.logNumber
        print("logNumber", logNumber, Dropitems[indexPath.row].title)
        
        changeTitle(logManager.sharedSingleton.logNumber)
        
        switch toggleWeek {
        case false:
            print("week表示")
            if let calendarView = calendarView {
                calendarView.resetMonthView()
                loadQuery(logNumber)
            }
        default:
            print("month表示")
            if let calendarAnotherView = calendarAnotherView {
                calendarAnotherView.resetWeekView()
                loadQuery(logNumber)
            }
        }
    }
    
    //NavigatoinBarのタイトルを設定
    override func changeTitle(logNumber: Int) {
        //スタックビューを作成
        let stackView = UIStackView()
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.frame = CGRectMake(0,0,100,40)
        
        //タイトルのラベルを作成する。
        let testLabel1 = UILabel(frame:CGRectMake(0,0,100,28))
        testLabel1.text = "ログ"
        
        //サブタイトルを作成する。
        let testLabel2 = UILabel(frame:CGRectMake(0,0,100,12))
        testLabel2.textColor = UIColor.lightGrayColor()
        let logNumber = logManager.sharedSingleton.logNumber
        switch logNumber {
        case 0:
            testLabel2.text = Dropitems[0].title
        case 1:
            testLabel2.text = Dropitems[1].title
        default:
            testLabel2.text = "その他"
        }
        
        //スタックビューに追加する。
        stackView.addArrangedSubview(testLabel1)
        stackView.addArrangedSubview(testLabel2)
        //タッチできるようにする
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        stackView.addGestureRecognizer(gesture)
        stackView.userInteractionEnabled = true
        //ナビゲーションバーのタイトルに設定する。
        navigationController!.navigationBar.topItem!.titleView = stackView
    }
    
}

