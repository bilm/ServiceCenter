//
//  ServiceCenter.swift
//  Goth
//
//  Created by Bil Moorhead on 9/19/21.
//

import Foundation

import Logger
import UIKit

fileprivate let logger = Logger[ServiceCenter.self]

public actor ServiceCenter {
	
	public typealias Key = String
	public typealias Substitutions = [Key: String]
	public typealias Queries = [Key: Any]
	public typealias QueryItems = [URLQueryItem]
	public typealias Duration = Double

	public typealias Output = (data: Data, response: URLResponse)
	
	public enum Failures: Error {
		
		case notImplementedYet(String)
		case notAvailableYet(String)
		case discontinued(String)
		case deprecated(String)
		case invalidEndpoint
		case invalidService
		case outOfScope(String)
		
	}
	public enum HTTPStatus: Error, CustomStringConvertible {
		
		case notOk(Int, Output)
		case continued(Int, Output)
		case redirect(Int, Output)
		case client(Int, Output)
		case server(Int, Output)
		
		public var description: String {

			func message(statusCode: Int, output: Output) ->String {
				
				let message = String(data: output.data, encoding: .utf8) ?? "«»"
				return "\(statusCode) - \(message)"
				
			}
			switch self {
				
			case let .notOk(statusCode, output): return message(statusCode: statusCode, output: output)
			case let .continued(statusCode, output): return message(statusCode: statusCode, output: output)
			case let .redirect(statusCode, output): return message(statusCode: statusCode, output: output)
			case let .client(statusCode, output): return message(statusCode: statusCode, output: output)
			case let .server(statusCode, output): return message(statusCode: statusCode, output: output)

			}
		}
	}

	
	public let session: URLSession

	public var auth: ServiceAuth
	public func update(auth: ServiceAuth) { self.auth = auth }
	
	public var mainURL: URL
	public func update(url: URL) { self.mainURL = url }
	
	public var state: ServiceState
	public func update(state: ServiceState) { self.state = state }
	
	public var history: ServiceHistory?
	public func update(history: ServiceHistory?) { self.history = history }
	
	//
	
	public init(configuration: URLSessionConfiguration = .default, auth: ServiceAuth = .nothing, mainURL: URL, state: ServiceState = EmptyServiceState(), history: ServiceHistory? = nil) {
		
		self.session = URLSession(configuration: configuration)
		self.auth = auth
		self.mainURL = mainURL
		self.state = state
		self.history = history
		
	}

}

//
// MARK: Data - Public 
//

extension ServiceCenter {
	
	public func data(
		_ service: Service,
		body: Data? = nil,
		mime: String? = nil,
		substitutions: Substitutions = [:],
		queryItems: QueryItems = [],
		authorization: ServiceAuth? = nil,
		timeoutInterval: TimeInterval = 60.0
	)
	async throws ->Data {

		try await data(
			ServiceRequest(
				service: service,
				body: body,
				mime: mime,
				substitutions: substitutions,
				queryItems: queryItems,
				authorization: authorization,
				timeoutInterval: timeoutInterval
			)
		)
		
	}

	public func data(
		_ service: Service,
		bodies: [Data],
		mime: String? = nil,
		substitutions: Substitutions = [:],
		queryItems: QueryItems = [],
		authorization: ServiceAuth? = nil,
		timeoutInterval: TimeInterval = 60.0
	)
	async throws ->[Data] {
		
		try await data(
			
			bodies.map {
				
				ServiceRequest(
					service: service,
					body: $0,
					mime: mime,
					substitutions: substitutions,
					queryItems: queryItems,
					authorization: authorization,
					timeoutInterval: timeoutInterval
				)

			}
			
		)
		
	}
	
}

//	MARK: Model - Public
extension ServiceCenter {
	
