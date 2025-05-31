//
//  ViewController.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit
import reShuffled
import QuickLook
import StoreKit
import AVKit
import SwiftUI
import os
import SwiftData

// add this class for managing the sheet
class SheetManager: ObservableObject {
	@Published var showImportantInfo = false
	@Published var json: SettingsJson?
	func triggerImportantInfo(json: SettingsJson) {
		showImportantInfo = true
	}
}

class ViewController: UIViewController {

#if INTERNAL
	static let cardsPerStack = 3
#else
	static let cardsPerStack = 20
#endif

	@State private var unsupportedios = true
	// add the sheet manager
	private let sheetManager = SheetManager()
	
	var version: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}
	
	var build: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
	}
	
	var modelContext: ModelContext! {
		didSet {
			db = DatabaseController(modelContainer: modelContext.container)
		}
	}
	
	private var db: DatabaseController!
	
	private let cardStack = SwipeCardStack()
	private var mainView: MainView!
	private var mainHostingController: UIHostingController<AnyView>!
	
	private let photosController = PhotosController()
	private var cards = [PhotoCard]()
	private var toDelete = [PhotoCard]()
	private var loadingBatch = true
	private var batchesLoaded = 0
	
	private let cardInfo = CardInfo()
	
	private var previewItem: URL?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		photosController.db = db
		
#if !INTERNAL
		fetchAlert()
