//
//  RoutineRepositoryProtocol.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

protocol RoutineRepositoryProtocol {
    func fetchRoutines(userId: String) async throws -> [RoutineBlock]
    func saveRoutine(_ routines: [RoutineBlock], userId: String) async throws
    func deleteRoutine(_ routine: RoutineBlock, userId: String) async throws
}
