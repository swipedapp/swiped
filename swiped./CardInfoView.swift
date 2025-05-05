//
//  CardInfoView.swift
//  swiped.
//
//  Created by tobykohlhagen on 5/5/2025.
//

import UIKit
import Photos

class CardInfoView: UIView {
	
	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()
	
	private let infoView = UIStackView()
	private let dateLabel = UILabel()
	private let subLabel = UILabel()
	
	var card: PhotoCard? {
		didSet { updateCard() }
	}

	init() {
		super.init(frame: .zero)
		
		infoView.translatesAutoresizingMaskIntoConstraints = false
		infoView.spacing = 4
		infoView.axis = .vertical
		infoView.distribution = .fill
		addSubview(infoView)
		
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		dateLabel.font = UIFont(name: "LoosExtended-Bold", size: 24)
		dateLabel.textColor = .white
		infoView.addArrangedSubview(dateLabel)
		
		subLabel.translatesAutoresizingMaskIntoConstraints = false
		subLabel.font = UIFont(name: "LoosExtended-Bold", size: 18)
		subLabel.textColor = .white
		infoView.addArrangedSubview(subLabel)
		
		NSLayoutConstraint.activate([
			infoView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
			infoView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
			infoView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
			infoView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func updateCard() {
		guard let card = card else {
			return
		}

		if let asset = card.asset {
			dateLabel.text = Self.dateFormatter.string(from: asset.creationDate ?? .distantPast)
			
			var types = [String]()
			if asset.mediaSubtypes.contains(.photoScreenshot) {
				types.append("Screenshot")
			}
			if asset.mediaSubtypes.contains(.photoHDR) {
				types.append("HDR Photo")
			}
			if asset.mediaSubtypes.contains(.photoLive) {
				types.append("Live Photo")
			}
			if asset.mediaSubtypes.contains(.photoPanorama) {
				types.append("Panorama")
			}
			if asset.mediaSubtypes.contains(.photoDepthEffect) {
				types.append("Portrait")
			}
			if asset.mediaSubtypes.contains(.spatialMedia) {
				types.append("Spatial Media")
			}
			if asset.mediaSubtypes.contains(.videoCinematic) {
				types.append("Cinematic Video")
			}
			if asset.mediaSubtypes.contains(.videoHighFrameRate) {
				types.append("High Frame Rate Video")
			}
			if asset.mediaSubtypes.contains(.videoStreamed) {
				types.append("Streamed Video")
			}
			if asset.mediaSubtypes.contains(.videoTimelapse) {
				types.append("Time Lapse")
			}
			
			if types.isEmpty {
				switch asset.mediaType {
				case .image:
					types.append("Photo")
				case .video:
					types.append("Video")
				case .audio:
					types.append("Audio")
				case .unknown:
					types.append("Unknown")
				@unknown default:
					types.append("Unknown")
				}
			}

			subLabel.text = types.joined(separator: ", ")
		}
	}

}
