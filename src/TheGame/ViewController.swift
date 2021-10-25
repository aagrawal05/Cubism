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
        
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
                    self.flagsChanged(with: $0)
                    return $0
                }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
    }
    
    override func keyDown(with event: NSEvent) {
            switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
            case [.command] where event.characters == "l",
                 [.command, .shift] where event.characters == "l":
                print("command-l or command-shift-l")
            default:
                break
            }
        }
        override func flagsChanged(with event: NSEvent) {
            switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
            case [.shift]:
                print("shift key is pressed")
            case [.control]:
                print("control key is pressed")
                deg+=1.0;
            case [.option] :
                print("option key is pressed")
            case [.command]:
                print("Command key is pressed")
                deg-=1.0;
            case [.control, .shift]:
                print("control-shift keys are pressed")
            case [.option, .shift]:
                print("option-shift keys are pressed")
            case [.command, .shift]:
                print("command-shift keys are pressed")
            case [.control, .option]:
                print("control-option keys are pressed")
            case [.control, .command]:
                print("control-command keys are pressed")
            case [.option, .command]:
                print("option-command keys are pressed")
            case [.shift, .control, .option]:
                print("shift-control-option keys are pressed")
            case [.shift, .control, .command]:
                print("shift-control-command keys are pressed")
            case [.control, .option, .command]:
                print("control-option-command keys are pressed")
            case [.shift, .command, .option]:
                print("shift-command-option keys are pressed")
            case [.shift, .control, .option, .command]:
                print("shift-control-option-command keys are pressed")
            default:
                print("no modifier keys are pressed")
            }
        }
}
