//
//  WindowController.swift
//  Browser
//
//  Created by jifu on 24/08/2017.
//  Copyright © 2017 Xunlei. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titlebarAppearsTransparent = true
        self.window?.titleVisibility = .hidden
        self.window?.styleMask = [(self.window?.styleMask)! ,.fullSizeContentView]
        self.window?.isMovableByWindowBackground = true
    }

}
