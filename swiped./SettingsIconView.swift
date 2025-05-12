//
//  SettingsIconView.swift
//  swiped.
//
//  Created by Adam Demasi on 10/05/2025.
//

import SwiftUI

struct SettingsIconView: View {

	let icons = [
		"AppIcon",
		"SFIcon",
		"ghostedIcon",
		"flightIcon"
	]

	var body: some View {
		ScrollView {
			LazyVGrid(
				columns: [
					GridItem(.fixed(70), alignment: .center),
					GridItem(.fixed(70), alignment: .center),
					GridItem(.fixed(70), alignment: .center),
					GridItem(.fixed(70), alignment: .center)
				],
				alignment: .center) {
					ForEach(icons, id: \.self) { icon in
						Button(action: {
							if icon == "AppIcon" {
								UIApplication.shared.setAlternateIconName(nil)
							} else {
								UIApplication.shared.setAlternateIconName(icon)
							}
						}, label: {
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
