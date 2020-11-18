//
//  Store.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//

import Foundation
import Combine

class Store: ObservableObject {
	@Published var appState = AppState()
	
	let timer = Timer.publish(every: 5, on: .main, in: .common)
	var disposeBag = Set<AnyCancellable>()
	
	init() {
		timer.autoconnect().sink { (_) in
			self.dispatch(.refreshEndpoint)
		}.store(in: &disposeBag)
	}
	
	func dispatch(_ action: AppAction) {
		let result = Store.reduce(state: appState, action: action)
		appState = result.0
		if let command = result.1 {
			command.execute(in: self)
		}
	}
}

extension Store {
	static func reduce(state: AppState, action: AppAction) -> (AppState, AppCommand?) {
		var appState = state
		var appCommand: AppCommand? = nil
		
		switch action {
		case .showHistory:
			appState.historieList.showHistoryPanel = true
		case .closeHistory:
			appState.historieList.showHistoryPanel = false
		case .showError(let error):
			appState.appInfo.appError = error
			appState.appInfo.showErrorView = true
		case .dismissError:
			appState.appInfo.appError = nil
			appState.appInfo.showErrorView = false
			
		case .loadEndpoint:
			appState.endpointList.isLoading = false
			appCommand = LoadEndpointCommand()
		case .refreshEndpoint:
			appState.endpointList.isLoading = true
			appCommand = RequestCommand()
		case .loadEndpointComplete(let result):
			switch result {
			case .success(let endpoints):
				appState.endpointList.endpoints = endpoints
			case .failure(let error):
				return reduce(state: appState, action: .showError(error))
			}
			
		case .loadHistory:
			appCommand = LoadHistoryCommand()
		case .loadHistoryComplete(let result):
			switch result {
			case .success(let histories):
				appState.historieList.histories = histories
			case .failure(let error):
				return reduce(state: appState, action: .showError(error))
			}
		}
		return (appState, appCommand)
	}
}


extension Store {
	static var sample: Store {
		let s = Store()
		s.appState.historieList.histories = [History(date: Date()), History(date: Date()), History(date: Date())]
		s.appState.endpointList.endpoints = [
			Endpoint(name: "current_user_url", value: "https://api.github.com/user"),
			Endpoint(name: "current_user_authorizations_html_url", value:  "https://github.com/settings/connections/applications{/client_id}"),
			Endpoint(name: "authorizations_url", value: "https://api.github.com/authorizations"),
			Endpoint(name: "code_search_url", value: "https://api.github.com/search/code?q={query}{&page,per_page,sort,order}"),
			Endpoint(name: "commit_search_url", value:  "https://api.github.com/search/commits?q={query}{&page,per_page,sort,order}"),
			Endpoint(name: "emails_url", value:"https://api.github.com/user/emails"),
			Endpoint(name: "emojis_url", value:"https://api.github.com/emojis")
		]
		return s
	}
}
