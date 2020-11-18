//
//  AppState.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//

import Foundation
import Combine

struct AppState {
	var endpointList = EndpointList()
	var historieList = HistroryList()
	var appInfo = AppInfo()
}


extension AppState {
	struct EndpointList {
		var endpoints: [Endpoint]?
		var isLoading = false
	}
}

extension AppState {
	struct HistroryList {
		var showHistoryPanel = false
		var histories: [History]?
	}
}

extension AppState {
	struct AppInfo: Equatable {
		var showErrorView = false
		var appError: AppError?
	}
}

extension AppState.EndpointList: Equatable {}
extension AppState.HistroryList: Equatable {}
extension AppState: Equatable {}
