//
//  Photo.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import Foundation

class Photo {
	enum Choice: Int {
		case none = 0
		case keep = 1
		case delete = 2
		case skip = 3
	}

	let id: String
	var size: Double = 0
	var choice: Choice = .none
	var swipeDate: Date?
	
	init(id: String) {
		self.id = id
	}
}
