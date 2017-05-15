/**
	A barebones HTML parser that reports tags as it encounters them
*/
public final class Parser {
	private enum ParserState {
		case starting
		case matchingComment
		case matchingTagName
		case matchingPropertyName
		case matchingPropertyValue
	}

	/**
		A block to call whenever an HTML tag is encountered and successfully parsed.
		
		- block parameter 0: a `String` that represents the tag that was parsed
		- block parameter 1: a `Dictionary` containing all attributes found in the tag
	
		for example, after parsing

			<meta property="og:title" content="The Rock" />

		`onFind` will be called with with the following arguments:

			("tag", ["property": "og:title", "content": "The Rock"])
	*/
	public var onFind: ((_ tag: String, _ value: [String: String]) -> Void)? = nil

	/**
		The designated initializer for `Parser`
	*/
	public init() {}

	/**
		Parse text and look for any HTML tags it contains. This does not perform any validation, such as checking if a <meta> tag appears inside of a <head> tag.
	
		`onFind` must be set before any parsing will occur.

		- Parameter text: The text to parse.

		- Returns: `true` if the entire document is parseable, or `false` if an error was encountered.
	*/
	public func parse(text: String) -> Bool {
		guard let onFind = onFind else {
			return false
		}

		var values = [String: String]()

		var tagStack = [String]()
		var currentProperty = ""

		var inString = false
		var ignoreNextCharacter = false
		var ignoringUntilClosingTag = false
		var stack = [Character]()
		var state: ParserState = .starting

		let matchedTagName = {
			state = .matchingPropertyName
			tagStack.append(String(stack))
			stack.removeAll()
		}

		let matchedKey = {
			state = .matchingPropertyValue
			currentProperty = String(stack)
			stack.removeAll()
		}

		let matchedValue = {
			state = .matchingPropertyName
			values[currentProperty] = String(stack)
			stack.removeAll()
		}

		for i in 0 ..< text.utf8.count {
			let character = text.characterAt(index: i)!
			if !inString && character == Character(">") {
				if state == .matchingComment {
					state = .starting
					ignoringUntilClosingTag = false
					continue
				} else if state == .matchingTagName {
					matchedTagName()
				} else if state == .matchingPropertyValue {
					matchedValue()
				}

				state = .starting

				guard let currentTag = tagStack.popLast() else {
					return false
				}

				if !currentTag.isEmpty {
					onFind(currentTag, values)
				}

				values.removeAll()
				currentProperty = ""

				ignoringUntilClosingTag = false
				continue
			}

			if ignoringUntilClosingTag {
				continue
			}

			var didSetMatchingTagState = false
			if character == Character("<") {
				didSetMatchingTagState = true
				state = .matchingTagName
			}

			guard let nextCharacter = text.characterAt(index: i + 1) else {
				break
			}

			if !inString && nextCharacter == Character("/") {
				ignoringUntilClosingTag = true
				continue
			}

			if didSetMatchingTagState {
				if nextCharacter == Character("!") {
					state = .matchingComment
					ignoringUntilClosingTag = true
				}
				continue
			}

			if state == .starting {
				continue
			}

			stack.append(character)

			if character == Character("\\") {
				if ignoreNextCharacter {
					ignoreNextCharacter = false
				} else {
					ignoreNextCharacter = true
					stack.removeLast()
					continue
				}
			} else {
				ignoreNextCharacter = false
			}

			if !ignoreNextCharacter && character == Character("\"") {
				stack.removeLast()

				if !inString {
					inString = true
					continue
				} else {
					inString = false
					continue
				}
			}

			if (character != Character(" ") && character != Character("=")) {
				continue
			}

			if state == .matchingTagName {
				stack.removeLast()
				matchedTagName()
				continue
			}

			if state == .matchingPropertyName {
				stack.removeLast()
				matchedKey()
				continue
			}

			if inString { continue }

			if state == .matchingPropertyValue {
				stack.removeLast()
				matchedValue()
				continue
			}
		}

		return tagStack.isEmpty
	}
}
