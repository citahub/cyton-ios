//
//  BrowserViewController.swift
//  Cyton
//
//  Created by XiaoLu on 2018/7/13.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift

class BrowserViewController: UIViewController, ErrorOverlayPresentable {
    @IBOutlet private weak var directionView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var forwardButton: UIButton!
    @IBOutlet private weak var directionViewHeightConstraint: NSLayoutConstraint!

    var requestUrlStr = ""
    var mainUrl: URL?
    private var observations: [NSKeyValueObservation] = []
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: self.config)
        let infoDictionary = Bundle.main.infoDictionary!
        let majorVersion = infoDictionary["CFBundleShortVersionString"]
        let customUserAgent = "Neuron(Platform=iOS&AppVersion=\(String(describing: majorVersion!))"
        webView.evaluateJavaScript("navigator.userAgent", completionHandler: {(result, _) in
            if let agent = result as? String {
                webView.customUserAgent = customUserAgent + agent
            }
        })
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.delegate = self
        webView.addAllNativeFunctionHandler()
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()

    lazy private var progressView: UIProgressView = {
        let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 2))
        progressView.tintColor = UIColor(named: "tint_color")
        progressView.trackTintColor = .white
        return progressView
    }()

    lazy var config: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration.make(for: .main, in: ScriptMessageProxy(delegate: self))
        config.websiteDataStore = WKWebsiteDataStore.default()
        return config
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.addSubview(webView)
        layoutWebView()
        view.addSubview(progressView)
        view.bringSubviewToFront(directionView)
        directionViewHeightConstraint.constant = 0

        requestUrlStr = requestUrlStr.trimmingCharacters(in: .whitespaces)
        mainUrl = URL(string: getRequestStr(requestStr: requestUrlStr))
        if let url = mainUrl {
            loadRequest(url: url)
        } else {
            errorOverlaycontroller.style = .blank
            errorOverlaycontroller.messageLabel.text = "DApp.Browser.InvalidLink".localized()
            showOverlay()
        }
        errorOverlayRefreshBlock = { [weak self] () in
            self?.removeOverlay()
            guard let url = self?.mainUrl else { return }
            self?.loadRequest(url: url)
        }

        observations.append(webView.observe(\.estimatedProgress) { [weak self] (webView, _) in
            guard let self = self else {
                return
            }
            self.progressView.alpha = 1.0
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (_) in
                    self.progressView.setProgress(0.0, animated: false)
                    self.title = webView.title
                })
            }
        })
        observations.append(webView.observe(\.canGoBack) { [weak self] (_, _) in
            self?.updateNavigationButtons()
        })
    }

    func getRequestStr(requestStr: String) -> String {
        if requestUrlStr.hasPrefix("http://") || requestUrlStr.hasPrefix("https://") {
            return requestStr
        } else {
            return "https://" + requestStr
        }
    }

    private func loadRequest(url: URL) {
        var request = URLRequest(url: url)
        request.setAcceptLanguage()
        webView.load(request)
    }

    @IBAction func didClickCloseButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func didClickCollectionButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "DApp.Browser.Collection".localized(), style: .default, handler: { (_) in
            let relJs = "document.querySelector('head').querySelector('link[rel=manifest]').href;"
            self.webView.evaluateJavaScript(relJs) { (manifest, _) in
                if let dappLink = self.webView.url?.absoluteString, let title = self.webView.title {
                    DAppAction().collectDApp(manifestLink: manifest as? String, dappLink: dappLink, title: title, completion: { (result) in
                        if result {
                            Toast.showToast(text: "DApp.Browser.CollectSuccess".localized())
                        } else {
                            Toast.showToast(text: "DApp.Browser.CollectFaild".localized())
                        }
                    })
                } else {
                    Toast.showToast(text: "DApp.Browser.CollectFaild".localized())
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Common.Connection.Refresh".localized(), style: .default, handler: { (_) in
            self.webView.reload()
        }))
        alert.addAction(UIAlertAction(title: "Common.cancel".localized(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func evaluateJavaScryptWebView(id: Int, value: String, error: DAppError?) {
        let script: String
        let valueJson = "{\"status\":\"OK\",\"hash\":\"\(value)\"}"
        if error == nil {
            script = "onSignSuccessful(\(id), \(valueJson))"
        } else {
            script = "onSignError(\(id), \"\(error!)\")"
        }
        webView.evaluateJavaScript(script, completionHandler: nil)
    }

    private func updateNavigationButtons() {
        directionViewHeightConstraint.constant = webView.canGoBack ? 50 : 0
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }

    private func layoutWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: directionView.topAnchor).isActive = true
    }

    @IBAction func backButtonAction(_ sender: UIButton) {
        webView.goBack()
    }

    @IBAction func forwardButtonAction(_ sender: UIButton) {
        webView.goForward()
    }

    deinit {
        observations.forEach { $0.invalidate() }
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

extension BrowserViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}

extension BrowserViewController {
    private func pushTransaction(dappCommonModel: DAppCommonModel) {
        if !identificateValueAndGas(dappModel: dappCommonModel) {
            return
        }
        let contractController = storyboard!.instantiateViewController(withIdentifier: "contractController") as! ContractController
        contractController.delegate = self
        contractController.requestAddress = webView.url!.absoluteString
        contractController.dappName = webView.title ?? "DApp"
        contractController.dappCommonModel = dappCommonModel
        navigationController?.pushViewController(contractController, animated: true)
    }

    private func pushSignMessage(dappCommonModel: DAppCommonModel) {
        let controller: MessageSignController = UIStoryboard(name: .dAppBrowser).instantiateViewController()
        controller.modalPresentationStyle = .overCurrentContext
        controller.delegate = self
        controller.dappCommonModel = dappCommonModel
        present(controller, animated: false)
    }

    func identificateValueAndGas(dappModel: DAppCommonModel) -> Bool {
        if dappModel.chainType == .cita {
            if dappModel.cita?.value?.toBigUInt() == nil {
                Toast.showToast(text: "DApp.SendTransactionError.emptyValue".localized())
                return false
            }
            if dappModel.cita?.quota == nil || dappModel.cita?.quota?.count == 0 {
                Toast.showToast(text: "DApp.SendTransactionError.emptyQuota".localized())
                return false
            }
            return true
        } else {
            if dappModel.eth?.value?.toBigUInt() == nil && dappModel.eth?.value != nil {
                Toast.showToast(text: "DApp.SendTransactionError.emptyValue".localized())
                return false
            }
            if dappModel.eth?.gasLimit?.toBigUInt() == nil && dappModel.eth?.gasLimit != nil {
                Toast.showToast(text: "DApp.SendTransactionError.emptyGasLimit".localized())
                return false
            }
            if dappModel.eth?.gasPrice?.toBigUInt() == nil && dappModel.eth?.gasPrice != nil {
                Toast.showToast(text: "DApp.SendTransactionError.emptyGasPrice".localized())
                return false
            }
            return true
        }
    }
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateNavigationButtons()

        let relJs = "document.querySelector('head').querySelector('link[rel=manifest]').href;"
        webView.evaluateJavaScript(relJs) { (manifest, _) in
            guard let link = manifest else {
                return
            }
            DAppAction().dealWithManifestJson(with: link as! String)
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let error = error as NSError
        errorOverlaycontroller.style = .networkFail
        if error.code == -1009 {
            errorOverlaycontroller.messageLabel.text = "Common.Connection.LoseConnect".localized()
        } else {
            errorOverlaycontroller.messageLabel.text = "Common.Connection.LoadFaild".localized()
        }
        showOverlay()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let requestURL = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        // TODO: should NOT define custom scheme for alipay and weixin, use path or other symbol instead.
        if requestURL.absoluteString.hasPrefix("alipays://") || requestURL.absoluteString.hasPrefix("alipay://") {
            UIApplication.shared.open(requestURL, options: [:]) { (result) in
                guard !result else { return }
                let alert = UIAlertController(title: "DApp.Browser.AlertTitle".localized(), message: "DApp.Browser.CheckNoAliPay".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Common.confirm".localized(), style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            decisionHandler(.cancel)
        } else if requestURL.absoluteString.hasPrefix("weixin://") {
            UIApplication.shared.open(requestURL, options: [:]) { (result) in
                guard !result else { return }
                let alert = UIAlertController(title: "DApp.Browser.AlertTitle".localized(), message: "DApp.Browser.CheckNoWeChat".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Common.confirm".localized(), style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            decisionHandler(.cancel)
        } else {
            if navigationAction.request.acceptLanguage == URLRequest.acceptLanguage || navigationAction.navigationType != .linkActivated {
                decisionHandler(.allow)
            } else {
                // Set Accept-Language for following requests
                var request = navigationAction.request
                request.setAcceptLanguage()
                decisionHandler(.cancel)
                webView.load(request)
            }
        }
    }
}

extension BrowserViewController: ContractControllerDelegate, MessageSignControllerDelegate {
    func messageSignCallBackWebView(id: Int, value: String, error: DAppError?) {
        evaluateJavaScryptWebView(id: id, value: value, error: error)
        if let error = error {
            error != .userCanceled ? Toast.showToast(text: "DApp.Browser.SignFaild".localized()) : nil
        }
    }

    func callBackWebView(id: Int, value: String, error: DAppError?) {
        evaluateJavaScryptWebView(id: id, value: value, error: error)
        if let error = error {
            error != .userCanceled ? Toast.showToast(text: "DApp.Browser.PayFaild".localized()) : nil
        }
    }
}

extension BrowserViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController!.viewControllers.count > 1
    }
}
