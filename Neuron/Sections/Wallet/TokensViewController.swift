//
//  TokensViewController.swift
//  Neuron
//
//  Created by Yate Fulham on 2018/08/28.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import web3swift

protocol TokensViewControllerDelegate: class {
    func getCurrentCurrencyModel(currencyModel: LocalCurrency, totleCurrency: Double)
}

/// ERC-20 Token List
class TokensViewController: UITableViewController, ErrorOverlayPresentable {
    var tokenArray: [TokenModel] = []
    var currentCurrencyModel = LocalCurrencyService().getLocalCurrencySelect()
    weak var delegate: TokensViewControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tokenArray.count != (WalletRealmTool.getCurrentAppModel().currentWallet?.selectTokenList.count)! + WalletRealmTool.getCurrentAppModel().nativeTokenList.count {
            didGetTokenList()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        didGetTokenList()
        addNotify()
    }

    func addNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeLocalCurrency), name: .changeLocalCurrency, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataForNewNetwork), name: .switchEthNetwork, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .beginRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchWalletLoadToken), name: .switchWallet, object: nil)
    }

    @objc private func reloadDataForNewNetwork() {
        getBalance(isRefresh: false)
    }

    @objc private func changeLocalCurrency() {
        currentCurrencyModel = LocalCurrencyService().getLocalCurrencySelect()
        getCurrencyPrice(currencyModel: currentCurrencyModel)
    }

    @objc private func refreshData() {
        getBalance(isRefresh: false)
    }

    @objc private func switchWalletLoadToken() {
        didGetTokenList()
    }

    /// get token list from realm
    func didGetTokenList() {
        tokenArray.removeAll()
        let appModel = WalletRealmTool.getCurrentAppModel()
        tokenArray += appModel.nativeTokenList
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        for item in walletModel.selectTokenList {
            tokenArray.append(item)
        }
        getBalance(isRefresh: true)
        if tokenArray.count == 0 {
            showBlankOverlay()
        } else {
            removeOverlay()
        }
    }

    func getCurrencyPrice(currencyModel: LocalCurrency) {
        var currencyTotle = 0.0
        for model in tokenArray {
            let currency = CurrencyService()
            let currencyToken = currency.searchCurrencyId(for: model.symbol)
            guard let tokenId = currencyToken?.id else {
                continue
            }
            currency.getCurrencyPrice(tokenid: tokenId, currencyType: currencyModel.short) { (result) in
                switch result {
                case .success(let price):
                    guard let balance = Double(model.tokenBalance) else {
                        return
                    }
                    guard balance != 0 else {
                        if currencyTotle == 0 {
                            self.delegate?.getCurrentCurrencyModel(currencyModel: currencyModel, totleCurrency: currencyTotle)
                        }
                        return
                    }
                    model.currencyAmount = String(format: "%.2f", price * balance)
                    currencyTotle += Double(model.currencyAmount) ?? 0
                    self.delegate?.getCurrentCurrencyModel(currencyModel: currencyModel, totleCurrency: currencyTotle)
                    self.tableView.reloadData()
                    SensorsAnalytics.Track.possessMoney(
                        chainType: model.chainId,
                        currencyType: model.symbol,
                        currencyNumber: Double(model.currencyAmount) ?? 0
                    )
                case .error:
                    Toast.showToast(text: "网络错误，请稍后再试.")
                }
            }
        }
    }

    func getBalance(isRefresh: Bool) {
        let group = DispatchGroup()
        if isRefresh {
            Toast.showHUD()
        }
        let walletModel = WalletRealmTool.getCurrentAppModel().currentWallet!
        for tm in tokenArray {
            if tm.chainId == NativeChainId.ethMainnetChainId {
                group.enter()
                EthNativeTokenService.getEthNativeTokenBalance(walletAddress: walletModel.address) {(result) in
                    switch result {
                    case .success(let balance):
                        tm.tokenBalance = balance
                    case .error:
                        Toast.showToast(text: "网络错误，请稍后再试.")
                    }
                    group.leave()
                }
            } else if tm.chainId != "" && tm.chainId != NativeChainId.ethMainnetChainId {
                group.enter()
                NervosNativeTokenService.getNervosNativeTokenBalance(walletAddress: walletModel.address) {(result) in
                    switch result {
                    case .success(let balance):
                        tm.tokenBalance = balance
                    case .error:
                        Toast.showToast(text: "网络错误，请稍后再试.")
                    }
                    group.leave()
                }
            } else if tm.address.count != 0 {
                group.enter()
                ERC20TokenService.getERC20TokenBalance(walletAddress: walletModel.address, contractAddress: tm.address) { (result) in
                    switch result {
                    case .success(let erc20Balance):
                        let balance = Web3.Utils.formatToPrecision(erc20Balance, numberDecimals: tm.decimals, formattingDecimals: 6, fallbackToScientific: false)
                        tm.tokenBalance = balance!
                    case .error:
                        Toast.showToast(text: "网络错误，请稍后再试.")
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            NotificationCenter.default.post(name: .endRefresh, object: nil)
            self.tableView.reloadData()
            self.getCurrencyPrice(currencyModel: self.currentCurrencyModel)
            if isRefresh {
                Toast.hideHUD()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokenArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tokenTableviewcell") as! TokenTableViewCell
        let model = tokenArray[indexPath.row]
        cell.tokenImage.sd_setImage(with: URL(string: model.iconUrl!), placeholderImage: UIImage(named: "eth_logo"))
        cell.balance.text = model.tokenBalance
        cell.token.text = model.symbol
        cell.network.text = (model.chainName?.isEmpty)! ? "Ethereum Mainnet": model.chainName
        if model.currencyAmount.count != 0 {
            cell.currency.text = currentCurrencyModel.symbol + model.currencyAmount
        } else {
            cell.currency.text = ""
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller: TransactionHistoryViewController = UIStoryboard(name: .transaction).instantiateViewController()
        let model = tokenArray[indexPath.row]
        controller.tokenModel = model
        if model.isNativeToken {
            if model.chainId == NativeChainId.ethMainnetChainId {
                controller.tokenType = .ethereumToken
            } else {
                controller.tokenType = .nervosToken
            }
        } else {
            controller.tokenType = .erc20Token
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y
        if #available(iOS 11.0, *) {
            offset += scrollView.adjustedContentInset.top
        } else {
            offset += scrollView.contentInset.top
        }
        tableView.isScrollEnabled = offset > 0
    }
}
