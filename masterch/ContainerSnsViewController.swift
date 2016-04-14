//
//  ContainerSnsViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/03/20.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit


class ContainerSnsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var conectSnsTabelView: UITableView!

//    sectionのタイトル
    let sectionTitle: NSArray = ["連携SNS"]
    
    let imgArray: NSArray = ["noprofile.png","noprofile.png"]
    let label1Array: NSArray = ["Twitter", "Facebook"]
    let label2Array: NSArray = ["たにぐちひろき", "谷口弘樹"]
    let labelOnOffArray: NSArray = ["連携中", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Sectionの数
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return sectionTitle.count
//    }
    
//    // Sectionのタイトル
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionTitle[section] as? String
//    }
    
    
    //
    func tableView(table: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 2
    }
    
    //各セルの要素を設定する
    func tableView(table: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // tableCell の ID で UITableViewCell のインスタンスを生成
        switch (indexPath.row){
        case 0 :
            print("case0 呼び出し")
            let cell = table.dequeueReusableCellWithIdentifier("conectedSnsCell", forIndexPath: indexPath)
            
            let user = NCMBUser.currentUser()
            
            // Tag番号 ２ （連携SNS名）
            let label1 = table.viewWithTag(2) as! UILabel
            label1.text = "\(label1Array[indexPath.row])"
            
            // Tag番号 ３ （連携SNSユーザー名）
            let label2 = table.viewWithTag(3) as! UILabel
            let snsName = user.objectForKey("twitterName") as! String?
            print("snsName: \(snsName)")
            label2.text = snsName
            
            // Tag番号 ４ （連携SNSのロゴImage）
            let img = UIImage(named: "\(imgArray[indexPath.row])")
            let logoImage1 = table.viewWithTag(4) as! UIImageView
            logoImage1.image = img
            
            //　Tag番号 ５ （連携済 or 未連携）
            let labelOnOff = table.viewWithTag(5) as! UILabel
            let twitterDid = NCMBTwitterUtils.isLinkedWithUser(user)
            if twitterDid == true {
                labelOnOff.text = "連携中"
            }else {
                labelOnOff.text = ""
            }
            
            return cell
            
        case 1:
            print("case0 呼び出し")
            let cell = table.dequeueReusableCellWithIdentifier("conectedSnsCell", forIndexPath: indexPath)
            
            let user = NCMBUser.currentUser()
            
            // Tag番号 ２ （連携SNS名）
            let label1 = table.viewWithTag(2) as! UILabel
            label1.text = "\(label1Array[indexPath.row])"
            
            // Tag番号 ３ （連携SNSユーザー名）
            let label2 = table.viewWithTag(3) as! UILabel
            let snsName = user.objectForKey("facebookName") as! String?
            print("snsName: \(snsName)")
            label2.text = snsName
            
            // Tag番号 ４ （連携SNSのロゴImage）
            let img = UIImage(named: "\(imgArray[indexPath.row])")
            let logoImage1 = table.viewWithTag(4) as! UIImageView
            logoImage1.image = img
            
            //　Tag番号 ５ （連携済 or 未連携）
            let labelOnOff = table.viewWithTag(5) as! UILabel
            let facebookDid = NCMBFacebookUtils.isLinkedWithUser(user)
            if facebookDid == true {
                labelOnOff.text = "連携中"
            }else {
                labelOnOff.text = ""
            }
            
            return cell
            
        default :
            fatalError()
        }
    }
    
    //cellを選択した時
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("cell選択")
        switch (indexPath.row){
        case 0:
            //Twitter連携
            print("Twitter連携cell")
            let user = NCMBUser.currentUser()
            let twitterDid = NCMBTwitterUtils.isLinkedWithUser(user)
            if twitterDid == true{
                print("Twitter連携している時")
                deleteTwitterAccount(user)
            }else {
                print("Twitter連携していない時")
                addSnsToTwitter(user)
            }
            
        case 1:
            //Facebook連携
            print("Facebook連携cell")
            let user = NCMBUser.currentUser()
            let facebookDid = NCMBFacebookUtils.isLinkedWithUser(user)
            if facebookDid == true {
                print("Facebook連携している時")
                deleteFacebookAccount(user)
            }else {
                print("Facebook連携していない時")
                addSnsToFacebook(user)
            }
        default:
            fatalError()
        }
    }
    
    func addSnsToFacebook(user: NCMBUser) {
            NCMBFacebookUtils.linkUser(user, withPublishingPermission: nil) { (user: NCMBUser!, error: NSError!) -> Void in
                if error == nil{
                    print("facebookアカウントリンク成功")
                    let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,email,gender,link,locale,name,timezone,updated_time,verified,last_name,first_name,middle_name"])
                    graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                        if error == nil{
                            print("facebook情報取得成功")
                            let name = result.valueForKey("name") as! NSString
                            print("facebookユーザー名 : \(name)")
                            user.setObject(name, forKey: "facebookName")
                            self.conectSnsTabelView.reloadData()
                        }else{
                            print("facebook情報取得失敗")
                        }
                    })
                }else {
                    print("facebookアカウントリンク失敗")
                }
            }
    }
    
    func addSnsToTwitter(user: NCMBUser) {
            NCMBTwitterUtils.linkUser(user) { (error: NSError!) -> Void in
                if error == nil{
                    print("twitterアカウントリンク成功")
                    let name = NCMBTwitterUtils.twitter().screenName
                    print("twitterユーザー名 : \(name)")
                    user.setObject(name, forKey: "twitterName")
                    self.conectSnsTabelView.reloadData()
                }else {
                    print("twitterアカウントリンク失敗")
                }
            }

    }
    
    
    
    func deleteTwitterAccount(user: NCMBUser) {
        //「解除しますか？」アラート呼び出し
        RMUniversalAlert.showAlertInViewController(self,
            withTitle: "このアカウントはすでにTwitterと連携しています。",
            message: "連携を解除する場合は、解除するボタンを押してください",
            cancelButtonTitle: "完了",
            destructiveButtonTitle: "解除する",
            otherButtonTitles:nil,
            tapBlock: {(alert, buttonIndex) in
                if (buttonIndex == alert.cancelButtonIndex) {
                    print("完了 Tapped")
                } else if (buttonIndex == alert.destructiveButtonIndex) {
                    print("解除する Tapped")
                    NCMBTwitterUtils.unlinkUserInBackground(user, block: { (error) -> Void in
                        if error == nil {
                            print("Twitterアカウント解除成功")
                            self.conectSnsTabelView.reloadData()
                        }else {
                            print("Twitterアカウント解除失敗", error)
                        }
                    })
                } else if (buttonIndex >= alert.firstOtherButtonIndex) {
                    print("Other Button Index \(buttonIndex - alert.firstOtherButtonIndex)")
                }
        })
    }
    
    func deleteFacebookAccount(user: NCMBUser) {
        //「解除しますか？」アラート呼び出し
        RMUniversalAlert.showAlertInViewController(self,
            withTitle: "このアカウントはすでにFacebookと連携しています。",
            message: "連携を解除する場合は、解除するボタンを押してください",
            cancelButtonTitle: "完了",
            destructiveButtonTitle: "解除する",
            otherButtonTitles:nil,
            tapBlock: {(alert, buttonIndex) in
                if (buttonIndex == alert.cancelButtonIndex) {
                    print("完了 Tapped")
                } else if (buttonIndex == alert.destructiveButtonIndex) {
                    print("解除する Tapped")
                    NCMBFacebookUtils.unLinkUser(user, withBlock: { (user, error) -> Void in
                        if error == nil {
                            print("Facebookアカウント解除成功")
                            self.conectSnsTabelView.reloadData()
                        }else {
                            print("Facebookアカウント解除失敗", error)
                        }
                    })
                }
        })
    }
    
//    @IBAction func addSnsCell(sender: AnyObject) {
//        print("addSnsCell押した")
//        
//        conectedSnsArray.addObject("連携SNS その1")
//        print("conectedSnsArray \(conectedSnsArray.count)")
//        conectSnsTabelView.reloadData()
//        
//    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func unwindToContainerSns(segue: UIStoryboardSegue) {
        print("back to ContainerSnsViewController")
    }
}
