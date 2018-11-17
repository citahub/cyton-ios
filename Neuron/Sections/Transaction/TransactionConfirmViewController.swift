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
    var paramBuilder: TransactionParamBuilder! {
        didSet {
            let controller: TransactionConfirmInfoViewController = UIStoryboard(name: .transaction).instantiateViewController()
            controller.paramBuilder = paramBuilder
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
                UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundView.alpha = 0.0
        contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.size.height)
        UIView.animate(withDuration: CATransaction.animationDuration()) {
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
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            self.backgroundView.alpha = 0.0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.contentView.bounds.size.height)
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
            self.delegate?.transactionCanceled(self)
        })
    }

    func confirmWalletPassword(password: String) {
        if paramBuilder != nil {
            sendTransaction()
        } else {
            delegate?.transactionConfirmWalletPassword(self, password: password)
        }
    }

    func confirmTransactionInfo() {
        let controller: TransactionConfirmSendViewController = UIStoryboard(name: .transaction).instantiateViewController()
        controller.delegate = self
        contentViewController = controller
    }

    @objc func keyboardWillShow(notification: Notification) {
        let boundsValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let bounds = boundsValue?.cgRectValue else { return }
        let durationValue = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        guard let duration = durationValue?.doubleValue else { return }
        let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
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

    @objc func keyboardWillHide(notification: Notification) {
        let durationValue = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        guard let duration = durationValue?.doubleValue else { return }
        let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        guard let curve = curveValue?.intValue else { return }
        let options = UIView.AnimationOptions(rawValue: UInt(curve << 16))
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.contentView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

private extension TransactionConfirmViewController {
    func sendTransaction() {
        Toast.showHUD()
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                // TODO: send tx
                //self.paramBuilder.sendTransaction(password: password)
                Toast.hideHUD()
            }
        }
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
    var paramBuilder: TransactionParamBuilder! {
        didSet {
            _ = view // load view
            amountLabel.text = Double.fromAmount(paramBuilder.value, decimals: paramBuilder.decimals).decimal
            let range = NSMakeRange(amountLabel.text!.lengthOfBytes(using: .utf8), paramBuilder.symbol.lengthOfBytes(using: .utf8))
            amountLabel.text! += paramBuilder.symbol
            let attributedText = NSMutableAttributedString(attributedString: amountLabel.attributedText!)
            attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)], range: range)
            amountLabel.attributedText = attributedText
            fromAddressLabel.text = paramBuilder.from
            toAddressLabel.text = paramBuilder.to
            gasCostLabel.text = "\(paramBuilder.txFeeNatural.decimal)\(paramBuilder.nativeCoinSymbol)"
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
