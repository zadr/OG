/**
	`TagTracker` is a container that can keep track of OpenGraph tags as they come in. In order to fully support OpenGraph,
	and support pages with multiple OpenGraph elements, `TagTracker` keeps track of things as an array of dictionaries.
*/
public final class TagTracker {
	/**
		The raw OpenGraph metadata found on a given page.
	
		for example, after tracking parsing of follwing html,

			<html prefix="og: http://ogp.me/ns#">
				<head>
					<title>The Rock (1996)</title>
					<meta property="og:title" content="The Rock" />
					<meta property="og:type" content="video.movie" />
					<meta property="og:url" content="http://www.imdb.com/title/tt0117500/" />
					<meta property="og:image" content="http://ia.media-imdb.com/images/rock.jpg" />
				</head>
			</html>

		`metadatum` will be
	
			[
				"og:title": "The Rock",
				"og:type": "video.movie",
				"og:url": "http://www.imdb.com/title/tt0117500/",
				"og:image": "http://ia.media-imdb.com/images/rock.jpg"
			]
	*/
	public fileprivate(set) lazy var metadatum: [[String: OpenGraphType]] = {
		var metadatum = [[String: OpenGraphType]]()
		metadatum.append([String: OpenGraphType]())
		return metadatum
	}()

	/**
	The designated initializer for `TagTracker`
	*/
	public init() {}

	/**
		Used to ask TagTracker to track a new tag.
	
		The same tag can be tracked multiple times, and will result in an array of values being tracked.

		- parameter tag: The tag to track
		- parameter values: any values associated with the tag

		For example, to track the following html

			<meta property="og:title" content="The Rock" />

		the `tag` parameter is `meta`, and the values are `["property": "og:title", "content": "The Rock"]`

		- returns: `true` if an OpenGraph meta tag with a property name and content was tracked, otherwise `false`
	*/
	public func track(_ tag: String, values: [String: String]) -> Bool {
		guard let tag = Tag(rawValue: tag), tag == .meta else {
			return false
		}

		var property: String? = nil
		var content: String? = nil

		for value in values {
			guard let pair = KeyValue(rawValue: value.0.lowercased()) else {
				continue
			}

			switch pair {
			case .property:
				property = value.1
			case .content:
				content = value.1
			}
		}

		var metadata = metadatum.popLast()!
		if let property = property, metadata[property] != nil && property == "og:type" {
			metadatum.append(metadata)
			metadata = [String: OpenGraphType]()
		}

		if let property = property, let content = content {
			if var existing = metadata[property] as? [OpenGraphType] {
				existing.append(property)
				metadata[property] = existing
			} else if let existing = metadata[property] {
				metadata[property] = [ existing, content ]
			} else {
				metadata[property] = content
			}
		}

		metadatum.append(metadata)

		return true
	}

	private enum Tag: RawRepresentable {
		typealias RawValue = String

		case head
		case meta

		init?(rawValue: RawValue) {
			switch rawValue.lowercased() {
			case "head": self = .head
			case "meta": self = .meta
			default: return nil
			}
		}

		var rawValue: RawValue {
			switch self {
			case .head: return "head"
			case .meta: return "meta"
			}
		}
	}

	private enum KeyValue: RawRepresentable {
		typealias RawValue = String

		case property
		case content

		init?(rawValue: RawValue) {
			switch rawValue.lowercased() {
			case "property": self = .property
			case "content": self = .content
			default: return nil
			}
		}

		var rawValue: RawValue {
			switch self {
			case .property: return "property"
			case .content: return "content"
			}
		}
	}
}
