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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    //cellの数
    func tableView(table: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 2
    }
    
    //各セルの要素を設定する
    func tableView(table: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // tableCell の ID で UITableViewCell のインスタンスを生成
        switch (indexPath.row){
        case 0 :
            print("Twitter連携確認cell")
            let cell = table.dequeueReusableCellWithIdentifier("conectedSnsCell", forIndexPath: indexPath)
            
            let user = NCMBUser.currentUser()
            
            // Tag番号 ２ （連携SNS名）
            let label1 = table.viewWithTag(2) as! UILabel
            label1.text = "\(label1Array[indexPath.row])"
            
            // Tag番号 ４ （連携SNSのロゴImage）
            
            //　Tag番号 ３、４、５ （SNSでのユーザー名、SNSのロゴ、連携済 or 未連携）
            let logoImage1 = table.viewWithTag(4) as! UIImageView
            
            let label2 = table.viewWithTag(3) as! UILabel
            let imgTwitterOn = UIImage(named: "twitter_logo_640*480_origin")
            let imgTwitterOff = UIImage(named: "twitter_logo_640*480_gray")
            
            let labelOnOff = table.viewWithTag(5) as! UILabel
            
            
            //!!!この方法のいいかもしれない, 谷口
//            let twitterDid_test = user.objectForKey("twitterName")
//            
//            if twitterDid_test == nil {
//                //Twitter連携済み
//                if let snsName = user.objectForKey("twitterName") {
//                    print("snsName: \(snsName)")
//                    label2.text = String(snsName)
//                    labelOnOff.text = "連携中"
//                    logoImage1.image = imgTwitterOn
//                } else{
//                    //連携していてtwitterNameがない時（ほぼありえ無い）
//                    label2.text = ""
//                    labelOnOff.text = ""
//                    logoImage1.image = imgTwitterOff
//                }
//            }else {
//                //Twitter未連携
//                label2.text = ""
//                labelOnOff.text = "未連携"
//                logoImage1.image = imgTwitterOff
//            }
//            
            
            let twitterDid = NCMBTwitterUtils.isLinkedWithUser(user)
            if twitterDid == true {
                //Twitter連携済み
                if let snsName = user.objectForKey("twitterName") {
                    print("snsName: \(snsName)")
                    label2.text = String(snsName)
                    labelOnOff.text = "連携中"
                    logoImage1.image = imgTwitterOn
                } else{
                    //連携していてtwitterNameがない時（ほぼありえ無い）
                    label2.text = ""
                    labelOnOff.text = ""
                    logoImage1.image = imgTwitterOff
                }
            }else {
                //Twitter未連携
                label2.text = ""
                labelOnOff.text = "未連携"
                logoImage1.image = imgTwitterOff
            }
    
            return cell
            
        case 1:
            print("Facebook連携確認cell")
            let cell = table.dequeueReusableCellWithIdentifier("conectedSnsCell", forIndexPath: indexPath)
            
            let user = NCMBUser.currentUser()
            
            // Tag番号 ２ （連携SNS名）
            let label1 = table.viewWithTag(2) as! UILabel
            label1.text = "\(label1Array[indexPath.row])"

            //　Tag番号 ３、４、５ （SNSでのユーザー名、SNSのロゴ、連携済 or 未連携）
            let label2 = table.viewWithTag(3) as! UILabel
            
            let logoImage1 = table.viewWithTag(4) as! UIImageView
            let imgFacebookOn = UIImage(named: "facebook_logo_640*480_origin")
            let imgFacebookOff = UIImage(named: "facebook_logo_640*480_gray")
            
            let labelOnOff = table.viewWithTag(5) as! UILabel
            let facebookDid = NCMBFacebookUtils.isLinkedWithUser(user)
            if facebookDid == true {
                //facebook連携済み
                if let snsName = user.objectForKey("facebookName"){
                    print("snsName: \(snsName)")
                    label2.text = String(snsName)
                    labelOnOff.text = "連携中"
                    logoImage1.image = imgFacebookOn
                }else {
                    //連携していてfacebookNameがない時（ほぼありえ無い）
                    label2.text = ""
                    labelOnOff.text = ""
                    logoImage1.image = imgFacebookOff
                }
            }else {
                //Facebook未連携
                label2.text = ""
                labelOnOff.text = "未連携"
                logoImage1.image = imgFacebookOff
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
    
    
    
    /***SNSリンクメソッド***/
    
    //Twitterリンク
    func addSnsToTwitter(user: NCMBUser) {
        NCMBTwitterUtils.linkUser(user) { (error: NSError!) -> Void in
            if error == nil{
                print("twitterリンク開始")
                let name = NCMBTwitterUtils.twitter().screenName
                print("twitterユーザー名 : \(name)")
                user.setObject(name, forKey: "twitterName")
                user.saveInBackgroundWithBlock({ (error) -> Void in
                    if error != nil {
                        print("twitterリンク失敗", error)
                    }else {
                        print("twitterリンク成功")
                        if let a = self.conectSnsTabelView{
                            a.reloadData()
                        }
                        
                    }
                })
            }else {
                print("twitterリンクできず")
            }
        }
        
    }
    
    //Facebookリンク
    func addSnsToFacebook(user: NCMBUser) {
            NCMBFacebookUtils.linkUser(user, withPublishingPermission: nil) { (user: NCMBUser!, error: NSError!) -> Void in
                if error == nil{
                    print("facebookリンク開始")
                    let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,email,gender,link,locale,name,timezone,updated_time,verified,last_name,first_name,middle_name"])
                    graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                        if error == nil{
                            print("facebookリンク情報ゲット")
                            let name = result.valueForKey("name") as! NSString
                            print("facebookユーザー名 : \(name)")
                            user.setObject(name, forKey: "facebookName")
                            user.saveInBackgroundWithBlock({ (error) -> Void in
                                if error != nil {
                                    print("Facebookリンク失敗", error)
                                }else {
                                    print("Facebookリンク成功")
                                    self.conectSnsTabelView.reloadData()
                                }
                            })
                        }else{
                            print("facebook情報ゲット失敗", error)
                        }
                    })
                }else {
                    print("facebookアカウントリンク失敗", error)
                }
            }
    }
    
    
    
    /***SNSアンリンクメソッド***/
    
    //Twitterアンリンク
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
                            print("Twitterアンリンク開始")
                            user.removeObjectForKey("twitterName")
                            user.saveInBackgroundWithBlock({ (error) -> Void in
                                if error == nil {
                                    self.conectSnsTabelView.reloadData()
                                    print("Twitterアンリンク成功")
                                }else{
                                    print("Twitterアンリンク失敗", error)
                                }
                            })
                        }else {
                            print("Twitterアンリンクできず", error)
                        }
                    })
                } else if (buttonIndex >= alert.firstOtherButtonIndex) {
                    print("Other Button Index \(buttonIndex - alert.firstOtherButtonIndex)")
                }
        })
    }
    
    //Facebookアンリンク
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
                            print("Facebookアンリンク開始")
                            user.removeObjectForKey("facebookName")
                            user.saveInBackgroundWithBlock({ (error) -> Void in
                                if error == nil {
                                    self.conectSnsTabelView.reloadData()
                                    print("Facebookアンリンク成功")
                                }else{
                                    print("Facebookアンリンク失敗", error)
                                }
                            })
                            
                        }else {
                            print("Facebookアンリンクできず", error)
                        }
                    })
                }
        })
    }

    @IBAction func unwindToContainerSns(segue: UIStoryboardSegue) {
        print("back to ContainerSnsViewController")
    }
}
