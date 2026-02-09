//
//  UserMapper.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/9/26.
//

import Foundation

extension UserDTO {
    func toEntity() -> User{
        return User(
            userCredentials: self.userCredentials?.toEntity() ?? .mockData,
            profession: self.profession ?? "No profession",
            sleepTime: self.sleepTime ?? Date(),
            wakeUpTime: self.wakeUpTime ?? Date(),
            focusTime: self.focusTime ?? Date(),
            goal: self.goal ?? "No goal",
            routines: self.routines?.map{$0.toEntity()} ?? Routine.allMocks,
            isAnonymous: self.isAnonymous ?? false
        )
    }
}

extension User {
    func toDTO() -> UserDTO{
        return UserDTO(
            userCredentials: self.userCredentials.toDTO(),
            profession: self.profession,
            sleepTime: self.sleepTime,
            wakeUpTime: self.wakeUpTime,
            focusTime: self.focusTime,
            goal: self.goal,
            routines: self.routines.map {$0.toDTO()},
            isAnonymous: self.isAnonymous
        )
    }
}

// MARK: - UserCredentialsDTO Mapper

extension UserCredentialsDTO {
    func toEntity() -> UserCredentials {
        return UserCredentials(
            id: self.id ?? "No id",
            name: self.name ?? "No name",
            email: self.email ?? "No email"
        )
    }
}

extension UserCredentials {
    func toDTO() -> UserCredentialsDTO {
        return UserCredentialsDTO(
            id: self.id,
            name: self.name ,
            email: self.email
        )
    }
}
