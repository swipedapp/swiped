//
//  InternalView.swift
//  swiped.
//
//  Created by tobykohlhagen on 12/5/2025.
//

import SwiftUI
import Combine
 
struct InternalView: View {
	// add this class for managing the sheet
	class SheetManager: ObservableObject {
		@Published var showImportantInfo = false
		@Published var json: SettingsJson?
		
		func triggerImportantInfo(json: SettingsJson) {
			showImportantInfo = true
			self.json = json
		}
	}
	@EnvironmentObject var sheetManager: SheetManager
	// updated this function to use the sheet manager
	func showUnsupportedMessage(json: SettingsJson) {
		sheetManager.triggerImportantInfo(json: json)
	}
	@ObservedObject var coordinationServer = Coordination()
	@AppStorage("sync")
	var sync: Bool = false
	var body: some View {
		Spacer()
		VStack {
			Text("⚠️Be careful what you wish for!⚠️").font(.custom("LoosExtended-Bold", size: 16))
				.padding()
			Text("Things in here are experimental, and could fail.").font(.custom("LoosExtended-Regular", size: 16))
		}
		
		Form {
			Section {
				// where settings go
				NavigationLink("Trigger Unsupported") {
					showUnsupportedMessage(json: json_copy)
				}
				.font(.custom("LoosExtended-Regular", size: 16))
				.listRowBackground(Color("listRowBackground"))
				
			}
			
			
		}
	}
	
}
class Coordination : ObservableObject {
	private static let userDefaultTextKey = "textKey"
	@Published var text = UserDefaults.standard.string(forKey: Coordination.userDefaultTextKey) ?? ""
	private var canc: AnyCancellable!
	
	init() {
		canc = $text.debounce(for: 0.2, scheduler: DispatchQueue.main).sink { newText in
			UserDefaults.standard.set(newText, forKey: Coordination.userDefaultTextKey)
		}
	}
	
	deinit {
		canc.cancel()
	}
}
#Preview {
	InternalView()
}
