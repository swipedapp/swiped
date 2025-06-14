//
//  PhotoCard.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit
import Photos

class PhotoCard: Equatable, Identifiable, ObservableObject {
	var id: Int = 0
	var photo: Photo?
	var asset: PHAsset?
	@Published var thumbnail: UIImage?
	@Published var fullImage: UIImage?

	static func == (lhs: PhotoCard, rhs: PhotoCard) -> Bool {
		return lhs.id == rhs.id
	}

	convenience init(id: Int, photo: Photo? = nil, asset: PHAsset? = nil, thumbnail: UIImage? = nil, fullImage: UIImage? = nil) {
		self.init()
		self.id = id
		self.photo = photo
		self.asset = asset
		self.thumbnail = thumbnail
		self.fullImage = fullImage
	}
}
