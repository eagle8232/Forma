//
//  Constants.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/16/26.
//

import Foundation

struct Constants {
    static let buttonHeight: CGFloat = 56
    
    // MARK: - Tips
    static let energyPeakTips: [(String, String)] = [
        ("🌅", "Most high performers wake between 5–7 AM to maximize deep work hours."),
        ("🧠", "Your brain reaches peak cognitive performance 2–3 hours after waking."),
        ("😴", "Adults need 7–9 hours of sleep for optimal memory and recovery."),
        ("⚡️", "Consistent sleep and wake times boost energy levels by up to 40%."),
        ("🌙", "Going to bed before midnight improves deep sleep quality significantly.")
    ]
    
    static let focusTimeTips: [(String, String)] = [
        ("🎯", "Starting focus work at the same time daily trains your brain to enter flow state faster."),
        ("⏰", "The first 90 minutes of your focus block are your most cognitively powerful."),
        ("📵", "Silencing notifications during your focus window increases output by up to 64%."),
        ("☕️", "Caffeine peaks 30–60 min after intake — time it just before your focus block begins."),
        ("🔁", "Consistent focus start times improve deep work quality within just 5 days.")
    ]
    
    // MARK: - Gemini API
    static let geminiApiKey = "AIzaSyAbMXgKkhlvSK_k64aNc3F5SKcJZ49Weoo"
    static let geminiApiModel = "gemini-2.5-flash"
    
    static func prompt(with userPreferences: UserPreferences) -> String {
        return """
            You are a JSON API. Your only output is raw JSON — no prose, no markdown, no code fences.
            
            USER PREFERENCES:
            \(userPreferences)
            
            TIMEZONE: \(userPreferences.timezone)
            
            TASK:
            Generate a full day of routines tailored to the user's preferences and lifestyle.
            Create 4–6 routines covering the user's day (e.g. Morning, Deep Work, Lunch, Evening, Wind-Down).
            Each routine must be realistic, time-blocked, and non-overlapping.
            
            OUTPUT FORMAT:
            Emit each routine as a standalone JSON object — do NOT wrap in an array.
            After each complete JSON object, write the word Finished on a new line.
            
            Example output structure:
            {"id":"...","name":"...","description":"...","iconString":"🌞","colorString":"#F97316","startTime":"07:00","endTime":"09:00","activities":          [{"id":"...","name":"...","startTime":"07:00","description":"...","duration":30}]}\nFinished
            
            STRICT RULES: [Titles should not exceeds 25 letters]
            - id: UUID string (e.g. "a1b2c3d4-...")
            - name: short routine name (e.g. "Morning Routine") 
            - description: 1 sentence describing the routine's purpose
            - iconString: a single relevant emoji
            - colorString: a hex color that matches the routine's mood
            - startTime / endTime: HH:mm format only, in the user's timezone (\(userPreferences.timezone))
            - activities: array of tasks that fill the time between startTime and endTime
              - Each activity's startTime must be HH:mm
              - duration is in minutes (Int)
              - Activities must be sequential and non-overlapping
              - Last activity's startTime + duration must equal the routine's endTime
            - No field should be null or omitted
            - Do not add any text before, between, or after the JSON objects except the word Finished
"""
    }
}
