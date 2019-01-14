//
//  SwitchChainViewController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/12/10.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import RealmSwift

protocol SwitchChainViewControllerDelegate: class {
    func callSelectChain(chain: Chain)
}

class SwitchChainViewController: UIViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    let ethereumChainId = "ethereumERC20"// switch chain work only
    let citaChainId = "citaNative"

    var chains: [Chain] = []
    var currentChain: Chain!
    weak var delegate: SwitchChainViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Assets.AddAssets.SwitchChainNetWorkTitle".localized()
        getChainModelList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundView.alpha = 0.0
        contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.size.height)
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.backgroundView.alpha = 1.0
            self.contentView.transform = CGAffineTransform.identity
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss()
    }

    @IBAction func dismiss() {
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            self.backgroundView.alpha = 0.0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.contentView.bounds.size.height)
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        })
    }

    func getChainModelList() {
        let ethChain = Chain().defaultChain
        let testChain = Chain(chainId: citaChainId, chainName: "Assets.AddAssets.CITANativeCoin".localized(), httpProvider: "")
        chains += [ethChain, testChain]
        let realm = try! Realm()
        let chainResult = realm.objects(ChainModel.self)
        chainResult.forEach { (model) in
            let chain = Chain(chainModel: model)
            chains.append(chain)
        }
        tableView.reloadData()
    }
}

extension SwitchChainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chains.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "switchChainTableViewCell") as! SwitchChainTableViewCell
        cell.networkLabel.text = chains[indexPath.row].chainName
        if currentChain.chainId == chains[indexPath.row].chainId {
            cell.selectedImageView.isHidden = false
        } else {
            cell.selectedImageView.isHidden = true
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentChain = chains[indexPath.row]
        delegate?.callSelectChain(chain: currentChain)
        dismiss()
    }

}

class SwitchChainTableViewCell: UITableViewCell {
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
}

struct Chain {
    var chainId = ""
    var chainName = ""
    var httpProvider = ""

    // first index chain default ethereum chain
    var defaultChain: Chain {
        return Chain(chainId: SwitchChainViewController().ethereumChainId, chainName: EthereumNetwork().networkType.chainName, httpProvider: EthereumNetwork().apiHost().absoluteString)
    }

    init() {
    }

    init(chainId: String,
         chainName: String,
         httpProvider: String) {
        self.chainId = chainId
        self.chainName = chainName
        self.httpProvider = httpProvider
    }

    init(chainModel: ChainModel) {
        chainId = chainModel.chainId
        chainName = chainModel.chainName
        httpProvider = chainModel.httpProvider
    }
}
