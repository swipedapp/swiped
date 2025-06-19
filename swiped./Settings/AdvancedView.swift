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
			return supportAlertLastVersion != version
		}, set: { value, _ in
			supportAlertLastVersion = value ? "" : version
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
			NavigationLink("Fonts") {
				SettingsFontView()
			}.listRowBackground(Color("listRowBackground")).font(Fonts.body)
			
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
		.navigationTitle("Advanced")
		.toolbar(removing: .title)
		.listRowBackground(Color.black)
	}
	
	private func checkCloudKitStatus() {
		let container = CKContainer.default()
		container.accountStatus { (accountStatus, error) in
			DispatchQueue.main.async {
				switch accountStatus {
				case .available:
					isSyncOK = true
					cloudKitStatus = "Linked with iCloud"
				case .noAccount:
					isSyncOK = false
					cloudKitStatus = "Disabled"
				case .restricted:
					isSyncOK = false
					cloudKitStatus = "Restricted"
				case .couldNotDetermine:
					isSyncOK = false
					SentrySDK.capture(message: "iCloud status: Could not determine")
					cloudKitStatus = "Could not determine"
				case .temporarilyUnavailable:
					isSyncOK = false
					SentrySDK.capture(message: "iCloud status: Temporarily unavailable")
					cloudKitStatus = "iCloud Unavailable"
				@unknown default:
					isSyncOK = false
					SentrySDK.capture(message: "iCloud status: Unknown")
					cloudKitStatus = "Could not determine"
				}
			}
		}
	}
}

#Preview {
	AdvancedView()
		.environmentObject(SheetManager())
}
