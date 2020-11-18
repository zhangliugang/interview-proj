//
//  GithubAPI.swift
//  Interview-proj
//
//  Created by August on 11/18/20.
//

import Combine
import CoreData
import Foundation

struct GithubAPI {
	let url: URL
	
	init() {
		url = URL(string: "https://api.github.com/")!
	}
	
	func get() -> AnyPublisher<[Endpoint], AppError> {
		let req = URLRequest(url: url)
		let conf = URLSessionConfiguration.default
		conf.requestCachePolicy = .reloadIgnoringCacheData
		
		return URLSession(configuration: conf).dataTaskPublisher(for: req)
			.mapError { _ in AppError.networkfail }
			.flatMap(maxPublishers: .max(1)) { pair in
				return handleResponse(data: pair.data, response: pair.response)
			}
			.eraseToAnyPublisher()
	}
	
	func handleResponse(data: Data, response: URLResponse) -> AnyPublisher<[Endpoint], AppError> {
		guard let httpResponse = response as? HTTPURLResponse else {
		  fatalError("URLResponse cannot be converted to HTTPURLResponse")
		}
		
		if 200...299 ~= httpResponse.statusCode {
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,String> as Dictionary<String, String>
				
				let ctx = CoreDataManager.shared.backgroundObjectContext()
				
				let history = History(context: ctx)
				history.date = Date()
				history.success = true
				
				var eps = [Endpoint]()
				for (key, value) in json {
					let endpoint = Endpoint(context: ctx)
					endpoint.name = key
					endpoint.value = value
					endpoint.from = history
					eps.append(endpoint)
				}
				
				CoreDataManager.shared.saveContext(ctx)
				
				return Result<[Endpoint], AppError>
					.Publisher(eps)
					.eraseToAnyPublisher()
			} catch {
				return Result<[Endpoint], AppError>
					.Publisher(.failure(.jsonDecodeError))
					.eraseToAnyPublisher()
			}
		}
		else {
			return Result<[Endpoint], AppError>
				.Publisher(.failure(.networkfail))
				.eraseToAnyPublisher()
		}
	}
}
