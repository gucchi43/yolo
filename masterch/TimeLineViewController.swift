//
//  TimeLineViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class TimeLineTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("TimeLineViewController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
        print("back to TimeLineView")
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(" セルの選択")
        
    }
    
}