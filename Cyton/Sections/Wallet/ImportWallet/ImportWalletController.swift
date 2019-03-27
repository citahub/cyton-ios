//
//  ImportWalletController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//
//  Should Reconstruction !!!

import UIKit
import RSKPlaceholderTextView

class ImportWalletController: UIViewController, NoScreenshot, EnterBackOverlayPresentable {
    @IBOutlet weak var tabbedButtonView: TabbedButtonsView!
    private var keystoreViewController: UIViewController!
    private var mnemonicViewController: UIViewController!
    private var privatekeyViewController: UIViewController!
    private var importWalletPageViewController: UIPageViewController!
    var pageViewControllers = [UIViewController]()
    var currentIndex = 0 {
        didSet {
            tabbedButtonView.selectedIndex = currentIndex
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet.Import.title".localized()
        tabbedButtonView.delegate = self
        tabbedButtonView.buttonTitles = [
            "Wallet.Import.keystore".localized(),
            "Wallet.Import.mnemonic".localized(),
            "Wallet.Import.privatekey".localized()
        ]

        importWalletPageViewController.delegate = self
        importWalletPageViewController.dataSource = self
        keystoreViewController = storyboard!.instantiateViewController(withIdentifier: "keystoreViewController")
        mnemonicViewController = storyboard!.instantiateViewController(withIdentifier: "mnemonicViewController")
        privatekeyViewController = storyboard!.instantiateViewController(withIdentifier: "privatekeyViewController")
        pageViewControllers.append(keystoreViewController)
        pageViewControllers.append(mnemonicViewController)
        pageViewControllers.append(privatekeyViewController)
        importWalletPageViewController.setViewControllers([keystoreViewController], direction: .forward, animated: false)

        setupEnterBackOverlay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNoScreenshotAlert(titile: "NoScreenshot.title".localized(), message: "NoScreenshot.importWalletMessage".localized())
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "importWalletPageViewController" {
            importWalletPageViewController = segue.destination as? UIPageViewController
        }
    }
}

extension ImportWalletController: TabbedButtonsViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        currentIndex = pageViewControllers.firstIndex(of: viewController)!
        let previousIndex = abs((currentIndex - 1) % pageViewControllers.count)
        if currentIndex == 0 {
            return nil
        } else {
            return pageViewControllers[previousIndex]
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        currentIndex = pageViewControllers.firstIndex(of: viewController)!
        let nextIndex = abs((currentIndex + 1) % pageViewControllers.count)
        if currentIndex == pageViewControllers.count - 1 {
            return nil
        } else {
            return pageViewControllers[nextIndex]
        }
    }

    func tabbedButtonsView(_ view: TabbedButtonsView, didSelectButtonAt index: Int) {
        importWalletPageViewController.setViewControllers([pageViewControllers[index]], direction: .forward, animated: false, completion: nil)
    }
}
