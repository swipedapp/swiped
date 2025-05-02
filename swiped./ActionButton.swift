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
		config.baseForegroundColor = .black
		configuration = config
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
