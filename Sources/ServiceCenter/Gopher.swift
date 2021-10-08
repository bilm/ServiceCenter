//
//  Gopher.swift
//  Goth
//
//  Created by Bil Moorhead on 10/3/21.
//

import Foundation

struct Gopher: AsyncSequence {
	
	typealias Element = Data

	struct GopherIterator: AsyncIteratorProtocol {
		
		var requests: [URLRequest]
		fileprivate var index = 0
		mutating func nextRequest() ->URLRequest? { 
			
			guard index < requests.count else { return nil }
			defer { index += 1 }

			return requests[index]

		}
		
		fileprivate var urlSession = URLSession.shared

		mutating func next() async throws -> Data? {
			
			guard let request = nextRequest() else { return nil }
			
			let (data, _) = try await urlSession.data(for: request)
			return data
			
		}
		
	}
	
	var requests: [URLRequest]

	func makeAsyncIterator() -> GopherIterator {
		
		GopherIterator(requests: requests)
		
	}
	
}
