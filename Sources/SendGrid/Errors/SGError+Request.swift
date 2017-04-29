//
//  SGError+Request.swift
//  SendGrid
//
//  Created by Scott Kawai on 6/10/16.
//  Copyright © 2016 Scott Kawai. All rights reserved.
//

import Foundation

public extension SGError {
    
    /**
     
     The `Request` enum contains all the errors thrown when attempting to build an HTTP request.
     
     */
    public enum Request: Error, CustomStringConvertible {
        
        // MARK: - Cases
        //=========================================================================
        
        /// Represents an attempt to use a class that doesn't conform to `Request`.
        case nonConformingRequest(AnyClass)
        
        /// Represents an error in constructing the URL for an API call.
        case unableToConstructUrl
        
        /// Represents an error where the "Authorization" error couldn't be added to the API call.
        case authorizationHeaderError
        
        /// Thrown when attempting to use the "onBehalfOf" feature on an API call that doesn't support it.
        case impersonationNotSupported(AnyClass)
        
        // MARK: - Properties
        //=========================================================================
        
        /// A description for the error.
        public var description: String {
            switch self {
            case .nonConformingRequest(let object):
                return "Error: Non-Conforming Request."
                
            case .unableToConstructUrl:
                return "Error: Unable to construct Url."
                
            case .authorizationHeaderError:
                return "Error: Authorization header error."
                
            case .impersonationNotSupported(let object):
                return "Error: Impersonation not supported."
            }
        }
    }
}
