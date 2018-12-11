//
//  TransactionDetailsViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/12/6.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import SafariServices

class TransactionDetailsViewController: UITableViewController {
    @IBOutlet private weak var tokenIconView: UIImageView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var paymentAddressTitleLabel: UILabel!
    @IBOutlet private weak var paymentAddressLabel: UILabel!
    @IBOutlet private weak var receiptAddressTitleLabel: UILabel!
    @IBOutlet private weak var receiptAddressLabel: UILabel!
    @IBOutlet private weak var chainIconView: UIImageView!
    @IBOutlet private weak var blockchainBrowserLabel: UILabel!
    @IBOutlet private weak var hashTitleLabel: UILabel!
    @IBOutlet private weak var hashLabel: UILabel!
    @IBOutlet private weak var chainNetworkTitleLable: UILabel!
    @IBOutlet private weak var chainNetworkLabel: UILabel!
    @IBOutlet private weak var blockTitleLabel: UILabel!
    @IBOutlet private weak var blockLabel: UILabel!
    @IBOutlet private weak var gasFeeTitleLabel: UILabel!
    @IBOutlet private weak var gasFeeLabel: UILabel!
    @IBOutlet private weak var gasPriceTitleLabel: UILabel!
    @IBOutlet private weak var gasPriceLabel: UILabel!
    @IBOutlet private weak var gasUsedLabel: UILabel!
    @IBOutlet private weak var gasLimitTitleLabel: UILabel!
    @IBOutlet private weak var gasLimitLabel: UILabel!

    var transaction: TransactionDetails! {
        didSet {
            if oldValue != nil && transaction != nil {
                setupUI()
            }
        }
    }

    private var hideItems = [(Int, Int)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transaction.Details.title".localized()
        paymentAddressTitleLabel.text = "Transaction.Details.paymentAddress".localized() + ":"
        receiptAddressTitleLabel.text = "Transaction.Details.receiptAddress".localized() + ":"
        blockchainBrowserLabel.text = "Transaction.Details.blockchainBrowserDesc".localized()
        hashTitleLabel.text = "Transaction.Details.hash".localized()
        chainNetworkTitleLable.text = "Transaction.Details.chainNetwork".localized()
        blockTitleLabel.text = "Transaction.Details.block".localized()
        gasFeeTitleLabel.text = "Transaction.Details.gasFee".localized()

        setupUI()
    }

    func setupUI() {
        tokenIconView.sd_setImage(with: URL(string: transaction.token.iconUrl ?? ""), placeholderImage: UIImage(named: "eth_logo"))
        amountLabel.text = transaction.value.toAmountText(transaction.token.decimals) + " " + transaction.token.symbol
        dateLabel.text = {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            return dateformatter.string(from: transaction.date)
        }()
        paymentAddressLabel.text = transaction.from
        receiptAddressLabel.text = transaction.to.count > 0 ? transaction.to : "Contract Created"

        switch transaction.token.type {
        case .ether, .erc20:
            chainNetworkLabel.text = EthereumNetwork().currentNetwork.rawValue.capitalized
            chainIconView.image = UIImage(named: "icon_tx_details_chain_eth")
        case .appChain, .appChainErc20:
            chainNetworkLabel.text = transaction.token.chainName ?? "CITA"
            chainIconView.image = UIImage(named: "icon_tx_details_chain_cita")
            if transaction.token.chainId != "1" {
                hideItems.append((0, 3))    // block chain network
            }
        }

        switch transaction.status {
        case .success:
            statusLabel.text = transaction.to.count > 0 ? "TransactionStatus.success".localized() : "Transaction.Details.contractCreationSuccess".localized()
            statusLabel.backgroundColor = UIColor(named: "secondary_color")?.withAlphaComponent(0.2)
            statusLabel.textColor = UIColor(named: "secondary_color")
            hashLabel.text = transaction.hash
            blockLabel.text = "\(transaction.blockNumber)"
        case .pending:
            statusLabel.text = transaction.to.count > 0 ? "TransactionStatus.success".localized() : "Transaction.Details.contractCreationPending"
            statusLabel.backgroundColor = UIColor(named: "warning_bg_color")
            statusLabel.textColor = UIColor(named: "warning_color")
            hashLabel.text = transaction.hash

            hideItems.append((1, 2))    // block
        case .failure:
            statusLabel.text = transaction.to.count > 0 ? "TransactionStatus.success".localized() :  "Transaction.Details.contractCreationFailure".localized()
            statusLabel.backgroundColor = UIColor(hex: "FF706B", alpha: 0.2)
            statusLabel.textColor = UIColor(hex: "FF706B")

            hideItems.append((0, 3))    // block chain network
            hideItems.append((1, 0))    // hash
            hideItems.append((1, 2))    // block
        }
        setupGasInfo()
    }

