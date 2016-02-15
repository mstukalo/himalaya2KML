//
//  Entities2KML.swift
//  himalaya2KML
//
//  Created by Mykola Stukalo on 14.02.16.
//  Copyright © 2016 Mykola Stukalo. All rights reserved.
//

import Foundation

func convertEntitiesToKML(entities: [NamedEntity]) -> KMLRoot {
    let root = KMLRoot()
    let document = KMLDocument()
    root.feature = document
    
    let style = KMLStyle()
    style.objectID = "local-mountain-style"

    let iconStyle = KMLIconStyle()
    iconStyle.scale = 0.8
    iconStyle.color = "0xff0CD7F2"
    let icon = KMLIcon()
    icon.href = "http://maps.google.com/mapfiles/kml/shapes/mountains.png"
    iconStyle.icon = icon
    
    style.iconStyle = iconStyle
    document.addStyleSelector(style)
    
    
    document.atomAuthor = "Mykola Stukalo"
    document.open = true
    
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
        
        if (point.name.containsString("("))
        {
            let separatedArray = point.name.componentsSeparatedByString("(")
            guard separatedArray.count == 2 else {
                print("Failed to parse point description \(point.name)")
                exit(0)
            }
            placemark.descriptionValue = separatedArray[1].stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ")"))
            placemark.name = separatedArray[0]
        }
        
        let pointKML = KMLPoint()
        placemark.geometry = pointKML
        placemark.styleUrl = "#local-mountain-style"
        
        let coordinate = KMLCoordinate()
        coordinate.latitude = degMinSecStringToDecimalDegrees(point.latitude)
        coordinate.longitude = degMinSecStringToDecimalDegrees(point.longitude)
        coordinate.altitude = CGFloat(point.height)
        
        pointKML.coordinate = coordinate

        folder.addFeature(placemark)
    }
    
    return folder
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




