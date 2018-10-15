//
//  SimpleGasViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/13.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import web3swift
import struct BigInt.BigUInt

protocol SimpleGasViewControllerDelegate: class {
    func getTransactionGasPrice(simpleGasViewController: SimpleGasViewController, gasPrice: BigUInt)
    func getTransactionCostGas(gas: String)
}

class SimpleGasViewController: UIViewController {
    let ethDefaultGasPrice = BigUInt("4000000000")!
    let nervosDefaultQuota = BigUInt(1000000)
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var gasSlider: UISlider!
    let viewModel = TAViewModel()
    var tokenModel = TokenModel()
    var gas: Float = 60000
    lazy var gasPrice: BigUInt = ethDefaultGasPrice
    var tokenType: TokenType = .nervosToken
    weak var delegate: SimpleGasViewControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.getTransactionGasPrice(simpleGasViewController: self, gasPrice: gasPrice)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if tokenType == .nervosToken {
            gasPrice = nervosDefaultQuota
        } else {
            gasPrice = ethDefaultGasPrice
            getGasPrice()
        }
        setGasLabelValue(finalGasPrice: gasSlider.value * Float(gasPrice.description)!)
        delegate?.getTransactionGasPrice(simpleGasViewController: self, gasPrice: gasPrice)
    }

    func setGasLabelValue(finalGasPrice: Float) {
        if tokenType == .nervosToken {
            let totleGas = Web3.Utils.formatToEthereumUnits(BigUInt(finalGasPrice), toUnits: .Gwei, decimals: 4, fallbackToScientific: false)
            gasLabel.text = totleGas! + tokenModel.symbol
        } else {
            let gasCosted = gas * finalGasPrice
            let totleGas = Web3.Utils.formatToEthereumUnits(BigUInt(gasCosted), toUnits: .eth, decimals: 4, fallbackToScientific: false)
            gasLabel.text = totleGas! + "  eth"
        }
        delegate?.getTransactionCostGas(gas: gasLabel.text!)
    }

    func getGasPrice() {
        viewModel.getGasPrice { (result) in
            switch result {
            case .success(let gasPriceResult):
                self.gasPrice = gasPriceResult
            case .error(let error):
                Toast.showToast(text: error.localizedDescription)
            }
            self.setGasLabelValue(finalGasPrice: self.gasSlider.value * Float(self.gasPrice.description)!)
        }
    }

    @IBAction func sliderValueChangedAction(_ sender: UISlider) {
        if tokenType == .nervosToken {
            let currentGasPrice = sender.value * Float(gasPrice)
            setGasLabelValue(finalGasPrice: currentGasPrice)
            delegate?.getTransactionGasPrice(simpleGasViewController: self, gasPrice: BigUInt(currentGasPrice))
        } else {
            let currentGasPrice = sender.value * Float(gasPrice)
            setGasLabelValue(finalGasPrice: currentGasPrice)
            delegate?.getTransactionGasPrice(simpleGasViewController: self, gasPrice: BigUInt(currentGasPrice))
        }
    }
}
