//
//  AdvancedView.swift
//  swiped.
//
//  Created by tobykohlhagen on 20/5/2025.
//
import SwiftUI
import Combine
import CloudKit
import Sentry

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
				.font(Fonts.body)
				.listRowBackground(Color("listRowBackground"))
			}
#endif
#if INTERNAL
			// INTERNAL FUNCTION: Upcoming font chooser.
			NavigationLink("Fonts") {
				SettingsFontView()
			}.listRowBackground(Color("listRowBackground")).font(Fonts.body)
#endif
			
			if let minimumiOSVersion = sheetManager.json?.minimumiOSVersion,
				 UIDevice.current.systemVersion.compare(minimumiOSVersion, options: .numeric) == .orderedAscending {
				Section {
					Toggle(isOn: showSupportAlert) {
						Text("Show Support Alerts")
							.font(Fonts.body)
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

		let dot = Text(".")
			.foregroundColor(isSyncOK ? Color("brandGreen") : Color("brandRed"))

		return Section {
			HStack {
				VStack(alignment: .leading, spacing: 2) {
					Text("SYNC\(dot)")
						.font(Fonts.bodyBold)
						.foregroundColor(.white)

					Text(cloudKitStatus)
						.font(Fonts.small)
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
					SentrySDK.capture(message: "iCloud status: Could not determine")
					self.cloudKitStatus = "Could not determine"
				case .temporarilyUnavailable:
					isSyncOK = false
					SentrySDK.capture(message: "iCloud status: Temporarily unavailable")
					self.cloudKitStatus = "iCloud Unavailable"
				@unknown default:
					isSyncOK = false
					SentrySDK.capture(message: "iCloud status: Unknown")
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
