//
//  ImportWalletController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/31.
//  Copyright © 2018年 cryptape. All rights reserved.
//
//  Should Reconstruction !!!

import UIKit
import RSKPlaceholderTextView
import IQKeyboardManagerSwift

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
        title = "导入钱包"
        tabbedButtonView.delegate = self
        tabbedButtonView.buttonTitles = ["Keystore", "助记词", "私钥"]

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
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNoScreenshotAlert(titile: "禁止截屏！", message: "keystore，助记词，私钥是打开您钱包的关键要素，请妥善保管！")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "importWalletPageViewController" {
            importWalletPageViewController = segue.destination as? UIPageViewController
        }
    }
}

extension ImportWalletController: TabbedButtonsViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        currentIndex = pageViewControllers.index(of: viewController)!
        let previousIndex = abs((currentIndex - 1) % pageViewControllers.count)
        if currentIndex == 0 {
            return nil
        } else {
            return pageViewControllers[previousIndex]
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        currentIndex = pageViewControllers.index(of: viewController)!
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
