import Foundation

let outputPath: NSString = "~/Documents/"
let optionalPath = NSBundle.mainBundle().pathForResource("himalaya", ofType: "txt")
guard let path = optionalPath else {print("Cannot find input file"); exit(0)}

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

let kmlOutput = convertEntitiesToKML(resultingArray).kml()

let URLToWrite = NSURL.fileURLWithPath(outputPath.stringByExpandingTildeInPath).URLByAppendingPathComponent("himalaya.kml")
do {
    try kmlOutput.writeToURL(URLToWrite, atomically: true, encoding: NSUTF8StringEncoding)
}
catch {
    print("Failed to write kml to file with error \(error)")
}

