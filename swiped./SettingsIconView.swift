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
	}

	let icons = [
		Icon(name: "AppIcon", title: "Classic"),
		Icon(name: "SFIcon", title: "SF"),
		Icon(name: "ghostedIcon", title: "ghosted"),
		Icon(name: "flightIcon", title: "Flight")
	]

	var body: some View {
		ScrollView {
			LazyVStack {
					ForEach(icons, id: \.name) { icon in
						Button(action: {
							if icon.name == "AppIcon" {
								UIApplication.shared.setAlternateIconName(nil)
							} else {
								UIApplication.shared.setAlternateIconName(icon.name)
							}
						}, label: {
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
						})
						
						Divider()
							.background(.gray)
					}
				}
		}
		.background(Color(uiColor: .systemBackground))
			//.navigationTitle("Icons")
	}
}

#Preview {
	SettingsIconView()
}
