//
//  AppDelegate.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/01/31.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let applicationkey = "d49ceb9e63bd3cf555c8aa7c339ea105b71fa00ed1e6517dec8172beef10c553"
    let clientkey = "ba1432ddcd33638afa4075ab527183c5e0a056e6a0441342be264dc8dd50fdd6"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        NCMB.setApplicationKey(applicationkey, clientKey: clientkey)
        
        let query: NCMBQuery = NCMBQuery(className: "TestClass")
        query.whereKey("message", equalTo: "Hello, NCMB!")
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            
            if error == nil {
                
                if objects.count > 0 {
                    let msg: AnyObject? = objects[0].objectForKey("message")
                    let msgStr: String = msg as! String
                    print("success find data. \(msgStr)")
                } else {
                    var saveError : NSError? = nil
                    let obj : NCMBObject = NCMBObject(className: "TestClass")
                    obj.setObject("Hello, NCMB!", forKey: "message")
                    obj.save(&saveError)
                    
                    if saveError == nil {
                        print("success save data.")
                    } else {
                        print("failure save data. \(saveError)")
                    }
                }
                
            } else {
                print(error.localizedDescription)
            }
        })
        
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

