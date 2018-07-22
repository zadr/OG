public class Metadata: OGMetadata {
	public fileprivate(set) var title: String = ""
	public fileprivate(set) var imageUrl: String = ""
	public fileprivate(set) var url: String = ""

	public fileprivate(set) var audioUrl: String? = nil
	public fileprivate(set) var graphDescription: String? = nil
	public fileprivate(set) var determiner: Determiner? = nil
	public fileprivate(set) var localeString: String? = nil
	public fileprivate(set) var alternateLocaleStrings: [String]? = nil
	public fileprivate(set) var siteName: String? = nil
	public fileprivate(set) var videoUrl: String? = nil

	public fileprivate(set) var rawData: [String: OpenGraphType]

	/**
		The designated initializer for OpenGraph metadata types.

		Direct usage of this is discouraged; `Metadata.from(_:)` will switch over any `og:type` and create the right class automatically.

	- parameter values: a dictionary of OpenGraph data
	*/
	public required init(values: [String: OpenGraphType]) {
		rawData = values

		if let title = values["og:title"] as? String { self.title = title }
		if let imageUrl = values["og:image"] as? String { self.imageUrl = imageUrl }
		if let url = values["og:url"] as? String { self.url = url }

		if let audioUrl = values["og:audio"] as? String { self.audioUrl = audioUrl }
		if let graphDescription = values["og:description"] as? String { self.graphDescription = graphDescription }
		if let determiner = values["og:determiner"] as? String { self.determiner = Determiner(rawValue: determiner) }
		if let locale = values["og:locale:alternate"] as? String { self.localeString = locale }
		if let alternateLocales = values["og:locale:alternate"] as? [String] { self.alternateLocaleStrings = alternateLocales }
		if let siteName = values["og:site_name"] as? String { self.siteName = siteName }
		if let videoUrl = values["og:video"] as? String { self.videoUrl = videoUrl }
	}

	/**
		A class function to create an `OpenGraph` class for any supported OpenGraph type of object.

		- parameter values: a dictionary of OpenGraph data
		- returns: `nil` if `og:type` isn't specified in the `values` dictionary, otherwise an OpenGraph object type
	*/
	public class func from(_ values: [String: OpenGraphType]) -> Metadata? {
		guard let type = values["og:type"] as? String else { return nil }

		switch type {
		case "music.song": return Song(values: values)
		case "music.album": return Album(values: values)
		case "music.playlist": return Playlist(values: values)
		case "music.radio_station": return RadioStation(values: values)
		case "video.movie": return Movie(values: values)
		case "video.episode": return Episode(values: values)
		case "video.tv_show": return TVShow(values: values)
		case "video.other": return OtherVideo(values: values)
		case "article": return Article(values: values)
		case "book": return Book(values: values)
		case "profile": return Profile(values: values)
		default: return Metadata(values: values)
		}
	}
}

extension Metadata: CustomStringConvertible {
	public var description: String {
		var mirrors = [Mirror]()
		var mirror: Mirror? = Mirror(reflecting: self)
		var description = "<\(Unmanaged.passUnretained(self).toOpaque())> \(mirror!.subjectType): {"

		while mirror != nil {
			mirrors.insert(mirror!, at: 0)
			mirror = mirror!.superclassMirror
		}

		for i in 0 ..< mirrors.count {
			let mirror = mirrors[i]
			let tabsForLevel = String(repeating: "\t", count: i + 1)

			description += mirror.children.compactMap {
				guard let key = $0.label else { return nil }
				return "\n \(tabsForLevel)\(key): \($0.value),"
			} .reduce("") { return $0 + $1 }

			description += "\n\(tabsForLevel)\(mirror.subjectType): {"
		}

		for i in stride(from: mirrors.count, to: 0, by: -1) {
			description += "\n\(String(repeating: "\t", count: i))}"
		}

		return description + "\n}"
	}
}

// MARK: -

public class Media: Metadata, OGMedia {
	public fileprivate(set) var secureUrl: String? = nil
	public fileprivate(set) var mimeType: String? = nil
}

