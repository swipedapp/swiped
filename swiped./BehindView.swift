//
//  BehindView.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit

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
		titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)

		continueButton.translatesAutoresizingMaskIntoConstraints = false
		continueButton.titleLabel!.font = UIFont(name: "LoosExtended-Bold", size: 16)
		continueButton.setTitle("Keep going", for: .normal)
		continueButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
		continueButton.tag = Action.continue.rawValue
		
		deleteButton.translatesAutoresizingMaskIntoConstraints = false
		deleteButton.titleLabel!.font = UIFont(name: "LoosExtended-Bold", size: 16)
		deleteButton.setTitle("Delete", for: .normal)
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
