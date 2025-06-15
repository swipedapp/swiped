//
//  SettingsFontView.swift
//  swiped.
//
//  Created by Adam Demasi on 13/6/2025.
//

import SwiftUI

struct SettingsFontView: View {

	struct FontItem: Identifiable {
		var id: Fonts.FontChoice
		var name: String
		var font: Font
	}

	private let fonts = [
		FontItem(id: .loos, name: "Loos", font: .custom("LoosExtended-Regular", size: 16)),
		FontItem(id: .sf, name: "SF", font: .system(size: 16).width(.ourExpanded)),
	]

	@Environment(\.presentationMode) var presentationMode

	@AppStorage("fontChoice") private var fontChoice: Fonts.FontChoice = .loos

	var body: some View {
		Form {
			ForEach(fonts) { font in
				Button {
					fontChoice = font.id
					presentationMode.wrappedValue.dismiss()
				} label: {
					HStack {
						Text(font.name)
						Spacer()
						if fontChoice == font.id {
							Image(systemName: "checkmark")
						}
					}
				}
				.font(font.font)
				.listRowBackground(Color("listRowBackground"))
			}
		}
			.navigationTitle("Font")
			.toolbar(removing: .title)
			.scrollContentBackground(.hidden)
			.background(Color("oled"))
	}
}

#Preview {
	NavigationView {
		SettingsFontView()
	}
}
