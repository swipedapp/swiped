//
//  SettingsJson.swift
//  swiped.
//
//  Created by tobykohlhagen on 6/5/2025.
//

import Foundation

class SettingsJson: Codable {
	let isAlertEnabled: Bool
	let alertTitle: String?
	let alertContents: String?
	let alertButtonText: String?
	let alertButtonURL: String?
	let appliesToBuild: String?
	let appliesToVersion: String?
}
