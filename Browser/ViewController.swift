//
//  ViewController.swift
//  Browser
//
//  Created by jifu on 24/08/2017.
//  Copyright © 2017 Xunlei. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {
    
    var tabViewController: TabViewController! = TabViewController(nibName: "TabViewController", bundle: Bundle.main)
    
   dynamic var progress: Double = 0
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var forwardBtn: NSButton!
    @IBOutlet weak var backwardBtn: NSButton!
    
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var searchField: NSSearchField! {
        didSet {
            searchField.sendsWholeSearchString = true
        }
    }
    
    @IBAction func goForward(_ sender: Any) {
        if let vc = tabViewController.selectedItem?.viewController as? WebViewController {
            vc.webView.goForward()
        }
    }
    
    @IBAction func goback(_ sender: Any) {
        if let vc = tabViewController.selectedItem?.viewController as? WebViewController {
            vc.webView.goBack()
        }

    }
    @IBAction func search(_ sender: Any) {
        var str = searchField.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        if str == "" {
            (tabViewController.selectedItem?.viewController as? WebViewController)?.webView.stopLoading()
            return
        }
        if !str.hasPrefix("http") {
            str = "http://\(str)"
        }
        
        if let vc = tabViewController.selectedItem?.viewController as? WebViewController, let url = URL(string: str) {
            vc.load(url: url)
        }
    }
    
    @IBAction func onClickNewTab(_ sender: Any) {
        self.newWebViewController(with: nil)
    }
    
    @discardableResult func newWebViewController(with webView: WKWebView?) -> WebViewController {
        let vc = WebViewController(nibName: "WebViewController", bundle:Bundle.main)!
        vc.delegate = self
        vc.webView = webView
        tabViewController.addTabViewItem(TabItem("New Tab", viewController: vc))
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addSubview(tabViewController.view )
        tabViewController.view.frame = contentView.frame
        tabViewController.delegate = self
        newWebViewController(with: nil)
        
    }
    
}

extension ViewController: WebUIDelegate {
    
    func controller(_ vc: WebViewController, createWebViewControllerWith configuration: WKWebViewConfiguration) -> WebViewController? {
        let vc = self.newWebViewController(with: WKWebView(frame: NSZeroRect, configuration: configuration))
        return vc
        
    }
    
    func controller(_ vc: WebViewController, didFinish navigation: WKNavigation!) {
        if let tabItem = tabViewController.item(for: vc), let host = vc.webView.url?.host {
            
            // get favicon
            tabItem.imageURL = URL(string: "http://\(host)/favicon.ico")
            
            // update search field address
            if tabViewController.selectedItem == tabItem {
                self.searchField.stringValue = (vc.webView.url?.absoluteString)!
                
            }
        }

    }
    
    func controller(_ vc: WebViewController, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func controller(_ vc: WebViewController, didCommit navigation: WKNavigation!) {
        
        
    }
    
    func controller(_ vc: WebViewController, didChangeTitle title: String) {
        tabViewController.item(for: vc)?.label = title
    }
    
    func controller(_ vc: WebViewController, updateProgress estimatedProgress: Double) {
        print("estimatedProgress: \(estimatedProgress)")
        
        self.progress = estimatedProgress  * 100
        progressIndicator.isHidden = estimatedProgress == 1.0
    }
    

}

// MARK: -

extension ViewController: TabViewDelegate {
    
    func tabItemSelectionWillChange(_ tabViewController: TabViewController) {
        
        // unbind forward/backward button status
        self.backwardBtn?.unbind("enabled")
        self.backwardBtn?.unbind("enabled")
        
    }

    func tabItemSelectionDidChange(_ tabViewController: TabViewController) {
        
        let selectedItem = tabViewController.selectedItem
        //if all tab is closed
        if selectedItem == nil {
            self.newWebViewController(with: nil)
            self.searchField.stringValue = ""

        }else {
            guard let vc = selectedItem!.viewController as? WebViewController else {
                return
            }
            
            //update searching field
            if let url  = vc.webView.url?.absoluteString {
                self.searchField.stringValue = url
            }
            

            // bind forward/backward button status
            self.backwardBtn?.bind("enabled", to: vc.webView, withKeyPath: "canGoBack", options: nil)
            self.forwardBtn?.bind("enabled", to: vc.webView, withKeyPath: "canGoForward", options: nil)

        }

    }
}
