//
//  TimeLineViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB

class TimeLineTableViewController: UITableViewController {
    
//     postデータを格納する配列
    var postArray: NSArray = NSArray()
//    tableViewの作成
    @IBOutlet var postTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("TimeLineViewController")
        
//        delegateを設定
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        
        self.postTableView.registerNib(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "postTableViewCell")
        
        self.getPostData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
        print("back to TimeLineView")
    }
//    tableviewのセクションの数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
//    cellの数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
//    選択した時のメソッド
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("セルの選択")
        
    }
//    cellの設定メソッド
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postTableViewCell", forIndexPath: indexPath) as! CustomTableViewCell
        
//        各値をセルに入れる
        let postData: AnyObject = self.postArray[indexPath.row]
        
//        textLabelには(key: "text")の値を入れる
        cell.postTextLabel.text = postData.objectForKey("text") as? String
        
//        画像データの取得
        if postData.objectForKey("image1") != nil { // 複数投稿の時にはどうにかしたいコード(if文)
            let fileName: String = (postData.objectForKey("image1") as? String)!
            let fileData = NCMBFile.fileWithName(fileName, data: nil) as! NCMBFile

            fileData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
                if error != nil {
                    print("写真の取得失敗: \(error)")
                } else {
                    cell.postImageView.image = UIImage(data: imageData!)
                }
            }
        }

//        TableView にある特定の Cell を選択不可にする
        cell.selectionStyle = UITableViewCellSelectionStyle.None
//        TableView にある特定の Cell のアクセサリーをつけない
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        return cell
        
    }
//    timeLineの更新メソッド
    func updatePost() {
        
    }
    
//    postDataの取得メソッド
    func getPostData() {
//        query作成
        let postQuery: NCMBQuery = NCMBQuery(className: "Post")
        postQuery.orderByDescending("postDate") // cellの並べ方
        postQuery.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            
            if error == nil {
                if objects.count > 0 {
                    self.postArray = objects
                    
                    //テーブルビューをリロードする
                    self.postTableView.reloadData()
                }
            } else {
                print(error.localizedDescription)
            }
        })
    }
    
}