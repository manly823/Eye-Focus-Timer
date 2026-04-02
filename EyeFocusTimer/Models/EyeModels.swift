import SwiftUI

// MARK: - Exercise

enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case followDot, nearFar, palming, figure8, blinkBreak, peripheralPeek
    var id: String { rawValue }
}

struct EyeExercise: Identifiable {
    let id: ExerciseType
    let name: String
    let subtitle: String
    let icon: String
    let color: Color
    let duration: Int
    let description: String
}

extension EyeExercise {
    static let all: [EyeExercise] = [
        EyeExercise(id: .followDot, name: "Follow the Dot", subtitle: "Track a moving target", icon: "circle.circle.fill", color: Theme.cyan, duration: 40,
                     description: "A glowing dot moves across the screen in smooth patterns. Follow it with your eyes without moving your head. This exercise is commonly recommended by optometrists to support eye muscle coordination (AAO)."),
        EyeExercise(id: .nearFar, name: "Near-Far Focus", subtitle: "Shift focal distance", icon: "arrow.up.arrow.down.circle.fill", color: Theme.violet, duration: 45,
                     description: "Alternate focus between a near target and a far target. Hold each focus for 3 seconds. Based on accommodation exercises recommended by the American Optometric Association (AOA)."),
        EyeExercise(id: .palming, name: "Palming Rest", subtitle: "Deep eye relaxation", icon: "hand.raised.circle.fill", color: Theme.mint, duration: 60,
                     description: "Cover your eyes gently with your palms. Follow the breathing guide to relax. Palming is a traditional relaxation technique referenced in optometric wellness literature."),
        EyeExercise(id: .figure8, name: "Figure 8", subtitle: "Trace infinity pattern", icon: "infinity.circle.fill", color: Color(red: 0.95, green: 0.55, blue: 0.25), duration: 40,
                     description: "Follow a dot tracing an infinity (∞) shape. A common optometric exercise for eye muscle flexibility and binocular coordination (AOA)."),
        EyeExercise(id: .blinkBreak, name: "Blink Break", subtitle: "Refresh your tear film", icon: "eye.circle.fill", color: Color(red: 0.85, green: 0.40, blue: 0.65), duration: 30,
                     description: "Research suggests blink rate decreases during screen use (Tsubota et al., NEJM 1993). This guided blinking exercise encourages a healthy blink rate."),
        EyeExercise(id: .peripheralPeek, name: "Peripheral Peek", subtitle: "Expand your vision field", icon: "viewfinder.circle.fill", color: Theme.amber, duration: 35,
                     description: "Stare at the center dot. Tap anywhere when you notice a flash at the edge of your vision. An awareness exercise based on standard visual field concepts."),
    ]
}

// MARK: - Session

struct BreakSession: Identifiable, Codable {
    var id = UUID()
    var date: Date = Date()
    var type: SessionType = .timerBreak
    var durationSec: Int = 20
}

enum SessionType: String, Codable {
    case timerBreak = "20-20-20 Break"
    case exercise = "Exercise"
}

struct ExerciseLog: Identifiable, Codable {
    var id = UUID()
    var date: Date = Date()
    var exerciseType: ExerciseType
    var durationSec: Int
    var score: Int?
}

// MARK: - Daily

struct DailyStats: Identifiable, Codable {
    var id: String { dateKey }
    var dateKey: String
    var breaksCompleted: Int
    var exercisesCompleted: Int
    var totalBreakSeconds: Int

    static func key(for date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: date)
    }
}

// MARK: - Timer State

enum TimerPhase {
    case idle, working, breakTime, exercisePrompt
}

enum ReminderInterval: String, Codable, CaseIterable {
    case min20 = "20 min"
    case min30 = "30 min"
    case min45 = "45 min"
    case min60 = "60 min"
    var seconds: Int {
        switch self {
        case .min20: return 1200
        case .min30: return 1800
        case .min45: return 2700
        case .min60: return 3600
        }
    }
}
