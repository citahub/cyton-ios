//
//  TransactionConfirmViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/31.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol TransactionConfirmViewControllerDelegate: NSObjectProtocol {
    func transactionConfirmWalletPassword(_ controller: TransactionConfirmViewController, password: String)
    func transactionCanceled(_ controller: TransactionConfirmViewController)
}

class TransactionConfirmViewController: UIViewController, TransactionConfirmSendViewControllerDelegate, TransactionConfirmInfoViewControllerDelegate {
    weak var delegate: TransactionConfirmViewControllerDelegate?
    @IBOutlet weak var containTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containView: UIView!
    var service: TransactionParamBuilder! {
        didSet {
            let controller: TransactionConfirmInfoViewController = UIStoryboard(name: .transaction).instantiateViewController()
            controller.service = service
            controller.delegate = self
            contentViewController = controller
        }
    }
    var contentViewController: UIViewController? {
        didSet {
            guard let controller = contentViewController else { return }
            _ = view // load view
            titleLabel.text = controller.title
            controller.view.frame = CGRect(
                x: 0,
                y: containView.bounds.height - controller.preferredContentSize.height,
                width: containView.bounds.size.width,
                height: controller.preferredContentSize.height
            )
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

    @IBAction func dismiss() {
        UIView.animate(withDuration: 0.33, animations: {
            self.backgroundView.alpha = 0.0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.contentView.bounds.size.height)
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
            self.delegate?.transactionCanceled(self)
        })
    }

    func confirmWalletPassword(password: String) {
        if let service = service {
            Toast.showHUD()
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    self.service.sendTransaction(password: password)
                    Toast.hideHUD()
                }
            }
        } else {
            delegate?.transactionConfirmWalletPassword(self, password: password)
        }
    }

    func confirmTransactionInfo() {
        let controller: TransactionConfirmSendViewController = UIStoryboard(name: .transaction).instantiateViewController()
        controller.delegate = self
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

protocol TransactionConfirmInfoViewControllerDelegate: NSObjectProtocol {
    func confirmTransactionInfo()
}

class TransactionConfirmInfoViewController: UIViewController {
    weak var delegate: TransactionConfirmInfoViewControllerDelegate?
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var gasCostLabel: UILabel!
    var service: TransactionParamBuilder! {
        didSet {
            _ = view // load view
            let amount = service.amount
            if amount == Double(Int(amount)) {
                amountLabel.text = "\(Int(amount))"
            } else {
                amountLabel.text = "\(amount)"
            }
            let range = NSMakeRange(amountLabel.text!.lengthOfBytes(using: .utf8), service.token.symbol.lengthOfBytes(using: .utf8))
            amountLabel.text! += service.token.symbol
            let attributedText = NSMutableAttributedString(attributedString: amountLabel.attributedText!)
            attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)], range: range)
            amountLabel.attributedText = attributedText
            fromAddressLabel.text = service.fromAddress
            toAddressLabel.text = service.toAddress
            gasCostLabel.text = "\(service.gasCost)" + "\(service.token.gasSymbol)"
        }
    }

    @IBAction func confirm(_ sender: Any) {
        delegate?.confirmTransactionInfo()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}

protocol TransactionConfirmSendViewControllerDelegate: NSObjectProtocol {
    func confirmWalletPassword(password: String)
}

class TransactionConfirmSendViewController: UIViewController {
    weak var delegate: TransactionConfirmSendViewControllerDelegate?
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func confirm(_ sender: Any) {
        let password = passwordTextField.text ?? ""
        if case .invalid(let reason) = PasswordValidator.validate(password: password) {
            Toast.showToast(text: reason)
            return
        }
        delegate?.confirmWalletPassword(password: password)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