public class VisualMedia: Media, OGVisualMedia {
	public fileprivate(set) var width: Double? = nil
	public fileprivate(set) var height: Double? = nil
}

// MARK: -

public final class Image: VisualMedia, OGImage {
	public required init(values: [String: OpenGraphType]) {
		super.init(values: values)

		if let url = values["og:image"] as? String { self.url = url }
		if let url = values["og:image:url"] as? String { self.url = url }

		self.secureUrl = values["og:image:secure_url"] as? String
		self.mimeType = values["og:image:type"] as? String

		if let width = values["og:image:width"] as? String { self.width = Double(width) }
		if let height = values["og:image:height"] as? String { self.height = Double(height) }
	}
}

// MARK: -

public class Music: Media, OGMusic {
	public required init(values: [String: OpenGraphType]) {
		super.init(values: values)

		if let url = values["og:audio"] as? String { self.url = url }
		if let url = values["og:audio:url"] as? String { self.url = url }
		if let secureUrl = values["og:audio:secure_url"] as? String { self.secureUrl = secureUrl }
		if let mimeType = values["og:audio:type"] as? String { self.mimeType = mimeType }
	}
}

public final class Song: Music, OGSong {
	public fileprivate(set) var duration: Int? = nil
	public fileprivate(set) var album: [OGAlbum]? = nil
	public fileprivate(set) var disc: Int? = nil
	public fileprivate(set) var track: Int? = nil
	public fileprivate(set) var musician: [OGProfile]? = nil

	public required init(values: [String: OpenGraphType]) {
		super.init(values: values)

		if let duration = values["og:music:duration"] as? String { self.duration = Int(duration) }
		if let albums = values["og:music:album"] as? [[String: OpenGraphType]] { self.album = albums.map { return Album(values: $0) } }
		if let disc = values["og:music:album:disc"] as? String { self.disc = Int(disc) }
		if let track = values["og:music:track"] as? String { self.track = Int(track) }
		if let musician = values["og:music:musician"] as? [[String: OpenGraphType]] { self.musician = musician.map { return Profile(values: $0) } }
		else if let musician = values["og:music:musician"] as? [String: OpenGraphType] { self.musician = [ Profile(values: musician) ] }
	}
}

public final class Album: Music, OGAlbum {
	public fileprivate(set) var song: OGSong? = nil
	public fileprivate(set) var disc: Int? = nil
	public fileprivate(set) var track: Int? = nil
	public fileprivate(set) var musician: [OGProfile]? = nil
	public fileprivate(set) var releaseDate: DateTime? = nil

	public required init(values: [String: OpenGraphType]) {
		super.init(values: values)

		if let song = values["og:music:song"] as? [String: OpenGraphType] { self.song = Song(values: song) }
		if let disc = values["og:music:album:disc"] as? String { self.disc = Int(disc) }
		if let track = values["og:music:track"] as? String { self.track = Int(track) }
		if let musician = values["og:music:musician"] as? [[String: OpenGraphType]] { self.musician = musician.map { return Profile(values: $0) } }
		else if let musician = values["og:music:musician"] as? [String: OpenGraphType] { self.musician = [ Profile(values: musician) ] }
		if let releaseDate = values["og:music:release_date"] as? String { self.releaseDate = DateTime(value: releaseDate) }
	}
}

public final class Playlist: Music, OGPlaylist {
	public fileprivate(set) var song: [OGSong]? = nil
	public fileprivate(set) var disc: Int? = nil
	public fileprivate(set) var track: Int? = nil
	public fileprivate(set) var creator: [OGProfile]? = nil

	public required init(values: [String: OpenGraphType]) {
		super.init(values: values)

		if let song = values["og:music:song"] as? [[String: OpenGraphType]] { self.song = song.map { return Song(values: $0) } }
		if let disc = values["og:music:album:disc"] as? String { self.disc = Int(disc) }
		if let track = values["og:music:track"] as? String { self.track = Int(track) }
		if let creator = values["og:music:creator"] as? [[String: OpenGraphType]] { self.creator = creator.map { return Profile(values: $0) } }
		else if let creator = values["og:music:creator"] as? [String: OpenGraphType] { self.creator = [ Profile(values: creator) ] }
	}
}

