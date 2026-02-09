//
//  User.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

struct UserCredentials: Identifiable {
    let id: String
    var name: String
    var email: String
}

struct User {
    var userCredentials: UserCredentials
    var profession: String
    var sleepTime: Date
    var wakeUpTime: Date
    var focusTime: Date
    var goal: String
    let isAnonymous: Bool
}
