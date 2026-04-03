import Foundation

extension UserDTO {
    func toEntity() -> User {
        User(
            credentials: self.credentials?.toEntity() ?? .mockCredentialData,
            preferences: self.preferences?.toEntity() ?? .mockPreferencesData
        )
    }
}

extension User {
    func toDTO() -> UserDTO {
        UserDTO(
            credentials: self.credentials.toDTO(),
            preferences: self.preferences?.toDTO()
        )
    }
}

extension UserCredentialsDTO {
    func toEntity() -> UserCredentials {
        UserCredentials(
            id: self.id ?? "No id",
            name: self.name ?? "No name",
            email: self.email ?? "No email",
            isAnonymous: self.isAnonymous ?? false
        )
    }
}

extension UserCredentials {
    func toDTO() -> UserCredentialsDTO {
        UserCredentialsDTO(
            id: self.id,
            name: self.name,
            email: self.email
        )
    }
}

extension UserPreferencesDTO {
    func toEntity() -> UserPreferences {
        UserPreferences(
            profession: self.profession ?? "No profession",
            sleepTime: self.sleepTime ?? Date(),
            wakeUpTime: self.wakeUpTime ?? Date(),
            focusTime: self.focusTime ?? Date(),
            goal: self.goal ?? ["No goal"],
            prayerFrequency: self.prayerFrequency,
            workStyle: self.workStyle,
            exerciseTime: self.exerciseTime,
            lunchBreak: self.lunchBreak,
            additionalContext: self.additionalContext
        )
    }
}

extension UserPreferences {
    func toDTO() -> UserPreferencesDTO {
        UserPreferencesDTO(
            profession: self.profession,
            sleepTime: self.sleepTime,
            wakeUpTime: self.wakeUpTime,
            focusTime: self.focusTime,
            goal: self.goal,
            prayerFrequency: self.prayerFrequency,
            workStyle: self.workStyle,
            exerciseTime: self.exerciseTime,
            lunchBreak: self.lunchBreak,
            additionalContext: self.additionalContext
        )
    }
}
