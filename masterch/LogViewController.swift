//
//  LogViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import CVCalendar

class LogViewController: UIViewController {
    
    @IBOutlet weak var calendarBaseView: UIView!
    var calendarView: CalendarView?

    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var monthLabel: UILabel!
    
    var animationFinished = true
    var selectedDay:DayView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("LogViewController")
        
        monthLabel.text = CVDate(date: NSDate()).globalDescription
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if calendarView == nil {
            calendarView = CalendarView(frame: calendarBaseView.bounds)
            if let calendarView = calendarView {
                calendarBaseView.addSubview(calendarView)
            }
        }
    }
    
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
        print("back to LogView")
    }

}

