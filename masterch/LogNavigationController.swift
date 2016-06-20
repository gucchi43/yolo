////
////  LogNavigationController.swift
////  masterch
////
////  Created by HIroki Taniguti on 2016/06/21.
////  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
////
//
//import UIKit
//import DropdownMenu
//


//-----本当はここで、Navigationのタイトルとか管理したい-----



//class LogNavigationController: UINavigationController, UINavigationControllerDelegate {
//    
//    var selectedRow: Int = 0
//    var Dropitems: [DropdownItem]!
//    
//    //最初からあるメソッド
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        //デリゲート先に自分を設定する。
//        self.delegate = self
//        
//    }
//    
//    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
//        
//        
////        let label = UILabel()
////        label.text = "ログ"
////        label.sizeToFit()
////        
////        
////        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
////        label.addGestureRecognizer(gesture)
////        label.userInteractionEnabled = true
//////        navigationItem.titleView = label
////        self.navigationBar.topItem?.titleView = label
////        
//////        viewdidloadでは呼ばないでいい
//        
//        
//        
//        
//        //スタックビューを作成
//        let stackView = UIStackView()
//        stackView.axis = .Vertical
//        stackView.alignment = .Center
//        stackView.frame = CGRectMake(0,0,100,40)
//        
//        //タイトルのラベルを作成する。
//        let testLabel1 = UILabel(frame:CGRectMake(0,0,100,20))
//        testLabel1.text = "ログ"
//        
//        //サブタイトルを作成する。
//        let testLabel2 = UILabel(frame:CGRectMake(0,0,100,20))
//        let logNumber = logManager.sharedSingleton.logNumber
//        switch logNumber {
//        case 0:
//            if let Dropitems = Dropitems {
//                testLabel2.text = Dropitems[0].title
//            }else {
//                testLabel2.text = "自分"
//            }
//        case 1:
//            if let Dropitems = Dropitems {
//                testLabel2.text = Dropitems[1].title
//            }else {
//                testLabel2.text = "フォロー"
//            }
//        default:
//            testLabel2.text = "その他"
//        }
//        
//        //スタックビューに追加する。
//        stackView.addArrangedSubview(testLabel1)
//        stackView.addArrangedSubview(testLabel2)
//        
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
//        stackView.addGestureRecognizer(gesture)
//        stackView.userInteractionEnabled = true
//        
//        
//        
//        //ナビゲーションバーのタイトルに設定する。
//        self.navigationBar.topItem!.titleView = stackView
//    }
//    
//        func tapped(tapGestureRecognizer: UITapGestureRecognizer) {
//            print("ナビゲーションタイトルをタップ")
//            let item1 = DropdownItem(title: "自分")
//            let item2 = DropdownItem(title: "フォロー")
//            //        let item3 = DropdownItem(title: "オール")
//            //        let item2 = DropdownItem(image: UIImage(named: "takigutihikari")!, title: "File")
//            //        let item3 = DropdownItem(image: UIImage(named: "takigutihikari")!, title: "Post", style: .Highlight)
//            //        let item4 = DropdownItem(image: UIImage(named: "takigutihikari")!, title: "Event", style: .Highlight, accessoryImage: UIImage(named: "accessory")!)
//            
//            
//            //将来的には可変になる、アプリないで変更可能に…
//            Dropitems = [item1, item2]
//            let menuView = DropdownMenu(navigationController: self, items: Dropitems, selectedRow: selectedRow)
////            let menuView = DropdownMenu(navigationController: navigationController!, items: Dropitems, selectedRow: selectedRow)
//            menuView.delegate = self
//            menuView.showMenu(onNavigaitionView: true)
//        }
//
//}
//
//
//
////DropdownMenuDelegateのDelegate
//extension LogNavigationController: DropdownMenuDelegate {
//    func dropdownMenu(dropdownMenu: DropdownMenu, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        print("DropdownMenu didselect \(indexPath.row) text:\(Dropitems[indexPath.row].title)")
//        
//        self.selectedRow = indexPath.row
//        
//        //        if indexPath.row != Dropitems.count - 1 {
//        //            //一番上選んだ時
//        //            self.selectedRow = indexPath.row
//        //        }else {
//        //            //それ意外
//        //            self.selectedRow = indexPath.row
//        //        }
//        logManager.sharedSingleton.logNumber = indexPath.row
//        let logNumber = logManager.sharedSingleton.logNumber
//        print("logNumber", logNumber, Dropitems[indexPath.row].title)
//        
////        let a = CalendarView()
////        a.resetMonthView()
////        
//        let logViewController = LogViewController()
//        logViewController.ChangeloadQuery(logNumber)
//        
//        
//        //        let b = CalendarMonthView(frame: calendarBaseView.bounds, date: CalendarManager.currentDate)
//        //        CalendarMonthView(frame: CGRect(origin: CGPoint(x: 0, y: CGRectGetHeight(frame)), size: frame.size), date: CalendarManager.currentDate - (CalendarManager.currentDate.day - 1).days)
//        
//        
//        //        b.startSetUpDays(CalendarManager.currentDate - (CalendarManager.currentDate.day - 1).days)
//        //        b.getLogColorDate(CalendarManager.currentDate)
//        
//    }
//}
//
