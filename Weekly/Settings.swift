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
        do {
            let readData = try Data(contentsOf: archivePath())
            self.settings = try JSONDecoder().decode(Settings.self, from: readData)
        } catch {
            reset()
        }
        needsDisplay = true
    }

    func archive() {
        let jsonData = try! JSONEncoder().encode(self.settings)
        try! jsonData.write(to: archivePath())
        needsDisplay = true
    }

    func archivePath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return URL(fileURLWithPath: paths[0].path + "/" + (Bundle.main.infoDictionary!["CFBundleName"] as! String) + ".cfg")
    }

    func reset() {
        settings.showLabel = false
        archive()
    }
}


