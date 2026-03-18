//
//  AIRepositoryProtocol.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/7/26.
//

import Foundation

protocol AIRepositoryProtocol: AnyObject {
    func generateRoutines(userPreferences: UserPreferences) async throws -> AsyncStream<RoutineBlock>
    func summarize() // - Integration depends on further usage statistics
}
