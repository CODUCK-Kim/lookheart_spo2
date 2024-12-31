//
//  File.swift
//  
//
//  Created by KHJ on 6/24/24.
//

import Foundation

public struct ExerciseList: Decodable {
    public let kind: String
    public let sDate: String
    public let eDate: String
    
    public let cal: Int
    public let calexe: Int
    public let step: Int
    public let distance: Int
    public let arrCount: Int
}

@available(iOS 13.0.0, *)
public class ExerciseService {
    
    public init() {}
    
    public func postExercise(exerciseData: [String: Any]) async -> NetworkResponse {
        var params: [String: Any] = [
            "eq": propEmail
        ]
        
        params.merge(exerciseData) { (current, _) in current }
        
        do {
            let data = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .postExerciseData,
                method: .post,
                mongo: true
            )
            
            print("Send Exercise data: \(data)")
            
            if data.contains("true") {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
    
    
    public func deleteExercise(exerciseData: [String: Any]) async -> NetworkResponse {
        var params: [String: Any] = [
            "eq": propEmail
        ]
        
        params.merge(exerciseData) { (current, _) in current }
        
        do {
            let data = try await AlamofireController.shared.alamofireControllerForString(
                parameters: params,
                endPoint: .deleteExerciseData,
                method: .post,
                mongo: true
            )
            
            print("delete Exercise data: \(data)")
            
            if data.contains("true") {
                return .success
            } else {
                return .failer
            }
        } catch {
            return AlamofireController.shared.handleError(error)
        }
    }
    
    
    public func getExerciseList(
        startDate: String,
        endDate: String
    ) async -> ([ExerciseList]?, NetworkResponse) {
        let params: [String: Any] = [
            "id": propEmail,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        do {
            let exerciseList: [ExerciseList] = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: params,
                endPoint: .getExerciseList,
                method: .get,
                mongo: true
            )
            
//            print("exerciseList: \(exerciseList)")
            
            return (exerciseList, .success)
        } catch {
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
    
    public func getExerciseData(
        kind: String,
        startDate: String,
        endDate: String
    ) async -> (data: [String]?, response: NetworkResponse) {
        let params: [String: Any] = [
            "id": propEmail,
            "startDate": startDate,
            "endDate": endDate,
            "kind": kind
        ]
        
        do {
            let exerciseData: [String] = try await AlamofireController.shared.alamofireControllerAsync(
                parameters: params,
                endPoint: .getExerciseData,
                method: .get,
                mongo: true
            )
            
            return (exerciseData, .success)
        } catch {
            return (nil, AlamofireController.shared.handleError(error))
        }
    }
}
