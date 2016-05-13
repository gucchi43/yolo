//
//  TimeLineViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
//import NCMB

class TimeLineTableViewController: UITableViewController {
    
    // postデータを格納する配列
    var postArray: NSArray = NSArray()
    //    tableViewの作成
    @IBOutlet var postTableView: UITableView!
    
    var selectedPostImage: UIImage!
    var selectedPostText: String!
    var selectedPostDate: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("TimeLineViewController")
        
        postTableView.estimatedRowHeight = 370
        postTableView.rowHeight = UITableViewAutomaticDimension
        
        // プルリフレッシュの作成
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("pullToRefresh"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        self.pullToRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
        print("back to TimeLineView")
    }
    
    // tableviewのセクションの数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // cellの数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    // cellの設定メソッド
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "TimelineCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TimelineCell
        
        // 各値をセルに入れる
        let postData = self.postArray[indexPath.row]
        
        // postTextLabelには(key: "text")の値を入れる
        cell.postTextLabel.text = postData.objectForKey("text") as? String
        
        // postDateLabelには(key: "postDate")の値を、NSDateからstringに変換して入れる
        let date = postData.objectForKey("postDate") as? NSDate
        let postDateFormatter: NSDateFormatter = NSDateFormatter()
        postDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        cell.postDateLabel.text = postDateFormatter.stringFromDate(date!)
        
        //プロフィール写真の形を円形にする
        cell.postImageView.layer.cornerRadius = cell.postImageView.frame.width/2
        cell.postImageView.layer.masksToBounds = true

        let auther = postData.objectForKey("user") as? NCMBUser
        if let auther = auther {
            cell.userNameLabel.text = auther.userName
            let postImageData = NCMBFile.fileWithName(auther.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
            postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("プロフィール画像の取得失敗： ", error)
                    cell.userProfileImageView.image = UIImage(named: "noprofile")
                } else {
                    cell.userProfileImageView.image = UIImage(data: imageData!)
                }
            })
        } else {
            cell.userNameLabel.text = "username"
            cell.userProfileImageView.image = UIImage(named: "noprofile")
        }
        
        // 画像データの取得
        if let postImageName = postData.objectForKey("image1") as? String {
            cell.imageViewHeightConstraint.constant = 150.0;
            let postImageData = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
            postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("サムネイルの取得失敗： ", error)
                } else {
                    cell.postImageView.image = UIImage(data: imageData!)
                }
            })
        } else {
            cell.postImageView.image = nil
            cell.imageViewHeightConstraint.constant = 0.0;
        }
        
        return cell
    }
    
    // 選択した時のメソッド
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("セルの選択: \(indexPath.row)")
        // 各値をセルに入れる
        let postData = self.postArray[indexPath.row]
        
        self.selectedPostText = postData.objectForKey("text") as? String
//        self.selectedPostDate = postData.objectForKey("postDate") as? String
        
        // postDateLabelには(key: "postDate")の値を、NSDateからstringに変換して入れる
        let date = postData.objectForKey("postDate") as? NSDate
        let postDateFormatter: NSDateFormatter = NSDateFormatter()
        postDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        self.selectedPostDate = postDateFormatter.stringFromDate(date!)
        
        
        // 画像データの取得
        if let postImageName = postData.objectForKey("image1") as? String {
            let postImageData = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
            postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("写真の取得失敗： ", error)
                } else {
                    self.selectedPostImage = UIImage(data: imageData!)
                }
            })
        }
        
        // SubViewController へ遷移するために Segue を呼び出す
        performSegueWithIdentifier("toPostDetailViewController", sender: nil)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPostDetailViewController" {
            let postDetailVC: PostDetailViewController = segue.destinationViewController as! PostDetailViewController

//            postDetailVC.postDateText = selectedPostDate
//            postDetailVC.postText = selectedPostText
//            postDetailVC.postImage = selectedPostImage
        }
    }
    
    // timeLineの更新メソッド
    func pullToRefresh() {
        self.getPostData()
        self.postTableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // postDataの取得メソッド
    func getPostData() {
        // query作成
        let postQuery: NCMBQuery = NCMBQuery(className: "Post")
        postQuery.orderByDescending("postDate") // cellの並べ方
        postQuery.includeKey("user")
        postQuery.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            
            if error == nil {
                if objects.count > 0 {
                    self.postArray = objects
                    
                    // テーブルビューをリロードする
                    self.postTableView.reloadData()
                }
            } else {
                print(error.localizedDescription)
            }
        })
    }
    
}