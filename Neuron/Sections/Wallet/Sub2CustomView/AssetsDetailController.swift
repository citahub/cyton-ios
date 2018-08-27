//
//  AssetsDetailController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

protocol AssetsDetailControllerDelegate: NSObjectProtocol {
    func didClickPay(tokenModel: TokenModel)
    func didClickGet()
}

class AssetsDetailController: UIViewController {
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var iconImageV: UIImageView!
    @IBOutlet weak var countLable: UILabel!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var getButtton: UIButton!
    weak var delegate: AssetsDetailControllerDelegate?

    var tokenModel = TokenModel() {
        didSet {
            iconImageV.sd_setImage(with: URL(string: tokenModel.iconUrl!), placeholderImage: UIImage.init(named: "ETH_test"), options: .retryFailed, completed: nil)
            titleLable.text = tokenModel.symbol
            countLable.text = tokenModel.tokenBalance
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
    }

    @IBAction func closeMyselfBtn(_ sender: UIButton) {
        self.view.removeFromSuperview()
    }
    @IBAction func didClickPayBtn(_ sender: UIButton) {
        delegate?.didClickPay(tokenModel: tokenModel)
        self.view.removeFromSuperview()
    }

    @IBAction func didClickGetBtn(_ sender: UIButton) {
        delegate?.didClickGet()
        self.view.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
