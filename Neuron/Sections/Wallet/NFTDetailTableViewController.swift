////
////  NFTDetailTableViewController.swift
////  Neuron
////
////  Created by XiaoLu on 2018/9/11.
////  Copyright © 2018年 Cryptape. All rights reserved.
////
//
//import UIKit
//
//class NFTDetailTableViewController: UICollectionView {
//    @IBOutlet weak var headImageView: UIImageView!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var idLabel: UILabel!
//    @IBOutlet weak var assetNamelabel: UILabel!
//
//    var assetsModel: AssetsModel!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "藏品详情"
//        if assetsModel.image_preview_url != nil {
//            headImageView.sd_setImage(with: URL(string: assetsModel.image_preview_url!))
//        }
//        if assetsModel.background_color != nil {
//            headImageView.backgroundColor = ColorFromString(hex: "#" + assetsModel.background_color!)
//        }
//        nameLabel.text = assetsModel.name
//        idLabel.text = "ID:" + assetsModel.token_id
//        assetNamelabel.text = assetsModel.asset_contract.name
//        traitsCollectionView.delegate = self
//        traitsCollectionView.dataSource = self
//        tableView.rowHeight = UITableViewAutomaticDimension
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 12
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "traitsCollectionCell", for: indexPath) as! TraitsCollectionViewCell
//        
//        return cell
//    }
//
//}
