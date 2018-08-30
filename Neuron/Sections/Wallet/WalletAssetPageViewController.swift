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
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.firstIndex(of: viewController)!
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
}

extension WalletAssetPageViewController: UIPageViewControllerDelegate {
}
