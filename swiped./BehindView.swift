//
//  BehindView.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit
import SQLite

class BehindView: UIView {

	enum Action: Int {
		case `continue`
		case delete
	}

	protocol Delegate: AnyObject {
		func didTapBehindButton(action: Action)
	}
	
	weak var delegate: Delegate?

	private let titleLabel = UILabel()
	private let continueButton = ActionButton()
	private let deleteButton = ActionButton()

	override init(frame: CGRect) {
		super.init(frame: .zero)
		
		translatesAutoresizingMaskIntoConstraints = false

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.font = UIFont(name: "LoosExtended-Bold", size: 16)!
		
//		continueButton.translatesAutoresizingMaskIntoConstraints = false
//		continueButton.setText(text: "Keep going")
//		continueButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
//		continueButton.tag = Action.continue.rawValue
		//titleLabel.text = "Ready to delete photos?"
		deleteButton.translatesAutoresizingMaskIntoConstraints = false
		deleteButton.setText(text: "Continue")
		deleteButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
		deleteButton.tag = Action.delete.rawValue
		
		let stackView = UIStackView(arrangedSubviews: [titleLabel, continueButton, deleteButton])
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
		delegate?.didTapBehindButton(action: Action(rawValue: button.tag)!)
	}

	func updateCount(count: Int) {
		titleLabel.text = "Ready to delete \(count) photos?"
	}

}
