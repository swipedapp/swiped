//
//  CardContentView.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit

class CardContentView: UIView {
	
	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()
	
	private let infoView = UIStackView()
	private let dateLabel = UILabel()

	private let shadowView = UIView()
	private let containerView = UIView()
	private let imageView = UIImageView()
	private let spinner = UIActivityIndicatorView(style: .medium)
	
	let card: PhotoCard

	init(card: PhotoCard) {
		self.card = card
		
		super.init(frame: .zero)
		
//		infoView.translatesAutoresizingMaskIntoConstraints = false
//		infoView.spacing = 4
//		infoView.axis = .vertical
//		infoView.distribution = .fill
//		addSubview(infoView)
//		
//		dateLabel.translatesAutoresizingMaskIntoConstraints = false
//		dateLabel.font = UIFont(name: "LoosExtended-Bold", size: 24)
//		infoView.addArrangedSubview(dateLabel)
		
		shadowView.translatesAutoresizingMaskIntoConstraints = false
		shadowView.backgroundColor = .secondarySystemBackground
		shadowView.layer.cornerRadius = 8
		shadowView.applyShadow(radius: 50, opacity: 0.3, offset: CGSize(width: 0, height: 8))
		addSubview(shadowView)
		
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.backgroundColor = .black
		containerView.clipsToBounds = true
		containerView.layer.cornerRadius = 8
		addSubview(containerView)
		
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.minificationFilter = .trilinear
		imageView.layer.magnificationFilter = .trilinear
		containerView.addSubview(imageView)
		
		spinner.translatesAutoresizingMaskIntoConstraints = false
		spinner.color = .blue
		spinner.tintColor = .red
		spinner.hidesWhenStopped = true
		spinner.startAnimating()
		containerView.addSubview(spinner)
		
		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
			imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
		])
		
		NSLayoutConstraint.activate([
			containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
			containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
			containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
			containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
			containerView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),
			containerView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -40)
		])
		
		NSLayoutConstraint.activate([
			shadowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			shadowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			shadowView.topAnchor.constraint(equalTo: containerView.topAnchor),
			shadowView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])
		
		NSLayoutConstraint.activate([
			spinner.widthAnchor.constraint(equalToConstant: 24),
			spinner.heightAnchor.constraint(equalToConstant: 24),
			spinner.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
			spinner.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
		])
		
		updateCard()
  }
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func updateCard() {
		if let asset = card.asset {
//			dateLabel.text = Self.dateFormatter.string(from: asset.creationDate ?? .distantPast)
		}
		
		if card.fullImage == nil {
			spinner.startAnimating()
		} else {
			spinner.stopAnimating()
		}
		
		guard let image = card.fullImage ?? card.thumbnail else {
			imageView.image = nil
			return
		}

		imageView.image = image
		
		let isLandscape = image.size.width > image.size.height
		imageView.contentMode = isLandscape ? .scaleAspectFit : .scaleAspectFill
	}
	
}
