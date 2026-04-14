import SwiftUI
import UserNotifications
import Combine

final class EyeManager: ObservableObject {
    @Published var onboardingDone: Bool { didSet { UserDefaults.standard.set(onboardingDone, forKey: "ef_onb") } }
    @Published var sessions: [BreakSession] { didSet { Storage.shared.save(sessions, forKey: "ef_sess") } }
    @Published var exerciseLogs: [ExerciseLog] { didSet { Storage.shared.save(exerciseLogs, forKey: "ef_exlogs") } }
    @Published var interval: ReminderInterval { didSet { Storage.shared.save(interval, forKey: "ef_int") } }
    @Published var notifEnabled: Bool { didSet { UserDefaults.standard.set(notifEnabled, forKey: "ef_notif") } }
    @Published var soundEnabled: Bool { didSet { UserDefaults.standard.set(soundEnabled, forKey: "ef_sound") } }
    @Published var hapticEnabled: Bool { didSet { UserDefaults.standard.set(hapticEnabled, forKey: "ef_haptic") } }

    @Published var dailyBreakGoal: Int { didSet { UserDefaults.standard.set(dailyBreakGoal, forKey: "ef_bgoal") } }
    @Published var dailyExerciseGoal: Int { didSet { UserDefaults.standard.set(dailyExerciseGoal, forKey: "ef_egoal") } }
    @Published var unlockedAchievements: Set<String> { didSet { Storage.shared.save(Array(unlockedAchievements), forKey: "ef_achievements") } }

    @Published var timerPhase: TimerPhase = .idle
    @Published var remainingSeconds: Int = 1200
    @Published var breakRemaining: Int = 20

    private var workTimer: AnyCancellable?
    private var breakTimer: AnyCancellable?

    init() {
        onboardingDone = UserDefaults.standard.bool(forKey: "ef_onb")
        sessions = Storage.shared.load(forKey: "ef_sess", default: Self.sampleSessions)
        exerciseLogs = Storage.shared.load(forKey: "ef_exlogs", default: Self.sampleExerciseLogs)
        interval = Storage.shared.load(forKey: "ef_int", default: .min20)
        notifEnabled = UserDefaults.standard.object(forKey: "ef_notif") == nil ? true : UserDefaults.standard.bool(forKey: "ef_notif")
        soundEnabled = UserDefaults.standard.object(forKey: "ef_sound") == nil ? true : UserDefaults.standard.bool(forKey: "ef_sound")
        hapticEnabled = UserDefaults.standard.object(forKey: "ef_haptic") == nil ? true : UserDefaults.standard.bool(forKey: "ef_haptic")
        dailyBreakGoal = UserDefaults.standard.object(forKey: "ef_bgoal") == nil ? 6 : UserDefaults.standard.integer(forKey: "ef_bgoal")
        dailyExerciseGoal = UserDefaults.standard.object(forKey: "ef_egoal") == nil ? 3 : UserDefaults.standard.integer(forKey: "ef_egoal")
        let savedAch: [String] = Storage.shared.load(forKey: "ef_achievements", default: [])
        unlockedAchievements = Set(savedAch)
        remainingSeconds = interval.seconds
        checkAchievements()
    }

