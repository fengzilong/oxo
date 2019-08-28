//
//  Preferences.swift
//  oxo
//
//  Created by zilong on 2018/12/11.
//  Copyright © 2018年 zilong. All rights reserved.
//

import Foundation

class Preferences {
    static let shared = Preferences()
    let defaults = UserDefaults.standard

    var copyMode: String {
        get {
            let value: String? = defaults.string(forKey: "copyMode")
            return value != nil ? value! : "Default"
        }

        set(value) {
            defaults.set( value, forKey: "copyMode" )
        }
    }

    var history: [String] {
        get {
            return defaults.stringArray(forKey: "history") ?? [String]()
        }

        set(value) {
            var real = value

            if value.count > 10 {
                real = Array(value[0...9])
            }

            defaults.set(real, forKey: "history")
        }
    }
}
