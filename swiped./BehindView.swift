//
//  BehindView.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit

protocol BehindViewDelegate: AnyObject {
	func didTapBehindButton(button: ActionButton)
}

class BehindView: UIView {
	
	enum Action: Int {
		case `continue`
		case delete
	}
	
	weak var delegate: BehindViewDelegate?
	
	private let continueButton = ActionButton()
	private let deleteButton = ActionButton()
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		
		continueButton.translatesAutoresizingMaskIntoConstraints = false
		continueButton.setTitle("Continue", for: .normal)
		continueButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
		continueButton.tag = Action.continue.rawValue
		
		deleteButton.translatesAutoresizingMaskIntoConstraints = false
		deleteButton.setTitle("Delete", for: .normal)
		deleteButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
		deleteButton.tag = Action.delete.rawValue
		
		let stackView = UIStackView(arrangedSubviews: [continueButton, deleteButton])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.spacing = 20
		addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
			stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
			stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
		])
		
		for button in [continueButton, deleteButton] {
			NSLayoutConstraint.activate([
				button.heightAnchor.constraint(equalToConstant: 44)
			])
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc private func handleTap(_ button: ActionButton) {
		delegate?.didTapBehindButton(button: button)
	}
	
}
