//
//  ViewController.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit
import Shuffle
import QuickLook
import StoreKit
import AVKit
import SwiftUI
import os


class ViewController: UIViewController {
	var version: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}
	
	var build: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
	}
	private let cardStack = SwipeCardStack()
	private let buttonStackView = ButtonStackView()
	private var infoView: CardInfoView!
	private var infoHostingController: UIHostingController<AnyView>!
	private var behindView: BehindView!
	private var behindViewHostingController: UIHostingController<AnyView>!

	private let photosController = PhotosController()
	private var cards = [PhotoCard]()
	private var toDelete = [PhotoCard]()
	private var loadingBatch = true
	private var batchesLoaded = 0
	
	private let cardInfo = CardInfo()
	
	private var previewItem: URL?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		#if !INTERNAL
		fetchAlert()
		#endif
		//view.backgroundColor = UIColor.black
		cardStack.delegate = self
		cardStack.dataSource = self
		buttonStackView.delegate = self
		infoView = CardInfoView()
		behindView = BehindView()
		behindView.delegate = self
		photosController.delegate = self
		
		configureNavigationBar()
		layoutBehindView()
		layoutButtonStackView()
		layoutInfoView()
		layoutCardStackView()
		
		loadBatch()
		
		Task {
			//await ServerController.shared.doRegister()
			_ = createRepeatingTask(every: 30.0) {
				await ServerController.shared.doRegister()
			}
		}
	}
	func createRepeatingTask(every seconds: TimeInterval, _ operation: @escaping () async -> Void) -> Task<Void, Never> {
		Task {
			while !Task.isCancelled {
				await operation()
				try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
			}
		}
	}
	
	private func configureNavigationBar() {
		navigationController?.setNavigationBarHidden(true, animated: false)
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
		cardStack.anchor(top: infoHostingController.view.bottomAnchor,
										 left: view.safeAreaLayoutGuide.leftAnchor,
										 bottom: buttonStackView.topAnchor,
										 right: view.safeAreaLayoutGuide.rightAnchor)
	}
	
	private func layoutInfoView() {
		infoHostingController = UIHostingController(rootView: AnyView(
			infoView
				.environmentObject(cardInfo)
		))
		infoHostingController.willMove(toParent: self)
		view.addSubview(infoHostingController.view)
		infoHostingController.view.anchor(top: view.safeAreaLayoutGuide.topAnchor,
																			left: view.safeAreaLayoutGuide.leftAnchor,
																			right: view.safeAreaLayoutGuide.rightAnchor)
	}
	
	private func layoutBehindView() {
		behindViewHostingController = UIHostingController(rootView: AnyView(
			behindView
				.environmentObject(cardInfo)
		))
		behindViewHostingController.willMove(toParent: self)
		view.addSubview(behindViewHostingController.view)
		behindViewHostingController.view.anchor(top: view.safeAreaLayoutGuide.topAnchor,
																						left: view.safeAreaLayoutGuide.leftAnchor,
																						bottom: view.safeAreaLayoutGuide.bottomAnchor,
																						right: view.safeAreaLayoutGuide.rightAnchor)
	}
	
	private func loadBatch() {
		loadingBatch = true
		batchesLoaded += 1
		
		var newCards = [PhotoCard]()
		for _ in 0..<3  {
			newCards.append(PhotoCard())
		}
		
		photosController.loadRandomPhotos(for: newCards) {
			for card in newCards {
				card.id = self.cards.count
				self.cards.append(card)
				self.cardStack.appendCards(atIndices: [card.id])
			}
			
			if self.loadingBatch {
				UIView.animate(withDuration: 0.3) {
					self.cardStack.alpha = 1
					self.buttonStackView.alpha = 1
				}
				self.loadingBatch = false
				self.updateCurrentItem()
			}
		}
	}
	
	private func updateCurrentItem() {
		if cards.count > 0 {
			let index = cardStack.topCardIndex ?? 0
			cardInfo.setCard(cards[index], summary: false)
		}
	}
	
	private func fetchAlert() {
#if RELEASE || DEBUG
		let url = URL(string: "https://swiped.pics/beta/conf.json")!
#else
		let url = URL(string: "https://swiped.pics")!
#endif
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				print("Error: \(error.localizedDescription)")
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
				print("Could not fetch config")
				return
			}
			
			guard let data = data else {
				print("Error: No data received")
				return
			}
			
			guard let json = try? JSONDecoder().decode(SettingsJson.self, from: data) else {
				os_log(.error, "⚠️ Failed to parse JSON request.")
				return
			}
			
			if !json.isAlertEnabled {
				return
			}
			
			DispatchQueue.main.async {
				if let appliesToVersion = json.appliesToVersion,
					 self.version.compare(appliesToVersion, options: .numeric) != .orderedDescending {
					if let buildNumber = Int(self.build),
						 let appliesToBuild = Int(json.appliesToBuild ?? ""),
						 appliesToBuild >= buildNumber {
						
						let alert = UIAlertController(title: json.alertTitle, message: json.alertContents, preferredStyle: .alert)
						
						if let buttonText = json.alertButtonText {
							alert.addAction(UIAlertAction(title: buttonText, style: .default, handler: { _ in
								if let buttonURL = json.alertButtonURL,
									 let url = URL(string: buttonURL) {
									UIApplication.shared.open(url)
								}
							}))
						}
						
						self.present(alert, animated: true)
					}
				}
				
			}
		}
		task.resume()
	}
}

