//
//  StatusItemController.swift
//  oxo
//
//  Created by zilong on 2018/12/10.
//  Copyright © 2018年 zilong. All rights reserved.
//

import Cocoa

class StatusItemController: NSObject {
    static let shared = StatusItemController()

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var progressIndicator: NSProgressIndicator!
    let preferences = Preferences.shared
    let utils = Utils.shared

    func checkMenuItem(_ item: NSMenuItem) {
        let menu = item.menu!

        for item in menu.items {
            item.state = .off
        }

        item.state = .on
    }

    func toggleMenuItem(_ item: NSMenuItem) {
        if item.state == .on {
            item.state = .off
        } else {
            item.state = .on
        }
    }

    @IBAction func onScreenshot(_ sender: NSMenuItem) {
        guard let path = utils.screenshot() else {
            return
        }

        let url = URL( fileURLWithPath: path )
        self.utils.delegate = UploadStatus()
        self.utils.upload( url: url )
    }

    @IBAction func onUploadFromPasteboard(_ sender: NSMenuItem) {
        let pboard = NSPasteboard.general

        let classes: [AnyClass] = [ NSURL.self, NSImage.self ]

        // read from pasteboard
        guard let objects = pboard.readObjects( forClasses: classes, options: nil ) else {
            return
        }

        for object in objects {
            if let url = object as? URL {
                self.utils.delegate = UploadStatus()
                if url.isFileURL {
                    print("FileURL")
                    self.utils.delegate = UploadStatus()
                    self.utils.upload( url: url )
                } else {
                    print("Not FileURL")
                    var imageData: Data?
                    do {
                        imageData = try Data(contentsOf: url)
                        self.utils.delegate = UploadStatus()
                        self.utils.upload( data: imageData!, ext: url.pathExtension )
                    } catch(let e) {
                        print(e)
                    }
                }
            } else if object is NSImage  {
                if let image = object as? NSImage {
                    print("NSImage")
                    var imageData = image.tiffRepresentation

                    if let imageRep = NSBitmapImageRep(data: imageData!) {
                        imageData = imageRep.representation(using: .jpeg, properties: [:])
                        self.utils.delegate = UploadStatus()
                        self.utils.upload( data: imageData!, ext: "jpg" )
                    }
                }
            }
        }
    }

    @IBAction func onClearHistory(_ sender: NSMenuItem) {
        preferences.history = []
        setupHistoryMenu(sender.menu!)
        utils.notify(title: "Cleared", description: "")
    }

    @IBAction func onSwitchCopyModeToDefault(_ sender: NSMenuItem) {
        checkMenuItem(sender)
        preferences.copyMode = "Default"
    }

    @IBAction func onSwitchCopyModeToMarkdown(_ sender: NSMenuItem) {
        checkMenuItem(sender)
        preferences.copyMode = "Markdown"
    }

    @IBAction func onQuit(_ sender: NSMenuItem) {
        NSApp.terminate(self)
    }

    func setup(_ menu: NSMenu) {
        statusItem.menu = menu

        let frame = NSRect( x: 0, y: 2, width: 16, height: 16 )
        progressIndicator = NSProgressIndicator( frame: frame )
        progressIndicator.style = .spinning
        progressIndicator.isIndeterminate = false
        progressIndicator.doubleValue = 0
        progressIndicator.isHidden = true

        if let button = statusItem.button {
            button.addSubview( progressIndicator )
        }

        self.hideProgress()
        self.setupCopyModeItem( menu )
        self.setupHistoryMenu( menu )
    }

    func setupHistoryMenu(_ menu: NSMenu) {
        let urls = preferences.history
        let item = menu.item(withTitle: "Upload History")

        if let submenu = item?.submenu {
            submenu.removeAllItems()

            if urls.count > 0 {
                DispatchQueue.main.async {
                    for url in urls {
                        let newItem = NSMenuItem()
                        let image = self.utils.createNSImage(url)
                        image.size = NSSize(width: 60, height: 60)
                        newItem.image = image
                        newItem.title = ""
                        newItem.target = self
                        newItem.action = #selector(self.copyHistoryItemUrl(_:))
                        submenu.addItem(newItem)
                    }
                }
            } else {
                let newItem = NSMenuItem()
                newItem.title = "none"
                submenu.addItem(newItem)
            }
        }
    }

    @objc func copyHistoryItemUrl(_ sender: NSMenuItem) {
        let urls = preferences.history
        let mode = preferences.copyMode

        if let index = sender.menu?.index(of: sender) {
            var content = urls[index]
            if utils.isMarkdownMode(mode) {
                content = utils.markdownify(content)
            }

            utils.copy(content: content)
            utils.notify(title: "Copied", description: content)
        } else {
            utils.notify(title: "Notfound record", description: "")
        }
    }

    func setupCopyModeItem(_ menu: NSMenu) {
        let copyMode = preferences.copyMode
        let item = menu.item(withTitle: "Copy Mode")
        let submenu = item?.submenu
        if let modeItem = submenu?.item(withTitle: copyMode) {
            checkMenuItem(modeItem)
        }
    }

    func showProgress() {
        statusItem.title = ""
        // Use empty image as placeholder
        statusItem.image = NSImage(named: NSImage.Name(rawValue: "EmptyIconImage"))
        statusItem.image?.isTemplate = true
        statusItem.button?.addSubview(progressIndicator)
        statusItem.button?.alphaValue = 1.0
        progressIndicator.isHidden = false
    }

    func hideProgress() {
        NSAnimationContext.runAnimationGroup( { _ in
            NSAnimationContext.current.duration = 0.2
            statusItem.button?.animator().alphaValue = 0.0
        }, completionHandler:{
            self.statusItem.image = nil
            self.statusItem.title = "Ծ‸Ծ"
            self.progressIndicator.doubleValue = 0
            self.progressIndicator.isHidden = true
            self.statusItem.button?.alphaValue = 1.0
        } )
    }

    func teardown() {
        NSStatusBar.system.removeStatusItem(statusItem)
    }
}
