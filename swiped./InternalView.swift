//
//  InternalView.swift
//  swiped.
//
//  Created by tobykohlhagen on 12/5/2025.
//

import SwiftUI
import Combine

struct InternalView: View {
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
				TextField("Custom coordination server", text: $coordinationServer.text)
				Toggle(isOn: $sync) {
					Text("Disable Sync")
						.font(.custom("LoosExtended-Regular", size: 16))
				}
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
