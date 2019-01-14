//
//  GuideViewController.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/10.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

private var GuideOnceTokenAssiciationKey = 0

class GuideViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let items = ["guide_page_1", "guide_page_2", "guide_page_3"]

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var createWalletButton: UIButton!
    @IBOutlet private weak var importWalletButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        createWalletButton.setTitle("Guide.createWallet".localized(), for: .normal)
        importWalletButton.setTitle("Guide.existingWallet".localized(), for: .normal)
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
        cell.imageView.image = UIImage(named: items[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.row
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
