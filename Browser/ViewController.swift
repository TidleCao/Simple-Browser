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
    
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var searchField: NSTextField!
    
    var tabViewController: TabViewController! = TabViewController(nibName: "TabViewController", bundle: Bundle.main)
    
    
    
    @IBAction func search(_ sender: Any) {
        var str = searchField.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
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
    
}

// MARK: -

extension ViewController: TabViewDelegate {
    func tabItemSelectionDidChange(_ tabViewController: TabViewController) {
        
        let selectedItem = tabViewController.selectedItem
        //if all tab is closed
        if selectedItem == nil {
            self.newWebViewController(with: nil)
            self.searchField.stringValue = ""

            
        }else {
            
            //update searching field
            if let url  = (selectedItem!.viewController as! WebViewController).webView.url?.absoluteString {
                self.searchField.stringValue = url
            }
        }

    }
}
