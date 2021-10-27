//
//  AppDelegate.swift
//  TheGame
//
//  Created by Aditya Agrawal on 15/9/21.
//

import Cocoa
import MetalKit

let WIDTH  = 800
let HEIGHT = 600
var deg = Float(0)
var deg2 = Float(0)

class AppDelegate: NSObject, NSApplicationDelegate {
    private var mWindow: NSWindow?
    private var mWindowController: NSWindowController?
    private var mRenderer: Renderer?
    private var mDevice: MTLDevice?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let screenSize = NSScreen.main?.frame.size ?? .zero

        let rect = NSMakeRect((screenSize.width  - CGFloat(WIDTH))  * 0.5,
                              (screenSize.height - CGFloat(HEIGHT)) * 0.5,
                              CGFloat(WIDTH),
                              CGFloat(HEIGHT))
        
        mWindow = NSWindow(contentRect: rect, // for full height and width of screen
                          styleMask: [.miniaturizable, .closable, .resizable, .titled],
                          backing: .buffered,
                          defer: false)
        
        mWindowController = WindowController(window: mWindow)
        mWindow?.title = ProcessInfo.processInfo.processName
        mWindow?.contentViewController = ViewController()
        mWindow?.makeKeyAndOrderFront(nil)

        mDevice = MTLCreateSystemDefaultDevice()
        if mDevice == nil { fatalError("NO GPU") }

        let view  = MTKView(frame: rect, device: mDevice)
        mRenderer = Renderer(view: view)
        mWindow?.contentViewController?.view = view
        
        NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

