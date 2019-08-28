//
//  Utils.swift
//  oxo
//
//  Created by zilong on 2018/12/11.
//  Copyright © 2018年 zilong. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON
import PlainPing

enum FormData {
    case url(URL)
    case data(Data)
}

class Utils: NSObject, NSUserNotificationCenterDelegate {
    static let shared = Utils()
    let preferences = Preferences.shared
    var delegate: UploadDelegate?
    var images: [String: NSImage] = [:]

    func screenshot() -> String? {
        let destinationPath = "/tmp/\(UUID().uuidString).png"
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-r", destinationPath]
        task.launch()
        task.waitUntilExit()
        var notDir = ObjCBool(false)
        return FileManager.default.fileExists(atPath: destinationPath, isDirectory: &notDir)
            ? destinationPath
            : nil
    }
    
    func upload(url: URL) {
        self.doUpload( formDataCallback: { multipartFormData in
            multipartFormData.append( url, withName: "file" )
        } )
    }
    
    func upload(data: Data, ext: String) {
        self.doUpload( formDataCallback: { multipartFormData in
            multipartFormData.append(
                data,
                withName: "file",
                fileName: ("file.\(ext)" ),
                mimeType: ("image/\(ext)" )
            )
        } )
    }
    
    func doUpload(formDataCallback: @escaping (MultipartFormData) -> Void) {
        self.delegate?.uploadStart()
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                formDataCallback(multipartFormData)
        },
            to: "REPLACE_THIS"
        ) {
            ( result ) in
            switch result {
            case .success( let upload, _ , _ ):
                upload.uploadProgress( closure: { ( progress ) in
                    self.delegate?.uploadProgress( progress.fractionCompleted )
                } )
                
                upload.responseJSON { response in
                    let value = response.result.value

                    if value != nil {
                        let json = JSON( value as Any )
                        let code = String( describing: json[ "code" ] )
                        let url = String( describing: json[ "body" ][ "url" ] )
                        
                        if code == "200" {
                            self.delegate?.uploadSuccess( url )
                        } else {
                            self.delegate?.uploadFailed()
                        }
                    } else {
                        self.delegate?.uploadFailed()
                    }
                }
            case .failure( let encodingError ):
                self.delegate?.uploadFailed()
                print( encodingError )
            }
        }
    }
    
    func isMarkdownMode(_ mode: String ) -> Bool {
        return mode == "Markdown"
    }
    
    func markdownify(_ content: String ) -> String {
        return "![](\(content))"
    }
    
    func setTimeout(delay:TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
    
    func copy( content: String ) -> Void {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects( [ content as NSString ] )
    }
    
    func notify( title: String, description: String ) -> Void {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = description
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.scheduleNotification( notification )
    }
    
    func createNSImage(_ url: String) -> NSImage {
        if images[ url ] != nil {
            return images[ url ]!
        } else {
            images[ url ] = NSImage(contentsOf: URL(string: url)!)
            
            if images[ url ] != nil {
                return images[ url ]!
            } else {
                return NSImage(named: NSImage.Name(rawValue: "EmptyIconImage"))!
            }
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}


