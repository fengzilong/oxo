//
//  ImageFormat.swift
//  oxo
//
//  Created by zilong on 2018/12/12.
//  Copyright © 2018年 zilong. All rights reserved.
//

import Foundation

struct ImageHeaderData {
    static var PNG: [UInt8] = [0x89]
    static var JPEG: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47]
    static var TIFF_01: [UInt8] = [0x49]
    static var TIFF_02: [UInt8] = [0x4D]
}
enum ImageFormat {
    case Unknown, PNG, JPEG, GIF, TIFF
}
extension Data {
    var imageFormat: ImageFormat {
        var buffer = [UInt8](repeating: 0, count: 1)
        copyBytes(to: &buffer, from: 0..<1)
        if buffer == ImageHeaderData.PNG { return .PNG }
        if buffer == ImageHeaderData.JPEG { return .JPEG }
        if buffer == ImageHeaderData.GIF { return .GIF }
        if buffer == ImageHeaderData.TIFF_01 ||
            buffer == ImageHeaderData.TIFF_02 {
            return .TIFF
        }
        return .Unknown
    }
}
