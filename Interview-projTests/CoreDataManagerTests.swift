//
//  CoreDataManagerTests.swift
//  Interview-projTests
//
//  Created by August on 11/18/20.
//

import XCTest
import CoreData
@testable import Interview_proj

class CoreDataManagerTests: XCTestCase {
	var manager: CoreDataManager!
	
	override func setUpWithError() throws {
		manager = CoreDataManager.shared
	}
	
	override func tearDownWithError() throws {
		try super.tearDownWithError()
	}
	
	func testCoreDataStackInit() throws {
		XCTAssertNotNil(manager.persistentStoreCoordinator)
	}
	
	func testClearStorage() throws {
		manager.clearStorage(entityName: "Endpoint")
		manager.clearStorage(entityName: "History")
		
		let ctx = manager.managedObjectContext
		
		let history = try ctx.fetch(History.fetchRequest())
		let endpoint = try ctx.fetch(Endpoint.fetchRequest())
		
		XCTAssert(history.count == 0)
		XCTAssert(endpoint.count == 0)
	}
	
	func testCreateData() throws {
		let data = ["current_user_url": "https://api.github.com/user",
					"current_user_authorizations_html_url": "https://github.com/settings/connections/applications{/client_id}",
	 "authorizations_url": "https://api.github.com/authorizations",
	 "code_search_url": "https://api.github.com/search/code?q={query}{&page,per_page,sort,order}",
	 "commit_search_url": "https://api.github.com/search/commits?q={query}{&page,per_page,sort,order}"]
		
		let ctx = manager.managedObjectContext
		let date = Date()
		
		let history = History(context: ctx)
		history.date = date
		history.success = true
		
		for (k,v) in data {
			let endpoint = Endpoint(context: ctx)
			endpoint.name = k
			endpoint.value = v
			endpoint.from = history
		}
		
		try ctx.save()
		
		let fetchHistory: NSFetchRequest<History> = History.fetchRequest()
		let history_result = try ctx.fetch(fetchHistory)
		XCTAssert(history_result.count == 1)
		XCTAssert(history_result[0].date == date)
		XCTAssert(history_result[0].success == true)
		
		let fetchEndpoint: NSFetchRequest<Endpoint> = Endpoint.fetchRequest()
		let endpoint_result = try ctx.fetch(fetchEndpoint)
		XCTAssert(endpoint_result.count == 5)
		for ep in endpoint_result {
			XCTAssert(ep.value! == data[ep.name!])
		}
	}
}
