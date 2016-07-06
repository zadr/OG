public protocol TagTracking {
	init()

	var metadatum: [[String: OpenGraphType]] { get }

	func track(tag: String, values: [String: String]) -> Bool
}

public final class TagTracker {
	public private(set) lazy var metadatum: [[String: OpenGraphType]] = {
		var metadatum = [[String: OpenGraphType]]()
		metadatum.append([String: OpenGraphType]())
		return metadatum
	}()


	public init() {}

	public func track(tag: String, values: [String: String]) -> Bool {
		guard let tag = Tag(rawValue: tag) where tag == .meta else {
			return false
		}

		var property: String? = nil
		var content: String? = nil

		for value in values {
			guard let pair = KeyValue(rawValue: value.0.lowercaseString) else {
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
		if let property = property where metadata[property] != nil && property == "og:type" {
			metadatum.append(metadata)
			metadata = [String: OpenGraphType]()
		}

		if let property = property, content = content {
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
}

// MARK: -

private enum Tag: RawRepresentable {
	typealias RawValue = String

	case head
	case meta

	init?(rawValue: RawValue) {
		switch rawValue.lowercaseString {
		case "head": self = .head
		case "meta": self = .meta
		default: return nil
		}
	}

	var rawValue: RawValue {
		switch self {
		case head: return "head"
		case meta: return "meta"
		}
	}
}

private enum KeyValue: RawRepresentable {
	typealias RawValue = String

	case property
	case content

	init?(rawValue: RawValue) {
		switch rawValue.lowercaseString {
		case "property": self = .property
		case "content": self = .content
		default: return nil
		}
	}

	var rawValue: RawValue {
		switch self {
		case property: return "property"
		case content: return "content"
		}
	}
}
