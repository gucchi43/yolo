//
//  likedManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/19.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

final class likedManager {
    private init() {
        
    }
    
    static let sharedSingleton = likedManager()
    
    var isLikedToggle: Bool = false
}