public class Metadata: OGMetadata {
	public private(set) var title: String = ""
	public private(set) var imageUrl: String = ""
	public private(set) var url: String = ""

	public private(set) var audioUrl: String? = nil
	public private(set) var graphDescription: String? = nil
	public private(set) var determiner: Determiner? = nil
	public private(set) var locale: String? = nil
	public private(set) var alternateLocales: [String]? = nil
	public private(set) var siteName: String? = nil
	public private(set) var videoUrl: String? = nil

	public required init(values: [String: AnyObject]) {
		if let title = values["og:title"] as? String { self.title = title }
		if let imageUrl = values["og:image"] as? String { self.imageUrl = imageUrl }
		if let url = values["og:url"] as? String { self.url = url }

		if let audioUrl = values["og:audio"] as? String { self.audioUrl = audioUrl }
		if let graphDescription = values["og:description"] as? String { self.graphDescription = graphDescription }
		if let determiner = values["og:determiner"] as? String { self.determiner = Determiner(rawValue: determiner) }
		if let locale = values["og:locale:alternate"] as? String { self.locale = locale }
		if let alternateLocales = values["og:locale:alternate"] as? [String] { self.alternateLocales = alternateLocales }
		if let siteName = values["og:site_name"] as? String { self.siteName = siteName }
		if let videoUrl = values["og:video"] as? String { self.videoUrl = videoUrl }
	}

	public class func from(values: [String: AnyObject]) -> Metadata? {
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
		var description = "<\(unsafeAddressOf(self))> \(mirror!.subjectType): {"

		while mirror != nil {
			mirrors.insert(mirror!, atIndex: 0)
			mirror = mirror!.superclassMirror()
		}

		for i in 0 ..< mirrors.count {
			let mirror = mirrors[i]
			let tabsForLevel = String(repeating: Character("\t"), count: i + 1)

			description += mirror.children.flatMap {
				guard let key = $0.label else { return nil }
				return "\n \(tabsForLevel)\(key): \($0.value),"
			} .reduce("") { return $0 + $1 }

			description += "\n\(tabsForLevel)\(mirror.subjectType): {"
		}

		for i in mirrors.count.stride(to: 0, by: -1) {
			description += "\n\(String(repeating: Character("\t"), count: i))}"
		}

		return description + "\n}"
	}
}

// MARK: -

public class Media: Metadata, OGMedia {
	public private(set) var secureUrl: String? = nil
	public private(set) var mimeType: String? = nil
	public private(set) var width: Double? = nil
	public private(set) var height: Double? = nil
}

public final class Image: Media, OGImage {
	public static var type: String { return "og:image" }

	public required init(values: [String: AnyObject]) {
		super.init(values: values)

		self.secureUrl = values["og:image:secure_url"] as? String
		self.mimeType = values["og:image:type"] as? String

		if let width = values["og:image:width"] as? String {
			self.width = Double(width)
		}

		if let height = values["og:image:height"] as? String {
			self.height = Double(height)
		}
	}
}

// MARK: -

public class Music: Metadata, OGMusic {}
public final class Song: Music, OGSong {
	public private(set) var duration: Int? = nil
	public private(set) var album: [OGAlbum]? = nil
	public private(set) var disc: Int? = nil
	public private(set) var track: Int? = nil
	public private(set) var musician: OGProfile? = nil

	public required init(values: [String: AnyObject]) {
		super.init(values: values)

		if let duration = values["og:music:duration"] as? String { self.duration = Int(duration) }
		if let albums = values["og:music:album"] as? [[String: AnyObject]] { self.album = albums.map { return Album(values: $0) } }
		if let disc = values["og:music:album:disc"] as? String { self.disc = Int(disc) }
		if let track = values["og:music:track"] as? String { self.track = Int(track) }
		if let musician = values["og:music:musician"] as? [String: AnyObject] { self.musician = Profile(values: musician) }
	}
}

public final class Album: Music, OGAlbum {
	public private(set) var song: OGSong? = nil
	public private(set) var disc: Int? = nil
	public private(set) var track: Int? = nil
	public private(set) var musician: OGProfile? = nil
	public private(set) var releaseDate: DateTime? = nil

	public required init(values: [String: AnyObject]) {
		super.init(values: values)

		if let song = values["og:music:song"] as? [String: AnyObject] { self.song = Song(values: song) }
		if let disc = values["og:music:album:disc"] as? String { self.disc = Int(disc) }
		if let track = values["og:music:track"] as? String { self.track = Int(track) }
		if let musician = values["og:music:musician"] as? [String: AnyObject] { self.musician = Profile(values: musician) }
		if let releaseDate = values["og:music:release_date"] as? String { self.releaseDate = DateTime(value: releaseDate) }
	}
}

public final class Playlist: Music, OGPlaylist {
	public private(set) var song: OGSong? = nil
	public private(set) var disc: Int? = nil
	public private(set) var track: Int? = nil
	public private(set) var creator: OGProfile? = nil

