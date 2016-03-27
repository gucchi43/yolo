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
    let sectionTitle: NSArray = ["連携済みSNSその１", "連携済みSNSその２"]
    
    
//    連携したSNSの配列
    var conectedSnsArray: NSMutableArray = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    // Sectioのタイトル
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section] as? String
    }
    
    
    func tableView(table: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section.advancedBy(0, limit: 3){
        case 0 :
            return 1
            
        default :
            return conectedSnsArray.count
        }
    }
    
    //各セルの要素を設定する
    func tableView(table: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // tableCell の ID で UITableViewCell のインスタンスを生成
        switch (indexPath.section){
        case 0 :
            print("case0 呼び出し")
            let cell = table.dequeueReusableCellWithIdentifier("addSnsCell", forIndexPath: indexPath)
            return cell
            
//            //            連携SNS追加
//                //        let img = UIImage(named: ""))
//                //        // Tag番号 1 で UIImageView インスタンスの生成
//                //        let imageView = table.viewWithTag(1) as! UIImageView
//                //        imageView.image = img
//                
//                // Tag番号 ２ で UILabel インスタンスの生成
//                let label1 = table.viewWithTag(2) as! UILabel
//                label1.text = "No.\(indexPath.row + 1)"
//                
//                // Tag番号 ３ で UILabel インスタンスの生成
//                let label2 = table.viewWithTag(3) as! UILabel
//                label2.text = "最上もが"
            
            
        default :
            //            連携済みSNSのリスト表示
                //        let img = UIImage(named: ""))
                //        // Tag番号 1 で UIImageView インスタンスの生成
                //        let imageView = table.viewWithTag(1) as! UIImageView
                //        imageView.image = img
                
                // Tag番号 ２ で UILabel インスタンスの生成
                let cell = table.dequeueReusableCellWithIdentifier("conectedSnsCell", forIndexPath: indexPath)
                
                let label1 = table.viewWithTag(2) as! UILabel
                label1.text = "No.\(indexPath.row + 1)"
                
                // Tag番号 ３ で UILabel インスタンスの生成
                let label2 = table.viewWithTag(3) as! UILabel
                label2.text = "夢見ねむ"
                return cell
        }
    }
    
    /*
    Cellが選択された際に呼び出される.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section){
        case 0:
            print("case 0")
        default :
            // 選択中のセルが何番目か.
            print("Num: \(indexPath.row)")
            
            // 選択中のセルのvalue.
            print("Value: \(conectedSnsArray[indexPath.row])")
            
            // 選択中のセルを編集できるか.
            print("Edeintg: \(tableView.editing)")

            
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
