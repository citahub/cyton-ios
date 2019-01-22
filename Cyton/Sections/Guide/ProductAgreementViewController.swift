//
//  ProductAgreementViewController.swift
//  Cyton
//
//  Created by 晨风 on 2018/10/10.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class ProductAgreementViewController: UIViewController {
    enum UserDefaultsKey: String {
        case agreement = "ProductAgreementUserDefaultsKey"
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var checkLabel: UILabel!
    @IBOutlet private weak var checkLabelHeight: NSLayoutConstraint!

    var isAgree: Bool = false {
        didSet {
            let attach = NSTextAttachment()
            if isAgree {
                confirmButton.isEnabled = true
                confirmButton.setTitleColor(UIColor(red: 54/255.0, green: 59/255.0, blue: 255/255.0, alpha: 1.0), for: .normal)
                attach.image = UIImage(named: "icon_check_yes")
            } else {
                confirmButton.isEnabled = false
                confirmButton.setTitleColor(UIColor(red: 233/255.0, green: 235/255.0, blue: 240/255.0, alpha: 1.0), for: .normal)
                attach.image = UIImage(named: "icon_check_no")
            }
            attach.bounds = CGRect(x: 0, y: 0, width: 14, height: 14)
            let attributedText = NSMutableAttributedString(attributedString: checkLabel.attributedText!)
            attributedText.replaceCharacters(in: NSRange(location: 0, length: 1), with: NSAttributedString(attachment: attach))
            checkLabel.attributedText = attributedText
        }
    }

    static var shouldDisplay: Bool {
        return !UserDefaults.standard.bool(forKey: UserDefaultsKey.agreement.rawValue)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        isAgree = false
        titleLabel.text = "Guide.cytonServiceAgreement".localized()
        confirmButton.setTitle("Guide.continue".localized(), for: .normal)

        let attach = NSTextAttachment()
        attach.image = UIImage(named: "icon_check_no")
        attach.bounds = CGRect(x: 0, y: 0, width: 14, height: 14)

        let attributedText = NSMutableAttributedString(string: "   " + "Guide.agreementOfConsent".localized())
        attributedText.addAttribute(NSAttributedString.Key.baselineOffset, value: 3, range: NSRange(location: 0, length: attributedText.string.count))
        attributedText.insert(NSAttributedString(attachment: attach), at: 0)
        checkLabel.attributedText = attributedText
        checkLabelHeight.constant = checkLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: checkLabel.bounds.size.width, height: 60), limitedToNumberOfLines: 0).size.height + 12

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProductAgreementViewController.agreement(_:)))
        checkLabel.addGestureRecognizer(tapGestureRecognizer)
        checkLabel.accessibilityIdentifier = "ckeckLabel"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.contentOffset = CGPoint.zero
    }

    func setupTextView() {
        let text = try! String(contentsOfFile: Bundle.main.path(forResource: "product_agreement", ofType: "txt")!)
        textView.text = text
        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        var searchRange = Range(uncheckedBounds: (text.startIndex, text.endIndex))
        while true {
            guard let range = text.range(of: "、", options: .literal, range: searchRange, locale: nil) else { break }
            searchRange = Range(uncheckedBounds: (range.upperBound, text.endIndex))
            let testText = text[Range(uncheckedBounds: (text.index(before: range.lowerBound), range.lowerBound))]
            guard ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"].contains("\(testText.first!)") else { continue }
            guard let fristLineFeedRange = text.range(of: "\n", options: .backwards, range: Range(uncheckedBounds: (text.startIndex, range.lowerBound)), locale: nil) else { break }
            guard let nextLineFeedRange = text.range(of: "\n", options: .literal, range: Range(uncheckedBounds: (range.upperBound, text.endIndex)), locale: nil) else { break }
            let lineRange = Range(uncheckedBounds: (fristLineFeedRange.upperBound, nextLineFeedRange.lowerBound))
            let nsRange = NSRange(lineRange, in: text)
            attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 16.0), range: nsRange)
            attributedText.addAttribute(.foregroundColor, value: UIColor(red: 46/255.0, green: 49/255.0, blue: 62/255.0, alpha: 1.0), range: nsRange)
        }
        textView.attributedText = attributedText
    }

    @IBAction func agreement(_ sender: Any) {
        isAgree.toggle()
    }

    @IBAction func confirm(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.agreement.rawValue)
    }
}
