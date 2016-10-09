//
//  EmojiKeyboard.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/10/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class EmojiCollectionKeyboard: UIView, UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {

    var collectionView:UICollectionView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        // レイアウト作成
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumInteritemSpacing = 5.0
        flowLayout.minimumLineSpacing = 5.0
        flowLayout.itemSize = CGSizeMake(frame.height / 6, frame.height / 6)

        // コレクションビュー作成
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.lightGrayColor()
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EmojiData.emojiArray.count
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectEmojiString = EmojiData.emojiArray[indexPath.row]
        print("seletEmojiString", selectEmojiString)

        let submitVC = SubmitViewController()
        submitVC.setSelectEmoji(selectEmojiString)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as UICollectionViewCell

        let label = UILabel()
        label.sizeThatFits(cell.bounds.size)
        label.text = EmojiData.emojiArray[indexPath.row]
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(32)
        
        cell.backgroundView = label
        
        return cell
    }
}
