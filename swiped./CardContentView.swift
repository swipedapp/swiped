//
//  CardContentView.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit

class CardContentView: UIView {

	private let shadowView = UIView()
	private let containerView = UIView()
	private let imageView = UIImageView()
	private let playImageView = UIImageView()
	private let spinner = UIActivityIndicatorView(style: .medium)
	
	let card: PhotoCard

	init(card: PhotoCard) {
		self.card = card
		
		super.init(frame: .zero)
		
		shadowView.translatesAutoresizingMaskIntoConstraints = false
		shadowView.backgroundColor = .black
		shadowView.layer.cornerRadius = 8
		shadowView.applyShadow(radius: 2, opacity: 0.3, offset: .zero, color: .white)
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
		
		playImageView.translatesAutoresizingMaskIntoConstraints = false
		playImageView.image = UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 48))
		playImageView.tintColor = .white
		containerView.addSubview(playImageView)
		
		spinner.translatesAutoresizingMaskIntoConstraints = false
		spinner.color = .white
		spinner.hidesWhenStopped = true
		spinner.startAnimating()
		containerView.addSubview(spinner)
		
		NSLayoutConstraint.activate([
			containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
			containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
			containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 100),
			containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
			containerView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -50),
			containerView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -130)
		])
		
		NSLayoutConstraint.activate([
			shadowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			shadowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			shadowView.topAnchor.constraint(equalTo: containerView.topAnchor),
			shadowView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])
		
		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
			imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
		])
		
		NSLayoutConstraint.activate([
			imageView.centerXAnchor.constraint(equalTo: playImageView.centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: playImageView.centerYAnchor),
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
		
		guard let asset = card.asset else {
			playImageView.isHidden = true
			return
		}

		playImageView.isHidden = asset.mediaType != .video
	}
	
}
