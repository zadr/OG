import Foundation

public protocol OGPreviewable {
	/**
	Fetch data from a URL and attempt to parse OpenGraph tags out of it

	- Parameter session: The `URLSession` to make a data task on. Defaults to `URLSession.shared`
	- Parameter completion: A block to call when a data task finishes downloading and parsing data. The first parameter is a boolean that indicates if parsing succeeded or failed, and the second is an array of OpenGraph metadata types from a website

	// note: if this changes, change the documentation in the extension on `ReferenceConvertible` below
	*/
	func fetchOpenGraphData(session: URLSession, completion: @escaping ((Bool, [OGMetadata]?) -> Void))
}

extension URL: OGPreviewable {
	public func fetchOpenGraphData(session: URLSession = .shared, completion: @escaping ((Bool, [OGMetadata]?) -> Void)) {
		URLRequest(url: self).fetchOpenGraphData(session: session, completion: completion)
	}
}

extension URLRequest: OGPreviewable {
	public func fetchOpenGraphData(session: URLSession = .shared, completion: @escaping ((Bool, [OGMetadata]?) -> Void)) {
		let task = session.dataTask(with: self) { (data, response, error) in
			if let data = data, let html = String(data: data, encoding: .utf8) {
				let parser = Parser()
				let tagTracker = TagTracker()

				parser.onFind = { (tag, values) in
					if !tagTracker.track(tag, values: values) {
						#if OG_DEBUG_LOGGING_ENABLED
							print("refusing to track non-meta tag \(tag) with values \(values)")
						#endif
					}
				}

				if parser.parse(html) {
					let graphs = tagTracker.metadatum.compactMap(Metadata.from)
					completion(true, graphs)
				} else {
					completion(false, nil)
				}
			} else {
				#if OG_DEBUG_LOGGING_ENABLED
					print("error \(String(describing: error)) on \(String(describing: response))")
				#endif

				completion(false, nil)
			}
		}
		task.resume()
	}
}

extension ReferenceConvertible where ReferenceType: OGPreviewable {
	/**
	Fetch data from a URL and attempt to parse OpenGraph tags out of it

	- Parameter session: The `URLSession` to make a data task on. Defaults to `URLSession.shared`
	- Parameter completion: A block to call when a data task finishes downloading and parsing data. The first parameter is a boolean that indicates if parsing succeeded or failed, and the second is an array of OpenGraph metadata types from a website

	note: if this changes, change the documentation in the protocol declaration of `OGPreviewable` above
	*/
	public func fetchOpenGraphData(session: URLSession = .shared, completion: @escaping ((Bool, [OGMetadata]?) -> Void)) {
		(self as! ReferenceType).fetchOpenGraphData(session: session, completion: completion)
	}
}
