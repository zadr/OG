/*
	- Property documentation (largely) copied from the OpenGraph Protocol spec, found at http://opengraphprotocol.org
	Which is licensed under the Open Web Foundation Agreement, Version 0.9, http://www.openwebfoundation.org/legal/the-0-9-agreements---necessary-claims/cla-copyright-grant-09-deed
	On May 14, 2017

	- There are some differences in data`OG` accepts vs what is specified in the OpenGraph protocol, however they all serve to expand on what the OpenGraph spec allows, rather than restrict.
	- All changes are released under the same license as the OpenGraph protocol
	- The things that were changed in OG's implementation vs the OpenGraph specification are:
		1. `title`, `image` and `url` are considered required elements in the spec, their absence will not cause a parse failure
		2. Some names were changed to be in line with the standard Cocoa convention found on iOS and macOS. For example, `image` is called `imageUrl`.
		3. Some values (`musician` and `creator`) are arrays of Profile objects, rather than a singular Profile object. OG will still accept single Profile objects when encountered during parsing.
		4. Profile.gender values are not tracked as closed enum (per the spec) and are instead treated as `String?` that may or may not exist, and may be set to any value.
*/

/// An empty protocol that's used to show that a type can be represented in OpenGraph form
public protocol OpenGraphType {}
extension Bool: OpenGraphType {}
extension DateTime: OpenGraphType {}
extension Double: OpenGraphType {}
extension Int: OpenGraphType {}
extension String: OpenGraphType {}

// `Array` shouldn't be an `OpenGraphType` but is currently needed as an implementation detail of TagTracker
extension Array: OpenGraphType {}

// MARK: -

/// Basic metadata that is common to every type that can be represented in OpenGraph form
public protocol OGMetadata {
	init(values: [String: OpenGraphType])

	/// The title of your object as it should appear within the graph, e.g., "The Rock". Required in OpenGraph spec but treated as an optional value.
	var title: String { get }

	/// An image URL which should represent your object within the graph. This has been renamed from `image` in the OpenGraph spec to better fit Cocoa idioms. Required in OpenGraph spec but treated as an optional value.
	var imageUrl: String { get }

	/// The canonical URL of your object that will be used as its permanent ID in the graph, e.g., "http://www.imdb.com/title/tt0117500/". Required in OpenGraph spec but treated as an optional value.
	var url: String { get }

	/// A URL to an audio file to accompany this object. This has been renamed from `audio` in the OpenGraph spec to better fit Cocoa idioms.
	var audioUrl: String? { get }

	/// A one to two sentence description of your object. This has been renamed from `description` in the OpenGraph spec to allow for objc compatibility.
	var graphDescription: String? { get }

	/// The word that appears before this object's title in a sentence. An enum of (a, an, the, "", auto). If auto is chosen, the consumer of your data should chose between "a" or "an". Default is "" (blank).
	var determiner: Determiner? { get }

	/// The locale these tags are marked up in. Of the format language_TERRITORY. Default is en_US. This has been renamed from `locale` in the OpenGraph spec to better fit Cocoa idioms.
	var localeString: String? { get }

	/// An array of other locales this page is available in. This has been renamed from `alternateLocales` in the OpenGraph spec to better fit Cocoa idioms.
	var alternateLocaleStrings: [String]? { get }

	/// If your object is part of a larger web site, the name which should be displayed for the overall site. e.g., "IMDb".
	var siteName: String? { get }

	/// A URL to a video file that complements this object. This has been renamed from `video` in the OpenGraph spec to better fit Cocoa idioms.
	var videoUrl: String? { get }
}

// MARK: -

/// Extended metadata that may exist for any kind of multimedia
public protocol OGMedia: OGMetadata {
	/// An alternate url to use if the webpage requires HTTPS.
	var secureUrl: String? { get }

	/// A MIME type for this image.
	var mimeType: String? { get }
}

/// Extended metadata that may exist for any kind of multimedia that is visually rendered (for example, an image or a movie).
public protocol OGVisualMedia: OGMedia {
	/// The number of pixels wide.
	var width: Double? { get }

	/// The number of pixels high.
	var height: Double? { get }
}

/// An empty protocol for images
public protocol OGImage: OGVisualMedia {}

// MARK: -

/// An empty protocol to serve as a base for any audio metadata
public protocol OGMusic: OGMedia {}

