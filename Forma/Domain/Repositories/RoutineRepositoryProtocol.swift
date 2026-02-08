//
//  RoutineRepositoryProtocol.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

protocol RoutineRepositoryProtocol {
    func saveRoutine(_ routine: [Routine]) async throws
    func fetchRoutines() async throws -> [Routine]
    func deleteRoutine(_ routine: Routine) async throws
    func updateRoutine(_ routine: Routine) async throws
}
