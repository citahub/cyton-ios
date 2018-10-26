//
//  QRCodeController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/21.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

protocol QRCodeControllerDelegate: class {
    func didBackQRCodeMessage(codeResult: String)
}

class QRCodeController: UIViewController, HRQRCodeScanToolDelegate {

    weak var delegate: QRCodeControllerDelegate?
    let shared = HRQRCodeScanTool()

    func scanQRCodeFaild(error: HRQRCodeTooError) {
    }

    func scanQRCodeSuccess(resultStrs: [String]) {
        self.navigationController?.popViewController(animated: true)
        delegate?.didBackQRCodeMessage(codeResult: resultStrs.first!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "扫描二维码"
        shared.delegate  = self
        shared.beginScanInView(view: view)
    }
}
