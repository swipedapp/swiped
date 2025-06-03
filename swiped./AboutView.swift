//
//  AboutView.swift
//  swiped.
//
//  Created by tobykohlhagen on 30/5/2025.
//

import SwiftUI

struct AboutView: View {
	@State var showRestriction = false
	let commitInfo = Bundle.main.infoDictionary?["GitCommitHash"] as? String ?? "swiped.pics"
	@AppStorage("timestamps")
	var timestamps: Bool = false
	
	var version: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}
	
	var build: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
	}
	
	
	@EnvironmentObject var sheetManager: SheetManager
	
	
	
	@Environment(\.modelContext) var modelContext
	
	var body: some View {
		NavigationStack {
			VStack {
				Form {
					Section(content: {}, header: {
						ZStack(alignment: .top) {
							
							HStack {
								Spacer()
								VStack(alignment: .center) {
									Text("SWIPED")
										.foregroundColor(.white)
										.font(.custom("LoosExtended-Bold", size: 50))
									+
									Text(".")
										.foregroundColor(Color("brandGreen"))
										.font(.custom("LoosExtended-Bold", size: 50))
#if !INTERNAL
									Text("Version \(version) (\(build))")
										.foregroundColor(.white).opacity(0.7).font(.custom("LoosExtended-Medium", size: 18))
#endif
								}
								Spacer()
							}
							.padding(.vertical, 30)
						}
						
					})
					.background(.black)
					Link("Website", destination: URL(string: "https://swiped.pics/")!)
						.listRowBackground(Color("forced")).foregroundColor(.white)
						.font(.custom("LoosExtended-Regular", size: 16))
					Link("GitHub", destination: URL(string: "https://github.com/swipedapp/swiped")!)
						.listRowBackground(Color("forced")).foregroundColor(.white)
						.font(.custom("LoosExtended-Regular", size: 16))
						Link("Have an issue? Let us know.", destination: URL(string: "https://swiped.pics/support")!)
					
					.listRowBackground(Color("forced")).foregroundColor(.white)
					.font(.custom("LoosExtended-Regular", size: 16))
				}
				
				Spacer()
				
#if INTERNAL
				Text("For testing purposes only.").opacity(0.5).font(.custom("LoosExtended-Medium", size: 16))
#elseif DEBUG
				Text("Candidate Release").opacity(0.5).font(.custom("LoosExtended-Medium", size: 16))
#endif
				Text(commitInfo).opacity(0.5).font(.custom("LoosExtended-Regular", size: 16))
				Text("Made in Australia").opacity(1).font(.custom("LoosExtended-Regular", size: 16))
			}
			.scrollContentBackground(.hidden)
			.background(.black)
			.foregroundColor(.white)
			
		}
		
	}
	
	
}


#Preview {
	AboutView()
		.preferredColorScheme(.dark)
		.environmentObject(SheetManager())
}

