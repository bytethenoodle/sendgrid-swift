//
//  Authentication.swift
//  SendGrid
//
//  Created by Scott Kawai on 6/9/16.
//  Copyright © 2016 Scott Kawai. All rights reserved.
//

import Foundation

/**
 
 The `Authentication` enum is used to represent the various ways you can authenticate with the SendGrid API.  Aside from representing the different methods, they also store the values of the desired authentication method.
 
 */
public enum Authentication: CustomStringConvertible {
    
    // MARK: - Cases
    //=========================================================================
    
    /// Used to authenticate with a username and password.
    case credential(username: String, password: String)
    
    /// Used to authenticate with a SendGrid API Key.
    case apiKey(String)
    
    
    // MARK: - Initialization
    //=========================================================================
    
    /**
     
     Initializes with a dictionary and returns the most appropriate authentication type.
     
     - parameter info:	A dictionary containing a `api_key`, or `username` and `password` key.
     
     */
    public init?(info: [AnyHashable: Any]) {
        if let k = info["api_key"] as? String {
            self = Authentication.apiKey(k)
        } else if let un = info["username"] as? String, let pw = info["password"] as? String {
            self = Authentication.credential(username: un, password: pw)
        } else {
            return nil
        }
    }
    
    
    // MARK: - Properties
    //=========================================================================
    
    /// Retrieves the user value for the authentication type (applies only to `.Credential`).
    public var user: String? {
        switch self {
        case .credential(let un, _):
            return un
        default:
            return nil
        }
    }
    
    /// Retrieves the key value for that authentication type. If the type is a `.Credentials`, this will be the password. Otherwise it will be the API key value.
    public var key: String {
        switch self {
        case .credential(_, let pw):
            return pw
        case .apiKey(let k):
            return k
        }
    }
    
    /// Returns that `Authorization` header value for the authentication type.  This can be used on any web API V3 call.
    public var authorizationHeader: String? {
        switch self {
        case .credential(let un, let pw):
            let str = "\(un):\(pw)"
            guard let data = str.data(using: String.Encoding.utf8) else {
                return nil
            }
            return "Basic " + data.base64EncodedString(options: [])
        case .apiKey(let k):
            return "Bearer \(k)"
        }
    }
    
    
    /// The ID of authentication type.
    public var description: String {
        switch self {
        case .credential(_,_):
            return LocalizableString("credential", comment: "Authentication credential")
        case .apiKey(_):
            return LocalizableString("API Key", comment: "Authentication API Key")
        }
    }

}

// MARK: - Custom Localization class
//=========================================================================

private class Localizator {
    static let sharedInstance = Localizator()
    private var localizableDictionary: [String : Any] {
        if let path = Bundle.main.path(forResource: "LocalizedStrings", ofType: "plist") {
            do {
                let rawData = try Data(contentsOf: URL(fileURLWithPath: path))
                if let realData = try PropertyListSerialization.propertyList(from: rawData, format: nil) as? [String:Any] {
                    return realData
                }
                else {
                    return [:]
                }
            }
            catch {
                return [:]
            }
        }
        else {
            return [:]
        }
    }
    
    func localize(_ key: String, message: String) -> String {
        if let rootDictionary = localizableDictionary[Locale.current.identifier] as? [String : Any] {
            if let value = rootDictionary[key] as? String {
                return value
            }
            else {
                return message
            }
        }
        else {
            return message
        }
    }
}

public func LocalizableString(_ message: String, comment: String) -> String {
    return Localizator.sharedInstance.localize(comment, message: message)
}
