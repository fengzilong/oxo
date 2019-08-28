//
//  AppDelegate.swift
//  oxo
//
//  Created by zilong on 2018/12/6.
//  Copyright © 2018年 zilong. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = StatusItemController.shared

    @IBOutlet weak var statusMenu: NSMenu!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.setup(statusMenu)
        NSApp.servicesProvider = ServicesProvider()
        NSUpdateDynamicServices()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        statusItem.teardown()
    }
}
