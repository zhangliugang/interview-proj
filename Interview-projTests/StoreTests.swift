//
//  StoreTests.swift
//  Interview-projTests
//
//  Created by August on 11/18/20.
//

import XCTest
@testable import Interview_proj

class StoreTests: XCTestCase {
	
	var store: Store!
	var history_data: [History]!
	var endpoint_data: [Endpoint]!

    override func setUpWithError() throws {
		store = Store.sample
		history_data = (0..<5).map { History(date: Date().addingTimeInterval(TimeInterval($0)), success: true)}
		
		let data = ["current_user_url": "https://api.github.com/user",
					"current_user_authorizations_html_url": "https://github.com/settings/connections/applications{/client_id}",
	 "authorizations_url": "https://api.github.com/authorizations",
	 "code_search_url": "https://api.github.com/search/code?q={query}{&page,per_page,sort,order}",
	 "commit_search_url": "https://api.github.com/search/commits?q={query}{&page,per_page,sort,order}"]
		
		endpoint_data = data.map { Endpoint(name: $0, value: $1) }
    }

    override func tearDownWithError() throws {
		try super.tearDownWithError()
    }

	func testAction() throws {
		let (state1, command1) = Store.reduce(state: store.appState, action: .showHistory)
		XCTAssertEqual(state1.historieList.showHistoryPanel, true)
		XCTAssertNil(command1)
		
		let (state2, command2) = Store.reduce(state: store.appState, action: .closeHistory)
		XCTAssertEqual(state2.historieList.showHistoryPanel, false)
		XCTAssertNil(command2)
		
		let (state3, command3) = Store.reduce(state: store.appState, action: .loadHistory)
		XCTAssertEqual(state3 , store.appState)
		XCTAssert(command3 is LoadHistoryCommand)
		
		let (state4, command4) = Store.reduce(state: store.appState, action: .loadHistoryComplete(.success(history_data)))
		XCTAssertEqual(state4.historieList.histories, history_data)
		XCTAssertNil(command4)
		
		let (state5, command5) = Store.reduce(state: store.appState, action: .loadEndpoint)
		XCTAssertFalse(state5.endpointList.isLoading)
		XCTAssert(command5 is LoadEndpointCommand)
		
		let (state6, command6) = Store.reduce(state: store.appState, action: .refreshEndpoint)
		XCTAssertTrue(state6.endpointList.isLoading)
		XCTAssert(command6 is RequestCommand)
		
		let (state7, command7) = Store.reduce(state: store.appState, action: .loadEndpointComplete(.success(endpoint_data)))
		XCTAssertEqual(state7.endpointList.endpoints, endpoint_data)
		XCTAssertNil(command7)
		
		let (state8, command8) = Store.reduce(state: store.appState, action: .showError(.databaseError))
		XCTAssertEqual(state8.appInfo.appError, .databaseError)
		XCTAssertEqual(state8.appInfo.showErrorView, true)
		XCTAssertNil(command8)
		
		let (state9, command9) = Store.reduce(state: store.appState, action: .dismissError)
		XCTAssertNil(state9.appInfo.appError)
		XCTAssertEqual(state9.appInfo.showErrorView, false)
		XCTAssertNil(command9)
	}

}
