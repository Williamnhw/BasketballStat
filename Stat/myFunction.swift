//
//  myFunction.swift
//  Stat
//
//  Created by William on 20/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import Foundation

func createDirectory(folderName: String) {
    let fm = FileManager.default
    let docsURL = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let newDir = docsURL.appendingPathComponent(folderName).path
    
    print(newDir)
    
    do {
        try fm.createDirectory(atPath: newDir,
                               withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
        print("Error: \(error.localizedDescription)")
    }
}