public final class RadioStation: Music, OGRadioStation {
	public fileprivate(set) var creator: [OGProfile]? = nil

	public required init(values: [String: OpenGraphType]) {
		super.init(values: values)

		if let creator = values["og:music:creator"] as? [[String: OpenGraphType]] { self.creator = creator.map { return Profile(values: $0) } }
		else if let creator = values["og:music:creator"] as? [String: OpenGraphType] { self.creator = [ Profile(values: creator) ] }
	}
}

// MARK: -

public class Video: VisualMedia {
	public fileprivate(set) var actor: [OGProfile]? = nil
	public fileprivate(set) var roles: [String]? = nil
	public fileprivate(set) var director: [OGProfile]? = nil
	public fileprivate(set) var writer: [OGProfile]? = nil
	public fileprivate(set) var duration: Int? = nil
	public fileprivate(set) var releaseDate: DateTime? = nil
	public fileprivate(set) var tag: [String]? = nil

	public required init(values: [String: OpenGraphType]) {
		super.init(values: values)

		if let url = values["og:video"] as? String { self.url = url }
		if let url = values["og:video:url"] as? String { self.url = url }
		if let secureUrl = values["og:video:secure_url"] as? String { self.secureUrl = secureUrl }
		if let mimeType = values["og:video:type"] as? String { self.mimeType = mimeType }
		if let width = values["og:video:width"] as? String { self.width = Double(width) }
		if let height = values["og:video:height"] as? String { self.height = Double(height) }

		if let actors = values["og:video:actor"] as? [[String: OpenGraphType]] { self.actor = actors.map { return Profile(values: $0) } }
		if let roles = values["og:video:actor:role"] as? [String] { self.roles = roles }
		if let directors = values["og:video:director"] as? [[String: OpenGraphType]] { self.director = directors.map { return Profile(values: $0) } }
		if let writers = values["og:video:writer"] as? [[String: OpenGraphType]] { self.writer = writers.map { return Profile(values: $0) } }
		if let duration = values["og:video:duration"] as? String { self.duration = Int(duration) }
		if let releaseDate = values["og:video:release_date"] as? String { self.releaseDate = DateTime(value: releaseDate) }
		if let tags = values["og:video:tag"] as? [String] { self.tag = tags }
	}
}

public final class Movie: Video, OGMovie {}
public final class TVShow: Video, OGTVShow {}
public final class OtherVideo: Video, OGOtherVideo {}
public final class Episode: Video, OGEpisode {
	public fileprivate(set) var series: OGTVShow? = nil

	public required init(values: [String: OpenGraphType]) {
		super.init(values: values)

		if let series = values["og:video:series"] as? [String: OpenGraphType] { self.series = TVShow(values: series) }
	}
}

// MARK: -

public final class Article: Metadata, OGArticle {
	public fileprivate(set) var publishedTime: DateTime? = nil
	public fileprivate(set) var modifiedTime: DateTime? = nil
	public fileprivate(set) var expirationTime: DateTime? = nil
	public fileprivate(set) var author: [OGProfile]? = nil
	public fileprivate(set) var section: String? = nil
	public fileprivate(set) var tag: [String]? = nil

	public required init(values: [String: OpenGraphType]) {
		super.init(values: values)

		if let publishedTime = values["og:article:published_time"] as? String { self.publishedTime = DateTime(value: publishedTime) }
		if let modifiedTime = values["og:article:modified_time"] as? String { self.modifiedTime = DateTime(value: modifiedTime) }
		if let expirationTime = values["og:article:expiration_time"] as? String { self.expirationTime = DateTime(value: expirationTime) }
		if let authors = values["og:article:author"] as? [[String: OpenGraphType]] { self.author = authors.map { return Profile(values: $0) } }
		if let section = values["og:article:section"] as? String { self.section = section }
		if let tags = values["og:article:tag"] as? [String] { self.tag = tags }
	}
}

