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

fileprivate let tabItemSpace: CGFloat = 2

fileprivate let addItemSpaceWidth: CGFloat = 80

protocol TabViewDelegate {
    
    func tabItemSelectionDidChange(_ tabViewController: TabViewController)
    func tabItemSelectionWillChange(_ tabViewController: TabViewController)

}

class TabViewController: NSViewController, NSGestureRecognizerDelegate {
    
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
    
    @IBOutlet weak var tabView: TabView! {
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
    
    fileprivate func drawTab() {
        
        var startx: CGFloat = 10.0
        let width = tabItemWidth
        
        for item in tabViewItems {
            item.frame = NSMakeRect(startx, 0, width, item.frame.size.height)
            startx += tabItemSpace + width
        }
    }
    
    private func tabItem(at location: NSPoint) -> TabItem? {
        for item in tabViewItems {
            if NSPointInRect(location, item.frame) { return item }
        }
        return nil
    }
    
    var dragedTabItem: TabItem?
    private var dragedXOffset: CGFloat = 0
    
    @IBAction func panGestureUpdated(_ recognizer: NSPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let dragedStartPosition =  recognizer.location(in: self.tabView)
            dragedTabItem = tabItem(at: dragedStartPosition)
            if dragedTabItem != nil {
                dragedXOffset =  dragedStartPosition.x - dragedTabItem!.frame.origin.x
            }

        case .changed:
            guard dragedTabItem != nil  else {
                return
            }
            let location =  recognizer.location(in: self.tabView)
            dragedTabItem!.frame.origin.x = location.x - dragedXOffset
            
        case .ended:
            dragedTabItem = nil
            dragedXOffset = 0
            drawTab()
        default:
            break
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
        return true
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
    
    func onTabHover(_ item: TabItem) {
        
        guard let dragedItem = self.dragedTabItem else {
            return
        }
        
        // exchange dragedItem and hoverItem
        if let hoverIndex = self.tabViewItems.index(of: item),
            let dragedIndex = self.tabViewItems.index(of: dragedItem) {
            self.tabViewItems.remove(at: dragedIndex)
            self.tabViewItems.insert(dragedItem, at: hoverIndex)

            self.drawTab()
        }

    }
}