// MARK: Data Source + Delegates

extension ViewController: PhotosController.PhotoLoadDelegate {
	func didLoadThumbnail(for card: PhotoCard, image: UIImage) {
		//print("loaded thumbnail for \(card.id)")
		card.thumbnail = image
		
		if let swipeCard = cardStack.card(forIndexAt: card.id),
			 let contentView = swipeCard.content as? CardContentView {
			contentView.updateCard()
		}
	}
	
	func didLoadFullImage(for card: PhotoCard, image: UIImage) {
		//print("loaded full image for \(card.id)")
		card.fullImage = image
		
		if let swipeCard = cardStack.card(forIndexAt: card.id),
			 let contentView = swipeCard.content as? CardContentView {
			contentView.updateCard()
		}
		
		updateCurrentItem()
	}
	
	func didFail(error: PhotosController.PhotoError) {
		print("Photo controller error: \(error.localizedDescription)")
		
		switch error {
		case .noAccessToPhotoLibrary, .noPhotosAvailable:
			let alert = UIAlertController(title: "No Photos!", message: "Your Photos library is empty, or you limited access.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
				UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
			}))
			present(alert, animated: true)
			
		case .noPhotosLeft:
			let alert = UIAlertController(title: "You’ve swiped all your photos", message: "Come back later when you need to clean up!", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
			present(alert, animated: true)
			
			didSwipeAllCards(cardStack)
			
		case .failedToDelete:
			let alert = UIAlertController(title: "Failed to delete photo", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
			present(alert, animated: true)
			
		case .failedToFetchPhoto:
			let idiom = UIDevice.current.userInterfaceIdiom
			
			if idiom == .phone {
				let alert = UIAlertController(title: "Oh Bugger!🪲", message: "We couldn't load your photo library. Please try again later.", preferredStyle: .alert)
				present(alert, animated: true)
			} else if idiom == .pad {
				let alert = UIAlertController(title: "swiped is not yet supported on this device.", message: "", preferredStyle: .alert)
				present(alert, animated: true)
			} else {
				// It's something else
			}
			/*
			 
			 */
			break
		}
	}
}
extension ViewController: SwipeCardStackDataSource, SwipeCardStackDelegate, ButtonStackView.Delegate, BehindView.Delegate {
	
