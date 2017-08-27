//
//  TabViewController.swift
//  Browser
//
//  Created by jifu on 24/08/2017.
//  Copyright © 2017 Xunlei. All rights reserved.
//

import Cocoa


fileprivate let tabItemWidthMax: CGFloat = 200
fileprivate let tabItemWidthMin: CGFloat = 50

fileprivate let tabItemHeight: CGFloat = 50

fileprivate let tabItemSpace: CGFloat = 5

fileprivate let addItemSpaceWidth: CGFloat = 80

protocol TabViewDelegate {
    
    func tabItemSelectionDidChange(_ tabViewController: TabViewController)
    func tabItemSelectionWillChange(_ tabViewController: TabViewController)

}

class TabViewController: NSViewController {
    
    var selectedItem: TabItem?
    var delegate: TabViewDelegate?
    var tabViewItems: [TabItem] = []
    
    var selectedTabViewItemIndex: Int {
        if nil != selectedItem {
            return tabViewItems.index(of: selectedItem!) ?? -1
        }
        return -1
    }
    
    @IBOutlet weak var contentView: NSView! {
        didSet {
            contentView.wantsLayer = true
            contentView.layer?.backgroundColor = NSColor.white.cgColor
        }
    }
    
    @IBOutlet weak var tabView: NSView! {
        didSet {
            tabView.wantsLayer = true
            tabView.layer?.backgroundColor = NSColor.white.cgColor
        }
    }
    
    fileprivate var tabItemWidth: CGFloat {
        let width = (tabView.frame.size.width - addItemSpaceWidth) / CGFloat(tabViewItems.count)
        
        if width <= tabItemWidthMin {
            return tabItemWidthMin
        }else if width >= tabItemWidthMax {
            return tabItemWidthMax
        }
        return width
    }
    
    fileprivate func drawTab() {
        
        var startx: CGFloat = 10.0
        let width = tabItemWidth
        
        for item in tabViewItems {
            item.frame = NSMakeRect(startx, 0, width, item.frame.size.height)
            startx += tabItemSpace + width
        }
    }
    
    func select(for item: TabItem) {
        guard tabViewItems.contains(item), selectedItem != item else {
            return
        }
        
        delegate?.tabItemSelectionWillChange(self)

        if selectedItem != nil {
            
            selectedItem?.isSelected = false
            selectedItem?.viewController?.view.removeFromSuperview()

        }
        
        selectedItem = item
        item.isSelected = true
        
        contentView.addSubview(item.viewController.view)
        item.viewController.view.frame = contentView.bounds
        item.viewController.view.autoresizingMask = [.viewHeightSizable, .viewMaxYMargin,.viewMinXMargin,.viewWidthSizable]
        delegate?.tabItemSelectionDidChange(self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
    }
    
}

// MARK:-
extension TabViewController {
    
    func addTabViewItem(_ item: TabItem) {
        item.delegate = self
        
        self.tabView.addSubview(item)
        self.tabViewItems.append(item)
        self.drawTab()
        self.select(for: item)
        
    }
    
    func insertTabViewItem(_ item: TabItem, at idx: Int) {
        if idx < tabViewItems.count {
            tabViewItems.insert(item, at: idx)
        }
    }
    
    func removeTabViewItem(_ item: TabItem) {

        if let idx = tabViewItems.index(of: item) {
            
            tabViewItems.remove(at: idx)
            
            if let lastItem = tabViewItems.last {
                self.select(for: lastItem)
            }else {
                self.selectedItem = nil
                delegate?.tabItemSelectionDidChange(self)
            }
            
            self.drawTab()
        }
        
    }
    
    func item(for viewController: NSViewController) -> TabItem? {
        
        for item in tabViewItems {
            if item.viewController == viewController {
                return item
            }
        }
        
        return nil
    }
}

// MARK: -
extension TabViewController: TabItemDelegate {
    func onCloseTabItem(_ sender: TabItem) {
        self.removeTabViewItem(sender)
    }
    
    func onTabSelect(_ item: TabItem) {
        self.select(for: item)
    }
}
