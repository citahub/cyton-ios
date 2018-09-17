//
//  SimpleGasViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/13.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import BigInt
import web3swift
import IQKeyboardManagerSwift

protocol SimpleGasViewControllerDelegate: class {
    func getTransactionGasPrice(simpleGasViewController: SimpleGasViewController, gasPrice: BigUInt)
    func getTransactionCostGas(gas: String)
}

class SimpleGasViewController: UIViewController {
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var gasSlider: UISlider!
    let viewModel = TAViewModel()
    var gas: Float = 60000
    var gasPrice: BigUInt = 4000000000
    weak var delegate: SimpleGasViewControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.getTransactionGasPrice(simpleGasViewController: self, gasPrice: gasPrice)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.getTransactionGasPrice(simpleGasViewController: self, gasPrice: gasPrice)
        setGasLableValue(finalGasPrice: gasSlider.value * Float(gasPrice.description)!)
        getGasPrice()
    }

    func setGasLableValue(finalGasPrice: Float) {
        let gasCosted = gas * finalGasPrice
        let totleGas = Web3.Utils.formatToEthereumUnits(BigUInt(gasCosted), toUnits: .eth, decimals: 4, fallbackToScientific: false)
        gasLabel.text = totleGas! + "  eth"
        delegate?.getTransactionCostGas(gas: gasLabel.text!)
    }

    func getGasPrice() {
        viewModel.getGasPrice { (result) in
            switch result {
            case .Success(let gasPriceResult):
                self.gasPrice = gasPriceResult
            case .Error(let error):
                NeuLoad.showToast(text: error.localizedDescription)
            }
            self.setGasLableValue(finalGasPrice: self.gasSlider.value * Float(self.gasPrice.description)!)
        }
    }

    @IBAction func sliderValueChangedAction(_ sender: UISlider) {
        let currentGasPrice = sender.value * Float(gasPrice)
        setGasLableValue(finalGasPrice: currentGasPrice)
        delegate?.getTransactionGasPrice(simpleGasViewController: self, gasPrice: BigUInt(currentGasPrice))
    }
}
