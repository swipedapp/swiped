//
//  CreativeKit.swift
//  swiped.
//
//  Created by tobykohlhagen on 6/6/2025.
//

import Foundation
import UIKit
// Key names for the Pasteboard
enum CreativeKitLiteKeys {
	static let clientID = "com.snapchat.creativekit.clientID"
	static let backgroundImage = "com.snapchat.creativekit.backgroundImage"
	static let backgroundVideo = "com.snapchat.creativekit.backgroundVideo"
	static let stickerImage = "com.snapchat.creativekit.stickerImage"
	static let payloadMetadata = "com.snapchat.creativekit.payloadMetadata"
	static let lensUUID = "com.snapchat.creativekit.lensUUID"
	static let appName = "com.snapchat.creativekit.appName"
	static let caption = "com.snapchat.creativekit.captionText"
	static let launchData = "com.snapchat.creativekit.lensLaunchData"
}

enum ShareDestination: String {
	case preview = "snapchat://creativekit/preview/1"
	case camera = "snapchat://creativekit/camera/1"
}

enum ShareMediaType {
	case image
	case video
}

// Shares media to a full screen snap that can be posted to stories or shared directly with a friend
func shareToPreview(clientID: String, mediaType: ShareMediaType, mediaData: Data)
{
	// Pass media content to the pasteboard
	var dict: [String: Any] = [ CreativeKitLiteKeys.clientID: clientID ]
	switch mediaType {
	case .image:
		dict[CreativeKitLiteKeys.backgroundImage] = mediaData
	case .video:
		dict[CreativeKitLiteKeys.backgroundVideo] = mediaData
	}
	
	
	
	createAndOpenShareUrl(clientID:clientID, shareDest: ShareDestination.preview, dict:dict)
}
func createAndOpenShareUrl(clientID:String, shareDest: ShareDestination, dict:[String:Any])
{
	// Verify if Snapchat can be opened
	guard var urlComponents = URLComponents(string: shareDest.rawValue),
				let url = urlComponents.url,
				UIApplication.shared.canOpenURL(url) else {
		return
	}
	
	let items = [ dict ]
	
	// Set content in the Pasteboard to expire in 5 minutes.
	// Content will be clared as soon as the Snapchat app receives it.
	let expire = Date().addingTimeInterval(5*60)
	let options = [ UIPasteboard.OptionsKey.expirationDate: expire ]
	UIPasteboard.general.setItems(items, options: options)
	
	// Ensure that the pasteboard isn't tampered, we pass the change
	// count to ensure the integrity of the pasteboard content
	let queryItem = URLQueryItem.init(name: "checkcount",
																		value: String(format: "%ld",
																									UIPasteboard.general.changeCount))
	
	// Pass Client ID to the share URL
	let clientIdQueryItem = URLQueryItem.init(name: "clientId", value: clientID)
	
	// Pass App Display name to the share URL
	var appDisplayName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String
	if (appDisplayName == nil) {
		appDisplayName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
	}
	let appDisplayNameQueryItem = URLQueryItem.init(name: "appDisplayName", value: appDisplayName)
	
	
	// Create and Open the final Share URL
	urlComponents.queryItems = [
		queryItem,
		clientIdQueryItem,
		appDisplayNameQueryItem
	]
	if let finalURL = urlComponents.url {
		UIApplication.shared.open(finalURL, options: [:],
															completionHandler: nil)
	}
}
