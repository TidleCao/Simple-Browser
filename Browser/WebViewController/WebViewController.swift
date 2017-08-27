//
//  WebViewController.swift
//  Browser
//
//  Created by jifu on 25/08/2017.
//  Copyright © 2017 Xunlei. All rights reserved.
//

import Cocoa
import WebKit


protocol WebUIDelegate {
    
    func controller(_ vc: WebViewController, createWebViewControllerWith configuration: WKWebViewConfiguration) -> WebViewController?
    func controller(_ vc: WebViewController, didFinish navigation: WKNavigation!)
    func controller(_ vc: WebViewController, didStartProvisionalNavigation navigation: WKNavigation!)
    func controller(_ vc: WebViewController, didCommit navigation: WKNavigation!)

    func controller(_ vc: WebViewController,  didChangeTitle title: String)
    func controller(_ vc: WebViewController,  updateProgress estimatedProgress: Double)

}

class WebViewController: NSViewController {
    
    
    var delegate: WebUIDelegate?
    
    var webView: WKWebView!
    
    private func setupWebView() {
        
        if webView == nil {
            webView = WKWebView(frame: self.view.bounds)
        }
        
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        self.view.addSubview(webView!)
        webView.setFrameSize(self.view.bounds.size)
        webView.autoresizingMask = [.viewHeightSizable, .viewMaxYMargin,.viewMinXMargin,.viewWidthSizable]
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)

        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    func load(url: URL) {
 
        webView?.load(URLRequest(url: url))
    }
    
    deinit {
        print("webview deinit...")
        
        if webView != nil {
            webView.removeObserver(self, forKeyPath: "title")
            webView.removeObserver(self, forKeyPath: "estimatedProgress")

        }
    }
}

// MAR: -
extension WebViewController {

    override  func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "title" , let title = webView?.title {
            if delegate != nil {
                delegate?.controller(self, didChangeTitle: title )
            }
        }else if keyPath == "estimatedProgress",let estimatedProgress = webView?.estimatedProgress {
            if delegate != nil {
                delegate?.controller(self, updateProgress: estimatedProgress)
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: -
extension WebViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if delegate != nil, navigationAction.targetFrame == nil {
            return delegate?.controller(self, createWebViewControllerWith: configuration)?.webView
        }
        return nil
    }
}

// MARK: -
extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if delegate != nil {
            delegate?.controller(self, didStartProvisionalNavigation: navigation)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if delegate != nil {
            delegate?.controller(self, didFinish: navigation)
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if delegate != nil {
            delegate?.controller(self, didCommit: navigation)
        }
    }
    
}