	public func model<Model>(
		_ service: Service,
		body: Data? = nil,
		mime: String? = nil,
		substitutions: Substitutions = [:],
		queryItems: QueryItems = [],
		authorization: ServiceAuth? = nil,
		timeoutInterval: TimeInterval = 60.0,
		logger: Logger? = nil
	) async throws ->Model 
	where Model: Codable, Model: ServiceModel {
		
		return try await model(
			ServiceRequest(
				service: service,
				body: body,
				mime: mime,
				substitutions: substitutions,
				queryItems: queryItems,
				authorization: authorization,
				timeoutInterval: timeoutInterval
			)
		)

	}

	public func model<Model>(
		_ service: Service,
		bodies: [Data],
		mime: String? = nil,
		substitutions: Substitutions = [:],
		queryItems: QueryItems = [],
		authorization: ServiceAuth? = nil,
		timeoutInterval: TimeInterval = 60.0,
		logger: Logger? = nil
	) async throws ->[Model] 
	where Model: Codable, Model: ServiceModel {
		
		try await model(
			
			bodies.map {
				
				ServiceRequest(
					service: service,
					body: $0,
					mime: mime,
					substitutions: substitutions,
					queryItems: queryItems,
					authorization: authorization,
					timeoutInterval: timeoutInterval
				)

			},
			logger: logger
			
		)
		
	}
}


// MARK: Requests - Private
extension ServiceCenter {
	
	public struct ServiceRequest {

		public let service: Service
		public let body: Data?
		public let mime: String?
		public var substitutions: Substitutions = [:]
		public var queryItems: QueryItems = []
		public var authorization: ServiceAuth? = nil
		public var timeoutInterval: TimeInterval = 60.0
		
		// derivitives
		public var path: String { service.path }
		public var absoluteURL: URL? { service.absoluteURL }
		public func subIn(string: String) ->String { substitutions.subIn(string: string) }
		
		public init(service: Service, body: Data? = nil, mime: String? = nil, substitutions: Substitutions = [:], queryItems: QueryItems = [], authorization: ServiceAuth? = nil, timeoutInterval: TimeInterval = 60.0) {
			
			self.service = service
			self.body = body
			self.mime = mime
			self.substitutions = substitutions
			self.queryItems = queryItems
			self.authorization = authorization
			self.timeoutInterval = timeoutInterval
			
		}
		
	}
	
	public func data(_ serviceRequest: ServiceRequest) async throws ->Data {
		
		var serviced = ServicedAt(service: serviceRequest.service)
		defer {
			
			serviced.split()
			history?.add(serviced)
			
		}
		
		let urlRequest = try self.urlRequest(serviceRequest: serviceRequest)		
		let output = try checkStatusCode( await session.data(for: urlRequest) )
		return output.data
		
	}
	public func model<Model>(_ serviceRequest: ServiceRequest, logger: Logger? = nil) async throws ->Model where Model: Codable, Model: ServiceModel {
		
		let data = try await data(serviceRequest)
		return try decode(data: data, logger: logger)
		
	}

}

extension ServiceCenter {
	
	public struct Gopher: AsyncSequence, AsyncIteratorProtocol {
		
		public typealias Element = Data

		public let center: ServiceCenter
		public var requests: [ServiceRequest]

		fileprivate var index = 0
		private mutating func nextRequest() ->ServiceRequest? { 
			
			guard index < requests.count else { return nil }
			defer { index += 1 }

			return requests[index]

		}
		
		public mutating func next() async throws -> Data? {
			
			guard let request = nextRequest() else { return nil }
			return try await center.data(request)
			
		}
			
		public func makeAsyncIterator() -> Gopher { self }
		
	}
	
	public func data(_ serviceRequests: [ServiceRequest]) async throws ->[Data] {
		
		var results: [Data] = []
		
		let gopher = Gopher(center: self, requests: serviceRequests)
		for try await data in gopher {
			
			results.append(data)
			
		}
		
		return results
		
	}
	
	public func model<Model>(_ serviceRequests: [ServiceRequest], logger: Logger? = nil) async throws ->[Model] where Model: Codable, Model: ServiceModel {

		var results: [Model] = []
		
		let gopher = Gopher(
			center: self,
			requests: serviceRequests
		)
			.map {
				
				raw ->Model in
				try self.decode(data: raw, logger: logger)
				
			}

		for try await model: Model in gopher {
			
			results.append(model)
			
		}
		
		return results

	}
	
}

