import Foundation

public protocol OGPreviewable {
	func fetchOpenGraphData(session: URLSession, completion: @escaping ((Bool, [OGMetadata]?) -> Void))
}

extension URL: OGPreviewable {
	public func fetchOpenGraphData(session: URLSession = .shared, completion: @escaping ((Bool, [OGMetadata]?) -> Void)) {
		URLRequest(url: self).fetchOpenGraphData(session: session, completion: completion)
	}
}

extension URLRequest: OGPreviewable {
	public func fetchOpenGraphData(session: URLSession = .shared, completion: @escaping ((Bool, [OGMetadata]?) -> Void)) {
		URLSession.shared.dataTask(with: self) { (data, response, error) in
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
					let graphs = tagTracker.metadatum.flatMap(Metadata.from)
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
	}
}

extension ReferenceConvertible where ReferenceType: OGPreviewable {
	public func fetchOpenGraphData(session: URLSession = .shared, completion: @escaping ((Bool, [OGMetadata]?) -> Void)) {
		(self as! ReferenceType).fetchOpenGraphData(session: session, completion: completion)
	}
}
