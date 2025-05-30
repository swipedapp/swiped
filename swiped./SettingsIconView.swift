//
//  SettingsIconView.swift
//  swiped.
//
//  Created by Adam Demasi on 10/05/2025.
//

import SwiftUI

struct SettingsIconView: View {
	
	struct Icon {
		var name: String
		var title: String
		var collection: String?
	}
	
	let collection: String
	
	var icons: [Icon] {
		switch collection {
		case "main":
			return [
				Icon(name: "AppIcon", title: "Classic"),
				Icon(name: "SFIcon", title: "SF"),
				Icon(name: "ghostedIcon", title: "ghosted"),
				Icon(name: "flightIcon", title: "Flight"),
				Icon(name: "brat-collection-general", title: "BRAT Collection", collection: "brat")
			]
			
		case "brat":
			return [
				Icon(name: "brat-collection-general", title: "BRAT"),
				Icon(name: "brat-collection-nextgen", title: "BRAT Phase II"),
				Icon(name: "brat-s-general", title: "BRAT Simplified"),
				Icon(name: "brat-s-nextgen", title: "BRAT Simplified Phase II")
			]

		default:
			fatalError()
		}
	}
	
	var body: some View {
		ScrollView {
			LazyVStack {
				ForEach(icons, id: \.name) { icon in
					if let collection = icon.collection {
						NavigationLink {
							SettingsIconView(collection: collection)
						} label: {
							self.button(icon: icon)
						}
					} else {
						Button(action: {
							if icon.name == "AppIcon" {
								UIApplication.shared.setAlternateIconName(nil)
							} else {
								UIApplication.shared.setAlternateIconName(icon.name)
							}
						}, label: {
							self.button(icon: icon)
						})
					}
					
					Divider()
						.background(.gray)
				}
			}
		}
		.background(Color("oled"))
		//.navigationTitle("Icons")
	}
	
	func button(icon: Icon) -> some View {
		HStack(alignment: .center, spacing: 10) {
			Image(uiImage: UIImage(named: "\(icon.name)-Preview") ?? UIImage(systemName: "questionmark")!)
				.frame(width: 60, height: 60)
				.background(Color(UIColor.secondarySystemBackground))
				.cornerRadius(12)
				.overlay(
					RoundedRectangle(cornerRadius: 12)
						.stroke(Color(UIColor.separator), lineWidth: 1)
				)
			
			Text(icon.title)
				.font(.custom("LoosExtended-Regular", size: 16))
				.foregroundColor(.primary)
			
			Spacer()
		}
			.padding(15)
	}
}

#Preview {
	NavigationView {
		SettingsIconView(collection: "main")
	}
}
