//
//  ServerController.swift
//  swiped.
//
//  Created by Adam Demasi on 10/05/2025.
//

import Foundation
import StoreKit
import SwiftUI
import Combine
import os

extension UserDefaults {
	@objc var sync: Bool {
		get { bool(forKey: "sync") }
		set { set(newValue, forKey: "sync") }
	}
}

struct RegisterRequest: Codable {
	let receipt: String?
	
}


struct SyncRequest: Codable {
	let receipt: String?
	let totalKept: Int
	let totalDeleted: Int
	let totalPhotoDeleted: Int
	let totalVideoDeleted: Int
	let spaceSaved: Int
	let swipeScore: Int64
}
// INTERNAL BUILDS
/*#if INTERNAL
class ServerController: NSObject {

	
	static let shared = ServerController()

	var syncFailed = false
	
	func getReceipt() async -> String? {
		return "Internal Build"
	}
	
	func doRegister() async {
		var syncFailed = true
	}
	
	func doSync() async {
		var syncFailed = true
	}
	
}
*///#else
// Release Builds
class ServerController: NSObject, ObservableObject {
	
	static let shared = ServerController()
#if !INTERNAL
	@AppStorage("sync")
	var sync: Bool = false
#else
	var sync: Bool = true
#endif
	
	static let server = URL(string: "https://swiped.pics/")!
	
	@Published var syncFailed = true
	
	private var syncPublisher: AnyCancellable?
	
	override init() {
		super.init()

		syncPublisher = UserDefaults.standard.publisher(for: \.sync)
			.sink { _ in
				if self.sync {
					self.syncFailed = false
				} else {
					Task {
						await self.doRegister()
					}
				}
			}
	}
	
	func getReceipt() async -> String? {
		await MainActor.run {
			self.syncFailed = true
		}
		
		var result: VerificationResult<AppTransaction>?
		do {
			result = try await AppTransaction.shared
		} catch {
			os_log(.error, "⚠️ Failed transaction. \(error)")
		}
		
		switch result {
		case .verified(_):
			break
			
		case .unverified(_, let verificationError):
			os_log(.error, "⚠️ Could not verify app receipt. \(verificationError)")
			
		case .none:
			return nil
		}
		
		return result?.jwsRepresentation
	}
	
	func doRegister() async {
		await MainActor.run {
			self.syncFailed = true
		}

		let syncFailed: Bool
		if (!sync) {
			print("🌐 Connecting with \(Self.server)")
			let receipt = await getReceipt()
			let data = RegisterRequest(receipt: receipt)
			
			var request = URLRequest(url: Self.server.appendingPathComponent("register"))
			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = try? JSONEncoder().encode(data)
			
			guard let (_, res) = try? await URLSession.shared.data(for: request) else {
				return
			}
			
			guard let res = res as? HTTPURLResponse else {
				return
			}
			
			syncFailed = res.statusCode != 200
		} else {
			syncFailed = false
		}

		
		await MainActor.run {
			self.syncFailed = syncFailed
		}
	}
	
	func doSync() async {
		if (!sync) {
			let db = DatabaseController.shared
			let receipt = await getReceipt()
			let data = SyncRequest(receipt: receipt,
														 totalKept: db.getTotalKept(),
														 totalDeleted: db.getTotalDeleted(),
														 totalPhotoDeleted: db.getTotalPhotoDeleted(),
														 totalVideoDeleted: db.getTotalVideoDeleted(),
														 spaceSaved: Int(db.getSpaceSaved()),
														 swipeScore: db.calcSwipeScore())
			
			var request = URLRequest(url: Self.server.appendingPathComponent("sync"))
			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = try? JSONEncoder().encode(data)
			
			guard let (_, res) = try? await URLSession.shared.data(for: request) else {
				return
			}
			
			guard let res = res as? HTTPURLResponse else {
				return
			}
			
			syncFailed = res.statusCode != 200
		}
	}
	
}
//#endif