extension ServiceCenter {
	
	public func decode<Model>(data: Data, logger: Logger? = nil) throws ->Model where Model: Codable, Model: ServiceModel {
		
		logger?.debug( String(data: data, encoding: .utf8) ?? "«»")
		
		do {
			switch Model.self {
				
			case is Nothing.Type:	return Nothing() as! Model
			case is Data.Type:		return data as! Model
			default:				return try ServiceCenterJSON.decoderNWK.decode(Model.self, from: data)
			}
		}
		catch {
			
			print(String(data: data, encoding: .utf8) ?? "«»")
			throw error
			
		}
		
	}
	
}

extension ServiceCenter {
	
	private func urlRequest(serviceRequest: ServiceRequest) throws ->URLRequest {
		
		try urlRequest(
			from: serviceRequest.service,
			endpoint: endpoint(serviceRequest: serviceRequest),
			body: serviceRequest.body,
			mime: serviceRequest.mime,
			authorization: serviceRequest.authorization,
			timeoutInterval: serviceRequest.timeoutInterval
		)
		
	}
	private func urlRequest(
		from service: Service,
		endpoint: URL?,
		body: Data?,
		mime: String? = nil,
		authorization: ServiceAuth?,
		timeoutInterval: TimeInterval = 60.0
	) throws ->URLRequest {
		
		guard let endpoint = endpoint else { throw Failures.invalidEndpoint }
		var request = URLRequest(url: endpoint, timeoutInterval: timeoutInterval)
		
		request.httpMethod = service.method
		request.setValue(service.accept, forHTTPHeaderField: "Accept")
		request.setValue((mime ?? service.mime), forHTTPHeaderField: "Content-Type")
		
		(authorization ?? auth).authorization.flatMap {
			request.setValue($0, forHTTPHeaderField: "Authorization")
		}
		
		request.setValue("\(body?.count ?? 0)", forHTTPHeaderField: "Content-Length")
		request.httpBody = body
		
		logger.debug( "requested: \(request)" )

		return request
		
	}
	
}

// MARK: Endpoints - Private
extension ServiceCenter {
	
	private func endpoint(serviceRequest: ServiceRequest) ->URL? {
		
		guard serviceRequest.absoluteURL == nil else { return serviceRequest.absoluteURL }
		
		return endpoint(
			from: URL(
				string: serviceRequest.subIn(string: serviceRequest.path),
				relativeTo: mainURL
			),
			queryItems: serviceRequest.queryItems
		)
		
	}
	private func endpoint(from url: URL?, queryItems: QueryItems) ->URL? {
		
		guard let url = url else { return nil }
		guard !queryItems.isEmpty else { return url }

		var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
		components?.queryItems = queryItems
		return components?.url
		
	}
	
}

// MARK: Status Codes - Private
extension ServiceCenter {
	
	private func checkStatusCode(_ output: Output) throws ->Output {
		
		guard let response = output.response as? HTTPURLResponse else { return output }
		let statusCode = response.statusCode
		
		//
		//	LINK - https://tools.ietf.org/html/rfc7231#section-6
		switch statusCode {
		case 100..<200: throw HTTPStatus.continued(statusCode,output)
		case 200..<300: return output
		case 300..<400: throw HTTPStatus.redirect(statusCode,output)
		case 400..<500: throw HTTPStatus.client(statusCode,output)
		case 500..<600: throw HTTPStatus.server(statusCode,output)
		default: 		throw HTTPStatus.notOk(statusCode,output)
		}
		//	END-LINK
		//
		
	}
	
	private func checkErrorResponse<M>( _ output: Output, errorModel: M.Type) throws ->Output where M: Error & Decodable{
		
		do { return try checkStatusCode(output) }
		catch {
			
			let data: Data
			switch error as? HTTPStatus {
				
			case .client(_, let output): data = output.data
			case .server(_, let output): data = output.data
				
			default: throw error
				
			}
			throw try ServiceCenterJSON.decoderNWK.decode(errorModel, from: data)

		}
	}

}
