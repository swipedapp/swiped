//
//  Photo.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import Foundation
import Photos
import SwiftData

@Model
class Photo {
	enum AssetType: Int, Codable {
		case unknown = 0
		case image = 1
		case video = 2
		case audio = 3
	}
	
	enum Choice: Int, Codable {
		case none = 0
		case keep = 1
		case delete = 2
		case skip = 3
	}
	
	var id: String = ""
	var size: Double = 0
	var creationDate: Date?
	var swipeDate: Date?
	
	var type: AssetType {
		get { AssetType(rawValue: _type)! }
		set { _type = newValue.rawValue }
	}
	
	var choice: Choice {
		get { Choice(rawValue: _choice)! }
		set { _choice = newValue.rawValue }
	}
	
	var _type = AssetType.unknown.rawValue
	var _choice = Choice.none.rawValue
	
	init(id: String) {
		self.id = id
	}
}
