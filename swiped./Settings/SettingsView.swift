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
	
	@EnvironmentObject var sheetManager: SheetManager
	
	
	@State
	var showResetAlert: Bool = false

	@AppStorage("swipeDownCount")
	var swipeDownCount = 0

	@AppStorage("launches")
	var launches = 0

	@Environment(\.modelContext) var modelContext
	
	var body: some View {
		NavigationStack {
			Form {
				Section(content: {}, header: {
					ZStack(alignment: .top) {
						if swipeDownCount < 5 {
							HStack {
								Image(systemName: "chevron.down")
								Text("Swipe down to dismiss")
								Image(systemName: "chevron.down")
							}
							.textCase(.uppercase)
							.font(Fonts.small)
						}

						HStack {
							Spacer()
							VStack(alignment: .center) {
								Text("Settings")
									.foregroundColor(.primary)
									.textCase(nil)
									.font(Fonts.hugeTitle)
							}
							Spacer()
						}
						.padding(.top, 40)
						.padding(.bottom, 30)
					}
						.padding(.top, -40)
				})


				// Production flags
				Toggle(isOn: $timestamps) {

					Text("Show relative timestamps")
						.font(Fonts.body)

				}.listRowBackground(Color("listRowBackground"))
				NavigationLink("App Icons") {
					SettingsIconView(collection: "main")
				}.listRowBackground(Color("listRowBackground")).font(Fonts.body)


				NavigationLink("Advanced") {
					AdvancedView()
						.environmentObject(sheetManager)
				}
				.font(Fonts.body)
				.listRowBackground(Color("listRowBackground"))
				NavigationLink("About") {
					AboutView()
						.environmentObject(sheetManager)
				}
				.font(Fonts.body)
				.listRowBackground(Color("listRowBackground"))

				Section {
					Button(action: {
						showResetAlert = true
					}, label: {
						HStack {
							Spacer()
							Label("Reset Database", systemImage: "xmark.bin")
								.font(Fonts.bodyMedium)
							Spacer()
						}
					})
					.foregroundColor(.red)
					.listRowBackground(Color("listRowBackground"))
				}
			}
				// Works around navbar height issue - could be an actual SwiftUI bug??
				.navigationTitle("Settings")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar(removing: .title)
				.toolbarBackgroundVisibility(.hidden, for: .navigationBar)
				.scrollContentBackground(.hidden)
				.background(Color("oled"))
				.alert("You will lose all statistics you have collected so far. Are you sure you want to do this?", isPresented: $showResetAlert, actions: {
					Button("Continue", role: .destructive) {
						Task {
							let db = DatabaseController(modelContainer: modelContext.container)
							await db.reset()
							swipeDownCount = 0
							launches = 0
						}
					}
					Button("Cancel", role: .cancel) {}
				})
		}
		.onAppear {
			swipeDownCount += 1
		}
	}
	
}


#Preview {
	SettingsView()
		.environmentObject(SheetManager())
}

