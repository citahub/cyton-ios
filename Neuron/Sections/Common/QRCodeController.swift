//
//  QRCodeController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/21.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import AVFoundation

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
        delegate?.didBackQRCodeMessage(codeResult: resultStrs.first!)
    }
    let share = HRQRCodeScanTool()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "扫描二维码"
        view.backgroundColor = UIColor.black
        share.delegate  = self
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self](result) in
            guard let self = self else { return }
            if result {
                self.share.beginScanInView(view: self.view)
            } else {
                let alert = UIAlertController(title: "", message: "扫描二维码需要相机访问权限", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "开启", style: .default, handler: { (_) in
                    let url = URL(string: UIApplication.openSettingsURLString)!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }))
                alert.addAction(UIAlertAction(title: "取消", style: .default, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
