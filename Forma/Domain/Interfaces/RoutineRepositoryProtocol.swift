//
//  RoutineRepositoryProtocol.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

protocol RoutineRepositoryProtocol {
    func fetchRoutines(userId: String) async throws -> [Routine]
    func saveRoutine(_ routines: [Routine], userId: String) async throws
    func deleteRoutine(_ routine: Routine, userId: String) async throws
}
