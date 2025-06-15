//
//  InternalView.swift
//  swiped.
//
//  Created by tobykohlhagen on 12/5/2025.
//

import SwiftUI
import Combine

struct InternalView: View {
	@State var showImportantInfo = false
	@ObservedObject var coordinationServer = Coordination()
	@AppStorage("sync")
	var sync: Bool = false
	var body: some View {
		Spacer()
		VStack {
			Text("⚠️Be careful what you wish for!⚠️").font(Fonts.bodyBold)
				.padding()
			Text("Things in here are experimental, and could fail.").font(Fonts.body)
		}
		
		Form {
			Section {
				// where settings go
				Text("Trigger Unsupported")
					.onTapGesture {
						showImportantInfo = true
					}
					.sheet(isPresented: $showImportantInfo) {
						ImportantInfoView()
					}
				
					.listRowBackground(Color("listRowBackground")).font(Fonts.body)
			}
			
			
		}
		.navigationTitle("Internal")
		.toolbar(removing: .title)
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
