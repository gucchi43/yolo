//
//  UserListManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/11/12.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB

final class UserListManager {
    private init() {
    }
    static let sharedSingleton  = UserListManager()
    var followNumber: Int?
    var followerNumber: Int?
    var followArray = [NCMBUser]()
    var followerArray = [NCMBUser]()
}
