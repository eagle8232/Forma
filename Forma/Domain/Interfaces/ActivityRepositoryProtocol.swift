//
//  ActivityRepositoryProtocol.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

protocol ActivityRepositoryProtocol {
    func fetchActivities(with id: String) async throws -> [RoutineTask]
    func saveActivity(_ activity: RoutineTask) async throws
    func deleteActivity(_ activity: RoutineTask) async throws
}
