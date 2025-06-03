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
	@State private var isSyncOK = false
	@State private var cloudKitStatus = "Checking.."
	
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
					Text("SYNC")
						.font(.custom("LoosExtended-Bold", size: 16))
						.foregroundColor(.white)
					+
					Text(".")
						.font(.custom("LoosExtended-Bold", size: 16))
						.foregroundColor(isSyncOK ? Color("brandGreen") : Color("brandRed"))
					Text(cloudKitStatus)
						.font(.custom("LoosExtended-Regular", size: 14))
						.foregroundColor(.white)
				}
				
				Spacer()
			}
		}
		.listRowBackground(Color.black)
	}
	
	private func checkCloudKitStatus() {
		let container = CKContainer.default()
		container.accountStatus { (accountStatus, error) in
			DispatchQueue.main.async {
				switch accountStatus {
				case .available:
					isSyncOK = true
					self.cloudKitStatus = "Linked with iCloud"
				case .noAccount:
					isSyncOK = false
					self.cloudKitStatus = "Disabled"
				case .restricted:
					isSyncOK = false
					self.cloudKitStatus = "Restricted"
				case .couldNotDetermine:
					isSyncOK = false
					self.cloudKitStatus = "Could not determine"
				case .temporarilyUnavailable:
					isSyncOK = false
					self.cloudKitStatus = "iCloud Unavailable"
				@unknown default:
					isSyncOK = false
					self.cloudKitStatus = "Could not determine"
				}
			}
		}
	}
}

#Preview {
	AdvancedView()
		.environmentObject(SheetManager())
}
