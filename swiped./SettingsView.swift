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
	
	@StateObject var serverController = ServerController.shared
	
#if !INTERNAL
	@AppStorage("sync")
	var sync: Bool = false
#else
	var sync: Bool = true
#endif
	
	
	@State
	var showResetAlert: Bool = false
	
	@AppStorage("swipeDownCount")
	var swipeDownCount = 0
	
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
									Text("Version \(version) (\(build))")
										.font(.custom("LoosExtended-Medium", size: 18))
								}
								Spacer()
							}
							.padding(.vertical, 30)
						}
					})
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
					// Production flags
					Toggle(isOn: $timestamps) {
						
						Text("Show relative timestamps")
							.font(.custom("LoosExtended-Regular", size: 16))
						
					}.listRowBackground(Color("listRowBackground"))
					NavigationLink("App Icons") {
						SettingsIconView()
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
						DatabaseController.shared.reset()
						self.swipeDownCount = 0
					}
					Button("Cancel", role: .cancel) {}
				})
				
				Spacer()
				
#if INTERNAL
				Text("Internal testing only.").opacity(0.5).font(.custom("LoosExtended-Medium", size: 16))
#elseif DEBUG
				Text("Candidate Release").opacity(0.5).font(.custom("LoosExtended-Medium", size: 16))
#endif
				Text(commitInfo).opacity(0.5).font(.custom("LoosExtended-Regular", size: 16))
			}
			
			.background(Color(uiColor: .systemBackground))
			.navigationBarTitleDisplayMode(.inline)
		}
		.onAppear {
			self.swipeDownCount += 1
		}
	}
	
	var syncSection: some View {
		let syncFailed = !sync || serverController.syncFailed
		
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
	SettingsView()
}

