//
//  MessageComposeView.swift
//  swiped.
//
//  Created by Adam Demasi on 8/6/2025.
//

import SwiftUI
import MessageUI
import UniformTypeIdentifiers

struct MessageComposeView: UIViewControllerRepresentable {
	var attachments: [MessageAttachment]
	@Binding var isPresented: Bool

	static var isAvailable: Bool {
		return MFMessageComposeViewController.canSendText() && MFMessageComposeViewController.canSendAttachments()
	}

	struct MessageAttachment {
		let data: Data
		let typeIdentifier: String
		let filename: String

		static func image(_ image: UIImage, filename: String = "image.jpg") -> MessageAttachment {
			let data = image.pngData() ?? Data()
			return MessageAttachment(
				data: data,
				typeIdentifier: UTType.jpeg.identifier,
				filename: filename
			)
		}
	}

	class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
		var parent: MessageComposeView

		init(parent: MessageComposeView) {
			self.parent = parent
		}

		func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
			controller.dismiss(animated: true) {
				self.parent.isPresented = false
			}
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(parent: self)
	}

	func makeUIViewController(context: Context) -> MFMessageComposeViewController {
		let messageController = MFMessageComposeViewController()
		messageController.messageComposeDelegate = context.coordinator

		if MFMessageComposeViewController.canSendAttachments() {
			for attachment in attachments {
				messageController.addAttachmentData(
					attachment.data,
					typeIdentifier: attachment.typeIdentifier,
					filename: attachment.filename
				)
			}
		}

		return messageController
	}

	func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
}

