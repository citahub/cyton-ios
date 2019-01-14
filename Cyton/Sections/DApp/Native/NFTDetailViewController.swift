//
//  NFTDetailController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/9/11.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import SafariServices

class NFTDetailViewController: UICollectionViewController {
    var assetsModel: AssetsModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DApp.NFT.DetailTitle".localized()
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: "collectionHeader", for: indexPath) as! NFTHeaderReusableView
            if assetsModel.image_preview_url != nil {
                reusableview.headerImageView.sd_setImage(with: URL(string: assetsModel.image_preview_url!))
            }
            if assetsModel.background_color != nil {
                reusableview.headerImageView.backgroundColor = UIColor(hex: "#" + assetsModel.background_color!)
            }
            reusableview.nameLabel.text = assetsModel.name
            reusableview.idLabel.text = "ID:" + assetsModel.token_id
            reusableview.assetNameLabel.text = assetsModel.asset_contract.name
            return reusableview
        } else if kind == UICollectionView.elementKindSectionFooter {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: "collectionFooter", for: indexPath) as! NFTFooterReusableView
            reusableview.introductionLabel.text = assetsModel.description
            return reusableview
        } else {
            let reusableview = UICollectionReusableView()
            return reusableview
        }
    }

    @IBAction func viewNFTDetail(_ sender: UIButton) {
        let safariController = SFSafariViewController(url: URL(string: assetsModel.external_link ?? "https://www.nervos.org")!)
        self.present(safariController, animated: true, completion: nil)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsModel.traits.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "traitsCollectionCell", for: indexPath) as! TraitsCollectionViewCell
        let traitModel = assetsModel.traits[indexPath.row]
        cell.traitTypeLabel.text = traitModel?.trait_type
        if traitModel?.value.string != nil {
            cell.valueLabel.text = traitModel?.value.string
        } else {
            cell.valueLabel.text = traitModel?.value.int?.description
        }
        return cell
    }

}
