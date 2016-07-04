import OG

let testPath = NSBundle.mainBundle().pathForResource("demo", ofType: "html")!

let testHTML = try! NSString(contentsOfFile: testPath, encoding: NSUTF8StringEncoding) as String
print(testHTML)

let parser = Parser()
let metaTagTracker = MetaTagTracker()
parser.onFind = { (tag, values) in
	if !metaTagTracker.track(tag, values: values) {
		print("refusing to track non-meta tag \(tag) with values \(values)")
	} else {
		print("found \(tag) \(values)")
	}
}

let success = parser.parse(testHTML)
if success, let tag = Metadata.from(metaTagTracker.metadata) {
	print(tag)
} else {
	print("parsing succeeded: \(success), unable to convert metadata \(metaTagTracker.metadata) to OpenGraph object")
}
