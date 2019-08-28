//
//  ServiceProvider.swift
//  oxo
//
//  Created by zilong on 2018/12/6.
//  Copyright © 2018年 zilong. All rights reserved.
//

import Cocoa

// TODO: upload history

class ServicesProvider: NSObject {
    let utils = Utils.shared
    let preferences = Preferences.shared
    
    @objc func upload(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        let classes: [AnyClass] = [ NSURL.self, NSImage.self ]
        
        // read from pasteboard
        guard let objects = pboard.readObjects( forClasses: classes, options: nil ) else {
            return
        }

        for object in objects {
            if let url = object as? URL {
                self.utils.delegate = UploadStatus()
                self.utils.upload( url: url )
            }
        }
    }
}
