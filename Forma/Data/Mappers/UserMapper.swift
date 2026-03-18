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
            credentials: self.credentials?.toEntity() ?? .mockCredentialData,
            preferences: self.preferences?.toEntity() ?? .mockPreferencesData
        )
    }
}

extension User {
    func toDTO() -> UserDTO {
        return UserDTO(
            credentials: self.credentials.toDTO(),
            preferences: self.preferences?.toDTO()
        )
    }
}

// MARK: - UserCredentialsDTO Mapper

extension UserCredentialsDTO {
    func toEntity() -> UserCredentials {
        return UserCredentials(
            id: self.id ?? "No id",
            name: self.name ?? "No name",
            email: self.email ?? "No email",
            isAnonymous: self.isAnonymous ?? false
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

extension UserPreferencesDTO {
    func toEntity() -> UserPreferences {
        return UserPreferences(
            profession: self.profession ?? "No profession",
            sleepTime: self.sleepTime ?? Date(),
            wakeUpTime: self.wakeUpTime ?? Date(),
            focusTime: self.focusTime ?? Date(),
            goal: self.goal ?? ["No goal"]
        )
    }
}

extension UserPreferences {
    func toDTO() -> UserPreferencesDTO {
        return UserPreferencesDTO(
            profession: self.profession,
            sleepTime: self.sleepTime,
            wakeUpTime: self.wakeUpTime,
            focusTime: self.focusTime,
            goal: self.goal
        )
    }
}
