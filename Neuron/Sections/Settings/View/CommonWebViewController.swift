//
//  CommonWebViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/8.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import WebKit

class CommonWebViewController: UIViewController, WKNavigationDelegate {
    var url: URL!

    lazy private var webView: WKWebView = {
        let webView = WKWebView.init(frame: .zero)
        webView.navigationDelegate = self
        return webView
    }()

    lazy private var progressView: UIProgressView = {
        let progressView = UIProgressView.init(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: 2))
        progressView.tintColor = AppColor.themeColor
        progressView.trackTintColor = .white
        return progressView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        view.addSubview(progressView)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.load(URLRequest.init(url: url))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        webView.frame = CGRect(origin: .zero, size: view.bounds.size)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.alpha = 1.0
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (_) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
}
