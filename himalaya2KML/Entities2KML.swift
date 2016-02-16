//
//  Entities2KML.swift
//  himalaya2KML
//
//  Created by Mykola Stukalo on 14.02.16.
//  Copyright © 2016 Mykola Stukalo. All rights reserved.
//

import Foundation

let stylesDictionary = [
    5000 : ("mountain-5k-style", "https://github.com/mstukalo/himalaya2KML/blob/master/himalaya2KML/assets/images/mountain5k.png?raw=true"),
    6000 : ("mountain-6k-style", "https://github.com/mstukalo/himalaya2KML/blob/master/himalaya2KML/assets/images/mountain6k.png?raw=true"),
    7000 : ("mountain-7k-style", "https://github.com/mstukalo/himalaya2KML/blob/master/himalaya2KML/assets/images/mountain7k.png?raw=true"),
    8000 : ("mountain-8k-style", "https://github.com/mstukalo/himalaya2KML/blob/master/himalaya2KML/assets/images/mountain8k.png?raw=true")]


func convertEntitiesToKML(entities: [NamedEntity]) -> KMLRoot {
    let root = KMLRoot()
    let document = KMLDocument()
    root.feature = document
    
    document.open = true
    addIconStyles(document)
    
    for entity in entities {
        if let range = entity as? Range {
            document.addFeature(rangeToKMLFolder(range))
        }
        else if let group = entity as? RangeGroup {
            document.addFeature(groupToKMLFolder(group))
        }
    }
    
    return root
}

func addIconStyles(document: KMLDocument) {
    
    for styleTuple in stylesDictionary {
        let style = KMLStyle()
        style.objectID = styleTuple.1.0
        let iconStyle = KMLIconStyle()
        iconStyle.scale = 0.8
        let icon = KMLIcon()
        icon.href = styleTuple.1.1
        iconStyle.icon = icon
        
        style.iconStyle = iconStyle
        document.addStyleSelector(style)
    }
}

func groupToKMLFolder(group: RangeGroup) -> KMLFolder {
    let folder = KMLFolder()
    folder.name = group.name
    folder.descriptionValue = group.name + " " + group.description
    folder.snippet = " "
    folder.open = false
    
    for range in group.ranges {
        folder.addFeature(rangeToKMLFolder(range))
    }
    
    return folder
}

func rangeToKMLFolder(range: Range) -> KMLFolder {
    let folder = KMLFolder()
    folder.name = range.name
    folder.descriptionValue = range.name + " "  + range.description
    folder.snippet = " "
    folder.open = false
    
    for point in range.points {
        let placemark = KMLPlacemark()
        placemark.name = point.name

        var regularExpression: NSRegularExpression?
        do {
            try regularExpression = NSRegularExpression(pattern: "P\\d\\d\\d\\d", options: NSRegularExpressionOptions.CaseInsensitive)

        }
        catch {
            print("Failed to create regular expression with error \(error)")
        }
        
        if let regularExpression = regularExpression {
            if regularExpression.numberOfMatchesInString(point.name, options: NSMatchingOptions.Anchored, range: NSMakeRange(0, point.name.characters.count)) == 0 {
                    placemark.descriptionValue = String(Int(point.height)) + " meters"
            }
            
        }

        
        if (point.name.containsString("("))
        {
            let separatedArray = point.name.componentsSeparatedByString("(")
            guard separatedArray.count == 2 else {
                print("Failed to parse point description \(point.name)")
                exit(0)
            }
            
            if placemark.descriptionValue  != nil {
                placemark.descriptionValue = placemark.descriptionValue + ". " + separatedArray[1].stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ")"))
            }
            else {
                placemark.descriptionValue = separatedArray[1].stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ")"))
            }
            
            placemark.name = separatedArray[0]
        }
        
        let pointKML = KMLPoint()
        placemark.geometry = pointKML
        placemark.styleUrl = peakStyleForHeight(point.height)
        
        let coordinate = KMLCoordinate()
        coordinate.latitude = degMinSecStringToDecimalDegrees(point.latitude)
        coordinate.longitude = degMinSecStringToDecimalDegrees(point.longitude)
        coordinate.altitude = CGFloat(point.height)
        
        pointKML.coordinate = coordinate

        folder.addFeature(placemark)
    }
    
    return folder
}

func peakStyleForHeight(height: Double) -> String {
    
    if height > 8000  {return stylesDictionary[8000]!.0}
    if height > 7000  {return stylesDictionary[7000]!.0}
    if height > 6000  {return stylesDictionary[6000]!.0}

    return stylesDictionary[5000]!.0
}

func degMinSecStringToDecimalDegrees(degMinSecString: String) -> CGFloat {
    let separatedArray = degMinSecString.componentsSeparatedByString("°")
    
    guard separatedArray.count == 2 else {
        print("No degrees \(degMinSecString)"); exit(0)
    }
    
    let optionalDegrees = Double(separatedArray[0])
    guard let degrees = optionalDegrees else {
        print("No degrees 2 \(degMinSecString)"); exit(0)
    }
    
    let separatedArray2 = separatedArray[1].componentsSeparatedByString("\'")
    
    guard separatedArray.count == 2 else {
        print("No minutes \(degMinSecString)"); exit(0)
    }

    let optionalMinutes = Double(separatedArray2[0])
    guard let minutes = optionalMinutes else {
        print(separatedArray2)
        print("No minutes 2 \(degMinSecString)"); exit(0)
    }

    
    let optionalSeconds = Double(separatedArray2[1].stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\"")))
    guard let seconds = optionalSeconds else {
        print("No seconds 2 \(degMinSecString)"); exit(0)
    }
    
    let decimalDegrees = CGFloat(degrees + minutes / 60 + seconds / 3600)
    
    return decimalDegrees
}




