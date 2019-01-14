//
//  WalletIconPickerViewController.swift
//  Cyton
//
//  Created by 晨风 on 2018/12/17.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class WalletIconPickerViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, WalletIconPickerFooterViewDelegate {
    var wallet: WalletModel!
    private var walletIcons: [WalletModel.Icon]!
    private var currentIcon: WalletModel.Icon!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet.Details.WalletIconPicker.title".localized()
        walletIcons = WalletModel.Icon.allCases
        currentIcon = wallet.icon
    }

    func confirm() {
        let realm = try! Realm()
        try? realm.write {
            wallet.icon = currentIcon
        }
        navigationController?.popViewController(animated: true)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return walletIcons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WalletIconCollectionViewCell.self), for: indexPath) as! WalletIconCollectionViewCell
        cell.iconView.image = walletIcons[indexPath.row].image
        if walletIcons[indexPath.row] == currentIcon {
            cell.selectedView.isHidden = false
            cell.iconView.borderWidth = 1
        } else {
            cell.selectedView.isHidden = true
            cell.iconView.borderWidth = 0
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let identifier = String(describing: WalletIconPickerFooterView.self)
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as! WalletIconPickerFooterView
            view.confirmButton.setTitle("Common.confirm".localized(), for: .normal)
            view.delegate = self
            return view
        }
        return UICollectionReusableView()
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let items = [IndexPath(row: walletIcons.firstIndex(of: currentIcon)!, section: 0), indexPath]
        currentIcon = walletIcons[indexPath.row]
        collectionView.reloadItems(at: items)
    }
}

class WalletIconCollectionViewCell: UICollectionViewCell {
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var selectedView: UIView!
}

protocol WalletIconPickerFooterViewDelegate: class {
    func confirm()
}

class WalletIconPickerFooterView: UICollectionReusableView {
    weak var delegate: WalletIconPickerFooterViewDelegate?
    @IBOutlet weak var confirmButton: UIButton!

    @IBAction func confirm(_ sender: Any) {
        delegate?.confirm()
    }
}
