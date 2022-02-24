//
//  Service.swift
//  Goth
//
//  Created by Bil Moorhead on 9/19/21.
//

@preconcurrency import Foundation

public struct Service: Identifiable, Hashable, Sendable {
	
	public typealias Name = String
	
	public let name: Name
	public var id: String { name }
	
	public let method: String
	public let path: String
	public var absoluteURL: URL? = nil
	
	public var mime: String? = nil 
	public var accept: String? = nil
	
	public var active: Bool = true

}

extension Service {
	
	public static let zero = Service.GET("«»", path: "")
	public static func absolute(_ name: Name, absoluteURL: URL, mime: String = "application/json", accept: String = "application/json", active: Bool = true) ->Service {
		
		Service(name: name, method: "GET", path: "", absoluteURL: absoluteURL, mime: mime, accept: accept, active: active)
		
	}
	
	//
	//	NOTE -	These are convienence methods that make the method
	//			more pronounced
	//
	
	public static func GET(_ name: Name, path: String, mime: String = "application/json", accept: String = "application/json", active: Bool = true) ->Service {
		
		Service(name: name, method: "GET", path: path, mime: mime, accept: accept, active: active)
		
	}
	public static func HEAD(_ name: Name, path: String, active: Bool = false) ->Service {
		
		Service(name: name, method: "HEAD", path: path, active: active)
		
	}
	public static func POST(_ name: Name, path: String, mime: String = "application/json", accept: String = "application/json", active: Bool = true) ->Service {
		
		Service(name: name, method: "POST", path: path, mime: mime, accept: accept, active: active)
		
	}
	public static func PUT(_ name: Name, path: String, mime: String = "application/json", accept: String = "application/json", active: Bool = true) ->Service {
		
		Service(name: name, method: "PUT", path: path, mime: mime, accept: accept, active: active)
		
	}
	public static func DELETE(_ name: Name, path: String, mime: String = "application/json", accept: String = "application/json", active: Bool = true) ->Service {
		
		Service(name: name, method: "DELETE", path: path, mime: mime, accept: accept, active: active)
		
	}
	public static func OPTIONS(_ name: Name, path: String, mime: String = "application/json", accept: String = "application/json", active: Bool = false) ->Service {
		
		Service(name: name, method: "OPTIONS", path: path, mime: mime, accept: accept, active: active)
		
	}
	public static func TRACE(_ name: Name, path: String, active: Bool = false) ->Service {
		
		Service(name: name, method: "TRACE", path: path, active: active)
		
	}
	public static func CONNECT(_ name: Name, path: String, active: Bool = false) ->Service {
		
		Service(name: name, method: "CONNECT", path: path, active: active)
		
	}
	
}

