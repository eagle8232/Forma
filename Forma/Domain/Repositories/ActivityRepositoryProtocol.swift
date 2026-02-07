//
//  ActivityRepositoryProtocol.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

protocol ActivityRepositoryProtocol {
    func fetchActivities(with id: UUID) async throws -> [Activity]
    func saveActivity(_ activity: Activity) async throws
    func deleteActivity(id: UUID) async throws
}
