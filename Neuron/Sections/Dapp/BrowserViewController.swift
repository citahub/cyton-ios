//
//  BrowserViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/13.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, ErrorOverlayPresentable {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionButton: UIButton!
    private var messageSignController: MessageSignController!
    var requestUrlStr = ""

    lazy private var webview: WKWebView = {
        let webview = WKWebView(
            frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height - 64),
            configuration: self.config
        )
        let infoDictionary = Bundle.main.infoDictionary!
        let majorVersion = infoDictionary["CFBundleShortVersionString"]
        webview.customUserAgent = "Neuron(Platform=iOS&AppVersion=\(String(describing: majorVersion!))"
        webview.navigationDelegate = self
        webview.uiDelegate = self
        return webview
    }()

    lazy private var progressView: UIProgressView = {
        let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: 2))
        progressView.tintColor = AppColor.themeColor
        progressView.trackTintColor = UIColor.white
        return progressView
    }()

    lazy var config: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration.make(for: .main, in: ScriptMessageProxy(delegate: self))
        config.websiteDataStore = WKWebsiteDataStore.default()
        return config
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webview)
        view.addSubview(progressView)
        webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        let url = URL(string: getRequestStr(requestStr: requestUrlStr))
        let request: URLRequest
        if let url = url {
            request = URLRequest(url: url)
            webview.load(request)
        } else {
            showNetworkFailOverlay()
        }
    }

    func getRequestStr(requestStr: String) -> String {
        if requestUrlStr.hasPrefix("http://") || requestUrlStr.hasPrefix("https://") {
            return requestStr
        } else {
            return "https://" + requestStr
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.alpha = 1.0
            progressView.setProgress(Float(webview.estimatedProgress), animated: true)
            if webview.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (_) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }

    @IBAction func didClickBackButton(_ sender: UIButton) {
        if webview.canGoBack {
            webview.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func dudCkucjCloseButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func didClickCollectionButton(_ sender: UIButton) {
    }

    func evaluateJavaScryptWebView(id: Int, value: String, error: DAppError?) {
        let script: String
        if error == nil {
            script = "onSignSuccessful(\(id), \"\(value)\")"
        } else {
            script = "onSignError(\(id), \"\(error!)\")"
        }
        webview.evaluateJavaScript(script, completionHandler: nil)
    }
}

extension BrowserViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "getTitleBar" {
//            let model = DAppDataHandle.fromTitleBarMessage(message: message)
//            if (model.right?.isShow)! {
//                collectionButton.isHidden = false
//            } else {
//                collectionButton.isHidden = true
//            }
        } else {
            let dappCommonModel = try! DAppDataHandle.fromMessage(message: message)
            switch dappCommonModel.name {
            case .sendTransaction, .signTransaction:
                pushTransaction(dappCommonModel: dappCommonModel)
            case .signPersonalMessage, .signMessage, .signTypedMessage:
                pushSignMessage(dappCommonModel: dappCommonModel)
            case .unknown: break
            }
        }
    }
}

extension BrowserViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            completionHandler()
        }))

        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            completionHandler(false)
        }))

        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            completionHandler(nil)
        }))

        present(alertController, animated: true, completion: nil)
    }
}

extension BrowserViewController {
    private func pushTransaction(dappCommonModel: DAppCommonModel) {
        let contractController = storyboard!.instantiateViewController(withIdentifier: "contractController") as! ContractController
        contractController.delegate = self
        contractController.requestAddress = webview.url!.absoluteString
        contractController.dappName = webview.title ?? "DApp"
        contractController.dappCommonModel = dappCommonModel
        navigationController?.pushViewController(contractController, animated: true)
    }

    private func pushSignMessage(dappCommonModel: DAppCommonModel) {
        messageSignController = storyboard!.instantiateViewController(withIdentifier: "messageSignController") as? MessageSignController
        messageSignController.delegate = self
        messageSignController.dappCommonModel = dappCommonModel
        messageSignController.requestUrlString = webview.url!.absoluteString
        UIApplication.shared.keyWindow?.addSubview(messageSignController.view)
    }
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        if webView.canGoBack {
            closeButton.isHidden = false
        } else {
            closeButton.isHidden = true
        }
        let js = "document.querySelector('head').querySelector('link[rel=manifest]').href;"
        webView.evaluateJavaScript(js) { (manifest, _) in
            guard let link = manifest else {
                return
            }
//            self.collectionButton.isHidden = false
            DAppAction().dealWithManifestJson(with: link as! String)
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showNetworkFailOverlay()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let requestURL = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        if requestURL.absoluteString.hasPrefix("alipays://") || requestURL.absoluteString.hasPrefix("alipay://") {
            UIApplication.shared.open(requestURL, options: [:]) { (result) in
                guard !result else { return }
                let alert = UIAlertController(title: "提示", message: "未检测到支付宝客户端，请安装后重试。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            decisionHandler(.cancel)
        } else if requestURL.absoluteString.hasPrefix("weixin://") {
            UIApplication.shared.open(requestURL, options: [:]) { (result) in
                guard !result else { return }
                let alert = UIAlertController(title: "提示", message: "未检测到微信客户端，请安装后重试。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

extension BrowserViewController: ContractControllerDelegate, MessageSignControllerDelegate {
    func messageSignCallBackWebView(id: Int, value: String, error: DAppError?) {
        evaluateJavaScryptWebView(id: id, value: value, error: error)
    }
    func callBackWebView(id: Int, value: String, error: DAppError?) {
        evaluateJavaScryptWebView(id: id, value: value, error: error)
    }
}
