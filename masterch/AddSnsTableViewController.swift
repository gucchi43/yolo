//
//  AddSnsTableViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/04/13.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class AddSnsTableViewController: UITableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        print("選択したcell", cell)
        return cell
    }
}

