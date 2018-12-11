//
//  AddAssetController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift
import BLTNBoard

class AddAssetController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tokenArray: [TokenModel] = []
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    private lazy var showTokenPageItem: ShowTokenPageItem = {
        return ShowTokenPageItem.create()
    }()
    private lazy var bulletinManager: BLTNItemManager = {
        return BLTNItemManager(rootItem: showTokenPageItem)
    }()

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

    func showTokenMessage(_ chainModel: ChainModel?, tokenModel: TokenModel) {
        showTokenPageItem.actionHandler = { item in
            item.manager?.displayActivityIndicator()
            self.save(tokenModel: tokenModel, chainModel: chainModel)
        }
        showTokenPageItem.update(tokenModel: tokenModel)
        bulletinManager.showBulletin(above: self)
    }

    func save(tokenModel: TokenModel, chainModel: ChainModel?) {
        if TokenModel.identifier(for: tokenModel) != nil {
            bulletinManager.dismissBulletin()
            Toast.showToast(text: "Assets.AddAssets.AlreadyExist".localized())
        }
        do {
            let wallet = AppModel.current.currentWallet!
            let realm = try Realm()
            try realm.write {
                realm.add(tokenModel, update: true)
                if !wallet.selectedTokenList.contains(where: { $0 == tokenModel }) {
                    wallet.selectedTokenList.append(tokenModel)
                }
                if !wallet.tokenModelList.contains(where: { $0 == tokenModel }) {
                    wallet.tokenModelList.append(tokenModel)
                }
                if chainModel != nil {
                    realm.add(chainModel!, update: true)
                    if !wallet.chainModelList.contains(where: { $0 == chainModel }) {
                        wallet.chainModelList.append(chainModel!)
                    }
                }
            }
            let successPageItem = SuccessPageItem.create(title: "DApp.Contract.TransactionSend".localized())
            successPageItem.actionHandler = { item in
                self.bulletinManager.dismissBulletin()
                Toast.showToast(text: "Assets.AddAssets.StoreSuccess".localized())
                self.navigationController?.popViewController(animated: true)
            }
            bulletinManager.push(item: successPageItem)
        } catch {
            bulletinManager.dismissBulletin()
            Toast.showToast(text: "Assets.AddAssets.StoreFailed".localized())
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
                    self.showTokenMessage(nil, tokenModel: result!)
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
                    self.showTokenMessage(chainModel!, tokenModel: tokenModel!)
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
                    self.showTokenMessage(nil, tokenModel: tokenModel!)
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
