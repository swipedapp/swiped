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
									Text("SWIPED\(Text(".").foregroundColor(Color("brandGreen")))")
										.foregroundColor(.white)
										.font(.custom("LoosExtended-Bold", size: 50))
#if !INTERNAL
									Text("Version \(version) (\(build))")
										.foregroundColor(.white).opacity(0.7).font(Fonts.summaryMedium)
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
						.font(Fonts.body)
					Link("GitHub", destination: URL(string: "https://github.com/swipedapp/swiped")!)
						.listRowBackground(Color("forced")).foregroundColor(.white)
						.font(Fonts.body)
					Link("Have an issue? Let us know.", destination: URL(string: "https://swiped.pics/support")!)
						.listRowBackground(Color("forced")).foregroundColor(.white)
						.font(Fonts.body)
					NavigationLink("Known Issues") {
						KnownIssuesView()
					}
					.listRowBackground(Color("forced")).foregroundColor(.white)
					.font(Fonts.body)
				}
				
				Spacer()
				

				Text(commitInfo).opacity(0.5).font(Fonts.body)
				Text("Made in Australia").opacity(1).font(Fonts.body)
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

