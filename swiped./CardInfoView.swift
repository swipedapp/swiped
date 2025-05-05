//
//  CardInfoView.swift
//  swiped.
//
//  Created by tobykohlhagen on 5/5/2025.
//

import UIKit
import Photos
import UniformTypeIdentifiers

class CardInfoView: UIView {
	
	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()

	private let infoView = UIStackView()
	private let dateLabel = UILabel()
	private let subLabel = UILabel()

	private let typeIcon = UIImageView()
	private let editedIcon = UIImageView()
	private let heartIcon = UIImageView()

	var card: PhotoCard? {
		didSet { updateCard() }
	}

	init() {
		super.init(frame: .zero)

		tintColor = .white

		infoView.translatesAutoresizingMaskIntoConstraints = false
		infoView.spacing = 4
		infoView.axis = .vertical
		infoView.distribution = .fill
		addSubview(infoView)
		
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		dateLabel.font = UIFont(name: "LoosExtended-Bold", size: 24)
		dateLabel.textColor = .white
		infoView.addArrangedSubview(dateLabel)

		let subView = UIStackView()
		subView.translatesAutoresizingMaskIntoConstraints = false
		subView.spacing = 8
		subView.axis = .horizontal
		subView.distribution = .fill
		subView.alignment = .lastBaseline
		infoView.addArrangedSubview(subView)

		typeIcon.translatesAutoresizingMaskIntoConstraints = false
		typeIcon.contentMode = .scaleAspectFit
		subView.addArrangedSubview(typeIcon)

		editedIcon.translatesAutoresizingMaskIntoConstraints = false
		editedIcon.image = UIImage(systemName: "pencil")
		editedIcon.contentMode = .scaleAspectFit
		editedIcon.isHidden = true
		subView.addArrangedSubview(editedIcon)

		heartIcon.translatesAutoresizingMaskIntoConstraints = false
		heartIcon.image = UIImage(systemName: "heart.fill")
		heartIcon.contentMode = .scaleAspectFit
		heartIcon.isHidden = true
		subView.addArrangedSubview(heartIcon)

		subLabel.translatesAutoresizingMaskIntoConstraints = false
		subLabel.font = UIFont(name: "LoosExtended-Bold", size: 18)
		subLabel.textColor = .white
		subView.addArrangedSubview(subLabel)

		NSLayoutConstraint.activate([
			infoView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
			infoView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
			infoView.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
			infoView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),

			typeIcon.heightAnchor.constraint(equalToConstant: 20),
			editedIcon.heightAnchor.constraint(equalToConstant: 20),
			heartIcon.heightAnchor.constraint(equalToConstant: 20),

			typeIcon.widthAnchor.constraint(equalTo: typeIcon.heightAnchor),
			editedIcon.widthAnchor.constraint(equalTo: editedIcon.heightAnchor),
			heartIcon.widthAnchor.constraint(equalTo: heartIcon.heightAnchor),
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
			var icon: String

			switch asset.mediaType {
			case .image:
				icon = "photo"
			case .video:
				icon = "video"
			case .audio:
				icon = "audio"
			case .unknown:
				icon = "questionmark.circle"
			@unknown default:
				icon = "questionmark.circle"
			}

			if asset.mediaSubtypes.contains(.photoScreenshot) {
				types.append("Screenshot")
				icon = "camera.viewfinder"
			}
			if asset.mediaSubtypes.contains(.photoHDR) {
				types.append("HDR Photo")
			}
			if asset.mediaSubtypes.contains(.photoLive) {
				types.append("Live Photo")
				icon = "livephoto"
			}
			if asset.mediaSubtypes.contains(.photoPanorama) {
				types.append("Panorama")
			}
			if asset.mediaSubtypes.contains(.photoDepthEffect) {
				types.append("Portrait")
				icon = "person.crop.square"
			}
			if asset.mediaSubtypes.contains(.spatialMedia) {
				types.append("Spatial Media")
				icon = "video"
			}
			if asset.mediaSubtypes.contains(.videoCinematic) {
				types.append("Cinematic Video")
				icon = "video"
			}
			if asset.mediaSubtypes.contains(.videoHighFrameRate) {
				types.append("High Frame Rate Video")
				icon = "video"
			}
			if asset.mediaSubtypes.contains(.videoStreamed) {
				types.append("Streamed Video")
				icon = "video"
			}
			if asset.mediaSubtypes.contains(.videoTimelapse) {
				types.append("Time Lapse")
				icon = "timelapse"
			}
			if asset.mediaSubtypes.contains(.screenRecording) {
				types.append("Screen Recording")
				icon = "record.circle"
			}
			if asset.burstIdentifier != nil {
				types.append("Burst Photo")
				icon = "square.stack.3d.down.forward"
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

			let resources = PHAssetResource.assetResources(for: asset)

			if resources.contains(where: { UTType($0.uniformTypeIdentifier)?.conforms(to: UTType.rawImage) == true }) {
				types.append("RAW")
			}

			if let resource = resources.first {
				let fileName = resource.originalFilename

				if fileName.starts(with: "telegram-") {
					types.append("Saved from Telegram")
				}
			}

			subLabel.text = types.joined(separator: ", ")
			typeIcon.image = UIImage(systemName: icon)
			editedIcon.isHidden = !asset.hasAdjustments
			heartIcon.isHidden = !asset.isFavorite
		}
	}

}
