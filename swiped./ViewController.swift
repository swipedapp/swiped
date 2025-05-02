//
//  ViewController.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit
import Shuffle

class ViewController: UIViewController {
    
	private let cardStack = SwipeCardStack()
	private let buttonStackView = ButtonStackView()
	private let behindView = BehindView()

	private let photosController = PhotosController()
	private var cards = [PhotoCard]()
	private var toDelete = [PhotoCard]()

	override func viewDidLoad() {
		super.viewDidLoad()

		cardStack.delegate = self
		cardStack.dataSource = self
		buttonStackView.delegate = self
		behindView.delegate = self
		photosController.delegate = self

		configureNavigationBar()
		layoutButtonStackView()
		layoutBehindView()
		layoutCardStackView()
		
		loadBatch()
	}

	private func configureNavigationBar() {
		let backButton = UIBarButtonItem(title: "Back",
																		 style: .plain,
																		 target: self,
																		 action: #selector(handleShift))
		backButton.tag = 1
		backButton.tintColor = .lightGray
		navigationItem.leftBarButtonItem = backButton

		let forwardButton = UIBarButtonItem(title: "Forward",
																				style: .plain,
																				target: self,
																				action: #selector(handleShift))
		forwardButton.tag = 2
		forwardButton.tintColor = .lightGray
		navigationItem.rightBarButtonItem = forwardButton

		navigationController?.navigationBar.layer.zPosition = -1
	}

	private func layoutButtonStackView() {
		view.addSubview(buttonStackView)
		buttonStackView.anchor(left: view.safeAreaLayoutGuide.leftAnchor,
													 bottom: view.safeAreaLayoutGuide.bottomAnchor,
													 right: view.safeAreaLayoutGuide.rightAnchor,
													 paddingLeft: 24,
													 paddingBottom: 12,
													 paddingRight: 24)
	}

	private func layoutCardStackView() {
		view.addSubview(cardStack)
		cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
										 left: view.safeAreaLayoutGuide.leftAnchor,
										 bottom: buttonStackView.topAnchor,
										 right: view.safeAreaLayoutGuide.rightAnchor)
	}
	
	private func layoutBehindView() {
		view.addSubview(behindView)
		behindView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
											left: view.safeAreaLayoutGuide.leftAnchor,
											bottom: buttonStackView.topAnchor,
											right: view.safeAreaLayoutGuide.rightAnchor)
	}

	@objc private func handleShift(_ sender: UIButton) {
		cardStack.shift(withDistance: sender.tag == 1 ? -1 : 1, animated: true)
	}
	
	private func loadBatch() {
		for _ in 0..<20 {
			let card = PhotoCard(id: self.cards.count)
			self.cards.append(card)
			self.cardStack.appendCards(atIndices: [card.id])
			photosController.loadRandomPhoto(for: card)
		}
	}
}

// MARK: Data Source + Delegates

extension ViewController: PhotosController.PhotoLoadDelegate {
	func didLoadThumbnail(for card: PhotoCard, image: UIImage) {
		print("loaded thumbnail for \(card.id)")
		card.thumbnail = image
		
		if let swipeCard = cardStack.card(forIndexAt: card.id),
			 let contentView = swipeCard.content as? CardContentView {
			contentView.updateCard()
		}
	}
	
	func didLoadFullImage(for card: PhotoCard, image: UIImage) {
		print("loaded full image for \(card.id)")
		card.fullImage = image
		
		if let swipeCard = cardStack.card(forIndexAt: card.id),
			 let contentView = swipeCard.content as? CardContentView {
			contentView.updateCard()
		}
	}
	
	func didFail(error: PhotosController.PhotoError) {
		print("oh poop \(error)")
	}
}

extension ViewController: ButtonStackViewDelegate, SwipeCardStackDataSource, SwipeCardStackDelegate, BehindViewDelegate {

	func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
		let card = SwipeCard()
		card.footerHeight = 80
		card.swipeDirections = [.left, .up, .right]
		for direction in card.swipeDirections {
			card.setOverlay(CardOverlay(direction: direction), forDirection: direction)
		}

		card.content = CardContentView(card: cards[index])

		return card
	}

	func numberOfCards(in cardStack: SwipeCardStack) -> Int {
		return cards.count
	}

	func didSwipeAllCards(_ cardStack: SwipeCardStack) {
		print("Swiped all cards!")
		
		cardStack.isUserInteractionEnabled = false
		buttonStackView.isUserInteractionEnabled = false
		
		UIView.animate(withDuration: 0.3) {
			self.buttonStackView.alpha = 0
		}
	}

	func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
		print("Undo")
	}

	func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
		print("Swiped \(direction)")
		let card = cards[index]
		
		var choice: Photo.Choice
		switch direction {
		case .left:
			choice = .delete
			toDelete.append(cards[index])
			
		case .right:
			choice = .keep
			
		case .up:
			choice = .skip

		case .down:
			fatalError()
		}
		
		let photo = card.photo!
		photo.choice = choice
		photo.swipeDate = Date()
		DatabaseController.shared.addPhoto(photo: photo)
	}

	func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
		print("Card tapped")
	}

	func didTapButton(button: ActionButton) {
		switch ButtonStackView.Action(rawValue: button.tag) {
		case .undo:
			cardStack.undoLastSwipe(animated: true)
		case .delete:
			cardStack.swipe(.left, animated: true)
		case .keep:
			cardStack.swipe(.right, animated: true)
		case .none:
			fatalError()
		}
	}

	func didTapBehindButton(button: ActionButton) {
		switch BehindView.Action(rawValue: button.tag) {
		case .continue:
			break
		case .delete:
			photosController.delete(cards: toDelete)
			toDelete.removeAll()
		case .none:
			fatalError()
		}
		
		// Release all but the last card from memory
		let oldCount = cards.count
		let allButLast = 0..<oldCount - 1
		cards.removeSubrange(allButLast)
		
		var indices = [Int]()
		for i in allButLast {
			indices.append(i)
		}
		cardStack.deleteCards(atIndices: indices)

		loadBatch()
		
		cardStack.isUserInteractionEnabled = true
		buttonStackView.isUserInteractionEnabled = true
		
		UIView.animate(withDuration: 0.3) {
			self.buttonStackView.alpha = 1
		}
	}
	
}
