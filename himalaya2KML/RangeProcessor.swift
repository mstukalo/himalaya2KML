//
//  RangeProcessor.swift
//  himalaya2KML
//
//  Created by Mykola Stukalo on 14.02.16.
//  Copyright © 2016 Mykola Stukalo. All rights reserved.
//

import Foundation

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

protocol NamedEntity {
    var name: String {get set}
}

struct Point: NamedEntity {
    var name: String
    let height: Double
    let latitude: String
    let longitude: String
}

struct Range : NamedEntity {
    var name: String
    let description: String
    let points: [Point]
}

struct RangeGroup: NamedEntity {
    var name: String
    let description: String
    let ranges: [Range]
}

extension String {
    init(count: Int, repeatedCharacter: Character) {
        self.init(count: count, repeatedValue: repeatedCharacter)
    }
}

func printNamedEntityArray <S>(entities: [S], level: Int) {
    let optionalEntity = entities.first as? NamedEntity
    
    if let entity = optionalEntity {
        let name = String(count: level, repeatedCharacter:" ") + entity.name
        print(name)
        
        if let group = entity as? RangeGroup {
            printNamedEntityArray(group.ranges, level: level + 1)
            printNamedEntityArray(Array(entities.dropFirst()), level: level)
        }
        else if let range = entity as? Range {
            printNamedEntityArray(range.points, level: level + 1)
            printNamedEntityArray(Array(entities.dropFirst()), level: level)
        }
        else {
            printNamedEntityArray(Array(entities.dropFirst()), level: level)
        }
    }
}

func processGroupString(rangeGroupString: String) -> RangeGroup? {
    let separatedArray = rangeGroupString.componentsSeparatedByString("$")
    guard separatedArray.count == 2 else {
        print("Cannot separate range group string") ;return nil}
    
    let groupArray = separatedArray[0].trim().componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    guard groupArray.count == 2 else {print("Failed to parse group data"); return nil}
    
    let groupName = groupArray[0]
    let groupDescription = groupArray[1]
    let ranges = processRangesString(separatedArray[1])
    
    return RangeGroup(name: groupName, description: groupDescription, ranges: ranges)
}

func processRangesString(rangesString: String) -> [Range] {
    var resultingArray: [Range] = []
    let rangesStringsArray = rangesString.componentsSeparatedByString("=")
    for rangeString in rangesStringsArray {
        if rangeString.isEmpty {
            continue
        }
        let range = processRange(rangeString.trim())
        if let range = range {
            resultingArray.append(range)
        }
        else
        {
            print("Failed to process range \(rangeString)");
        }
    }
    
    return resultingArray
}

func processRange(rangeString: String) -> Range? {
    let separatedArray = rangeString.componentsSeparatedByString("[")
    guard separatedArray.count == 2 else {return nil}
    
    
    let nameAndDescription = separatedArray[0].trim().componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    
    guard nameAndDescription.count == 2 else {print("Failed to process name and description \(nameAndDescription)"); return nil}
    
    let name = nameAndDescription[0].trim()
    let description = nameAndDescription[1].trim()
    
    let optionalPoints = processPoints(separatedArray[1])
    
    guard let points = optionalPoints else {print("Failes to process points string \(separatedArray[1])"); return nil}
    
    return Range(name:name, description: description, points: points)
}

func processPoints(pointsString: String) -> [Point]? {
    let separatedArray = pointsString.trim().componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    guard separatedArray.count > 0 else {return nil}
    
    var points: [Point] = []
    
    for pointString in separatedArray {
        if let point = processPointString(pointString) {
            points.append(point)
        }
        else
        {
            print("Failed to process point string \(pointString)")
            return nil
        }
    }
    
    return points
}

func processPointString(pointString: String) -> Point? {
    let separatedArray = pointString.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: String(Character(UnicodeScalar(0009))))) //tab
    
    guard separatedArray.count == 4 else {return nil}
    
    let name = separatedArray[0].trim()
    let optionalHeight = Double(separatedArray[1].trim())
    guard let height = optionalHeight else {print("Cannot convert to int \(separatedArray[1])"); return nil}
    let latitude = separatedArray[2].trim()
    let longitude = separatedArray[3].trim()
    
    return Point(name: name, height: height, latitude: latitude, longitude: longitude)
}