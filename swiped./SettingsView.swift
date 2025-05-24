//
//  SettingsView.swift
//  swiped.
//
//  Created by Adam Demasi on 10/05/2025.
//
import SwiftUI

struct SettingsView: View {
	@State var showRestriction = false
	let commitInfo = Bundle.main.infoDictionary?["GitCommitHash"] as? String ?? "Unknown"
	
	@AppStorage("timestamps")
	var timestamps: Bool = false
	
	var version: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}
	
	var build: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
	}
	
	
	

	
	
	@State
	var showResetAlert: Bool = false
	
	@AppStorage("swipeDownCount")
	var swipeDownCount = 0

	@Environment(\.modelContext) var modelContext

	var body: some View {
		NavigationStack {
			VStack {
				Form {
					Section(content: {}, header: {
						ZStack(alignment: .top) {
							if swipeDownCount < 5 {
								HStack {
									Image(systemName: "chevron.down")
									Text("Swipe down to dismiss")
									Image(systemName: "chevron.down")
								}
								.font(.custom("LoosExtended-Regular", size: 14))
							}
							
							HStack {
								Spacer()
								VStack(alignment: .center) {
									Text("SWIPED")
										.foregroundColor(.primary)
										.font(.custom("LoosExtended-Bold", size: 50))
									+
									Text(".")
										.foregroundColor(Color("brandGreen"))
										.font(.custom("LoosExtended-Bold", size: 50))
#if !INTERNAL
									Text("Version \(version) (\(build))")
										.font(.custom("LoosExtended-Medium", size: 18))
#endif
								}
								Spacer()
							}
							.padding(.vertical, 30)
						}
					})
					
					
					// Production flags
					Toggle(isOn: $timestamps) {
						
						Text("Show relative timestamps")
							.font(.custom("LoosExtended-Regular", size: 16))
						
					}.listRowBackground(Color("listRowBackground"))
					NavigationLink("App Icons") {
						SettingsIconView(collection: "main")
					}.listRowBackground(Color("listRowBackground")).font(.custom("LoosExtended-Regular", size: 16))
					NavigationLink("Advanced") {
						AdvancedView()
					}
					.font(.custom("LoosExtended-Regular", size: 16))
					.listRowBackground(Color("listRowBackground"))
					
					Section {
						Button(action: {
							showResetAlert = true
						}, label: {
							HStack {
								Spacer()
								Label("Reset Database", systemImage: "xmark.bin")
									.font(.custom("LoosExtended-Medium", size: 16))
								Spacer()
							}
						})
						.foregroundColor(.red)
						.listRowBackground(Color("listRowBackground"))
					}
				}
				.scrollContentBackground(.hidden)
				.background(Color(uiColor: .systemBackground))
				.alert("You will lose all statistics you have collected so far. Are you sure you want to do this?", isPresented: $showResetAlert, actions: {
					Button("Continue", role: .destructive) {
						let db = DatabaseController(modelContainer: modelContext.container)
						self.swipeDownCount = 0
					}
					Button("Cancel", role: .cancel) {}
				})
				
				Spacer()
				
#if INTERNAL
				Text("For testing purposes only.").opacity(0.5).font(.custom("LoosExtended-Medium", size: 16))
#elseif DEBUG
				Text("Candidate Release").opacity(0.5).font(.custom("LoosExtended-Medium", size: 16))
#endif
				Text(commitInfo).opacity(0.5).font(.custom("LoosExtended-Regular", size: 16))
			}
			
			.background(Color(uiColor: .systemBackground))
			.navigationBarTitleDisplayMode(.large)
		}
		.onAppear {
			self.swipeDownCount += 1
		}
	}
	
}


#Preview {
	SettingsView()
}

