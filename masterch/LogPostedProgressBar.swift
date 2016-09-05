//
//  LogPostedProgressBar.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/29.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import YLProgressBar

//なぜかこっちが反応しない（怒）
class LogPostedProgressBar: YLProgressBar {
    
    internal func setProgressBar (){
        self.type = YLProgressBarType.Flat
        self.tintColor = UIColor.orangeColor()
        self.behavior = YLProgressBarBehavior.Indeterminate
        self.stripesOrientation = YLProgressBarStripesOrientation.Vertical
    }
    
}
