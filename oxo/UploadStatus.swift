//
//  UploadStatus.swift
//  oxo
//
//  Created by zilong on 2018/12/11.
//  Copyright © 2018年 zilong. All rights reserved.
//

protocol UploadDelegate {
    func uploadStart()
    func uploadProgress(_ progress: Double)
    func uploadSuccess(_ url: String)
    func uploadFailed()
}

class UploadStatus: UploadDelegate {
    let statusItem = StatusItemController.shared
    let preferences = Preferences.shared
    let utils = Utils.shared

    func uploadStart() {
        statusItem.showProgress()
    }
    
    func uploadProgress(_ progress: Double) {
        statusItem.progressIndicator.doubleValue = progress * 100 - 1
    }
    
    func uploadSuccess(_ url: String) {
        reset()

        var content = url
        if preferences.copyMode == "Markdown" {
            content = "![](\(url))"
        }

        utils.copy( content: content )
        utils.notify( title: "Copied", description: content )
        print( "url: \(url)" )

        var history = preferences.history
        history.insert(url, at: 0)
        preferences.history = history
        
        statusItem.setupHistoryMenu( statusItem.statusItem.menu! )
    }
    
    func uploadFailed() {
        reset()
        utils.notify( title: "Upload failed", description: "" )
    }
    
    func reset() {
        statusItem.hideProgress()
    }
}
