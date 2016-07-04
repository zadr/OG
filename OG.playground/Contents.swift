import OG

let testPath = NSBundle.mainBundle().pathForResource("demo", ofType: "html")!

let testHTML = try! NSString(contentsOfFile: testPath, encoding: NSUTF8StringEncoding) as String
print(testHTML)

var metadata = [String: AnyObject]()
let parser = Parser()
parser.onFind = { (tag, values) in
	if tag == "meta" {
		var property: String? = nil
		var content: AnyObject? = nil

		for value in values {
			switch value.0 {
			case "property": property = value.1 as? String
			case "content": content = value.1
			default: print("Unknown key \(value.0) with value \(value.1)")
			}
		}

		if let property = property, content = content {
			metadata[property] = content
		}
	}
}

let _ = parser.parse(testHTML)
if let tag = Metadata.from(metadata) {
	print(tag)
}
