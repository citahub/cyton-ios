//
//  ImportWalletPageViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/8/29.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit

class ImportWalletPageViewController: UIPageViewController {
    var pages = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        let keystoreViewController = storyboard!.instantiateViewController(withIdentifier: "keystoreViewController")
        let mnemonicViewController = storyboard!.instantiateViewController(withIdentifier: "mnemonicViewController")
        let privatekeyViewController = storyboard!.instantiateViewController(withIdentifier: "privatekeyViewController")
        pages.append(keystoreViewController)
        pages.append(mnemonicViewController)
        pages.append(privatekeyViewController)

        setViewControllers([keystoreViewController], direction: .forward, animated: false)
    }
}

extension ImportWalletPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
}

extension ImportWalletPageViewController: UIPageViewControllerDelegate {
}
