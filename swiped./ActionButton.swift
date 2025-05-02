//
//  ActionButton.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit

class ActionButton: UIButton {

	override init(frame: CGRect) {
		super.init(frame: .zero)
		
		var config = UIButton.Configuration.plain()
		config.baseForegroundColor = .white
		configuration = config
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setText(text: String) {
		var config = configuration!
		var container = AttributeContainer()
		container.font = UIFont(name: "LoosExtended-Bold", size: 18)
		config.attributedTitle = AttributedString(text, attributes: container)
		configuration = config
	}

}
