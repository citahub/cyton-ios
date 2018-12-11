//
//  AddAssetController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class AddAssetController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tokenArray: [TokenModel] = []
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    var chain = Chain()
    var inputText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Assets.AddAssets.Title".localized()
        searchButton.setTitle("Assets.AddAssets.Search".localized(), for: .normal)
        rightBarButton.title = "Assets.AddAssets.ListSettings".localized()
        chain = Chain().defaultChain
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "switchChain" {
            let switchChainViewController = segue.destination as! SwitchChainViewController
            switchChainViewController.currentChain = chain
            switchChainViewController.delegate = self
        }
    }

    @IBAction func listSettings(_ sender: UIBarButtonItem) {

    }

    @IBAction func searchTokenButton(_ sender: UIButton) {
        if inputText.count == 0 {
            Toast.showToast(text: "Assets.AddAssets.EmptyResult".localized())
            return
        }
        if chain.chainId == Chain().defaultChain.chainId {
            ethereumERC20Token(contractAddress: inputText)
        } else if chain.chainId == SwitchChainViewController().appChainId {
            appchainNativeToken(nodeAddress: inputText)
        } else {
            appchainERC20Token(chain: chain, contractAddress: inputText)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectChainTableViewCell") as! SelectChainTableViewCell
            cell.detailTextLabel?.text = chain.chainName
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contractAddressTableViewCell") as! ContractAddressTableViewCell
            cell.delegate = self
            cell.contractAddressTextField.text = inputText
            if chain.chainId == SwitchChainViewController().appChainId {
                cell.contractAddressTextField.placeholder = "Assets.AddAssets.NodeAddressPlaceHolder".localized()
                cell.contractAddressLabel.text = "Assets.AddAssets.NodeAddress".localized()
            } else {
                cell.contractAddressLabel.text = "Assets.AddAssets.ContractAddress".localized()
                cell.contractAddressTextField.placeholder = "Assets.AddAssets.ContractAddressPlaceHolder".localized()
            }
            return cell
        }
    }

    @IBAction func clickSelectChainButton(_ sender: UIButton) {

    }

    @IBAction func clickQRCodeButton(_ sender: UIButton) {
        let qrCodeViewController = QRCodeViewController()
        qrCodeViewController.delegate = self
        self.navigationController?.pushViewController(qrCodeViewController, animated: true)
    }

    func ethereumERC20Token(contractAddress: String) {
        let walletAddress = AppModel.current.currentWallet!.address
        Toast.showHUD()
        DispatchQueue.global().async {
            let result = try? CustomERC20TokenService.searchTokenData(contractAddress: contractAddress, walletAddress: walletAddress)
            DispatchQueue.main.async {
                Toast.hideHUD()
                if result != nil {

                } else {
                    Toast.showToast(text: "Assets.AddAssets.EmptyResult".localized())
                }
                self.table.reloadData()
            }
        }
    }

    func appchainNativeToken(nodeAddress: String) {
        Toast.showHUD()
        DispatchQueue.global().async {
            let (tokenModel, chainModel) = AddAppChainToken.appChainNativeToken(nodeAddress: nodeAddress)
            DispatchQueue.main.async {
                Toast.hideHUD()
                if tokenModel != nil && chainModel != nil {

                } else {
                    Toast.showToast(text: "Assets.AddAssets.EmptyResult".localized())
                }
            }
        }
    }

    func appchainERC20Token(chain: Chain, contractAddress: String) {
        Toast.showHUD()
        DispatchQueue.global().async {
            let tokenModel = AddAppChainToken.appChainERC20Token(chain: chain, contractAddress: contractAddress)
            DispatchQueue.main.async {
                Toast.hideHUD()
                if tokenModel != nil {

                } else {
                    Toast.showToast(text: "Assets.AddAssets.EmptyResult".localized())
                }
            }
        }
    }
}

extension AddAssetController: QRCodeViewControllerDelegate {
    func didBackQRCodeMessage(codeResult: String) {
        let finalText = codeResult.trimmingCharacters(in: .whitespaces)
        inputText = finalText
        table.reloadData()
    }
}

extension AddAssetController: ContractAddressTableViewCellDelegate {
    func textFieldInput(text: String) {
        let finalText = text.trimmingCharacters(in: .whitespaces)
        inputText = finalText
    }
}

extension AddAssetController: SwitchChainViewControllerDelegate {
    func callSelectChain(chain: Chain) {
        self.chain = chain
        table.reloadData()
    }
}
