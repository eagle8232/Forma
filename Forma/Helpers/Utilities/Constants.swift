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
    
}

// MARK: - AI Constants

extension Constants {
    
    static let geminiApiKey = "AIzaSyDhgyPd0CZqkVABgRyd-91If_N9Qe-f-oE"
    static let geminiApiModel = "gemini-2.5-flash"
    
    static func prompt(with userPreferences: UserPreferences) -> String {

        // ── Current local time in user's timezone (for context only) ──
        let tz = TimeZone(identifier: userPreferences.timezone ?? "GMT+0") ?? .current

        let timeFmt = DateFormatter()
        timeFmt.dateFormat = "HH:mm"
        timeFmt.timeZone = tz
        let currentTime = timeFmt.string(from: Date())

        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "EEEE, MMM d yyyy"
        dateFmt.timeZone = tz
        let currentDate = dateFmt.string(from: Date())

        return """
        You are a JSON API. Your only output is raw JSON — no prose, no markdown, no code fences.

        CONTEXT:
        Current date: \(currentDate)
        Current time: \(currentTime) (\(userPreferences.timezone))
        All times you generate MUST be in \(userPreferences.timezone). Do NOT use UTC. Do NOT convert.

        USER PREFERENCES:
        \(userPreferences)

        TASK:
        Generate a complete daily routine plan tailored to the user's preferences and lifestyle.
        Create 4–6 routines that cover the user's FULL day — from their natural wake time to their sleep time.
        The schedule must represent the user's ideal full day, regardless of the current time.
        Current time is provided only as context — do NOT use it as the starting point.
        Base the start and end times on the user's preferences (wake time, sleep time, work schedule, etc).
        Each routine must be realistic, time-blocked, and non-overlapping.
        Leave small gaps between routines (5–15 min) for rest and transitions.
        Routines must be ordered chronologically from morning to night.

        OUTPUT FORMAT:
        Emit each routine as a standalone JSON object — do NOT wrap them in an array.
        After each complete JSON object, write the word Finished on its own line.

        Example:
        {"id":"a1b2c3d4-e5f6-7890-abcd-ef1234567890","name":"Morning Routine","description":"Start the day with intention.","iconString":"🌅","colorString":"#F97316","startTime":"07:00","endTime":"09:00","activities":[{"id":"e5f6g7h8-i9j0-1234-klmn-op5678901234","name":"Meditation","startTime":"07:00","description":"Calm the mind.","duration":20},{"id":"i9j0k1l2-m3n4-5678-opqr-st9012345678","name":"Journaling","startTime":"07:20","description":"Reflect on goals.","duration":40}]}
        Finished

        STRICT RULES:
        - id: UUID string (e.g. "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
        - name: max 25 characters, short and descriptive (e.g. "Morning Routine")
        - description: 1 sentence describing the routine's purpose
        - iconString: a single relevant emoji
        - colorString: a hex color that reflects the routine's mood or energy level
        - startTime / endTime: HH:mm format, strictly in \(userPreferences.timezone) local time
        - activities: array of tasks that exactly fill the time between startTime and endTime
          - Each activity id: UUID string
          - Each activity name: max 25 characters
          - Each activity startTime: HH:mm, in \(userPreferences.timezone) local time
          - Each activity description: 1 short sentence
          - duration: integer, in minutes
          - Is it break time: False or true (Boolean)
          - Activities must be sequential and non-overlapping
          - First activity startTime must equal routine startTime
          - Last activity startTime + duration (in minutes) must equal routine endTime
          - Sum of all activity durations must equal the total routine duration in minutes
        - No field may be null or omitted
        - Do not output any text before, between, or after JSON objects except the word Finished
        - Do not wrap output in an array or any outer object
        """
    }

    static func questionsPrompt(with userPreferences: UserPreferences) -> String {
        let tz = TimeZone(identifier: userPreferences.timezone ?? "UTC") ?? .current

        let timeFmt = DateFormatter()
        timeFmt.dateFormat = "HH:mm"
        timeFmt.timeZone   = tz
        let currentTime    = timeFmt.string(from: Date())

        return """
        You are Forma AI. Based on the user profile below, generate 3–4 personalised
        follow-up questions to better tailor their daily routine.

        USER PROFILE:
        \(userPreferences)

        CURRENT TIME: \(currentTime) (\(userPreferences.timezone ?? "UTC"))

        OUTPUT — raw JSON only, no prose, no markdown, no code fences:
        {
          "message": "one warm sentence intro (max 12 words)",
          "questions": [
            {
              "id": "snake_case_id",
              "text": "Question text (max 12 words)",
              "type": "single_choice",
              "options": [
                { "id": "option_id", "label": "Max 4 words" }
              ]
            }
          ]
        }

        STRICT RULES:
        - Generate exactly 3–4 questions
        - Each question must have 2–4 options
        - Option labels: max 4 words each
        - Question types: single_choice (pick one), multi_choice (pick many), yes_no
        - ALWAYS include a prayer/spirituality question — critical for schedule blocking
        - ALWAYS include a work-style question
        - Make remaining questions relevant to the user's job and goal
        - A software engineer gets different questions than a student or a parent
        - Output JSON only — nothing before or after
        """
    }
}
