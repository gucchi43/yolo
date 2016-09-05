//
//  UserData.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/04/18.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB


//@@@多分シングルトン機能している
//シングルトン実装
 class UserData {
    static var sharedUserData: UserData = {
        return UserData()
    }()
    
    private init(){
    }
    let newUser = NCMBUser()
    
    let user = NCMBUser.currentUser()
    let userProfileImage = NCMBUser.currentUser().objectForKey("userProfileImage")
    let userFaceName = NCMBUser.currentUser().objectForKey("userFaceName")
    let twitterName = NCMBUser.currentUser().objectForKey("twitterName")
    let facebookName = NCMBUser.currentUser().objectForKey("facebookName")
}
