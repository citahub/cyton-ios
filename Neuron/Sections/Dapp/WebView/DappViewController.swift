//
//  DappViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

/// DApp Home
class DappViewController: UIViewController, WKUIDelegate, ErrorOverlayPresentable {
    private let webView = WKWebView(frame: .zero)
    private var mainUrl = URL(string: "https://dapp.staging.cryptape.com")!
    private var customUserAgent: String {
        let infoDictionary = Bundle.main.infoDictionary!
        let majorVersion = infoDictionary["CFBundleShortVersionString"]!
        return "Neuron(Platform=iOS&AppVersion=\(String(describing: majorVersion))"
    }

    private var customStyle: String {
        return """
        #id-page-home #id-container-dappblocks .block { ; }
        """
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "DApp.Home".localized()

        addWebView()
        layoutWebView()

        errorOverlayRefreshBlock = { [weak self] () in
            guard let self = self else {
                return
            }
            self.removeOverlay()
            self.webView.load(URLRequest(url: self.mainUrl))
        }

        webView.load(URLRequest(url: mainUrl))
    }

    private func addWebView() {
        var js = ""
        if let path = Bundle.main.path(forResource: "dappOpration", ofType: "js") {
            do {
                js += try String(contentsOfFile: path)
            } catch { }
        }
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webView.customUserAgent = customUserAgent
        webView.configuration.userContentController.addUserScript(userScript)
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.userContentController.add(self, name: "pushSearchView")
        webView.configuration.userContentController.add(self, name: "pushMyDAppView")
        webView.configuration.userContentController.add(self, name: "pushCollectionView")
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false

        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        webView.uiDelegate = self

        view.addSubview(webView)
    }

    private func layoutWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension DappViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            decisionHandler(.cancel)
            let browserViewController: BrowserViewController = UIStoryboard(name: .dAppBrowser).instantiateViewController()
            browserViewController.requestUrlStr = navigationAction.request.url?.absoluteString ?? ""
            self.navigationController?.pushViewController(browserViewController, animated: true)
            return
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let error = error as NSError
        errorOverlaycontroller.style = .networkFail
        if error.code == -1009 {
            errorOverlaycontroller.messageLabel.text = "Common.Connection.ConnectionLost".localized()
        } else {
            errorOverlaycontroller.messageLabel.text = "Common.Connection.FailToLoadPage".localized()
        }
        showOverlay()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        /// Inject custom CSS style
        webView.evaluateJavaScript("var style = document.createElement('style'); style.innerHTML = '\(customStyle)'; document.head.appendChild(style);")
    }
}

extension DappViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "pushSearchView":
            let searchAppController = UIStoryboard(name: "DAppBrowser", bundle: nil).instantiateViewController(withIdentifier: "searchAppController")
            self.navigationController?.pushViewController(searchAppController, animated: true)
        case "pushMyDAppView":
            let myDAppViewController: MyDAppViewController = UIStoryboard(name: .dAppBrowser).instantiateViewController()
            self.navigationController?.pushViewController(myDAppViewController, animated: true)
        case "pushCollectionView":
            let nftViewController = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "nftViewController")
            self.navigationController?.pushViewController(nftViewController, animated: true)
        default:
            break
        }
    }
}

extension DappViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