public final class Book: Metadata, OGBook {
	public fileprivate(set) var author: [OGProfile]? = nil
	public fileprivate(set) var isbn: String? = nil
	public fileprivate(set) var releaseDate: DateTime? = nil
	public fileprivate(set) var tag: [String]? = nil

	public required init(values: [String: OpenGraphType]) {
		super.init(values: values)

		if let authors = values["og:book:author"] as? [[String: OpenGraphType]] { self.author = authors.map { return Profile(values: $0) } }
		if let isbn = values["og:book:isbn"] as? String { self.isbn = isbn }
		if let releaseDate = values["og:book:release_date"] as? String { self.releaseDate = DateTime(value: releaseDate) }
		if let tags = values["og:book:tag"] as? [String] { self.tag = tags }
	}
}

public final class Profile: Metadata, OGProfile {
	public fileprivate(set) var firstName: String? = nil
	public fileprivate(set) var lastName: String? = nil
	public fileprivate(set) var username: String? = nil
	public fileprivate(set) var gender: String? = nil

	public required init(values: [String: OpenGraphType]) {
		super.init(values: values)

		if let firstName = values["og:profile:first_name"] as? String { self.firstName = firstName }
		if let lastName = values["og:profile:last_name"] as? String { self.lastName = lastName }
		if let username = values["og:profile:username"] as? String { self.username = username }
		if let gender = values["og:profile:gender"] as? String { self.gender = gender }
	}
}

/// A DateTime represents a temporal value composed of a date (year, month, day) and an optional time component (hours, minutes)
public struct DateTime {
	fileprivate enum DateTimeProperty {
		case year
		case month
		case day
		case hours
		case minutes
	}

	var year: Int
	var month: Int
	var day: Int

	var hours: Int?
	var minutes: Int?

	/**
		Create a `DateTime` object for a given temporal value.

		- parameter value: An ISO8601-formatted string to be parsed into a date.
	*/
	init(value: String) {
		var year: Int? = nil
		var month: Int? = nil
		var day: Int? = nil

		var current = ""
		var property = DateTimeProperty.year
		for i in 0 ..< current.utf8.count {
			var previousEnding: String? = nil
			var length: Int = 0

			switch property {
			case .year:
				previousEnding = ""
				length = 4
			case .month:
				previousEnding = "-"
				length = 2
			case .day:
				previousEnding = "-"
				length = 2
			case .hours:
				previousEnding = "T"
				length = 2
			case .minutes:
				previousEnding = ":"
				length = 2
			}


			let characterStart = current.index(current.startIndex, offsetBy: i)
			let character = String(current[characterStart ..< current.index(after: characterStart)])

			if character == previousEnding {
				continue
			}

			if current.count == length {
				switch property {
				case .year:
					year = Int(current)!
					property = .month
				case .month:
					month = Int(current)!
					property = .day
				case .day:
					day = Int(current)!
					property = .hours
				case .hours:
					self.hours = Int(current)
					property = .minutes
				case .minutes:
					self.minutes = Int(current)
				}
			} else {
				current.append(character)
			}
		}

		self.year = year!
		self.month = month!
		self.day = day!
	}
}

// MARK: -

/// The word that appears before this object's title in a sentence. An enum of (a, an, the, "", auto). If auto is chosen, the consumer of your data should chose between "a" or "an". Default is "" (blank).
public enum Determiner: RawRepresentable {
	public typealias RawValue = String

	case a
	case an
	case blank
	case the
	case quotes
	case auto

	public init?(rawValue: RawValue) {
		switch rawValue.lowercased() {
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
		case .a: return "a"
		case .an: return "an"
		case .blank: return ""
		case .the: return "the"
		case .quotes: return "\""
		case .auto: return "auto"
		}
	}
}
