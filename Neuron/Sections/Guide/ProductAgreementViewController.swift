//
//  ProductAgreementViewController.swift
//  Neuron
//
//  Created by 晨风 on 2018/10/10.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class ProductAgreementViewController: UIViewController {
    enum UserDefaultsKey: String {
        case agreement = "ProductAgreementUserDefaultsKey"
    }

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var checkButton: UIButton!
    var isAgree: Bool = false {
        didSet {
            if isAgree {
                confirmButton.isEnabled = true
                confirmButton.setTitleColor(UIColor(red: 54/255.0, green: 59/255.0, blue: 255/255.0, alpha: 1.0), for: .normal)
                checkButton.setImage(UIImage(named: "icon_check_yes"), for: .normal)
            } else {
                confirmButton.isEnabled = false
                confirmButton.setTitleColor(UIColor(red: 233/255.0, green: 235/255.0, blue: 240/255.0, alpha: 1.0), for: .normal)
                checkButton.setImage(UIImage(named: "icon_check_no"), for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        isAgree = false
    }

    func setupTextView() {
        let text = try! String(contentsOfFile: Bundle.main.path(forResource: "ProductAgreement", ofType: "txt")!)
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

    static func show(in inController: UIViewController) {
        guard UserDefaults.standard.bool(forKey: UserDefaultsKey.agreement.rawValue) == false else { return }
        let controller: ProductAgreementViewController = UIStoryboard(name: .guide).instantiateViewController()
        controller.modalPresentationStyle = .overCurrentContext
        inController.present(controller, animated: true, completion: nil)
    }

    @IBAction func agreement(_ sender: Any) {
        isAgree.toggle()
    }

    @IBAction func confirm(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.agreement.rawValue)
    }
}
