//
//  TabbarItem.swift
//  Browser
//
//  Created by jifu on 24/08/2017.
//  Copyright © 2017 Xunlei. All rights reserved.
//

import Cocoa

fileprivate let backgroundHoverColor: NSColor = NSColor(srgbRed: 0xd0/255.0, green: 0xd0/255.0, blue: 0xd0/255.0, alpha: 1.0)
fileprivate let backgroundColor: NSColor = NSColor.lightGray
fileprivate let selectedColor: NSColor = NSColor(srgbRed: 0xdd/255.0, green: 0xdd/255.0, blue: 0xdd/255.0, alpha: 1.0)
fileprivate let imageSize: NSSize = NSMakeSize(16, 16)
fileprivate let closeBtnSize: NSSize = NSMakeSize(32, 32)

fileprivate let defaultSize =  NSMakeSize(100, 40)
fileprivate let spaceSize: CGFloat = 3.0

protocol TabItemDelegate {
    func onCloseTabItem(_ sender: TabItem)
    func onTabSelect(_ item: TabItem)
    func onTabHover(_ item: TabItem)
}

class TabItem: NSView {
    
    var delegate: TabItemDelegate?
    
    private var imageView: NSImageView = NSImageView(frame: NSMakeRect(0, 0, imageSize.width, imageSize.height))
    private var closeButton: NSButton =  NSButton(frame: NSMakeRect(0,0, closeBtnSize.width, closeBtnSize.height))
    
    private(set) var viewController: NSViewController!
    
    deinit {
        Swift.print("TabItem deinit...\(self.label)")
    }
    
    init(_ label: String, viewController: NSViewController) {
        super.init(frame: NSMakeRect(0, 0, defaultSize.width, defaultSize.height))
        self.viewController = viewController
        self.label = label
        self.addSubview(imageView)
        self.addSubview(closeButton)
        self.wantsLayer = true
        self.layer?.backgroundColor = backgroundColor.cgColor

    }
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        
        layoutCloseButton()
        layoutImageView()
    }
    
    fileprivate func layoutCloseButton() {
        let viewSize = self.frame.size
        closeButton.setFrameOrigin(NSMakePoint(viewSize.width - closeBtnSize.width, (viewSize.height - closeBtnSize.height)/2))
        closeButton.title = "X"
        closeButton.isBordered = false
        closeButton.autoresizingMask = [ .viewMaxYMargin,.viewMaxXMargin]
        closeButton.target = self
        closeButton.action = #selector(TabItem.onCloseButtonClick(_:))
    }
    
    fileprivate func layoutImageView() {
        let viewSize = self.frame.size
        imageView.setFrameOrigin(NSMakePoint(spaceSize, (viewSize.height - imageSize.height)/2))
        
    }
    
    
    @objc func onCloseButtonClick(_ sender: Any) {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        self.removeFromSuperview()
        
        self.viewController.view.removeFromSuperview()
        self.viewController = nil
        
        delegate?.onCloseTabItem(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var label: String = "New Tab" {
        didSet {
            self.needsDisplay = true
        }
    }
    
    var imageURL: URL? {
        didSet {
            if imageURL == nil {
                imageView.image = nil
            }else {
                imageView.image = NSImage(contentsOf: imageURL!)
            }
            self.needsDisplay = true
        }
    }
    
    
    var isSelected: Bool = false {
        
        didSet {
            if isSelected == true {
                self.layer?.backgroundColor = selectedColor.cgColor
            }else {
                self.layer?.backgroundColor = backgroundColor.cgColor
            }
            
            self.needsDisplay = true
        }
    }
    
    var haveCloseButton: Bool = false {
        
        didSet {
            self.needsDisplay = true
        }
    }
    
    var area: NSTrackingArea?
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        
        let startx: CGFloat = spaceSize * 3 + imageSize.width
        
        
        // draw label
        let title = NSAttributedString(string: label)
        let titleSize = title.size()
        let titleActualWidth = dirtyRect.size.width - startx - closeBtnSize.width - 5
        title.draw(in: NSMakeRect(startx, (dirtyRect.size.height - titleSize.height)/2, titleActualWidth, titleSize.height))
        
        
    }
    

    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.layer?.backgroundColor = selectedColor.cgColor
        self.needsDisplay = true
        
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        self.needsDisplay = true

        delegate?.onTabSelect(self)
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.layer?.backgroundColor = backgroundHoverColor.cgColor
        self.needsDisplay = true
        delegate?.onTabHover(self)

    }
    
    override func mouseExited(with event: NSEvent) {
        self.layer?.backgroundColor = isSelected ? selectedColor.cgColor : backgroundColor.cgColor
        self.needsDisplay = true
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if area == nil {
           area = NSTrackingArea.init(rect: NSZeroRect, options: [.inVisibleRect, .activeAlways, .mouseEnteredAndExited
                    ], owner: self, userInfo: nil)
            self.addTrackingArea(area!)
        }

    }
}
