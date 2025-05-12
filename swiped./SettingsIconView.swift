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
		Icon(name: "flightIcon" title: "Flight")
	]

	var body: some View {
		ScrollView {
			LazyVStack {
					ForEach(icons, id: \.self) { icon in
						Button(action: {
							if icon == "AppIcon" {
								UIApplication.shared.setAlternateIconName(nil)
							} else {
								UIApplication.shared.setAlternateIconName(icon)
							}
						}, label: {
							HStack {
								Image(uiImage: UIImage(named: "\(icon)-Preview") ?? UIImage(systemName: "questionmark")!)
									.frame(width: 60, height: 60)
									.background(Color(UIColor.secondarySystemBackground))
									.cornerRadius(12)
									.overlay(
										RoundedRectangle(cornerRadius: 12)
											.stroke(Color(UIColor.separator), lineWidth: 1)
									)
							})
							.padding(5)
					}
				}
		}
			.navigationTitle("Icons")
	}
}

#Preview {
	SettingsIconView()
}
