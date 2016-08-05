//
//  ColorManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/07/13.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

final class ColorManager {
    private init() {
    }
    static let sharedSingleton = ColorManager()
    //緑系の色
    func mainColor() -> UIColor {
        return UIColor.init(fromHexString: "37CD5F")
        //            return UIColor.init(hexString: "37CD5F", withAlpha: 1.0)
    }
    //紫系の色（mainColorの補色）
    func accsentColor() -> UIColor {
        return UIColor.init(fromHexString: "cd37a5")
        //        return UIColor.init(hexString: "cd37a5", withAlpha: 1.0)
    }

    func defaultButtonColor() -> UIColor { //skyBuleColor
        return UIColor(red: 19/255.0, green:144/255.0, blue:255/255.0, alpha:1.0)

    }

}

//
//final class logManager {
//    private init() {
//    }
//    static let sharedSingleton = logManager()
//    var logNumber: Int = 0
//    var logUser: NCMBUser = NCMBUser.currentUser()
//    var logTitleToggle: Bool = true
//
//}