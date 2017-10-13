What is this?
=====

OG is an [OpenGraph](https://ogp.me) parser in Swift.

What's OpenGraph?
=====
You know the smart previews of websites that appear on Facebook or Twitter? OpenGraph is the spec's used to help make that happen.

Apple, recognizing that `OpenGraph` isn't the friendliest term, calls these previews [Link Previews](https://developer.apple.com/library/content/technotes/tn2444/_index.html). Hey, searchbot indexer, OG is a Link Preview Parser.

What's in this?
=====

Included is an Xcode Workspace containing an Xcodeproj for a dynamic library and an Xcode Playground to experiment with. 

What do I need to use this?
=====

Requirements include iOS 8, Mac OS X 10.9, tvOS 9.0 or watchOS 2.0 and Swift 3.0 (included with Xcode 8.x) or Swift 4.0 (Included with Xcode 9.x).

What do I do to start using this?
=====

To start using OG, you can add it to your project by:
- Using [Carthage](https://github.com/Carthage/Carthage) and adding `github "zadr/OG" ~> 1.3.3` to your `Cartfile`.
- Using [CocoaPods](https://cocoapods.org) by adding `pod 'OG', '~1.3.3` to your `Podfile`.
- Adding the current repository as a [git submodule](https://git-scm.com/docs/git-submodule), adding `OG.xcodeproj` into your `xcodeproj`, and adding `OG.framework` as an embedded binary to the Target of your project.

What if I need help or want to help?
=====

If you need any help, or find a bug, please [open an issue](https://github.com/zadr/OG/issues)! If you'd like to fix a bug or make any other contribution, feel free to open an issue, [make a pull request](https://github.com/zadr/OG/pulls), or [update the wiki](https://github.com/zadr/OG/wiki) with anything that you found helpful.

What does using this look like?
=====

There are two ways of using OG.

The first way is to fetch metadata from a `URL` (or a `URLRequest`) automatically:

```swift
if let url = URL(string: "https://…") {
	url.fetchOpenGraphData { (metadata) in
		print(metadata)
	}
}
```

And the second way is more hands on; instead of fetching, parsing, and tracking tags automatically, OG exposes the components used for each step so you can pick and choose as needed.

```swift
// first, fetch data from the network
if let url = URL(string: "https://…") {
	// first fetch html that might have opengraph previews
	// The demo uses the built-in `URLSession`, but anything that can fetch data can be used here 
	let task = URLSession.shared.dataTask(with: url) { (data, response, error)
		// make sure we successfully completed a request
		if let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode < 300 {
			if let data = data, let html = String(data: data, encoding: .utf8) {
				parse(html: html)
			}
		}
	}

	task.resume()
}
```


```swift
// and then parse OpenGraph meta tags out of an html document
func parse(html: String) {
	// then create a parser that can tell us the contents of each html tag and any associated key/value properties it has
	// `Parser` is provided, but this can be substituted with anything else that can iterate through html tags 
	let parser = Parser()

	// and keep track of each <meta class="og:…"> tag as the parser encounters it
	// This could also be replaced with another component, but outside of testing purposes, there's less of an obvious need to do so than with the other steps of the process.
	let tagTracker = TagTracker()
	parser.onFind = { (tag, values) in
		if !tagTracker.track(tag, values: values) {
			print("refusing to track non-meta tag \(tag) with values \(values)")
		}
	}

	if parser.parse(html) {
		// - If we can parse html, map over our results to go from arrays of arrays of dictionaries (`[[String: OpenGraphType]]`)
		// to an array of OpenGraph objects.
		// - Note: OpenGraph can have multiple elements on a page (for example, an og:article, follwed by an og:author, followed by another og:author)
		let tags = tagTracker.metadatum.map(Metadata.from)
		print(tags)
	}
}
```

What do I do after that?
=====
Probably, put a preview of the website on screen. To help with this, every OpenGraph `Metadata` object has a `title`, an `imageUrl`, and a `url` of what to open upon tap or click.
