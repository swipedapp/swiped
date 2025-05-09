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
	
	private static let fileSizeFormatter = ByteCountFormatter()
	
	weak var delegate: Delegate?

	private let keepLabel = UILabel()
	private let deletedLabel = UILabel()
	private let savedLabel = UILabel()
	private let scoreLabel = UILabel()
	private let deleteButton = ActionButton()

	override init(frame: CGRect) {
		super.init(frame: .zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		
		keepLabel.translatesAutoresizingMaskIntoConstraints = false
		keepLabel.font = UIFont(name: "LoosExtended-Bold", size: 16)!
		keepLabel.textAlignment = .center
		
		deletedLabel.translatesAutoresizingMaskIntoConstraints = false
		deletedLabel.font = UIFont(name: "LoosExtended-Bold", size: 16)!
		deletedLabel.textAlignment = .center
		
		savedLabel.translatesAutoresizingMaskIntoConstraints = false
		savedLabel.font = UIFont(name: "LoosExtended-Bold", size: 16)!
		savedLabel.textAlignment = .center
		
		scoreLabel.translatesAutoresizingMaskIntoConstraints = false
		scoreLabel.font = UIFont(name: "LoosExtended-Bold", size: 16)!
		scoreLabel.textAlignment = .center
		
		deleteButton.translatesAutoresizingMaskIntoConstraints = false
		deleteButton.setText(text: "Continue", color: .green)
		deleteButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
		deleteButton.tag = Action.delete.rawValue
		
		let stackView = UIStackView(arrangedSubviews: [keepLabel, deletedLabel, savedLabel, scoreLabel, deleteButton])
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
		
		for button in [deleteButton] {
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

	func updateCount() {
		let db = DatabaseController.shared
		keepLabel.text = "\(db.getTotalKept().formatted()) kept"
		deletedLabel.text = "\(db.getTotalDeleted().formatted()) deleted"
		savedLabel.text = "\(Self.fileSizeFormatter.string(fromByteCount: Int64(db.getSpaceSaved()))) saved"
		scoreLabel.text = "SwipeScore: \(db.calcSwipeScore().formatted())"
	}

}
