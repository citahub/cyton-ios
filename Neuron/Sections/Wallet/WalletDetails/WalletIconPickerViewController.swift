//
//  WalletIconPickerViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/12/17.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

//icon_wallet_dog
//icon_wallet_fish
//icon_wallet_owl
//icon_wallet_parrot
//icon_wallet_rat
//icon_wallet_squirrel
//icon_wallet_fox
//icon_wallet_tiger

class WalletIconPickerViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private var walletIcons: [WalleIconType]!
    var wallet: WalletModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "选择头像"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        walletIcons = WalleIconType.allType
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return walletIcons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WalletIconCollectionViewCell.self), for: indexPath) as! WalletIconCollectionViewCell
        cell.iconView.image = walletIcons[indexPath.row].image
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: WalletIconPickerFooterView.self), for: indexPath)
        }
        return UICollectionReusableView()
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

class WalletIconCollectionViewCell: UICollectionViewCell {
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var selectedView: UIView!
}

class WalletIconPickerFooterView: UICollectionReusableView {
    @IBAction func confirm(_ sender: Any) {
    }
}
