import OG

let testPath = NSBundle.mainBundle().pathForResource("demo", ofType: "html")!
let testHTML = try! NSString(contentsOfFile: testPath, encoding: NSUTF8StringEncoding) as String
print(testHTML)

let parser = Parser()
let tagTracker = TagTracker()
parser.onFind = { (tag, values) in
	if !tagTracker.track(tag, values: values) {
		print("refusing to track non-meta tag \(tag) with values \(values)")
	}
}

let success = parser.parse(testHTML)
if success {
	let tags = tagTracker.metadatum.flatMap(Metadata.from)
	print(tags)
} else {
	print("parsing succeeded: \(success), unable to convert metadata \(tagTracker.metadatum) to OpenGraph object")
}
