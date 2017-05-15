internal extension String {
	internal func characterAt(index i: Int) -> Character? {
		guard i < utf8.count else { return nil }
		return self[characters.index(startIndex, offsetBy: i)]
	}
}
