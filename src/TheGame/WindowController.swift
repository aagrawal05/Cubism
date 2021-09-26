//
//  WindowController.swift
//  TheGame
//
//  Created by Aditya Agrawal on 22/9/21.
//

import Cocoa

class WindowController: NSWindowController {
    let main = NSTouchBarItem.Identifier("com.TheGame.TouchBarItem.main")
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    override func makeTouchBar() -> NSTouchBar? {

        let touchBar = NSTouchBar()
        touchBar.delegate = self

        touchBar.customizationIdentifier = NSTouchBar.CustomizationIdentifier("com.TheGame.mainTouchBar")
        touchBar.defaultItemIdentifiers = [main]
        touchBar.customizationAllowedItemIdentifiers = [main]
        
        return touchBar
    }
}

// MARK: - NSTouchBarDelegate

extension WindowController: NSTouchBarDelegate {
    
    // The system calls this while constructing the NSTouchBar for each NSTouchBarItem you want to create.
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case main:
            let view = NSView()
            view.wantsLayer = true
            view.layer?.backgroundColor = NSColor.systemGray.cgColor
            
            let custom = NSCustomTouchBarItem(identifier: identifier)
            custom.view = view
            return custom
        default:
            return nil
        }
    }
}

