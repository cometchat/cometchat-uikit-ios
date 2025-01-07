//
//  ActionElement.swift
//  
//
//  Created by Abhishek Saralaya on 15/09/23.
//

import Foundation

public class APIAction: ActionEntity {
    public var method:HttpMethodType = .POST
    @objc public var url = ""
    @objc public var payLoad = [String:Any]()
    @objc public var headers = [String:String]()
    @objc public var dataKey = "data"
    @objc public var disableAfterInteracted = false
    
    public init() {
        super.init(actionType: "apiAction")
    }
}

public enum HttpMethodType {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
    
    public var value:String {
        
        switch self {
        case .GET:
            return "GET";
        case .POST:
            return "POST";
        case .PUT:
            return "PUT"
        case .PATCH:
            return "PATCH"
        case .DELETE:
            return "DELETE"
        }
    }
}

public class URLNavigationAction:ActionEntity {
    public init() {
        super.init(actionType: "urlNavigation")
    }
    @objc public var url = ""
}

extension String {
    
    internal var stringValueToHttpMethodType: HttpMethodType?{
        
        if self.compare(HttpMethodType.GET.value) == .orderedSame {
            return .GET;
        }
        else if self.compare(HttpMethodType.POST.value) == .orderedSame {
            return .POST;
        }
        else if self.compare(HttpMethodType.PUT.value) == .orderedSame {
            return .PUT;
        }
        else if self.compare(HttpMethodType.PATCH.value) == .orderedSame {
            return .PATCH;
        }
        else if self.compare(HttpMethodType.DELETE.value) == .orderedSame {
            return .DELETE;
        }
        return nil;
    }
}