    func setupGasInfo() {
        switch transaction.status {
        case .success, .pending:
            if let ethereum = transaction as? EthereumTransactionDetails {
                gasFeeLabel.text = ethereum.gasUsed.toGweiText() + " ETH"
                gasPriceLabel.text = ethereum.gasPrice.toAmountText(transaction.token.decimals) + " Ether " + "(\(ethereum.gasPrice.toGweiText()) Gwei)"
            } else if let erc20 = transaction as? Erc20TransactionDetails {
                gasFeeLabel.text = erc20.gasUsed.toGweiText() + " ETH"
                gasPriceLabel.text = erc20.gasPrice.toAmountText(transaction.token.decimals) + " Ether " + "(\(erc20.gasPrice.toGweiText()) Gwei)"
            } else if let appChain = transaction as? AppChainTransactionDetails {
                gasFeeLabel.text = appChain.quotaUsed.toGweiText() + " \(transaction.token.symbol)"
            } else if let appChainErc20 = transaction as? AppChainErc20TransactionDetails {
                gasFeeLabel.text = appChainErc20.quotaUsed.toGweiText() + " \(transaction.token.symbol)"
            }
        case .failure:
            hideItems.append((1, 3)) // gas fee
            hideItems.append((1, 4)) // gas price
            hideItems.append((1, 5))    // gas used
        }

        if transaction.status == .pending {
            gasLimitLabel.text = "\(transaction.gasLimit)"
        } else {
            hideItems.append((1, 6)) // gas limit
        }

        if transaction.status == .success {
            if let ethereum = transaction as? EthereumTransactionDetails {
                gasUsedLabel.text = "\(ethereum.gasUsed)"
            } else if let erc20 = transaction as? Erc20TransactionDetails {
                gasUsedLabel.text = "\(erc20.gasUsed)"
            } else if let appChain = transaction as? AppChainTransactionDetails {
                gasUsedLabel.text = "\(appChain.quotaUsed)"
            } else if let appChainErc20 = transaction as? AppChainErc20TransactionDetails {
                gasUsedLabel.text = "\(appChainErc20.quotaUsed)"
            }
        } else {
            hideItems.append((1, 5))    // gas used
        }
    }
}

extension TransactionDetailsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if hideItems.contains(where: { $0.0 == indexPath.section && $0.1 == indexPath.row }) {
            return 0.0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.isHidden = hideItems.contains(where: { $0.0 == indexPath.section && $0.1 == indexPath.row })
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return [(0, 1), (0, 2), (0, 3)].contains(where: { $0.0 == indexPath.section && $0.1 == indexPath.row })
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 1 {
            UIPasteboard.general.string = transaction.from
            Toast.showToast(text: "Wallet.QRCode.copySuccess".localized())
        } else if indexPath.section == 0 && indexPath.row == 2 {
            UIPasteboard.general.string = transaction.to
            Toast.showToast(text: "Wallet.QRCode.copySuccess".localized())
        } else if indexPath.section == 0 && indexPath.row == 3 {
            let url: URL
            if transaction.token.type == .erc20 || transaction.token.type == .ether {
                url = EthereumNetwork().host().appendingPathComponent("/tx/\(transaction.hash)")
            } else if transaction.token.chainId == "1" {
                url = URL(string: "http://microscope.cryptape.com/#/transaction/\(transaction.hash)")!
            } else {
                fatalError()
            }
            let safariController = SFSafariViewController(url: url)
            self.present(safariController, animated: true, completion: nil)
        }
    }
}
