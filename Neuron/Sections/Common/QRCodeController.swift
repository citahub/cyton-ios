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

    func scanQRCodeFaild(error: HRQRCodeTooError) {
        print(error)
    }

    func scanQRCodeSuccess(resultStrs: [String]) {
        self.navigationController?.popViewController(animated: true)
        print(resultStrs.first ?? "")
        delegate?.didBackQRCodeMessage(codeResult: resultStrs.first!)
    }
    let share = HRQRCodeScanTool()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isDarkStyle = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "扫描二维码"
        share.delegate  = self
        share.beginScanInView(view: view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
