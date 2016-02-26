//
//  CalendarDayView.swift
//  CrossCalendarSample
//
//  Created by Eisuke Sato on 2016/02/19.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit

class CalendarDayView: UIView {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, year: Int, month: Int, day: Int, weekday: Int) {
        super.init(frame: frame)
        let dayWidth = Int((UIScreen.mainScreen().bounds.size.width) / 7)
        let dayHeight = 30
        
        let dayButton = UIButton(frame: CGRect(x: 0, y: 0, width: dayWidth, height: dayHeight))
        dayButton.titleLabel?.textAlignment = NSTextAlignment.Center
        dayButton.setTitle(String(format: "%02d", day), forState: UIControlState.Normal)
        dayButton.addTarget(self, action: "onTapCalendarDayButton:", forControlEvents: .TouchUpInside)

        if weekday == 1 {
            //日曜日は赤
            dayButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        } else if weekday == 7 {
            //土曜日は青
            dayButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        } else {
            dayButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        }

        self.addSubview(dayButton)
    }

    func onTapCalendarDayButton(sender: UIButton) {
        print("onTapCalendarDayButton:")
        print("押した日付: \(sender.currentTitle)")
        sender.setTitleColor(UIColor.greenColor(), forState: .Normal)
    }
}
