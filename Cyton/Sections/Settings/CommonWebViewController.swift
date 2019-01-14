//
//  CommonWebViewController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/7/8.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import WebKit

class CommonWebViewController: UIViewController, WKNavigationDelegate {
    var url: URL!
    var webViewProgressObservation: NSKeyValueObservation!

    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        return webView
    }()

    lazy private var progressView: UIProgressView = {
        let screenSize = UIScreen.main.bounds.size
        let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 2))
        progressView.tintColor = UIColor(named: "tint_color")
        progressView.trackTintColor = .white
        return progressView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        view.addSubview(progressView)
        webView.load(URLRequest.init(url: url))

        webViewProgressObservation = webView.observe(\.estimatedProgress) { [weak self](webView, _) in
            guard let self = self else { return }
            self.progressView.alpha = 1.0
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (_) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        webView.frame = CGRect(origin: .zero, size: view.bounds.size)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }

    deinit {
        webViewProgressObservation.invalidate()
    }
}
