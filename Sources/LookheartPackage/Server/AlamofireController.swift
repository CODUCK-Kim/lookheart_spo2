import Alamofire
import Foundation

public enum NetworkResponse {
    case successWithData(String)
    case success
    case failer
    case notConnected
    case session
    case invalidResponse
    case noData
}


public class AlamofireController: NetworkProtocol {
    public static let shared = AlamofireController()

    private lazy var baseURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "Base URL") as? String else {
            fatalError("Base URL not found in Info.plist")
        }
        return url
    }()
    
    private lazy var mongoURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "Mongo URL") as? String else {
            fatalError("Mongo URL not found in Info.plist")
        }
        return url
    }()


    public func task<T: Decodable>(
        parameters: [String : Any],
        endPoit: EndPoint,
        method: HTTPMethod,
        type: T.Type
    ) async -> (result: T?, response: NetworkResponse) {
        do {
            let result: T = try await alamofireControllerTask(
                parameters: parameters,
                endPoint: endPoit,
                method: method
            )
            return (result: result, response: .success)
        } catch {
            let error = handleError(error)
            return (result: nil, response: error)
        }
    }
    
    private func alamofireControllerTask <T: Decodable> (
        parameters: [String: Any],
        endPoint: EndPoint,
        method: HTTPMethod,
        mongo: Bool = false
    ) async throws -> T {
        
        let baseUrl = mongo ? mongoURL : baseURL
        
        guard let url = URL(string: baseUrl + endPoint.rawValue) else {
            throw NSError(domain: "InvalidURL", code: -1, userInfo: nil)
        }

        let response = try await AF.request(url, method: method, parameters: parameters, encoding: (method == .get) ? URLEncoding.default : URLEncoding.httpBody)
            .validate(statusCode: 200..<300)
            .serializingData().value
        
        if T.self == String.self {
            /* String */
            guard let stringData = String(data: response, encoding: .utf8) as? T else {
                throw NSError(domain: "DataEncodingError", code: -2, userInfo: nil)
            }
            return stringData
        } else {
            /* Decoding */
            return try JSONDecoder().decode(T.self, from: response)
        }
    }
    
    
    public func handleError(_ error: Error) -> NetworkResponse {
        if let error = error as? AFError {
            switch error {
            case .sessionTaskFailed(let underlyingError):
                if let urlError = underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                    return .notConnected
                } else {
                    return .session
                }
            default:
                return .invalidResponse
            }
        } else {
            return .invalidResponse
        }
    }

    public func getBaseURL() -> String {
        return baseURL
    }
    
    
    
    
    
    
    
    
    
    
    
    @available(iOS 13.0.0, *)
    public func alamofireControllerAsync <T: Decodable> (
        parameters: [String: Any],
        endPoint: EndPoint,
        method: HTTPMethod,
        mongo: Bool = false
    ) async throws -> T {
        
        let baseUrl = mongo ? mongoURL : baseURL
        
        guard let url = URL(string: baseUrl + endPoint.rawValue) else {
            throw NSError(domain: "InvalidURL", code: -1, userInfo: nil)
        }

        let response = try await AF.request(url, method: method, parameters: parameters, encoding: (method == .get) ? URLEncoding.default : URLEncoding.httpBody)
            .validate(statusCode: 200..<300)
            .serializingData().value
        
        return try JSONDecoder().decode(T.self, from: response)
    }
    
    
    
    @available(iOS 13.0.0, *)
    public func alamofireControllerForString(
        parameters: [String: Any],
        endPoint: EndPoint,
        method: HTTPMethod,
        mongo: Bool = false
    ) async throws -> String {
        
        let baseUrl = mongo ? mongoURL : baseURL
        
        guard let url = URL(string: baseUrl + endPoint.rawValue) else {
            throw NSError(domain: "InvalidURL", code: -1, userInfo: nil)
        }
            
        let response = try await AF.request(url, method: method, parameters: parameters,
                                            encoding: (method == .get) ? URLEncoding.default : URLEncoding.httpBody)
            .validate(statusCode: 200..<300)
            .serializingData().value
        
        guard let stringData = String(data: response, encoding: .utf8) else {
            throw NSError(domain: "DataEncodingError", code: -2, userInfo: nil)
        }

        return stringData
    }

}
