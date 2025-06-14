//
//  Fonts.swift
//  swiped.
//
//  Created by Adam Demasi on 13/6/2025.
//

import SwiftUI

extension Font.Width {
	static var ourExpanded: Font.Width {
		return Font.Width(0.3)
	}
}

class Fonts {

	enum FontChoice: Int {
		case loos
		case sf
	}

	@AppStorage("fontChoice") static var fontChoice: FontChoice = .loos

	static var hugeTitle: Font {
		switch fontChoice {
		case .loos: return .custom("LoosExtended-Medium", size: 50)
		case .sf:   return .system(size: 50, weight: .medium).width(.ourExpanded)
		}
	}

	static var title: Font {
		switch fontChoice {
		case .loos: return .custom("LoosExtended-Bold", size: 24)
		case .sf:   return .system(size: 24, weight: .bold).width(.ourExpanded)
		}
	}

	static var subhead: Font {
		switch fontChoice {
		case .loos: return .custom("LoosExtended-Regular", size: 18)
		case .sf:   return .system(size: 18, weight: .regular).width(.ourExpanded)
		}
	}

	static var body: Font {
		switch fontChoice {
		case .loos: return .custom("LoosExtended-Regular", size: 16)
		case .sf:   return .system(size: 16, weight: .regular).width(.ourExpanded)
		}
	}

	static var bodyMedium: Font {
		switch fontChoice {
		case .loos: return .custom("LoosExtended-Medium", size: 16)
		case .sf:   return .system(size: 16, weight: .medium).width(.ourExpanded)
		}
	}

	static var bodyBold: Font {
		switch fontChoice {
		case .loos: return .custom("LoosExtended-Bold", size: 16)
		case .sf:   return .system(size: 16, weight: .bold).width(.ourExpanded)
		}
	}

	static var small: Font {
		switch fontChoice {
		case .loos: return .custom("LoosExtended-Regular", size: 14)
		case .sf:   return .system(size: 14, weight: .regular).width(.ourExpanded)
		}
	}
	static var extraSmall: Font {
		switch fontChoice {
		case .loos: return .custom("LoosExtended-Regular", size: 12)
		case .sf:   return .system(size: 12, weight: .regular).width(.ourExpanded)
		}
	}
	

	static var summaryMedium: Font {
		switch fontChoice {
		case .loos: return .custom("LoosExtended-Medium", size: 18)
		case .sf:   return .system(size: 18, weight: .medium).width(.ourExpanded)
		}
	}

	static var summaryBold: Font {
		switch fontChoice {
		case .loos: return .custom("LoosExtended-Bold", size: 18)
		case .sf:   return .system(size: 18, weight: .bold).width(.ourExpanded)
		}
	}

	static var overlay: UIFont {
		switch fontChoice {
		case .loos: return UIFont(name: "LoosExtended-Bold", size: 42)!
		case .sf:   return UIFont.systemFont(ofSize: 42, weight: .bold, width: .init(Font.Width.ourExpanded.value))
		}
	}

}
