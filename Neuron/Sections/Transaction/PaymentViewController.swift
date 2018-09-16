//
//  PaymentViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/13.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import BigInt
import IQKeyboardManagerSwift

class PaymentViewController: UITableViewController {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var assetTypeLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var switchButton: UISwitch!
    private var gasPageViewController: UIPageViewController!
    private var simpleGasViewController: SimpleGasViewController!
    private var ethGasViewController: EthGasViewController!
    private var nervosQuoteViewController: NervosQuoteViewController!
    var tokenType: TokenType = .nervosToken
    var tokenModel = TokenModel()
    var ethGasPrice: BigUInt!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "转账"

        simpleGasViewController = storyboard!.instantiateViewController(withIdentifier: "simpleGasViewController") as? SimpleGasViewController
        ethGasViewController = storyboard!.instantiateViewController(withIdentifier: "ethGasViewController") as? EthGasViewController
        nervosQuoteViewController = storyboard!.instantiateViewController(withIdentifier: "nervosQuoteViewController") as? NervosQuoteViewController
        nervosQuoteViewController.tokenModel = tokenModel
        gasPageViewController.setViewControllers([simpleGasViewController], direction: .forward, animated: false)
        getBaseData()
    }

    func getBaseData() {
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
        iconImageView.image = UIImage(data: walletModel.iconData)
        nameLabel.text = walletModel.name
        addressLabel.text = walletModel.address
        assetTypeLabel.text = tokenModel.symbol
        balanceLabel.text = tokenModel.tokenBalance + tokenModel.symbol
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gasPageViewController" {
            gasPageViewController = segue.destination as? UIPageViewController
        }
    }

    @IBAction func advancedSettingAction(_ sender: UISwitch) {
        if sender.isOn {
            switch tokenType {
            case .nervosToken:
                gasPageViewController.setViewControllers([nervosQuoteViewController], direction: .forward, animated: false)
            default:
                gasPageViewController.setViewControllers([ethGasViewController], direction: .forward, animated: false)
            }
        } else {
            gasPageViewController.setViewControllers([simpleGasViewController], direction: .forward, animated: false)
        }
    }
    
    @IBAction func clickQRButton(_ sender: UIButton) {
        let qrCtrl = QRCodeController()
        qrCtrl.delegate = self
        self.navigationController?.pushViewController(qrCtrl, animated: true)
    }
}

extension PaymentViewController: SimpleGasViewControllerDelegate, QRCodeControllerDelegate, EthGasViewControllerDelegate, NervosQuoteViewControllerDelegate {
    func getNervosTransactionQuota(nervosQuoteViewController: NervosQuoteViewController, quota: BigUInt, data: Data) {
        
    }

    func getTransactionGasPriceAndData(ethGasViewController: EthGasViewController, gasPrice: BigUInt, data: Data) {
        ethGasPrice = gasPrice
    }

    func getTransactionGasPrice(simpleGasViewController: SimpleGasViewController, gasPrice: BigUInt) {
        ethGasPrice = gasPrice
    }

    func didBackQRCodeMessage(codeResult: String) {
        addressTextField.text = codeResult
    }

}
