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
import Sentry

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
#elseif SHOWCASE
	static let cardsPerStack = 10
#else
	static let cardsPerStack = 20
#endif

	var version: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}
	
	var build: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
	}
	
	var modelContext: ModelContext! {
		didSet {
			db = DatabaseController(modelContainer: modelContext.container)
			photosController.db = db
		}
	}

	// add the sheet manager
	var sheetManager: SheetManager!
	var cardInfo: CardInfo!

	private var db: DatabaseController!
	
	private let cardStack = SwipeCardStack()

	private let photosController = PhotosController()
	private var cards = [PhotoCard]()
	private var toDelete = [PhotoCard]()
	private var loadingBatch = true
	private var batchesLoaded = 0
	private var swipedAll = false
	
	private var previewItem: URL?
	
	override func viewDidLoad() {
		super.viewDidLoad()

		fetchAlert()
		//view.backgroundColor = UIColor.black
		cardStack.delegate = self
		cardStack.dataSource = self
		photosController.delegate = self

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
	
	private func layoutCardStackView() {
		view.addSubview(cardStack)
		cardStack.anchor(top: view.topAnchor,
										 left: view.leftAnchor,
										 bottom: view.bottomAnchor,
										 right: view.rightAnchor)
	}

	private func loadBatch() {
		Task {
			let logger = Logger(subsystem: "Batch Loader", category: "Cards")
			logger.debug("Creating stack of cards..")
			loadingBatch = true
			batchesLoaded += 1

			var newCards = [PhotoCard]()
			/// Defines number of cards to show. CSN
			for _ in 0..<Self.cardsPerStack {
				newCards.append(PhotoCard())
			}

			do {
				try await photosController.loadRandomPhotos(for: newCards)
			} catch let error as PhotosController.PhotoError {
				await MainActor.run {
					self.didFail(error: error)
				}
			}

			for card in newCards {
				card.id = self.cards.count
				self.cards.append(card)
				self.cardStack.appendCards(atIndices: [card.id])
			}

			if self.loadingBatch {
				await MainActor.run {
					UIView.animate(withDuration: 0.3, delay: 0.3) {
						self.cardStack.alpha = 1
					}
					self.loadingBatch = false
					self.swipedAll = false
					self.cardInfo.appReady = true
					self.updateCurrentItem()
				}
			}
		}
	}
	
	private func updateCurrentItem() {
		if cards.count > 0 && !swipedAll {
			let index = cardStack.topCardIndex ?? 0
			cardInfo.setCard(cards[index], position: cardStack.swipedCards().count, summary: false)
		}
	}
	
	private func fetchAlert() {
		let logger = Logger(subsystem: "Fetch Alert", category: "Initialization")
		let url = URL(string: "https://swiped.pics/api/v2/conf.json")!
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				SentrySDK.capture(error: error)
				logger.error("⚠️ \(error.localizedDescription)")
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
				SentrySDK.capture(message: "Server returned a response code other than 200.")
				logger.error("Server returned a response code other than 200.")
				return
			}
			
			guard let data = data else {
				SentrySDK.capture(message: "Server returned no data.")
				logger.error("Server returned no data.")
				return
			}
			
			
			guard let json = try? JSONDecoder().decode(SettingsJson.self, from: data) else {
				SentrySDK.capture(message: "Server returned malformed JSON.")
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
	@MainActor
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
			let alert = UIAlertController(title: "Oh Bugger!🪲", message: "We couldn't load your photo library. Please try again later.", preferredStyle: .alert)
			present(alert, animated: true)
			break
		}
	}
}
extension ViewController: SwipeCardStackDataSource, SwipeCardStackDelegate, ActionButtonsView.Delegate, BehindView.Delegate {

	func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
		let card = SwipeCard()
		card.footerHeight = 80
		card.swipeDirections = [.left, .right]
		for direction in card.swipeDirections {
			card.setOverlay(CardOverlayWrapperView(direction: direction), forDirection: direction)
		}
		
		card.content = CardContentWrapperView(card: cards[index])

		return card
	}
	
	func numberOfCards(in cardStack: SwipeCardStack) -> Int {
		return cards.count
	}
	
	func didSwipeAllCards(_ cardStack: SwipeCardStack) {
		let logger = Logger(subsystem: "Swiped all cards", category: "Cards")
		logger.debug("Swiped all cards")

		swipedAll = true
		
#if !SHOWCASE
		// Disabled in showcase mode
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
#endif
	
		
		cardStack.isUserInteractionEnabled = false
		
		Task {
			await ServerController.shared.doSync(db: db)
		}
		
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.3) {
				self.cardStack.alpha = 0
			}
			
			self.cardInfo.setSummary(true)
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
#if !SHOWCASE
			// Disabled in showcase mode
			await self.db.addPhoto(photo: photo)
#endif
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
	// Deprecated in v2 in favor of a custom quick look view. See CardContentView.swift for replacement or see 06ba959 for former code. 
	return
	}
	
	func didTapButton(action: ActionButtonsView.Action) {
		switch action {
		case .undo:
			cardStack.undoLastSwipe(animated: true)
		case .delete:
			cardStack.swipe(.left, animated: true)
		case .keep:
			cardStack.swipe(.right, animated: true)
		case .share:
			break
		}
	}
	
	// updated this function to use the sheet manager
	func showUnsupportedMessage(json: SettingsJson) {
		sheetManager.triggerImportantInfo(json: json)
	}
	
	func didTapContinue() {
		cardStack.isUserInteractionEnabled = true

		loadBatch()
		
		if batchesLoaded == 4 && !UserDefaults.standard.bool(forKey: "requestedReview") {
			UserDefaults.standard.set(true, forKey: "requestedReview")
			AppStore.requestReview(in: view.window!.windowScene!)
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

struct MainViewControllerView: UIViewControllerRepresentable {
	@Environment(\.modelContext) private var modelContext

	@EnvironmentObject private var sheetManager: SheetManager

	@EnvironmentObject private var cardInfo: CardInfo

	let onCoordinatorCreated: (Coordinator) -> Void

	init(onCoordinatorCreated: @escaping (Coordinator) -> Void) {
		self.onCoordinatorCreated = onCoordinatorCreated
	}

	func makeUIViewController(context: Context) -> ViewController {
		let viewController = ViewController()
		viewController.modelContext = modelContext
		context.coordinator.viewController = viewController
		onCoordinatorCreated(context.coordinator)
		return viewController
	}

	func updateUIViewController(_ viewController: ViewController, context: Context) {
		viewController.sheetManager = sheetManager
		viewController.cardInfo = cardInfo
	}

	func makeCoordinator() -> Coordinator {
		return Coordinator()
	}

	// Bridge the delegates back into the view controller while the logic for them is still here
	class Coordinator: NSObject, ActionButtonsView.Delegate, BehindView.Delegate {
		weak var viewController: ViewController?

		func didTapButton(action: ActionButtonsView.Action) {
			viewController?.didTapButton(action: action)
		}

		func didTapContinue() {
			viewController?.didTapContinue()
		}
	}
}
