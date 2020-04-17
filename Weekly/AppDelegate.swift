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
    
    @objc func about(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(self)
    }
    
    @objc func showLabel(_ sender: Any?) {
        settings.settings.showLabel = !settings.settings.showLabel
        settings.archive()
        update()
    }
    
    @objc func openCalendar(_ sender: Any?) {
        NSWorkspace.shared.launchApplication("iCal")
    }
    
    @objc func quit(_ sender: Any?) {
        NSApplication.shared.terminate(nil)
    }
    
    func constructMenu(_ weekNo: Int) {
        let menu = NSMenu()
    
        menu.addItem(NSMenuItem(title: "Open week \(weekNo)", action: #selector(AppDelegate.openCalendar(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About...", action: #selector(AppDelegate.about(_:)), keyEquivalent: ""))
        
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
        
        var inDarkMode: Bool {
            let mode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
            return mode == "Dark"
        }
        
        if weekNo != priorWeekNo || settings.needsDisplay == true || inDarkMode != priorMode {
            priorWeekNo = weekNo
            priorMode = inDarkMode

            var statusText = ""
            if self.settings.settings.showLabel {
                statusText = "Week "
            }
            statusItem.title = "\(statusText)"
            
            var img = NSImage(named: "LightMenubarIcon")
            var textColor = NSColor.white
            if inDarkMode {
                img = NSImage(named: "DarkMenubarIcon")
                textColor = NSColor.black
            }
            statusItem.image = createMenubarIcon(weekNo:weekNo, textColor:textColor, image:img!)
            statusItem.button?.imagePosition = .imageRight
            
            settings.needsDisplay = false
        }
        constructMenu(weekNo)
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
    
    func createMenubarIcon(weekNo: Int, textColor: NSColor, image: NSImage) -> NSImage {

        let targetImage = NSImage(size: image.size, flipped: false) { (dstRect: CGRect) -> Bool in

            let text = "\(weekNo)"
            
            image.draw(in: dstRect)
            let textColor = textColor
            let textFont = NSFont(name: "HelveticaNeue", size: 12)!
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.center

            let textFontAttributes = [
                NSAttributedString.Key.font: textFont,
                NSAttributedString.Key.foregroundColor: textColor,
                ] as [NSAttributedString.Key : Any]

            let stringSize = text.size(withAttributes: textFontAttributes)

            text.draw(
                in: CGRect(
                    x: (image.size.width - stringSize.width) / 2,
                    y: (image.size.height - stringSize.height) + 5 / 2,
                    width: stringSize.width,
                    height: stringSize.height
                ),
                withAttributes: textFontAttributes
            )

            
            return true
        }
        return targetImage
    }
}

