//
//  DeviseSize.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/10/17.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

struct DeviseSize {

    //CGRectを取得
    static func bounds()->CGRect{
        return UIScreen.mainScreen().bounds;
    }

    //画面の横サイズを取得
    static func screenWidth()->Int{
        return Int( UIScreen.mainScreen().bounds.size.width);
    }

    //画面の縦サイズを取得
    static func screenHeight()->Int{
        return Int(UIScreen.mainScreen().bounds.size.height);
    }
}

/*
//
//こうやって使う
//
*/
//iPhone5またはiPhone5s
//if (screenWidth == 320 && screenHeight == 568) {
//
//    //iPhone6
//} else if (screenWidth == 375 && screenHeight == 667) {
//
//    //iPhone6 plus
//} else if (screenWidth == 414 && screenHeight == 736) {
//
//}