	func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
		let card = SwipeCard()
		card.footerHeight = 80
		card.swipeDirections = [.left, .right]
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
		
		photosController.delete(cards: toDelete) { success in
			if !success {
				for card in self.toDelete {
					if let photo = card.photo {
						photo.choice = .skip
						DatabaseController.shared.addPhoto(photo: photo)
					}
				}
			}
			
			self.toDelete.removeAll()
		}
		
		cardStack.isUserInteractionEnabled = false
		buttonStackView.isUserInteractionEnabled = false
		
		Task {
			await ServerController.shared.doSync()
		}

		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.3) {
				self.cardStack.alpha = 0
				self.buttonStackView.alpha = 0
				self.behindViewHostingController.view.alpha = 1
			}

			self.cardInfo.setCard(nil, summary: true)
		}
	}
	
	func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
		print("Undo")
		updateCurrentItem()
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
			toDelete.removeAll(where: { $0.id == card.id })
			
		case .up:
			choice = .skip
			
		case .down:
			fatalError()
		}
		
		guard let photo = card.photo else {
			return
		}
		
		photo.choice = choice
		photo.swipeDate = Date()
		DatabaseController.shared.addPhoto(photo: photo)
		
		if direction == .up {
			if let image = card.fullImage ?? card.thumbnail {
				let shareSheet = UIActivityViewController(activityItems: [image], applicationActivities: [])
				present(shareSheet, animated: true)
			}
		}
		
		updateCurrentItem()
	}
	
	func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
		print("Card tapped")
		
		do {
			let card = cards[index]
			if let asset = card.asset {
				if asset.mediaType == .video {
					let playerViewController = AVPlayerViewController()
					present(playerViewController, animated: true)
					photosController.getVideoPlayer(asset: asset) { player in
						playerViewController.player = player
						try? AVAudioSession.sharedInstance().setCategory(.playback)
						player.play()
					}
				} else {
					if let data = card.fullImage?.pngData() {
						let temp = FileManager.default.temporaryDirectory.appendingPathComponent("Photo.png")
						try data.write(to: temp)
						previewItem = temp
						
						let quickLook = QLPreviewController()
						quickLook.delegate = self
						quickLook.dataSource = self
						present(quickLook, animated: true)
					}
				}
			}
		} catch {
			print("Error in quick look \(error.localizedDescription)")
		}
	}
	
	func didTapButton(action: ButtonStackView.Action) {
		switch action {
		case .undo:
			cardStack.undoLastSwipe(animated: true)
		case .delete:
			cardStack.swipe(.left, animated: true)
		case .keep:
			cardStack.swipe(.right, animated: true)
		}
	}
	
	func didTapContinue() {
		cardStack.isUserInteractionEnabled = true
		buttonStackView.isUserInteractionEnabled = true

		UIView.animate(withDuration: 0.3) {
			//self.cardStack.alpha = 1
			//self.buttonStackView.alpha = 1
			self.behindViewHostingController.view.alpha = 0
		} completion: { _ in
			self.loadBatch()
		}

		if batchesLoaded == 4 && !UserDefaults.standard.bool(forKey: "requestedReview") {
			UserDefaults.standard.set(true, forKey: "requestedReview")
			AppStore.requestReview(in: self.view.window!.windowScene!)
		}
		
		// Release all but the last card from memory
		let oldCount = cards.count
		if oldCount != 0 {
			let allButLast = 0..<oldCount - 1
			cards.removeSubrange(allButLast)
			
			var indices = [Int]()
			for i in allButLast {
				indices.append(i)
			}
			cardStack.deleteCards(atIndices: indices)
		}
	}
	
}

extension ViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
	func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
		return 1
	}
	
	func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
		return previewItem! as QLPreviewItem
	}
	
	func previewControllerWillDismiss(_ controller: QLPreviewController) {
		if let previewItem = previewItem {
			try? FileManager.default.removeItem(at: previewItem)
			self.previewItem = nil
		}
	}
}

