//
//  NFTDetailController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/11.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class NFTDetailController: UICollectionViewController {

    var assetsModel: AssetsModel!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableview: UICollectionReusableView!
        if kind == UICollectionElementKindSectionHeader {
            reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: "collectionHeader", for: indexPath)
        } else if kind == UICollectionElementKindSectionFooter {
            reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: "collectionFooter", for: indexPath)
        }
        return reusableview
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "traitsCollectionCell", for: indexPath) as! TraitsCollectionViewCell
        // Configure the cell
        return cell
    }

}
