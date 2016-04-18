//
//  UserData.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/04/18.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

 class UserData: UIViewController {
    let newUser = NCMBUser()
    
    let user = NCMBUser.currentUser()
    let userProfileImage = NCMBUser.currentUser().objectForKey("userProfileImage")
    let userFaceName = NCMBUser.currentUser().objectForKey("userFaceName")
    let twitterName = NCMBUser.currentUser().objectForKey("twitterName")
    let facebookName = NCMBUser.currentUser().objectForKey("facebookName")
    
}
