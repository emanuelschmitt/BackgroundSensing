//
//  NetworkController.swift
//  BackgroundSensing
//
//  Created by Emanuel Schmitt on 04.05.17.
//  Copyright © 2017 Emanuel Schmitt. All rights reserved.
//
import Foundation
import PromiseKit

let BASE_URL: String = "http://130.149.222.214/api/v1/"
let CHUNK_SIZE: Int = 300

private enum requestType {
    case GET, POST
}

private enum endpointURL: String {
    case login = "login/"
    case sensorData = "sensordata/"
}

class NetworkController {
    static let shared = NetworkController()
    
    let authenticationService = AuthenticationService.shared
    
    // MARK: - Helpers
    
    private func buildRequest(requestType: requestType, url: String, data: Data?) -> URLRequest {
        
        var request = URLRequest(url: URL(string: url)!)
        
        // set Json Headers
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        // set Authetication Headers
        if (authenticationService.isAuthenticated()){
            let token = authenticationService.authToken!
            request.setValue("Token " + token, forHTTPHeaderField: "Authorization")
        }
        
        switch requestType{

        case .GET:
            request.httpMethod = "GET"
            break
        
        case .POST:
            request.httpMethod = "POST"
            request.httpBody = data!
            break
        }
        
        return request
    }
    
    private func performRequest(request: URLRequest) -> Promise<[String: Any]>{
        return Promise<[String: Any]> { fulfill, reject in
        
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let data = data, let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
                    
                    fulfill(json)
                    
                } else if let error = error {
                    reject(error)
                } else {
                    let error = NSError(
                        domain: "NetworkController",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Unknown error"]
                    )
                    reject(error)
                }
            }
            
            task.resume()
    
        }
        
    }
    
    // MARK: - Endpoints
    
    public func login(with credentials: LoginCredentials) -> Promise<[String: Any]> {
        let url = BASE_URL + endpointURL.login.rawValue
        
        let request = buildRequest(
            requestType: .POST,
            url: url,
            data: credentials.toJSON()
        )

        return performRequest(request: request)
    }

    
    public func sendSensorData(sensorData: [SensorData]) -> Promise<[[String: Any]]>{
    
        let url = BASE_URL + endpointURL.sensorData.rawValue
        
        // Split all SensorData into arrays of CHUNK_SIZE
        let sensorDataChunks = sensorData.splitBy(subSize: CHUNK_SIZE)

        func sendChunk(sensorDataArray: [SensorData]) -> Promise<[String: Any]> {
            let jsonArray = sensorDataArray.map({ return $0.toJSONDictionary() })
            
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray, options: [])
            let request = buildRequest(
                requestType: .POST,
                url: url,
                data: jsonData
            )

            return performRequest(request: request)
        }
        
        // Create promise for each sensor chunk
        let chunkPromises = sensorDataChunks.map({ chunk in return sendChunk(sensorDataArray: chunk) })
    
        // Return promise when fulfilling all promises
        return when(fulfilled: chunkPromises)
    }
}
