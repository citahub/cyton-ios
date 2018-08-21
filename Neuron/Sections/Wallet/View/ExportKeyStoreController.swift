//
//  ExportKeyStoreController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ExportKeyStoreController: BaseViewController {

    @IBOutlet weak var kestoreTextView: UITextView!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    var walletModel = WalletModel()
    var password = ""
    var keyStoreStr = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "导出keystore"
        walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
        keyStoreStr = WalletCryptService.didCheckoutKeyStoreWithCurrentWallet(password: password)
        kestoreTextView.text = keyStoreStr
        setUpUI()
    }

    func setUpUI() {
        shareButton.layer.cornerRadius = 5
        shareButton.layer.borderWidth = 1
        shareButton.layer.borderColor = ColorFromString(hex: themeColor).cgColor
    }

    @IBAction func didClickCopyButton(_ sender: UIButton) {
        UIPasteboard.general.string = keyStoreStr
        NeuLoad.showToast(text: "keystore已经复制到粘贴板")
    }

    @IBAction func didClickShareButton(_ sender: UIButton) {
        let shareText = keyStoreStr
        let shareItem = ShareItem.init(shareString: shareText)
        let activityVC = UIActivityViewController.init(activityItems: [shareItem], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
