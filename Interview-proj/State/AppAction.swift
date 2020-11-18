//
//  AppAction.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//

import Foundation

enum AppAction {
	case showHistory
	case closeHistory
	
	case showError(AppError)
	case dismissError
	
	case loadHistory
	case loadHistoryComplete(Result<[History], AppError>)
	
	/// load endpoint from local database
	case loadEndpoint
	/// load endpoint from internet
	case refreshEndpoint
	
	case loadEndpointComplete(Result<[Endpoint], AppError>)
}
