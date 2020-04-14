//
//  Settings.swift
//  Weekly
//
//  Created by Paul Wong on 4/13/20.
//  Copyright © 2020 Paul Wong. All rights reserved.
//

import Cocoa

class Settings: NSObject {

    struct Settings: Codable {
        // persistant
        var showLabel: Bool = false
    }

    var settings: Settings = Settings()
    var needsDisplay: Bool = false

    override init() {
        super.init()
        unarchive()
    }

    func unarchive() {
        let fileManager = FileManager()
        let jsonDecoder = JSONDecoder()
        if fileManager.fileExists(atPath: archivePath()) {
            let jsonData = NSKeyedUnarchiver.unarchiveObject(withFile: archivePath()) as! Data
            do {
                try settings = jsonDecoder.decode(Settings.self, from: jsonData)
            } catch {
                reset()
                settings = Settings()
            }
        } else {
            settings = Settings()
        }
        needsDisplay = true
    }

    func archive() {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(settings)
        NSKeyedArchiver.archiveRootObject(jsonData, toFile: archivePath())
        needsDisplay = true
    }

    func archivePath() -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].path + "/" + (Bundle.main.infoDictionary!["CFBundleName"] as! String) + ".cfg"
    }

    func reset() {
        settings.showLabel = false
        archive()
    }
}


