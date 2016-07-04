public enum Determiner: RawRepresentable {
	public typealias RawValue = String

	case a
	case an
	case blank
	case the
	case quotes
	case auto

	public init?(rawValue: RawValue) {
		switch rawValue {
		case "a": self = .a
		case "an": self = .an
		case "": self = .blank
		case "the": self = .the
		case "\"": self = .quotes
		case "'": self = .quotes
		case "‘": self = .quotes
		case "’": self = .quotes
		case "“": self = .quotes
		case "”": self = .quotes
		case "auto": self = .auto
		default: return nil
		}
	}

	public var rawValue: RawValue {
		switch self {
		case a: return "a"
		case an: return "an"
		case blank: return ""
		case the: return "the"
		case quotes: return "\""
		case auto: return "auto"
		}
	}
}

// MARK: -

public protocol OpenGraphType {}
extension Bool: OpenGraphType {}
extension DateTime: OpenGraphType {}
extension Double: OpenGraphType {}
extension Int: OpenGraphType {}
extension String: OpenGraphType {}
extension Array: OpenGraphType {}

// MARK: -

public protocol OGMetadata {
	init(values: [String: AnyObject])

	var title: String { get }
	var imageUrl: String { get }
	var url: String { get }

	var audioUrl: String? { get }
	var graphDescription: String? { get }
	var determiner: Determiner? { get }
	var locale: String? { get }
	var alternateLocales: [String]? { get }
	var siteName: String? { get }
	var videoUrl: String? { get }
}

// MARK: -

public protocol OGMedia: OGMetadata {
	var secureUrl: String? { get }
	var mimeType: String? { get }
	var width: Double? { get }
	var height: Double? { get }
}

public protocol OGImage: OGMedia {}

// MARK: -

public protocol OGMusic: OGMetadata {}
public protocol OGSong: OGMusic {
	var duration: Int? { get }
	var album: [OGAlbum]? { get }
	var disc: Int? { get }
	var track: Int? { get }
	var musician: OGProfile? { get }
}

public protocol OGAlbum: OGMusic {
	var song: OGSong? { get }
	var disc: Int? { get }
	var track: Int? { get }
	var musician: OGProfile? { get }
	var releaseDate: DateTime? { get }
}

public protocol OGPlaylist: OGMusic {
	var song: OGSong? { get }
	var disc: Int? { get }
	var track: Int? { get }
	var creator: OGProfile? { get }
}

public protocol OGRadioStation: OGMusic {
	var creator: OGProfile? { get }
}

// MARK: -

public protocol OGVideo: OGMetadata {
	var actor: [OGProfile]? { get }
	var roles: [String]? { get }
	var director: [OGProfile]? { get }
	var writer: [OGProfile]? { get }
	var duration: Int? { get }
	var releaseDate: DateTime? { get }
	var tag: [String]? { get }
}
public protocol OGMovie: OGVideo {}
public protocol OGTVShow: OGVideo {}
public protocol OGOtherVideo: OGVideo {}
public protocol OGEpisode: OGVideo {
	var series: OGTVShow? { get }
}

// MARK: -

public protocol OGArticle: OGMetadata {
	var publishedTime: DateTime? { get }
	var modifiedTime: DateTime? { get }
	var expirationTime: DateTime? { get }
	var author: [OGProfile]? { get }
	var section: String? { get }
	var tag: [String]? { get }
}

public protocol OGBook: OGMetadata {
	var author: [OGProfile]? { get }
	var isbn: String? { get }
	var releaseDate: DateTime? { get }
	var tag: [String]? { get }
}

public protocol OGProfile: OGMetadata {
	var firstName: String? { get }
	var lastName: String? { get }
	var username: String? { get }
	var gender: String? { get } // spec says this is an enum, but, nope to that
}
