
//
//  AdvancedView.swift
//  swiped.
//
//  Created by tobykohlhagen on 20/5/2025.
//
import SwiftUI
import Combine

struct AdvancedView: View {
	@State private var showRestriction = false
#if !INTERNAL
	@AppStorage("sync")
	var sync: Bool = false
#else
	@State
	var sync: Bool = true
#endif
	@StateObject var serverController = ServerController.shared

	
	var body: some View {
		Spacer()
		VStack {
			Form {
				syncSection
				
#if INTERNAL
				// INTERNAL FLAGS
				Section {
					NavigationLink("Internal") {
						InternalView()
					}
					.font(.custom("LoosExtended-Regular", size: 16))
					.listRowBackground(Color("listRowBackground"))
				}
#endif
				
				/*Section {
					Toggle(isOn: $sync) {
						Text("Disable Sync")
							.font(.custom("LoosExtended-Regular", size: 16))
					}
					.listRowBackground(Color("listRowBackground"))
					#if INTERNAL
					.disabled(true)
					#endif
					
				}
				 */
			}
			.scrollContentBackground(.hidden)
			.background(Color(uiColor: .systemBackground))
		}
	}
	
	var syncSection: some View {
		let syncFailed = !sync && serverController.syncFailed
		
		return Section {
			HStack {
				Text("SYNC.")
					.font(.custom("LoosExtended-Bold", size: 16))
					.foregroundColor(syncFailed ? .black : .primary)
				Spacer()
				if (!sync) {
					Text(syncFailed ? "Restricted." : "Connected")
						.font(.custom("LoosExtended-Regular", size: 16))
						.foregroundColor(syncFailed ? .black : Color("syncStatus"))
						.onTapGesture {
							if syncFailed {
								showRestriction = true
							}
						}
						.sheet(isPresented: $showRestriction) {
							RestrictionView()
						}
				} else {
					Text("Disabled")
						.font(.custom("LoosExtended-Regular", size: 16))
						.foregroundColor(.gray)
				}
			}
		}
		.listRowBackground(syncFailed ? .yellow : Color("listRowBackground"))
	}
}

#Preview {
	AdvancedView()
}

