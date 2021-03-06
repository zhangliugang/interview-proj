//
//  AppError.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//

import Foundation

enum AppError: Error, Equatable {
	case unknown
	case jsonDecodeError
	case networkfail
	case databaseError
}

extension AppError {
	func description() -> String {
		switch self {
		case .unknown:
			return "Unknown Error"
		case .jsonDecodeError:
			return "JSON Decode Error"
		case .databaseError:
			return "Database Error"
		case .networkfail:
			return "Network Request Failed"
		}
	}
}
