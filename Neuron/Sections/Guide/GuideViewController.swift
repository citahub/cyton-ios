//
//  GuideViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/10.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

private var GuideOnceTokenAssiciationKey = 0

class GuideViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    struct GuideItem {
        let title: String
        let subTitle: String
        let imageName: String
    }

    var items = [GuideItem]()
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        items = [
            GuideItem(title: "甄选全球最新DAPP", subTitle: "一应俱全", imageName: "guide_1"),
            GuideItem(title: "多重安全算法保护", subTitle: "钱包秘钥惟您掌握", imageName: "guide_2"),
            GuideItem(title: "开启区块链之旅", subTitle: "探索无限可能", imageName: "guide_3")
        ]
        perform(#selector(showProductAgreementView), with: nil, afterDelay: 0.5)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        GuideService.shared.window?.windowLevel = .alert
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GuideService.shared.window?.windowLevel = .normal
    }

    @objc func showProductAgreementView() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showProductAgreementView), object: nil)
        ProductAgreementViewController.show(in: self)
    }

    @IBAction func createWallet(_ sender: Any) {
        let controller: CreateWalletController = UIStoryboard(storyboard: .addWallet).instantiateViewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func importWallet(_ sender: Any) {
        let controller: ImportWalletController = UIStoryboard(storyboard: .addWallet).instantiateViewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - GuideViewControllerProtocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GuideCollectionViewCell.self), for: indexPath) as! GuideCollectionViewCell
        cell.titleLabel.text = items[indexPath.row].title
        cell.subTitleLabel.text = items[indexPath.row].subTitle
        cell.imageView.image = UIImage(named: items[indexPath.row].imageName)
        cell.backgroundColor = indexPath.row == 3 ? UIColor.clear : UIColor.white
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

}
