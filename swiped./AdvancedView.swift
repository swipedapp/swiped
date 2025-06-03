//
//  AdvancedView.swift
//  swiped.
//
//  Created by tobykohlhagen on 20/5/2025.
//
import SwiftUI
import Combine
import CloudKit

struct AdvancedView: View {
	
	var version: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}
	
	@State private var showRestriction = false
	@State private var cloudKitStatus = "checking..."
	
#if !INTERNAL
	@AppStorage("sync")
	var sync: Bool = false
#else
	@State
	var sync: Bool = true
#endif
	@StateObject var serverController = ServerController.shared
	
	@EnvironmentObject var sheetManager: SheetManager
	
	@AppStorage("supportAlertLastVersion")
	var supportAlertLastVersion: String = ""
	
	var showSupportAlert: Binding<Bool> {
		return Binding(get: {
			return self.supportAlertLastVersion != self.version
		}, set: { value, _ in
			self.supportAlertLastVersion = value ? "" : self.version
		})
	}
	
	var body: some View {
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
			
			if let minimumiOSVersion = sheetManager.json?.minimumiOSVersion,
				 UIDevice.current.systemVersion.compare(minimumiOSVersion, options: .numeric) == .orderedAscending {
				Section {
					Toggle(isOn: showSupportAlert) {
						Text("Show Support Alerts")
							.font(.custom("LoosExtended-Regular", size: 16))
					}
				}
				.listRowBackground(Color("listRowBackground"))
			}
		}
		.scrollContentBackground(.hidden)
		.background(Color("oled"))
		.onAppear {
			checkCloudKitStatus()
		}
	}
	
	var syncSection: some View {
		let syncFailed = !sync && serverController.syncFailed
		
		return Section {
			HStack {
				VStack(alignment: .leading, spacing: 2) {
					Text("SYNC.")
						.font(.custom("LoosExtended-Bold", size: 16))
						.foregroundColor(syncFailed ? .black : .primary)
					
					Text(cloudKitStatus)
						.font(.custom("LoosExtended-Regular", size: 12))
						.foregroundColor(syncFailed ? .black : .secondary)
				}
				
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
	
	private func checkCloudKitStatus() {
		let container = CKContainer.default()
		container.accountStatus { (accountStatus, error) in
			DispatchQueue.main.async {
				switch accountStatus {
				case .available:
					self.cloudKitStatus = "icloud available"
				case .noAccount:
					self.cloudKitStatus = "no icloud account"
				case .restricted:
					self.cloudKitStatus = "icloud restricted"
				case .couldNotDetermine:
					self.cloudKitStatus = "status unknown"
				@unknown default:
					self.cloudKitStatus = "status unknown"
				}
			}
		}
	}
}

#Preview {
	AdvancedView()
		.environmentObject(SheetManager())
}
