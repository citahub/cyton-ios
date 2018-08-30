//
//  WalletAssetPageViewController.swift
//  Neuron
//
//  Created by Yate Fulham on 2018/08/28.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class WalletAssetPageViewController: UIPageViewController {
    var pages = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        let tokensViewController = storyboard!.instantiateViewController(withIdentifier: "tokensViewController")
        let nfcViewController = storyboard!.instantiateViewController(withIdentifier: "nfcViewController")
        pages.append(tokensViewController)
        pages.append(nfcViewController)

        setViewControllers([tokensViewController], direction: .forward, animated: false)
    }
}

extension WalletAssetPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.firstIndex(of: viewController)!
        if currentIndex > 0 {
            return pages[currentIndex - 1]
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.firstIndex(of: viewController)!
        if currentIndex < pages.count - 1 {
            return pages[currentIndex + 1]
        } else {
            return nil
        }
    }
}

extension WalletAssetPageViewController: UIPageViewControllerDelegate {
}
