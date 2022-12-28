//
//  AppDelegate.swift
//  Weekly
//
//  Created by Paul Wong on 4/12/20.
//  Copyright © 2020 Paul Wong. All rights reserved.
//

import Cocoa


@available(OSX 10.14, *)
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let timeInterval: Double = 300
    var priorWeekNo = 0
    var priorMode: Bool = false
    
    var aboutBoxController: NSWindowController!
    var aboutBoxView: MZAboutBoxViewController!

    var timer: Timer!
    var settings: Settings!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // load settings
        settings = Settings()
        processCommandLine()
        
        // Last things to do
        update()
        timer = Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: self,
            selector: #selector(fireTimer(_:)),
            userInfo: nil,
            repeats: true
        )
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func fireTimer(_ sender: Any?) {
        update()
    }
    
    @objc func showLabel(_ sender: Any?) {
        settings.settings.showLabel = !settings.settings.showLabel
        settings.archive()
        update()
    }
    
    @objc func openCalendar(_ sender: Any?) {
        NSWorkspace.shared.launchApplication("iCal")
    }
    
    @IBAction func openAbout(_ sender: Any?) {
        if aboutBoxController == nil {
            let mainStoryboard = NSStoryboard.init(name: "MZAboutBox", bundle: nil)
            aboutBoxController = (mainStoryboard.instantiateController(
                withIdentifier: "MZ About Box") as! NSWindowController)
            aboutBoxView = (mainStoryboard.instantiateController(
                withIdentifier: "MZ AboutBox Controller"
                ) as! MZAboutBoxViewController)
            aboutBoxController.contentViewController = aboutBoxView
            aboutBoxView.setMacId(newMacId: "id1508616995")
        }
        aboutBoxController.showWindow(self)
        aboutBoxController.window?.makeKeyAndOrderFront(self)
        aboutBoxView.forceHelp(force: false)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quit(_ sender: Any?) {
        NSApplication.shared.terminate(nil)
    }
    
    func constructMenu(_ weekNo: Int) {
        let menu = NSMenu()
    
        menu.addItem(NSMenuItem(title: "Open week \(weekNo)", action: #selector(AppDelegate.openCalendar(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About...", action: #selector(AppDelegate.openAbout(_:)), keyEquivalent: ""))
        
        let showmenu = NSMenuItem(title: "Show Label", action: #selector(AppDelegate.showLabel(_:)), keyEquivalent: "s")
        if settings.settings.showLabel == true {
            showmenu.state = NSControl.StateValue.on
        } else {
            showmenu.state = NSControl.StateValue.off
        }
        menu.addItem(showmenu)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }
    
    func update() {
        let calendar = Calendar.current
        let weekNo = calendar.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))
        
        if weekNo != priorWeekNo || settings.needsDisplay == true  {
            priorWeekNo = weekNo

            var statusText = ""
            if self.settings.settings.showLabel {
                statusText = "Week "
            }
            statusItem.button!.title = "\(statusText)"
            
            let text = "\(weekNo)"

            let iconImage = createMenuIcon(text: text, overrideWidth: 16)
            iconImage.isTemplate = true
            
            statusItem.button!.image = iconImage
            statusItem.button?.imagePosition = .imageRight
            
            settings.needsDisplay = false
        }
        constructMenu(weekNo)
    }
    
    func createMenuIcon(text: String, overrideWidth: CGFloat?) -> NSImage {
        
        let textFont = NSFont(name: "HelveticaNeue", size: 12)!
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: NSColor.white,
        ] as [NSAttributedString.Key : Any]
        let stringSize = text.size(withAttributes: textFontAttributes)
        let width = overrideWidth ?? (stringSize.width + 4)
        let size = NSSize(width: width, height: 16)
        
        let backgroundImage = NSImage(size: size)
        backgroundImage.lockFocus()
        let rect = NSRect(origin: .zero, size: size)
        let borderPath = NSBezierPath()
        borderPath.appendRoundedRect(rect, xRadius: 3.0, yRadius: 3.0)
        borderPath.lineWidth = 1
        let fillColor = NSColor.black
        fillColor.set()
        borderPath.fill()
        borderPath.stroke()
        backgroundImage.unlockFocus()
        
        let foregroundImage = NSImage(size: size)
        foregroundImage.lockFocus()
        text.draw(
            in: CGRect(
                x: (size.width - stringSize.width) / 2,
                y: (size.height - stringSize.height) / 2,
                width: stringSize.width,
                height: stringSize.height
            ),
            withAttributes: textFontAttributes
        )
        foregroundImage.unlockFocus()
        
        backgroundImage.lockFocus()
        foregroundImage.draw(in: CGRect(origin: .zero, size: size), from: CGRect(origin: .zero, size: foregroundImage.size), operation: .destinationOut, fraction: 1.0)
        backgroundImage.unlockFocus()
        
        return backgroundImage
    }
    
    func processCommandLine() {
        let arguments = ProcessInfo.processInfo.arguments
        // reset takes takes priority
        for i in 0..<arguments.count {
            if (arguments[i] == "-R") {
                settings.reset()
                print("Reset configuration.")
            }
        }
        // now handle the rest
        for i in 0..<arguments.count {
            switch arguments[i] {
                case "-R":
                    print("Reset configuration, already handled.")
                default:
                    print("Unhandled argument: \(arguments[i])")
            }
        }
    }
}