#endif
		//view.backgroundColor = UIColor.black
		cardStack.delegate = self
		cardStack.dataSource = self
		mainView = MainView()
		mainView.delegate = self
		photosController.delegate = self
		
		configureNavigationBar()
		layoutMainView()
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
	
	private func layoutCardStackView() {
		view.addSubview(cardStack)
		cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
										 left: view.safeAreaLayoutGuide.leftAnchor,
										 bottom: view.safeAreaLayoutGuide.bottomAnchor,
										 right: view.safeAreaLayoutGuide.rightAnchor,
										 paddingTop: 76,
										 paddingBottom: 56)
	}
	
	private func layoutMainView() {
		mainHostingController = UIHostingController(rootView: AnyView(
			mainView
				.environmentObject(cardInfo)
				.environmentObject(sheetManager)
				.modelContext(modelContext)
		))
		mainHostingController.willMove(toParent: self)
		view.addSubview(mainHostingController.view)
		mainHostingController.view.anchor(top: view.safeAreaLayoutGuide.topAnchor,
																			left: view.safeAreaLayoutGuide.leftAnchor,
																			bottom: view.safeAreaLayoutGuide.bottomAnchor,
																			right: view.safeAreaLayoutGuide.rightAnchor)
	}
	
	private func loadBatch() {
		let logger = Logger(subsystem: "Batch Loader", category: "Cards")
		logger.debug("Creating stack of cards..")
		loadingBatch = true
		batchesLoaded += 1
		
		var newCards = [PhotoCard]()
		/// Defines number of cards to show. CSN
		for _ in 0..<Self.cardsPerStack {
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
				}
				self.loadingBatch = false
				self.updateCurrentItem()
			}
		}
	}
	
	private func updateCurrentItem() {
		if cards.count > 0 {
			let index = cardStack.topCardIndex ?? 0
			print("\(cardStack.swipedCards().count)")
			cardInfo.setCard(cards[index], position: cardStack.swipedCards().count, summary: false)
		}
	}
	
	private func fetchAlert() {
		let logger = Logger(subsystem: "Fetch Alert", category: "Initialization")
#if RELEASE || DEBUG
		let url = URL(string: "https://swiped.pics/beta/conf.json")!
#else
		let url = URL(string: "https://swiped.pics")!
#endif
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				os_log(.error, "⚠️ \(error.localizedDescription)")
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
				logger.error("Server returned a response code other than 200.")
				return
			}
			
			guard let data = data else {
				os_log(.error, "⚠️ Server returned no data")
				logger.error("Server returned no data.")
				return
			}
			
			
			guard let json = try? JSONDecoder().decode(SettingsJson.self, from: data) else {
				logger.error("Server returned malformed JSON.")
				return
			}
			
			if !json.isAlertEnabled {
				return
			}
			
			DispatchQueue.main.async {
				self.sheetManager.json = json
				if let minimumiOSVersion = json.minimumiOSVersion,
					 UIDevice.current.systemVersion.compare(minimumiOSVersion, options: .numeric) == .orderedAscending,
					 UserDefaults.standard.object(forKey: "supportAlertLastVersion") as? String != self.version {
					self.showUnsupportedMessage(json: json)
					return
				}
				
				if let appliesToVersion = json.appliesToVersion,
					 self.version.compare(appliesToVersion, options: .numeric) != .orderedDescending {
					if let buildNumber = Int(self.build),
						 let appliesToBuild = Int(json.appliesToBuild ?? ""),
						 appliesToBuild >= buildNumber {
						
						let alert = UIAlertController(title: json.alertTitle, message: json.alertContents, preferredStyle: .alert)
						
						if json.isButtonEnabled,
							 let buttonText = json.alertButtonText {
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
		
		card.thumbnail = image
		
		if let swipeCard = cardStack.card(forIndexAt: card.id),
			 let contentView = swipeCard.content as? CardContentView {
			contentView.updateCard()
		}
	}
	
	func didLoadFullImage(for card: PhotoCard, image: UIImage) {
		card.fullImage = image
		
		if let swipeCard = cardStack.card(forIndexAt: card.id),
			 let contentView = swipeCard.content as? CardContentView {
			contentView.updateCard()
		}
		
		updateCurrentItem()
	}
	
	func didFail(error: PhotosController.PhotoError) {
		let logger = Logger(subsystem: "didFail", category: "PhotoController")
		logger.critical("PhotoController Error: \(error.localizedDescription)")
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
			// This shows an alert if theres an issue loading the library.
			let idiom = UIDevice.current.userInterfaceIdiom
			let alert = UIAlertController(title: "Oh Bugger!🪲", message: "We couldn't load your photo library. Please try again later.", preferredStyle: .alert)
			present(alert, animated: true)
			break
		}
	}
}
extension ViewController: SwipeCardStackDataSource, SwipeCardStackDelegate, MainView.Delegate, BehindView.Delegate {
	
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
		let logger = Logger(subsystem: "Swiped all cards", category: "Cards")
		logger.debug("Swiped all cards")
		
		photosController.delete(cards: toDelete) { success in
			if !success {
				Task {
					for card in self.toDelete {
						if let photo = card.photo {
							photo.choice = .skip
							await self.db.addPhoto(photo: photo)
						}
					}
				}
			}
			
			self.toDelete.removeAll()
		}
		
		cardStack.isUserInteractionEnabled = false
		
		Task {
			await ServerController.shared.doSync(db: db)
		}
		
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.3) {
				self.cardStack.alpha = 0
			}
			
			self.cardInfo.setCard(nil, position: 0, summary: true)
		}
	}
	
	func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
		let logger = Logger(subsystem: "Undo Card", category: "Cards")
		logger.debug("Undid Swipe")
		updateCurrentItem()
	}
	
	func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
		let logger = Logger(subsystem: "Swipe Card", category: "Cards")
		logger.debug("Swiped \(direction)")
		let card = cards[index]
		
		var choice: Photo.Choice
		switch direction {
		case .left:
			choice = .delete
			toDelete.append(cards[index])
			
		case .right:
			choice = .keep
			toDelete.removeAll(where: { $0.photo?.id == card.photo?.id })
			
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
		
		Task {
			await self.db.addPhoto(photo: photo)
		}
		
		if direction == .up {
			if let image = card.fullImage ?? card.thumbnail {
				let shareSheet = UIActivityViewController(activityItems: [image], applicationActivities: [])
				present(shareSheet, animated: true)
			}
		}
		
		updateCurrentItem()
	}
	
	func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
		let logger = Logger(subsystem: "Quick Look", category: "Cards")
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
			logger.critical("Could not present quick look: \(error.localizedDescription)")
		}
	}
	
	func didTapButton(action: MainView.Action) {
		switch action {
		case .undo:
			cardStack.undoLastSwipe(animated: true)
		case .delete:
			cardStack.swipe(.left, animated: true)
		case .keep:
			cardStack.swipe(.right, animated: true)
		}
	}
	
	// updated this function to use the sheet manager
	func showUnsupportedMessage(json: SettingsJson) {
		sheetManager.triggerImportantInfo(json: json)
	}
	
	func didTapContinue() {
		cardStack.isUserInteractionEnabled = true
		
		UIView.animate(withDuration: 0.3) {
			//self.cardStack.alpha = 1
			//self.buttonStackView.alpha = 1
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
