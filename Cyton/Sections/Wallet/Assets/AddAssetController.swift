//
//  AddAssetController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/5/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift
import BLTNBoard

class AddAssetController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tokenArray: [TokenModel] = []
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var listSettingButton: DesignableButton!
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
        listSettingButton.setTitle("Assets.AddAssets.ListSettings".localized(), for: .normal)
        chain = Chain().defaultChain
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "switchChain" {
            let switchChainViewController = segue.destination as! SwitchChainViewController
            switchChainViewController.currentChain = chain
            switchChainViewController.delegate = self
        }
    }

    @IBAction func searchTokenButton(_ sender: UIButton) {
        if inputText.count == 0 {
            Toast.showToast(text: "Assets.AddAssets.EmptyResult".localized())
            return
        }
        if chain.chainId == Chain().defaultChain.chainId {
            ethereumERC20Token(contractAddress: inputText)
        } else if chain.chainId == SwitchChainViewController().citaChainId {
            citaNativeToken(nodeAddress: inputText)
        } else {
            citaERC20Token(chain: chain, contractAddress: inputText)
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
        do {
            let realm = try Realm()
            let wallet = AppModel.current.currentWallet!
            var tokenModel = tokenModel
            if let tokenIdentifier = TokenModel.identifier(for: tokenModel) {
                tokenModel = realm.object(ofType: TokenModel.self, forPrimaryKey: tokenIdentifier)!
            } else {
                try realm.write {
                    realm.add(tokenModel, update: true)
                }
            }

            if !wallet.tokenModelList.contains(where: { $0 == tokenModel }) {
                try realm.write {
                    wallet.tokenModelList.append(tokenModel)
                    wallet.selectedTokenList.append(tokenModel)

                    if chainModel != nil {
                        realm.add(chainModel!, update: true)
                        if !wallet.chainModelList.contains(where: { $0 == chainModel }) {
                            wallet.chainModelList.append(chainModel!)
                        }
                    }
                }

                let successPageItem = SuccessPageItem.create(title: "Assets.AddAssets.StoreSuccess".localized())
                successPageItem.actionHandler = { item in
                    self.bulletinManager.dismissBulletin()
                    self.navigationController?.popViewController(animated: true)
                }
                bulletinManager.push(item: successPageItem)
            } else {
                bulletinManager.dismissBulletin()
                Toast.showToast(text: "Assets.AddAssets.AlreadyExist".localized())
            }
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
            if chain.chainId == SwitchChainViewController().citaChainId {
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
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let result = try? CustomERC20TokenService.searchTokenData(contractAddress: contractAddress, walletAddress: walletAddress)
            DispatchQueue.main.async {
                Toast.hideHUD()
                if let result = result {
                    if !result.symbol.isEmpty {
                        self.showTokenMessage(nil, tokenModel: result)
                    } else {
                        Toast.showToast(text: "Assets.AddAssets.EmptySymbol".localized())
                    }
                } else {
                    Toast.showToast(text: "Assets.AddAssets.EmptyResult".localized())
                }
                self.tableView.reloadData()
            }
        }
    }

    func citaNativeToken(nodeAddress: String) {
        Toast.showHUD()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let (tokenModel, chainModel) = AddCITAToken.nativeToken(nodeAddress: nodeAddress)
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

    func citaERC20Token(chain: Chain, contractAddress: String) {
        Toast.showHUD()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let tokenModel = AddCITAToken.erc20Token(chain: chain, contractAddress: contractAddress)
            DispatchQueue.main.async {
                Toast.hideHUD()
                if tokenModel != nil {
                    if tokenModel?.symbol.count == 0 {
                        Toast.showToast(text: "Assets.AddAssets.EmptySymbol".localized())
                    } else {
                        self.showTokenMessage(nil, tokenModel: tokenModel!)
                    }
                } else {
                    Toast.showToast(text: "Assets.AddAssets.EmptyResult".localized())
                }
            }
        }
    }
}

extension AddAssetController: QRCodeViewControllerDelegate {
    func didBackQRCodeMessage(codeResult: String) {
        inputText = codeResult.trimmingCharacters(in: .whitespaces)
        tableView.reloadData()
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
        tableView.reloadData()
    }
}
