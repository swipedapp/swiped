//
//  InternalView.swift
//  swiped.
//
//  Created by tobykohlhagen on 12/5/2025.
//

import SwiftUI

struct InternalView: View {
	@AppStorage("timestamps")
	var timestamps: Bool = false
	var body: some View {
		Toggle(isOn: $timestamps) {
			Text("Show relative timestamps")
				.font(.custom("LoosExtended-Regular", size: 16))
		}
	}
}
#Preview {
	InternalView()
}
