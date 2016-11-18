//
//  DeviceDataViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/11/16.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import Photos
import IDMPhotoBrowser

class DeviceDataViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, IDMPhotoBrowserDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    var shareCameraRollTime: NSDate?
    var shareCameraRollImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
//        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = DeviceDataManager.sharedSingleton.PicOneDayAssetArray.count
        print(count)
        return count
    }


    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Cell はストーリーボードで設定したセルのID

        let cameraRollCell = collectionView.dequeueReusableCellWithReuseIdentifier("cameraRollCell", forIndexPath: indexPath)

        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = cameraRollCell.contentView.viewWithTag(1) as! UIImageView
        let shareButton = cameraRollCell.contentView.viewWithTag(2) as! UIButton
        let timeLabel = cameraRollCell.contentView.viewWithTag(3) as! UILabel
        let locationLabel = cameraRollCell.contentView.viewWithTag(4) as! UILabel

        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
        let assetArray = DeviceDataManager.sharedSingleton.PicOneDayAssetArray
        let asset = assetArray[indexPath.row]
        let manager: PHImageManager = PHImageManager()
        manager.requestImageDataForAsset(asset, options: nil) { (data, title, orientation, dic) in
            imageView.image = UIImage(data: data!)
        }

        shareButton.layer.cornerRadius = shareButton.frame.width / 4

        if let location = asset.location{
            //座標を住所に変換する。
            let myGeocoder:CLGeocoder = CLGeocoder()
            myGeocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in

                if(error == nil) {
                    for placemark in placemarks! {
                        print("placemark", placemark)
                        //                            cell.locationLabel.text = "\(placemark.administrativeArea!)\(placemark.locality!)\(placemark.thoroughfare!)"
                        var locationText = ""
                        if let name = placemark.name{
                            locationText += name
                        }
                        locationLabel.text = locationText
                    }
                } else {
                    locationLabel.text = "住所不明"
                }
            })
        }else {
            locationLabel.text = ""
        }


        // postDateLabel
        let date = asset.creationDate!
        let postDateFormatter: NSDateFormatter = NSDateFormatter()
        postDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        timeLabel.text = postDateFormatter.stringFromDate(date)

        return cameraRollCell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("indexPath.row", indexPath.row )

        let assetArray = DeviceDataManager.sharedSingleton.PicOneDayAssetArray
        let asset = assetArray[indexPath.row]
        let manager: PHImageManager = PHImageManager()
//        let location = makeLocation(asset)
        manager.requestImageDataForAsset(asset, options: nil) { (data, title, orientation, dic) in
            self.tapPostImage(UIImage(data: data!)!, asset: asset)
        }

        
//        delegate?.changeCurrentEmojiLabel(selectEmojiString)

        //        let submitVC = SubmitViewController()
        //        submitVC.setSelectEmoji(selectEmojiString)
    }

    //投稿写真タップ
    func tapPostImage(image : UIImage, asset: PHAsset) {
        print("tapPostImage")
        let photo = IDMPhoto(image: image)
        let photos: NSArray = [photo]
        let browser = IDMPhotoBrowser.init(photos: photos as [AnyObject])
        browser.delegate = self
        var locationText = ""
//        if let location = asset.location{
//            //座標を住所に変換する。
//            let myGeocoder:CLGeocoder = CLGeocoder()
//            myGeocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
//                if(error == nil) {
//                    for placemark in placemarks! {
//                        print("placemark", placemark)
//                        //                            cell.locationLabel.text = "\(placemark.administrativeArea!)\(placemark.locality!)\(placemark.thoroughfare!)"
//                        if let name = placemark.name{
//                            photo.caption += name + " / "
//                        }
//                        if let administrativeArea = placemark.administrativeArea{
//                            photo.caption += administrativeArea
//                        }
//                        if let locality = placemark.locality{
//                            photo.caption += locality
//                        }
//                        if let thoroughfare = placemark.thoroughfare{
//                            photo.caption += thoroughfare
//                        }
//                    }
//                } else {
//                    photo.caption = "住所不明"
//                }
//            })
//        }else {
//            photo.caption = ""
//        }
        self.presentViewController(browser,animated:true ,completion:nil)
    }

//    //位置情報を取得
//    func makeLocation(asset: PHAsset) -> String {
//        if let location = asset.location{
//            //座標を住所に変換する。
//            let myGeocoder:CLGeocoder = CLGeocoder()
//            myGeocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
//                if(error == nil) {
//                    var locationText = ""
//                    for placemark in placemarks! {
//                        print("placemark", placemark)
//                        //                            cell.locationLabel.text = "\(placemark.administrativeArea!)\(placemark.locality!)\(placemark.thoroughfare!)"
//                        if let name = placemark.name{
//                            locationText += name + " / "
//                        }
//                        if let administrativeArea = placemark.administrativeArea{
//                            locationText += administrativeArea
//                        }
//                        if let locality = placemark.locality{
//                            locationText += locality
//                        }
//                        if let thoroughfare = placemark.thoroughfare{
//                            locationText += thoroughfare
//                        }
//                    }
//                } else {
//
//                }
//            })
//        }else {
//            return ""
//        }
//    }

    /// セルの大きさ
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var pageViewRect = self.view.bounds
        return CGSize(width: pageViewRect.width / 2, height: pageViewRect.width / 2)
    }

    /// 横のスペース
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {

        return 0.0

    }

    /// 縦のスペース
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {

        return 0.0
        
    }

    @IBAction func tapShareButton(sender: AnyObject) {
        print("SHAREボタン押した")
        let button = sender as! UIButton
        let cell = button.superview?.superview as! CameraRollCollectionViewCell
        let row = collectionView.indexPathForCell(cell)!.row
        let asset = DeviceDataManager.sharedSingleton.PicOneDayAssetArray[row] as! PHAsset
        if let time = asset.creationDate{
            shareCameraRollTime = time
        }else {
            shareCameraRollTime = CalendarManager.currentDate
        }
        let manager: PHImageManager = PHImageManager()
        manager.requestImageDataForAsset(asset, options: nil) { (data, title, orientation, dic) in
            self.shareCameraRollImage = UIImage(data: data!)
            self.performSegueWithIdentifier("toSubmitVC", sender: true)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toSubmitVC" {
            let submitVC: SubmitViewController = segue.destinationViewController as! SubmitViewController
            print("これはどうなる")
//            if toggleWeek == false {
//                submitVC.weekToggle = false
//            }else {
//                submitVC.weekToggle = true
//            }
            submitVC.postDate = shareCameraRollTime
            submitVC.postImage1 = shareCameraRollImage
        }
//        if segue.identifier == "toSubmitVCfromPic" {
//            let submitVC: SubmitViewController = segue.destinationViewController as! SubmitViewController
//            if toggleWeek == false {
//                submitVC.weekToggle = false
//            }else {
//                submitVC.weekToggle = true
//            }
//            print("shareCameraRollDate", shareCameraRollDate)
//            submitVC.postDate = shareCameraRollDate
//            submitVC.postImage1 = shareCameraRollImage
//        }
    }

}
