//
//  TokensViewController.swift
//  Neuron
//
//  Created by Yate Fulham on 2018/08/28.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import web3swift

/// ERC-20 Token List
class TokensViewController: UITableViewController {
    @IBOutlet weak var totle: UILabel!
    var tokenArray: [TokenModel] = []
    var viewModel = SubController2ViewModel()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tokenArray.count != (WalletRealmTool.getCurrentAppmodel().currentWallet?.selectTokenList.count)! + WalletRealmTool.getCurrentAppmodel().nativeTokenList.count {
            didGetTokenList()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        didGetTokenList()
    }

    /// get token list from realm
    func didGetTokenList() {
        tokenArray.removeAll()
        let appModel = WalletRealmTool.getCurrentAppmodel()
        tokenArray += appModel.nativeTokenList
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
        for item in walletModel.selectTokenList {
            tokenArray.append(item)
        }
        getBalance(isRefresh: false)
    }

    func getBalance(isRefresh: Bool) {
        let group = DispatchGroup()
        if isRefresh {
        } else {
            //NeuLoad.showHUD(text: "")
        }
        let walletModel = WalletRealmTool.getCurrentAppmodel().currentWallet!
        for tm in tokenArray {
            if tm.chainId == ETH_MainNetChainId {
                group.enter()
                viewModel.didGetTokenForCurrentwallet(walletAddress: walletModel.address) { (balance, error) in
                    if error == nil {
                        tm.tokenBalance = balance!
                    } else {
                        NeuLoad.showToast(text: (error?.localizedDescription)!)
                    }
                    group.leave()
                }
            } else if tm.chainId != "" && tm.chainId != ETH_MainNetChainId {
                group.enter()
                viewModel.getNervosNativeTokenBalance(walletAddress: walletModel.address) { (balance, error) in
                    if error == nil {
                        tm.tokenBalance = balance!
                    } else {
                        NeuLoad.showToast(text: (error?.localizedDescription)!)
                    }
                    group.leave()
                }
            } else if tm.address.count != 0 {
                group.enter()
                viewModel.didGetERC20BalanceForCurrentWallet(wAddress: walletModel.address, ERC20Token: tm.address) { (erc20Balance, error) in
                    if error == nil {
                        let balance = Web3.Utils.formatToPrecision(erc20Balance!, numberDecimals: tm.decimals, formattingDecimals: 6, fallbackToScientific: false)
                        tm.tokenBalance = balance!
                    } else {
                        NeuLoad.showToast(text: (error?.localizedDescription)!)
                    }
                    group.leave()
                }
            } 
        }
        group.notify(queue: .main) {
            self.tableView.reloadData()
            if isRefresh {
                //   self.mainTable.mj_header.endRefreshing()
            } else {
                NeuLoad.hidHUD()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokenArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tokenTableviewcell") as! TokenTableViewCell
        let model = tokenArray[indexPath.row]
        cell.imageView?.sd_setImage(with: URL(string: model.iconUrl!), placeholderImage: UIImage(named: "eth_logo"))
        cell.balance.text = model.tokenBalance
        cell.token.text = model.symbol
        cell.network.text = (model.chainName?.isEmpty)! ? "ethereum Mainnet": model.chainName
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
