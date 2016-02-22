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

//// MARK: - CVCalendarViewDelegate & CVCalendarMenuViewDelegate
//
//extension LogViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
//    
//    /// Required method to implement!
//    func presentationMode() -> CalendarMode {
//        return .MonthView
//    }
//    
//    /// Required method to implement!
//    func firstWeekday() -> Weekday {
//        return .Sunday
//    }
//    
//    // MARK: Optional methods
//    
//    
//    func shouldAnimateResizing() -> Bool {
//        return true // Default value is true
//    }
//    
//    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
//        print("\(dayView.date.commonDescription) is selected!")
//        selectedDay = dayView
//    }
//    
//    func presentedDateUpdated(date: CVDate) {
//        if monthLabel.text != date.globalDescription && self.animationFinished {
//            let updatedMonthLabel = UILabel()
//            updatedMonthLabel.textColor = monthLabel.textColor
//            updatedMonthLabel.font = monthLabel.font
//            updatedMonthLabel.textAlignment = .Center
//            updatedMonthLabel.text = date.globalDescription
//            updatedMonthLabel.sizeToFit()
//            updatedMonthLabel.alpha = 0
//            updatedMonthLabel.center = self.monthLabel.center
//            
//            let offset = CGFloat(48)
//            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
//            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
//            
//            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
//                self.animationFinished = false
//                self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
//                self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
//                self.monthLabel.alpha = 0
//                
//                updatedMonthLabel.alpha = 1
//                updatedMonthLabel.transform = CGAffineTransformIdentity
//                
//                }) { _ in
//                    
//                    self.animationFinished = true
//                    self.monthLabel.frame = updatedMonthLabel.frame
//                    self.monthLabel.text = updatedMonthLabel.text
//                    self.monthLabel.transform = CGAffineTransformIdentity
//                    self.monthLabel.alpha = 1
//                    updatedMonthLabel.removeFromSuperview()
//            }
//            
//            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
//        }
//    }
//    
//    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
//        return true
//    }
//    
//    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
//        let day = dayView.date.day
//        let randomDay = Int(arc4random_uniform(31))
//        if day == randomDay {
//            return true
//        }
//        
//        return false
//    }
//    
//    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
//        
//        let red = CGFloat(arc4random_uniform(600) / 255)
//        let green = CGFloat(arc4random_uniform(600) / 255)
//        let blue = CGFloat(arc4random_uniform(600) / 255)
//        
//        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
//        
//        let numberOfDots = Int(arc4random_uniform(3) + 1)
//        switch(numberOfDots) {
//        case 2:
//            return [color, color]
//        case 3:
//            return [color, color, color]
//        default:
//            return [color] // return 1 dot
//        }
//    }
//    
//    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
//        return true
//    }
//    
//    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
//        return 13
//    }
//    
//    
//    func weekdaySymbolType() -> WeekdaySymbolType {
//        return .Short
//    }
//    
//    func selectionViewPath() -> ((CGRect) -> (UIBezierPath)) {
//        return { UIBezierPath(rect: CGRectMake(0, 0, $0.width, $0.height)) }
//    }
//    
//    func shouldShowCustomSingleSelection() -> Bool {
//        return false
//    }
//    
//    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
//        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
//        circleView.fillColor = .colorFromCode(0xCCCCCC)
//        return circleView
//    }
//    
//    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
//        if (dayView.isCurrentDay) {
//            return true
//        }
//        return false
//    }
//    
//    
//    
//    // MARK: - サークルの実装
//    
//    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
//        //        カレンダーレイアウトコード実装部分
//        let π = M_PI
//        
//        let ringSpacing: CGFloat = 3.0
//        let ringInsetWidth: CGFloat = 1.0
//        let ringVerticalOffset: CGFloat = 1.0
//        var ringLayer: CAShapeLayer!
//        let ringLineWidth: CGFloat = 4.0
//        let ringLineColour: UIColor = .redColor()
//        
//        let newView = UIView(frame: dayView.bounds)
//        
//        let diameter: CGFloat = (newView.bounds.width) - ringSpacing
//        let radius: CGFloat = diameter / 2.0
//        
//        let rect = CGRectMake(newView.frame.midX-radius, newView.frame.midY-radius-ringVerticalOffset, diameter, diameter)
//        
//        ringLayer = CAShapeLayer()
//        newView.layer.addSublayer(ringLayer)
//        
//        ringLayer.fillColor = nil
//        ringLayer.lineWidth = ringLineWidth
//        ringLayer.strokeColor = ringLineColour.CGColor
//        
//        let ringLineWidthInset: CGFloat = CGFloat(ringLineWidth/2.0) + ringInsetWidth
//        let ringRect: CGRect = CGRectInset(rect, ringLineWidthInset, ringLineWidthInset)
//        let centrePoint: CGPoint = CGPointMake(ringRect.midX, ringRect.midY)
//        let startAngle: CGFloat = CGFloat(-π/2.0)
//        let endAngle: CGFloat = CGFloat(π * 2.0) + startAngle
//        let ringPath: UIBezierPath = UIBezierPath(arcCenter: centrePoint, radius: ringRect.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
//        
//        ringLayer.path = ringPath.CGPath
//        ringLayer.frame = newView.layer.bounds
//        
//        return newView
//    }
//    
//    // MARK: - サークル実装のreturn
//    //    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
//    //        if (Int(arc4random_uniform(3)) == 1) {
//    //            return true
//    //        }
//    //
//    //        return false
//    //    }
//}
//
//
//// MARK: - CVCalendarViewAppearanceDelegate
//
//extension LogViewController: CVCalendarViewAppearanceDelegate {
//    func dayLabelPresentWeekdayInitallyBold() -> Bool {
//        return false
//    }
//    
//    func spaceBetweenDayViews() -> CGFloat {
//        return 2
//    }
//}