	public required init(values: [String: AnyObject]) {
		super.init(values: values)

		if let song = values["og:music:song"] as? [String: AnyObject] { self.song = Song(values: song) }
		if let disc = values["og:music:album:disc"] as? String { self.disc = Int(disc) }
		if let track = values["og:music:track"] as? String { self.track = Int(track) }
		if let creator = values["og:music:creator"] as? [String: AnyObject] { self.creator = Profile(values: creator) }
	}
}

public final class RadioStation: Music, OGRadioStation {
	public private(set) var creator: OGProfile? = nil

	public required init(values: [String: AnyObject]) {
		super.init(values: values)

		if let creator = values["og:music:creator"] as? [String: AnyObject] { self.creator = Profile(values: creator) }
	}
}

// MARK: -

public class Video: Media {
	public private(set) var actor: [OGProfile]? = nil
	public private(set) var roles: [String]? = nil
	public private(set) var director: [OGProfile]? = nil
	public private(set) var writer: [OGProfile]? = nil
	public private(set) var duration: Int? = nil
	public private(set) var releaseDate: DateTime? = nil
	public private(set) var tag: [String]? = nil

	public required init(values: [String: AnyObject]) {
		super.init(values: values)

		if let actors = values["og:video:actor"] as? [[String: AnyObject]] { self.actor = actors.map { return Profile(values: $0) } }
		if let roles = values["og:video:actor:role"] as? [String] { self.roles = roles }
		if let directors = values["og:video:director"] as? [[String: AnyObject]] { self.director = directors.map { return Profile(values: $0) } }
		if let writers = values["og:video:writer"] as? [[String: AnyObject]] { self.writer = writers.map { return Profile(values: $0) } }
		if let duration = values["og:video:duration"] as? String { self.duration = Int(duration) }
		if let releaseDate = values["og:video:release_date"] as? String { self.releaseDate = DateTime(value: releaseDate) }
		if let tags = values["og:video:tag"] as? [String] { self.tag = tags }
	}
}

public final class Movie: Video, OGMovie {}
public final class TVShow: Video, OGTVShow {}
public final class OtherVideo: Video, OGOtherVideo {}
public final class Episode: Video, OGEpisode {
	public private(set) var series: OGTVShow? = nil

	public required init(values: [String: AnyObject]) {
		super.init(values: values)

		if let series = values["og:video:series"] as? [String: AnyObject] { self.series = TVShow(values: series) }
	}
}

// MARK: -

public final class Article: Metadata, OGArticle {
	public private(set) var publishedTime: DateTime? = nil
	public private(set) var modifiedTime: DateTime? = nil
	public private(set) var expirationTime: DateTime? = nil
	public private(set) var author: [OGProfile]? = nil
	public private(set) var section: String? = nil
	public private(set) var tag: [String]? = nil

	public required init(values: [String: AnyObject]) {
		super.init(values: values)

		if let publishedTime = values["og:article:published_time"] as? String { self.publishedTime = DateTime(value: publishedTime) }
		if let modifiedTime = values["og:article:modified_time"] as? String { self.modifiedTime = DateTime(value: modifiedTime) }
		if let expirationTime = values["og:article:expiration_time"] as? String { self.expirationTime = DateTime(value: expirationTime) }
		if let authors = values["og:article:author"] as? [[String: AnyObject]] { self.author = authors.map { return Profile(values: $0) } }
		if let section = values["og:article:section"] as? String { self.section = section }
		if let tags = values["og:article:tag"] as? [String] { self.tag = tags }
	}
}

public final class Book: Metadata, OGBook {
	public private(set) var author: [OGProfile]? = nil
	public private(set) var isbn: String? = nil
	public private(set) var releaseDate: DateTime? = nil
	public private(set) var tag: [String]? = nil

	public required init(values: [String: AnyObject]) {
		super.init(values: values)

		if let authors = values["og:book:author"] as? [[String: AnyObject]] { self.author = authors.map { return Profile(values: $0) } }
		if let isbn = values["og:book:isbn"] as? String { self.isbn = isbn }
		if let releaseDate = values["og:book:release_date"] as? String { self.releaseDate = DateTime(value: releaseDate) }
		if let tags = values["og:book:tag"] as? [String] { self.tag = tags }
	}
}

public final class Profile: Metadata, OGProfile {
	public private(set) var firstName: String? = nil
	public private(set) var lastName: String? = nil
	public private(set) var username: String? = nil
	public private(set) var gender: String? = nil

	public required init(values: [String: AnyObject]) {
		super.init(values: values)

		if let firstName = values["og:profile:first_name"] as? String { self.firstName = firstName }
		if let lastName = values["og:profile:last_name"] as? String { self.lastName = lastName }
		if let username = values["og:profile:username"] as? String { self.username = username }
		if let gender = values["og:profile:gender"] as? String { self.gender = gender }
	}
}

public struct DateTime {
	private enum DateTimeProperty {
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

			guard let character = current.characterAt(index: i) else { break }

			if String(character) == previousEnding {
				continue
			}

			if current.utf8.count == length {
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

public enum Determiner: RawRepresentable {
	public typealias RawValue = String

	case a
	case an
	case blank
	case the
	case quotes
	case auto

	public init?(rawValue: RawValue) {
		switch rawValue.lowercaseString {
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