/// A song on an album or in a playlist
public protocol OGSong: OGMusic {
	/// >=1 - The song's length in seconds.
	var duration: Int? { get }

	/// The album this song is from. A song can belong to multiple albums.
	var album: [OGAlbum]? { get }

	/// >=1 - Which disc of the album this song is on.
	var disc: Int? { get }

	/// >=1 - Which track this song is.
	var track: Int? { get }

	///  The musician that made this song. Multiple artists can be involved in one song.
	var musician: [OGProfile]? { get }
}

/// A song on an album or in a playlist
public protocol OGAlbum: OGMusic {
	///  The song on this album.
	var song: OGSong? { get }

	///  >=1 - The same as music:album:disc but in reverse.
	var disc: Int? { get }

	/// >=1 - The same as music:album:track but in reverse.
	var track: Int? { get }

	///  The musician that made this song. This differs from the spec in being an array, rather than a single musician.
	var musician: [OGProfile]? { get }

	/// The date the album was released.
	var releaseDate: DateTime? { get }
}

/// A collection of songs made by any number of people
public protocol OGPlaylist: OGMusic {
	///  The songs on this album.
	var song: [OGSong]? { get }

	///  >=1 - The same as music:album:disc but in reverse.
	var disc: Int? { get }

	/// >=1 - The same as music:album:track but in reverse.
	var track: Int? { get }

	/// The creator of this playlist. This differs from the spec in being an array, rather than a single musician.
	var creator: [OGProfile]? { get }
}

/// A song being broadcasted by a dj is a radio station in OpenGraph terms
public protocol OGRadioStation: OGMusic {
	/// The creator of this playlist. This differs from the spec in being an array, rather than a single musician.
	var creator: [OGProfile]? { get }
}

// MARK: -

/// Extended metadata that may exist for any kind of video metadata (for example, an episode of a tv show, a movie, or a youtube clip)
public protocol OGVideo: OGVisualMedia {
	/// Actors in the movie.
	var actor: [OGProfile]? { get }

	/// The role they played.
	var roles: [String]? { get }

	/// Directors of the movie.
	var director: [OGProfile]? { get }

	/// Writers of the movie.
	var writer: [OGProfile]? { get }

	/// >=1 - The movie's length in seconds.
	var duration: Int? { get }

	/// The date the movie was released.
	var releaseDate: DateTime? { get }

	/// Tag words associated with this movie.
	var tag: [String]? { get }
}

/// An empty protocol for movies that conforms to `OGVideo`
public protocol OGMovie: OGVideo {}

/// A multi-episode TV show. The metadata is identical to `OGMovie`.
public protocol OGTVShow: OGVideo {}

/// A video that doesn't belong in any other category. The metadata is identical to `OGMovie`.
public protocol OGOtherVideo: OGVideo {}

/// An empty protocol for an episode of a tv show
public protocol OGEpisode: OGVideo {
	/// Which series this episode belongs to.
	var series: OGTVShow? { get }
}

// MARK: -

/// A protocol that represents an essay, blog post, paper, or any other collection of words
public protocol OGArticle: OGMetadata {
	/// When the article was first published.
	var publishedTime: DateTime? { get }

	/// When the article was last changed.
	var modifiedTime: DateTime? { get }

	/// When the article is out of date after.
	var expirationTime: DateTime? { get }

	/// Writers of the article.
	var author: [OGProfile]? { get }

	/// A high-level section name. E.g. Technology
	var section: String? { get }

	/// Tag words associated with this article.
	var tag: [String]? { get }
}

/// A protocol that represents a published or unpublished book
public protocol OGBook: OGMetadata {
	/// Who wrote this book.
	var author: [OGProfile]? { get }

	/// The ISBN(-10 or -13) of a book
	var isbn: String? { get }

	/// The date the book was released.
	var releaseDate: DateTime? { get }

	/// Tag words associated with this book.
	var tag: [String]? { get }
}

/// A protocol that represents details about an individual
public protocol OGProfile: OGMetadata {
	/// A name normally given to an individual by a parent or self-chosen.
	var firstName: String? { get }

	/// A name inherited from a family or marriage and by which the individual is commonly known.
	var lastName: String? { get }

	/// A short unique string to identify them.
	var username: String? { get }

	/// Their gender. This differs from the spec in being a string that can contain any value, rather than a closed enum
	var gender: String? { get }
}
