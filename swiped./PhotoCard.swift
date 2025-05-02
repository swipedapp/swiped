//
//  PhotoCard.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit
import Photos

class PhotoCard: Equatable {
	var id: Int
	var asset: PHAsset?
	var thumbnail: UIImage?
	var fullImage: UIImage?
	
	init(id: Int) {
		self.id = id
	}
	
	static func == (lhs: PhotoCard, rhs: PhotoCard) -> Bool {
		return lhs.id == rhs.id
	}
}
