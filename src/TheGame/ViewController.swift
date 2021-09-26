//
//  ViewController.swift
//  TheGame
//
//  Created by Aditya Agrawal on 15/9/21.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    override func loadView(){
        let rect = NSRect(x: 0, y: 0, width: WIDTH, height: HEIGHT)
        view = NSView(frame: rect)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.red.cgColor
    }
}
