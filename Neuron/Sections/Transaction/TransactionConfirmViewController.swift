//
//  TransactionConfirmViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/31.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class TransactionConfirmViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containView: UIView!
    var service: TransactionService!
    var contentViewController: UIViewController? {
        didSet {
            guard let controller = contentViewController else { return }
            controller.view.frame = containView.bounds
            containView.addSubview(controller.view)

            if let oldValue = oldValue {
                let offset = oldValue.view.bounds.size.width
                controller.view.transform = CGAffineTransform(translationX: offset, y: 0)
                containView.addSubview(controller.view)
                UIView.animate(withDuration: 0.33, animations: {
                    oldValue.view.transform = CGAffineTransform(translationX: -offset, y: 0)
                    controller.view.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    oldValue.view.removeFromSuperview()
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let controller: TransactionConfirmInfoViewController = UIStoryboard(name: .transaction).instantiateViewController()
        controller.service = service
        contentViewController = controller

        registerEventStrategy(with: TransactionConfirmInfoViewController.Event.confirm.rawValue, action: #selector(TransactionConfirmViewController.confirmInfo))
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(node:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(node:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundView.alpha = 0.0
        contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.size.height)
        UIView.animate(withDuration: 0.33) {
            self.backgroundView.alpha = 1.0
            self.contentView.transform = CGAffineTransform.identity
        }
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss()
    }

    @IBAction func dismiss() {
        UIView.animate(withDuration: 0.33, animations: {
            self.backgroundView.alpha = 0.0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.contentView.bounds.size.height)
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        })
    }

    @objc func confirmInfo() {
        let controller: TransactionConfirmSendViewController = UIStoryboard(name: .transaction).instantiateViewController()
        controller.service = service
        contentViewController = controller
    }

    @objc func keyBoardWillShow(node: Notification) {
        let boundsValue = node.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let bounds = boundsValue?.cgRectValue else { return }
        let durationValue = node.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        guard let duration = durationValue?.doubleValue else { return }
        let curveValue = node.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        guard let curve = curveValue?.intValue else { return }
        let offset = view.bounds.size.height - contentView.bounds.size.height - bounds.size.height - contentView.frame.origin.y
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: UInt(curve << 16))
            UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                self.contentView.transform = self.contentView.transform.translatedBy(x: 0, y: offset)
            }, completion: { (_) in
            })
        }
    }

    @objc func keyBoardWillHide(node: Notification) {
        let durationValue = node.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        guard let duration = durationValue?.doubleValue else { return }
        let curveValue = node.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        guard let curve = curveValue?.intValue else { return }
        let options = UIView.AnimationOptions(rawValue: UInt(curve << 16))
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.contentView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

class TransactionConfirmInfoViewController: UIViewController {
    enum Event: String {
        case confirm = "TransactionConfirmInfoViewController.Event.confirm"
    }

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var gasCostLabel: UILabel!
    var service: TransactionService! {
        didSet {
            _ = view // load view
            let amount = service.amount
            if amount == Double(Int(amount)) {
                amountLabel.text = "\(Int(amount))"
            } else {
                amountLabel.text = "\(amount)"
            }
            amountLabel.text! += service.token.symbol
            let attributedText = NSMutableAttributedString(attributedString: amountLabel.attributedText!)
            let range = NSMakeRange(amountLabel.text!.lengthOfBytes(using: .utf8), service.token.symbol.lengthOfBytes(using: .utf8))
            attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)], range: range)
            amountLabel.attributedText = attributedText
            fromAddressLabel.text = service.fromAddress
            toAddressLabel.text = service.toAddress
            gasCostLabel.text = "\(service.gasCost)"
        }
    }

    @IBAction func confirm(_ sender: Any) {
        routerEvent(with: Event.confirm.rawValue, userInfo: nil)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}

class TransactionConfirmSendViewController: UIViewController {
    enum Event: String {
        case confirm = "TransactionConfirmSendViewController.Event.confirm"
    }

    @IBOutlet weak var passwordTextField: UITextField!
    var service: TransactionService!

    @IBAction func confirm(_ sender: Any) {
        routerEvent(with: Event.confirm.rawValue, userInfo: ["password": passwordTextField.text ?? ""])
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
