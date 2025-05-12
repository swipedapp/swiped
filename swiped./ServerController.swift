//
//  ServerController.swift
//  swiped.
//
//  Created by Adam Demasi on 10/05/2025.
//

import Foundation
import StoreKit

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

class ServerController: NSObject {

	static let shared = ServerController()

	static let server = URL(string: "https://swiped.missaustraliana.net")!

	var syncFailed = true

	func getReceipt() async -> String? {
		syncFailed = true

		var result: VerificationResult<AppTransaction>?
		do {
			result = try await AppTransaction.shared
		} catch {
			print("Transaction error: \(error)")
		}

		switch result {
		case .verified(_):
			break

		case .unverified(_, let verificationError):
			print("Receipt error: \(verificationError)")

		case .none:
			return nil
		}

		return result?.jwsRepresentation
	}

	func doRegister() async {
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
	}

	func doSync() async {
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
