What is this?
=====

OG is an [OpenGraph](https://ogp.me) parser in Swift.

What's OpenGraph?
=====
You know the smart previews of websites that appear on Facebook or Twitter? OpenGraph is the spec's used to help make that happen.

What's in this?
=====

Included is an Xcode Workspace containing an Xcodeproj for a dynamic library and an Xcode Playground to experiment with. 

What do I need to use this?
=====

Requirements include iOS 8, Mac OS X 10.9, tvOS 9.0 or watchOS 2.0 and Swift 2.2 (included with Xcode 7.3.x).

What do I do to start using this?
=====

To start using OG, you can add it to your project by:
- Using [Carthage](https://github.com/Carthage/Carthage) and adding `github "zadr/OG" ~> 1.0` to your `Cartfile`.
- Using [CocoaPods](https://cocoapods.org) by adding `pod 'OG', '~1.0` to your `Podfile`.
- Adding the current repository as a [git submodule](https://git-scm.com/docs/git-submodule), adding `OG.xcodeproj` into your `xcodeproj`, and adding `OG.framework` as an embedded binary to the Target of your project.

What if I need help or want to help?
=====

If you need any help, or find a bug, please [open an issue](https://github.com/zadr/OG/issues)! If you'd like to fix a bug or make any other contribution, feel free to open an issue, [make a pull request](https://github.com/zadr/OG/pulls), or [update the wiki](https://github.com/zadr/OG/wiki) with anything that you found helpful.

What does using this look like?
=====

There are two steps to take:

`1.` Parse `<meta>` tags out of html, keeping track of any relevant OpenGraph meta tags. To help with this, `OG` provides a barebones parser:

```swift
let parser = Parser()
let metaTagTracker = MetaTagTracker()
parser.onFind = { (tag, values) in
	if !metaTagTracker.track(tag, values: values) {
		print("refusing to track non-meta tag \(tag) with values \(values)")
	}
}

let success = parser.parse(html)
```

`2.` Turn a dictionary of attributes into an OpenGraph metadata object:

```swift
if success, let tag = Metadata.from(metaTagTracker.metadata) {
	print(tag)
}
```

What do I do after that?
=====
Probably, put a preview of the website on screen. To help with this, every OpenGraph `Metadata` object has a `title`, an `imageUrl`, and a `url` of what to open upon tap or click.
