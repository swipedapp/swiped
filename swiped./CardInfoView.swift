//
//  CardInfoView.swift
//  swiped.
//
//  Created by tobykohlhagen on 5/5/2025.
//

import UIKit
import SwiftUI
import Photos
import UniformTypeIdentifiers

class CardInfo: ObservableObject {
	@Published var card: PhotoCard?
}

struct CardInfoView: View {

	protocol Delegate: AnyObject {
		func share(sender: UIButton)
		func settings()
	}

	weak var delegate: Delegate?

	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()

	private static let fileSizeFormatter = ByteCountFormatter()

	@ObservedObject var cardInfo: CardInfo

	var body: some View {
		Text("SWIPED")
			.foregroundColor(.white)
			.font(.custom("LoosExtended-Bold", size: 50))
		+
		Text(".")
			.foregroundColor(.accentColor)
			.font(.custom("LoosExtended-Bold", size: 50))
	}

}

#Preview {
	let cardInfo = CardInfo()
	cardInfo.card = PhotoCard()

	return CardInfoView(cardInfo: cardInfo)
}

class CardInfoView2: UIView {

	protocol Delegate: AnyObject {
		func share(sender: UIButton)
		func settings()
	}

	weak var delegate: Delegate?

	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()

	private static let fileSizeFormatter = ByteCountFormatter()

	private let infoView = UIStackView()
	private let dateLabel = UILabel()
	private let subLabel = UILabel()

	private let settingsButton = ActionButton(frame: .zero)
	private let shareButton = ActionButton(frame: .zero)

	private let typeIcon = UIImageView()
	private let editedIcon = UIImageView()
	private let heartIcon = UIImageView()

	var card: PhotoCard? {
		didSet { updateCard() }
	}

	init() {
		super.init(frame: .zero)
		setSwipedText(summary: false)
		tintColor = .white

		infoView.translatesAutoresizingMaskIntoConstraints = false
		infoView.spacing = 4
		infoView.axis = .vertical
		infoView.distribution = .fill
		addSubview(infoView)
		
		let titleView = UIStackView()
		titleView.translatesAutoresizingMaskIntoConstraints = false
		titleView.spacing = 0
		titleView.axis = .horizontal
		titleView.distribution = .fill
		titleView.alignment = .lastBaseline
		infoView.addArrangedSubview(titleView)
		
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		dateLabel.font = UIFont(name: "LoosExtended-Bold", size: 24)
		titleView.addArrangedSubview(dateLabel)

		shareButton.setText(text: nil, image: UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 18, weight: .bold))))
		shareButton.accessibilityLabel = "Share"
		shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
		titleView.addArrangedSubview(shareButton)

		settingsButton.setText(text: nil, image: UIImage(systemName: "gear", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 18, weight: .bold))))
		settingsButton.accessibilityLabel = "Settings"
		settingsButton.addTarget(self, action: #selector(settings), for: .touchUpInside)
		titleView.addArrangedSubview(settingsButton)

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
		subLabel.font = UIFont(name: "LoosExtended-Regular", size: 18)
		subLabel.textColor = .white
		subView.addArrangedSubview(subLabel)

		NSLayoutConstraint.activate([
			infoView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
			infoView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
			infoView.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
			infoView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 18),
			infoView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),

			settingsButton.heightAnchor.constraint(equalToConstant: 44),
			shareButton.heightAnchor.constraint(equalToConstant: 44),
			typeIcon.heightAnchor.constraint(equalToConstant: 20),
			editedIcon.heightAnchor.constraint(equalToConstant: 20),
			heartIcon.heightAnchor.constraint(equalToConstant: 20),

			settingsButton.widthAnchor.constraint(equalTo: shareButton.heightAnchor),
			shareButton.widthAnchor.constraint(equalTo: shareButton.heightAnchor),
			typeIcon.widthAnchor.constraint(equalTo: typeIcon.heightAnchor),
			editedIcon.widthAnchor.constraint(equalTo: editedIcon.heightAnchor),
			heartIcon.widthAnchor.constraint(equalTo: heartIcon.heightAnchor),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setSwipedText(summary: Bool) {
		let fullText = "SWIPED."
		let attributedString = NSMutableAttributedString(string: fullText)
		let mainTextRange = NSRange(location: 0, length: fullText.count - 1)
		attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: mainTextRange)
		let periodRange = NSRange(location: fullText.count - 1, length: 1)
		attributedString.addAttribute(.foregroundColor, value: UIColor.green, range: periodRange)
		dateLabel.attributedText = attributedString

		subLabel.text = summary ? "Summary" : ""
		typeIcon.isHidden = true
		editedIcon.isHidden = true
		heartIcon.isHidden = true
		shareButton.isHidden = true
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
				types.append("Depth Effect")
				icon = "person.and.background.dotted"
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
				} else if !fileName.starts(with: "IMG_") && !asset.mediaSubtypes.contains(.screenRecording) {
					types.append("Imported")
				}
			}
			
			types.append(Self.fileSizeFormatter.string(fromByteCount: Int64(card.photo?.size ?? 0)))
			
			subLabel.text = types.joined(separator: ", ")
			typeIcon.image = UIImage(systemName: icon)
			editedIcon.isHidden = !asset.hasAdjustments
			heartIcon.isHidden = !asset.isFavorite
			shareButton.isHidden = asset.mediaType != .image
			typeIcon.isHidden = false
		}
	}

	@objc func share() {
		delegate?.share(sender: shareButton)
	}

	@objc func settings() {
		delegate?.settings()
	}

}
