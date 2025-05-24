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
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setText(text: String?, image: UIImage? = nil, color: UIColor = .label) {
		var config = UIButton.Configuration.plain()
		config.baseForegroundColor = color
		config.image = image
		
		if let text = text {
			var container = AttributeContainer()
			container.font = UIFont(name: "LoosExtended-Medium", size: 18)
			config.attributedTitle = AttributedString(text, attributes: container)
		}
		
		configuration = config
		
		configurationUpdateHandler = { update in
			UIView.animate(withDuration: 0.1) {
				self.alpha = update.isHighlighted ? 0.5 : 1
			}
		}
	}
	
}
