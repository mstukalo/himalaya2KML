import Foundation

let basePath = "/Users/mykolastukalo/Documents/outdoor/himalaya/txt/"
let path = basePath + "109_carter_himalaya_aaj1985.txt"

let fileContent = readFile(path)

guard let fileContent = fileContent else {exit(0)}

let separatedArray = fileContent.componentsSeparatedByString("#")

var resultingArray: [NamedEntity] = []

for string in separatedArray {
    let trimmedString = string.trim()
    
    if string.containsString("$") { //it is group of ranges
        let group = processGroupString(trimmedString)
        if let group = group {
            resultingArray.append(group)
        }
        else
        {
            print("Failed to process group \(trimmedString)");
        }
    }
    else //it is a range outside any group
    {
        let rangesArray = processRangesString(trimmedString)
        for range in rangesArray {
            resultingArray.append(range)
        }
    }
}

//printNamedEntityArray(resultingArray, level: 1)

let kmlOutput = convertEntitiesToKML(resultingArray).kml()

do {
    try kmlOutput.writeToFile(basePath + "himalaya.kml", atomically: true, encoding: NSUTF8StringEncoding)
}
catch {
    print("Failed to write kml to file with error \(error)")
}

