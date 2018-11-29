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

    private let items = [
        GuideItem(title: "甄选全球最新DAPP", subTitle: "一应俱全", imageName: "guide_1"),
        GuideItem(title: "多重安全算法保护", subTitle: "钱包秘钥惟您掌握", imageName: "guide_2"),
        GuideItem(title: "开启区块链之旅", subTitle: "探索无限可能", imageName: "guide_3")
    ]

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showProductAgreementView()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc func showProductAgreementView() {
        if ProductAgreementViewController.shouldDisplay {
            performSegue(withIdentifier: "displayAgreement", sender: self)
        }
    }

    // MARK: - GuideViewControllerProtocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = items.count
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

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.row
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
