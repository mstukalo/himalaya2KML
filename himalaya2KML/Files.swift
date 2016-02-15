//
//  Files.swift
//  himalaya2KML
//
//  Created by Mykola Stukalo on 14.02.16.
//  Copyright © 2016 Mykola Stukalo. All rights reserved.
//

import Foundation

func readFile(path:String) -> String?
{
    var fileContent: NSString?
    
    do {
        try fileContent = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
    }
    catch {
        print("Failed to read file at path \(path) with error \(error)")
        
        return nil
    }
    
    
    return String(fileContent!)
}