    // MARK: - Timer
    func startTimer() {
        timerPhase = .working
        remainingSeconds = interval.seconds
        workTimer?.cancel()
        workTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self, self.timerPhase == .working else { return }
            if self.remainingSeconds > 0 { self.remainingSeconds -= 1 }
            else { self.triggerBreak() }
        }
    }

    func pauseTimer() { workTimer?.cancel(); timerPhase = .idle }

    func triggerBreak() {
        workTimer?.cancel()
        timerPhase = .breakTime; breakRemaining = 20
        if hapticEnabled { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
        scheduleBreakNotification()
        breakTimer?.cancel()
        breakTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self, self.timerPhase == .breakTime else { return }
            if self.breakRemaining > 0 { self.breakRemaining -= 1 }
            else { self.completeBreak() }
        }
    }

    func completeBreak() {
        breakTimer?.cancel()
        sessions.append(BreakSession())
        if hapticEnabled { UINotificationFeedbackGenerator().notificationOccurred(.success) }
        timerPhase = .exercisePrompt
        checkAchievements()
    }

    func skipExercise() { startTimer() }

    func logExercise(_ type: ExerciseType, duration: Int, score: Int? = nil) {
        exerciseLogs.append(ExerciseLog(exerciseType: type, durationSec: duration, score: score))
        checkAchievements()
    }

    // MARK: - Stats
    var todayBreaks: Int { sessions.filter { Calendar.current.isDateInToday($0.date) }.count }
    var todayExercises: Int { exerciseLogs.filter { Calendar.current.isDateInToday($0.date) }.count }

    var currentStreak: Int {
        let cal = Calendar.current; var streak = 0; var day = Date()
        for _ in 0..<365 {
            let hasActivity = sessions.contains { cal.isDate($0.date, inSameDayAs: day) } || exerciseLogs.contains { cal.isDate($0.date, inSameDayAs: day) }
            if hasActivity { streak += 1 } else if streak > 0 { break }
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }; return streak
    }

    var weeklyBreaks: [Double] {
        let cal = Calendar.current
        return (0..<7).reversed().map { i in
            let d = cal.date(byAdding: .day, value: -i, to: Date())!
            return Double(sessions.filter { cal.isDate($0.date, inSameDayAs: d) }.count)
        }
    }

    var weeklyExercises: [Double] {
        let cal = Calendar.current
        return (0..<7).reversed().map { i in
            let d = cal.date(byAdding: .day, value: -i, to: Date())!
            return Double(exerciseLogs.filter { cal.isDate($0.date, inSameDayAs: d) }.count)
        }
    }

    var totalBreaks: Int { sessions.count }
    var totalExercises: Int { exerciseLogs.count }

    var eyeHealthScore: Int {
        let breakScore = min(Double(todayBreaks) / Double(max(dailyBreakGoal, 1)), 1.0) * 50
        let exScore = min(Double(todayExercises) / Double(max(dailyExerciseGoal, 1)), 1.0) * 30
        let streakScore = min(Double(currentStreak) / 7.0, 1.0) * 20
        return Int(breakScore + exScore + streakScore)
    }

    var todayExerciseTypes: Set<ExerciseType> {
        Set(exerciseLogs.filter { Calendar.current.isDateInToday($0.date) }.map(\.exerciseType))
    }

    // MARK: - Notifications
    func requestNotifPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { ok, _ in
            DispatchQueue.main.async { self.notifEnabled = ok }
        }
    }

    private func scheduleBreakNotification() {
        guard notifEnabled else { return }
        let c = UNMutableNotificationContent()
        c.title = "Eye Break Time! 👁️"
        c.body = "Look at something 20 feet away for 20 seconds."
        c.sound = soundEnabled ? .default : nil
        let t = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "eye_break_\(UUID().uuidString)", content: c, trigger: t))
    }

    func resetAllData() {
        sessions = Self.sampleSessions
        exerciseLogs = Self.sampleExerciseLogs
        timerPhase = .idle
        remainingSeconds = interval.seconds
        unlockedAchievements = []
        checkAchievements()
    }

    // MARK: - Achievements
    func checkAchievements() {
        var new = unlockedAchievements
        if totalBreaks >= 1 { new.insert(AchievementType.firstBreak.rawValue) }
        if totalBreaks >= 10 { new.insert(AchievementType.tenBreaks.rawValue) }
        if totalBreaks >= 50 { new.insert(AchievementType.fiftyBreaks.rawValue) }
        if totalBreaks >= 100 { new.insert(AchievementType.hundredBreaks.rawValue) }
        if totalExercises >= 1 { new.insert(AchievementType.firstExercise.rawValue) }
        if todayExerciseTypes.count >= ExerciseType.allCases.count { new.insert(AchievementType.allExercisesInDay.rawValue) }
        if currentStreak >= 3 { new.insert(AchievementType.streak3.rawValue) }
        if currentStreak >= 7 { new.insert(AchievementType.streak7.rawValue) }
        if currentStreak >= 14 { new.insert(AchievementType.streak14.rawValue) }
        if currentStreak >= 30 { new.insert(AchievementType.streak30.rawValue) }
        if eyeHealthScore >= 80 { new.insert(AchievementType.score80.rawValue) }
        if eyeHealthScore >= 100 { new.insert(AchievementType.score100.rawValue) }
        if new != unlockedAchievements { unlockedAchievements = new }
    }

    // MARK: - Samples
    static var sampleSessions: [BreakSession] {
        let cal = Calendar.current
        var s: [BreakSession] = []
        for day in 0..<7 {
            let d = cal.date(byAdding: .day, value: -day, to: Date())!
            let count = day == 0 ? 3 : Int.random(in: 2...8)
            for h in 0..<count {
                let date = cal.date(bySettingHour: 9 + h * 2, minute: Int.random(in: 0...59), second: 0, of: d)!
                s.append(BreakSession(date: date))
            }
        }; return s
    }

    static var sampleExerciseLogs: [ExerciseLog] {
        let cal = Calendar.current; let types = ExerciseType.allCases
        var logs: [ExerciseLog] = []
        for day in 0..<7 {
            let d = cal.date(byAdding: .day, value: -day, to: Date())!
            let count = day == 0 ? 1 : Int.random(in: 1...3)
            for i in 0..<count {
                let date = cal.date(bySettingHour: 10 + i * 3, minute: Int.random(in: 0...59), second: 0, of: d)!
                let t = types[Int.random(in: 0..<types.count)]
                logs.append(ExerciseLog(date: date, exerciseType: t, durationSec: Int.random(in: 30...60), score: t == .peripheralPeek ? Int.random(in: 60...95) : nil))
            }
        }; return logs
    }
}
