//
//  RowDataStruct.swift
//  BatterExtendApp
//
//  Created by jay on 29/05/2020.
//  Copyright © 2020 xiaoke yang. All rights reserved.
//

import AppKit
public struct rowDataStruct{
    var appName:String
    var icon:NSImage
}

extension rowDataStruct{
    func encode() -> Data {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(appName, forKey: "appName")
        archiver.encode(icon.tiffRepresentation, forKey: "icon")
        archiver.finishEncoding()
        
        
        
        return data as Data
    }
    
    init?(data: Data) {
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        defer {
            unarchiver.finishDecoding()
        }
        guard let appName = unarchiver.decodeObject(forKey: "appName") as? String else { return nil}
        guard let icon = unarchiver.decodeObject(forKey: "icon") as? NSImage else { return nil}
        self.appName = appName
        self.icon = icon
    }
}
