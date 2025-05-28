//
//  ImportantInfoView.swift
//  swiped.
//
//  Created by tobykohlhagen on 24/5/2025.
//

import SwiftUI

struct ImportantInfoView: View {

	@EnvironmentObject var sheetManager: SheetManager

	var json: SettingsJson? {
		return sheetManager.json
	}

	var body: some View {
		NavigationView {
			VStack {
				ZStack(alignment: .top) {
					HStack {
						Image(systemName: "chevron.down")
						Text("Swipe down to dismiss")
						Image(systemName: "chevron.down")
					}
					.textCase(.uppercase)
					.font(.custom("LoosExtended-Regular", size: 14))
					.foregroundColor(Color(uiColor: .secondaryLabel))
					.padding(.top, 17)
				}

				Image(systemName: json?.hasDroppedSupport ?? false ? "xmark.shield.fill" : "exclamationmark.shield.fill")
					.font(.system(size: 80))
					.foregroundColor(json?.hasDroppedSupport ?? false ? .brandRed : .primary)
					.padding([.bottom, .top], 20)
				Spacer()
				Text("You're on iOS \(UIDevice.current.systemVersion)")
				//.font(.custom("LoosExtended-Bold", size: 23))
					.font(.custom("LoosExtended-Bold", size: 23))
					.padding(.bottom, 20)

				VStack(alignment: .leading) {
					if json?.hasDroppedSupport ?? false {
						Text("As we continue to pave the way for the future of this app, we sometimes need new tools. Tools that simply don't exist on your version of iOS.\n\nWe have discontinued support for your version of iOS. Meaning you will no longer receive quality updates. Please update iOS or switch to a device that is compatible with iOS \(json?.minimumiOSVersion ?? "17.0") or later.")
					} else {
						Text("As we continue to pave the way for the future of this app, we sometimes need new tools. Tools that simply don't exist on your version of iOS.\n\nWe unfortunately will be dropping support for your version of iOS to adapt to the evolution of tomorrows tech. We know it's not ideal, but we recommend you update to a later version of iOS to get future updates from this app.")
					}

					Text("\nYou can disable this popup at any time in the Settings pane.")

					Spacer()
				}
				.font(.custom("LoosExtended-Regular", size: 16))
				.padding(.horizontal, 30)
				.padding(.vertical, 20)
			}
			.background(Color(uiColor: .systemBackground))
			.navigationBarHidden(true)
		}
	}
}

#Preview {
	let sheetManager = SheetManager()
	sheetManager.showImportantInfo = true

	let json = """
	{
		"isAlertEnabled": false,
		"isButtonEnabled": false,
		"minimumiOSVersion": "19.0",
		"hasDroppedSupport": true
	}
	"""
	sheetManager.json = try! JSONDecoder().decode(SettingsJson.self, from: json.data(using: .utf8)!)

	return ImportantInfoView()
		.environmentObject(sheetManager)
}
