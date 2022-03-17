//
//  ServiceCenter.swift
//  Goth
//
//  Created by Bil Moorhead on 9/19/21.
//

@preconcurrency import Foundation

@preconcurrency import Logger

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
		case versionMismatch(String, String, String)
		
	}

	public enum HTTPStatus: Error, CustomStringConvertible {
		
		case notOk(Int, Output)
		case continued(Int, Output)
		case ok(Int, Output)
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
			case let .ok(statusCode, output): return message(statusCode: statusCode, output: output)
			case let .redirect(statusCode, output): return message(statusCode: statusCode, output: output)
			case let .client(statusCode, output): return message(statusCode: statusCode, output: output)
			case let .server(statusCode, output): return message(statusCode: statusCode, output: output)

			}
		}
	}

	
	public let session: URLSession

	public var mainURL: URL
	public func update(url: URL) { self.mainURL = url }
	
	public var curator: ServiceCurator
	public func update(curator: ServiceCurator) { self.curator = curator }
	public func update(auth: ServiceAuth) { curator.update(serviceAuth: auth) }
	
	public var state: ServiceState
	public func update(state: ServiceState) { self.state = state }
	
	public var history: ServiceHistory?
	public func update(history: ServiceHistory?) { self.history = history }
	
	//
	
	public init(configuration: URLSessionConfiguration = .default, mainURL: URL, curator: ServiceCurator = BasicCurator(), state: ServiceState = EmptyServiceState(), history: ServiceHistory? = nil) {
		
		self.session = URLSession(configuration: configuration)
		self.mainURL = mainURL
		self.curator = curator
		self.state = state
		self.history = history
		
	}
	public convenience init(serviceCenter: ServiceCenter) async {
		
		await self.init(
			configuration: serviceCenter.session.configuration,
			mainURL: serviceCenter.mainURL,
			curator: serviceCenter.curator,
			state: serviceCenter.state,
			history: serviceCenter.history
		)
		
	}

}

//
//	MARK:	Data - Public 
extension ServiceCenter {
	
	public func data(
		_ service: Service,
		body: Data? = nil,
		mime: String? = nil,
		substitutions: Substitutions = [:],
		queryItems: QueryItems = [],
		authorization: ServiceAuth? = nil,
		timeoutInterval: TimeInterval = 60.0,
		logger: Logger? = nil
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
				timeoutInterval: timeoutInterval,
				logger: logger
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
		timeoutInterval: TimeInterval = 60.0,
		logger: Logger? = nil
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
					timeoutInterval: timeoutInterval,
					logger: logger
				)

			}
			
		)
		
	}
	
}

//	MARK:	Model - Public
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
				timeoutInterval: timeoutInterval,
				logger: logger
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
					timeoutInterval: timeoutInterval,
					logger: logger
				)

			}
			
		)
		
	}
}


//	MARK:	Service Requests - Private
extension ServiceCenter {
	
	public struct ServiceRequest : Sendable {

		public let service: Service
		public let body: Data?
		public let mime: String?
		public var substitutions: Substitutions = [:]
		public var queryItems: QueryItems = []
		public var authorization: ServiceAuth? = nil
		public var timeoutInterval: TimeInterval = 60.0
		public var logger: Logger? = nil
		
		// derivitives
		public var path: String { service.path }
		public var absoluteURL: URL? { service.absoluteURL }
		public func subIn(string: String) ->String { substitutions.subIn(string: string) }
		
		//
		
		public init(service: Service, body: Data? = nil, mime: String? = nil, substitutions: Substitutions = [:], queryItems: QueryItems = [], authorization: ServiceAuth? = nil, timeoutInterval: TimeInterval = 60.0, logger: Logger? = nil) {
			
			self.service = service
			self.body = body
			self.mime = mime
			self.substitutions = substitutions
			self.queryItems = queryItems
			self.authorization = authorization
			self.timeoutInterval = timeoutInterval
			self.logger = logger
			
		}
		
		//
		
		public func log(data: Data) {
			
			let logMessage = String(data: data, encoding: .utf8) ?? "«»"
			logger?.debug( "\(logMessage)" )
			
		}
		
		public func log(urlRequest: URLRequest) {
			
			let logMessage = urlRequest
			logger?.debug( "\(logMessage)" )
			
		}
		
	}
	
	//
	
	public func output(_ serviceRequest: ServiceRequest) async throws ->Output {
		
		let urlRequest = try self.urlRequest(serviceRequest: serviceRequest)
		serviceRequest.log(urlRequest: urlRequest)
		
		let output = try await checkStatusCode( session.data(for: urlRequest), serviceRequest: serviceRequest )
		serviceRequest.log(data: output.data)

		return output
		
	}
	
	public func data(_ serviceRequest: ServiceRequest) async throws ->Data {
		
		var serviced = ServicedAt(service: serviceRequest.service)
		defer {
			
			serviced.split()
			history?.add(serviced)
			
		}
		
		let output = try await output(serviceRequest)
		return output.data
		
	}
	public func model<Model>(_ serviceRequest: ServiceRequest) async throws ->Model where Model: Codable, Model: ServiceModel {
		
		let data = try await data(serviceRequest)
		return try decode(data: data)
		
	}

}

//	MARK:	Gopher - Private
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
			
			let data = try await center.data(request)
			request.log(data: data)
			
			return data
			
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
	
	public func model<Model>(_ serviceRequests: [ServiceRequest]) async throws ->[Model] where Model: Codable, Model: ServiceModel {

		var results: [Model] = []
		
		let gopher = Gopher(
			center: self,
			requests: serviceRequests
		)
			.map {
				
				raw ->Model in
				try self.decode(data: raw)
				
			}

		for try await model: Model in gopher {
			
			results.append(model)
			
		}
		
		return results

	}
	
}

//	MARK:	Decode
extension ServiceCenter {
	
	public func decode<Model>(data: Data) throws ->Model where Model: Codable, Model: ServiceModel {
		
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

//	MARK:	URLRequests - Private
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
		
		(authorization ?? curator.serviceAuth).authorization.flatMap {
			request.setValue($0, forHTTPHeaderField: "Authorization")
		}
		
		request.setValue("\(body?.count ?? 0)", forHTTPHeaderField: "Content-Length")
		request.httpBody = body
		
		return request
		
	}
	
}

//	MARK:	Endpoints - Private
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

//	MARK:	Status Codes - Private
extension ServiceCenter {
	
	private func checkStatusCode(_ output: Output, serviceRequest: ServiceRequest) async throws ->Output {
		
		guard let response = output.response as? HTTPURLResponse else { return output }
		let statusCode = response.statusCode
		
		//
		//	INFO	HTTP status codes
		//	LINK -	https://tools.ietf.org/html/rfc7231#section-6
		//
		
		var httpStatus: HTTPStatus = .notOk(statusCode, output)
		
		switch statusCode {
		case 100..<200: httpStatus = .continued(statusCode,output)
		case 200..<300: httpStatus = .ok(statusCode,output)
		case 300..<400: httpStatus = .redirect(statusCode,output)
		case 400..<500: httpStatus = .client(statusCode,output)
		case 500..<600: httpStatus = .server(statusCode,output)
		default: 		break
			
		}

		//
		//	INFO -	Let the curator handle the the status code appropriately.
		//
		//			The service request is passed, in case the curator has need of the information therein.
		//			The service center is passed, in case the curator has need make API calls.
		//
		//			The most common case is for 401/403's that are returned by the OAUTH folks.
		//
		return try await curator.handle(
			status: httpStatus,
			for: serviceRequest,
			on: self
		)
		
	}
	
	
}
