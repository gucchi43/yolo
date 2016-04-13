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
//    連携したSNSの配列
    var conectedSnsArray: NSMutableArray = []
    
    
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
        switch (indexPath.section){
        case 0 :
            print("case0 呼び出し")
            let cell = table.dequeueReusableCellWithIdentifier("conectedSnsCell", forIndexPath: indexPath)
            
            // Tag番号 ２ で UILabel インスタンスの生成
            let label1 = table.viewWithTag(2) as! UILabel
            label1.text = "\(label1Array[indexPath.row])"
            
            // Tag番号 ３ で UILabel インスタンスの生成
            let label2 = table.viewWithTag(3) as! UILabel
            label2.text = "\(label2Array[indexPath.row])"
            return cell
            
            // Tag番号 ４ で UIImageView インスタンスの生成
            let img = UIImage(named: "\(imgArray[indexPath.row])")
            let logoImage1 = table.viewWithTag(4) as! UIImageView
            logoImage1.image = img
            
            let labelOnOff = table.viewWithTag(5) as! UILabel
            labelOnOff.text = "\(labelOnOffArray[indexPath.row])"
            return cell
            
        default :
            fatalError()
        }
    }
    
//    /*
//    Cellが選択された際に呼び出される.
//    */
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        switch (indexPath.section){
//        case 0:
//            print("case 0")
//        default :
//            // 選択中のセルが何番目か.
//            print("Num: \(indexPath.row)")
//            
//            // 選択中のセルのvalue.
//            print("Value: \(conectedSnsArray[indexPath.row])")
//            
//            // 選択中のセルを編集できるか.
//            print("Edeintg: \(tableView.editing)")
//        }
//    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("cell選択")
//        addSnsToFacebook()
        switch (indexPath.row){
        case 0:
            addSnsToTwitter()
            print("選択したindexPath", indexPath.row)
        case 1:
            addSnsToFacebook()
            print("選択したindexPath", indexPath.row)
        default:
            fatalError()
        }
    }
    
    func addSnsToFacebook() {
        let user = NCMBUser.currentUser()
        NCMBFacebookUtils.linkUser(user, withPublishingPermission: nil) { (user: NCMBUser!, error: NSError!) -> Void in
            if error == nil{
                print("facebookアカウントリンク成功")
            }else {
                print("facebookアカウントリンク失敗")
            }
        }
    }
    
    func addSnsToTwitter() {
        let user = NCMBUser.currentUser()
        NCMBTwitterUtils.linkUser(user) { (error: NSError!) -> Void in
            if error == nil{
                print("twitterアカウントリンク成功")
            }else {
                print("twitterアカウントリンク失敗")
            }
        }
    }
    
    @IBAction func addSnsCell(sender: AnyObject) {
        print("addSnsCell押した")
        
        conectedSnsArray.addObject("連携SNS その1")
        print("conectedSnsArray \(conectedSnsArray.count)")
        conectSnsTabelView.reloadData()
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func unwindToContainerSns(segue: UIStoryboardSegue) {
        print("back to ContainerSnsViewController")
    }
}
