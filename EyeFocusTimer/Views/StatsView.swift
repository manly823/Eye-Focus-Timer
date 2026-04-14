import SwiftUI

struct StatsView: View {
    @EnvironmentObject var m: EyeManager
    @State private var monthOffset: Int = 0
    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                header
                scoreCard
                achievementsSection
                weeklySection
                monthlySection
                summaryCards
                recentActivity
            }.padding(.horizontal, 16).padding(.bottom, 40)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Eye Health Stats").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
                Text("Track your progress").font(.system(size: 13, design: .rounded)).foregroundColor(Theme.sub)
            }; Spacer()
        }.padding(.top, 8)
    }

    private var scoreCard: some View {
        HStack(spacing: 20) {
            ZStack {
                CountdownRing(progress: Double(m.eyeHealthScore) / 100.0, color: scoreColor, lineWidth: 8, size: 100)
                VStack(spacing: 0) {
                    Text("\(m.eyeHealthScore)").font(.system(size: 28, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
                    Text("score").font(.system(size: 10, design: .rounded)).foregroundColor(Theme.dim)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Eye Health Score").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
                Text(scoreMessage).font(.system(size: 12, design: .rounded)).foregroundColor(Theme.sub).lineSpacing(2)
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").font(.system(size: 12)).foregroundColor(Theme.amber)
                    Text("\(m.currentStreak) day streak").font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundColor(Theme.amber)
                }
            }
        }.glassCard()

        return Text("This score tracks your break & exercise habits. It is not a medical diagnosis. Consult an eye care professional for clinical advice.")
            .font(.system(size: 9, design: .rounded)).foregroundColor(Theme.dim).multilineTextAlignment(.center).padding(.horizontal, 8)
    }

    private var scoreColor: Color { m.eyeHealthScore >= 70 ? Theme.mint : m.eyeHealthScore >= 40 ? Theme.amber : Theme.rose }
    private var scoreMessage: String {
        if m.eyeHealthScore >= 80 { return "Great consistency! You're building healthy screen habits." }
        if m.eyeHealthScore >= 60 { return "Good progress. A few more breaks will boost your streak." }
        if m.eyeHealthScore >= 30 { return "Try adding more breaks to your routine today." }
        return "Start taking breaks to build your daily habit."
    }

    private var weeklySection: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("BREAKS THIS WEEK").font(.system(size: 10, weight: .bold, design: .rounded)).foregroundColor(Theme.sub).tracking(1.5)
                MiniBarChart(data: m.weeklyBreaks, color: Theme.cyan).frame(height: 80)
                weekLabels
            }.glassCard()

            VStack(alignment: .leading, spacing: 8) {
                Text("EXERCISES THIS WEEK").font(.system(size: 10, weight: .bold, design: .rounded)).foregroundColor(Theme.sub).tracking(1.5)
                MiniBarChart(data: m.weeklyExercises, color: Theme.violet).frame(height: 80)
                weekLabels
            }.glassCard()
        }
    }

    private var weekLabels: some View {
        let cal = Calendar.current; let f = DateFormatter(); f.dateFormat = "E"
        let labels = (0..<7).reversed().map { i in
            let d = cal.date(byAdding: .day, value: -i, to: Date())!; return f.string(from: d)
        }
        return HStack { ForEach(labels, id: \.self) { l in Text(l).font(.system(size: 9, design: .rounded)).foregroundColor(Theme.dim).frame(maxWidth: .infinity) } }
    }

    private var summaryCards: some View {
        HStack(spacing: 12) {
            sumCard("Total Breaks", "\(m.totalBreaks)", "eye.fill", Theme.cyan)
            sumCard("Total Exercises", "\(m.totalExercises)", "figure.mind.and.body", Theme.violet)
        }
    }

    private func sumCard(_ label: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 20)).foregroundStyle(color)
            Text(value).font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
            Text(label).font(.system(size: 11, design: .rounded)).foregroundColor(Theme.sub)
        }.frame(maxWidth: .infinity).padding(.vertical, 16).glassCard(pad: 0, rad: 16)
    }

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECENT EXERCISES").font(.system(size: 10, weight: .bold, design: .rounded)).foregroundColor(Theme.sub).tracking(1.5).padding(.leading, 4)
            let recent = m.exerciseLogs.sorted { $0.date > $1.date }.prefix(8)
            if recent.isEmpty { Text("No exercises yet.").font(.system(size: 13, design: .rounded)).foregroundColor(Theme.dim).padding(.vertical, 16).frame(maxWidth: .infinity) }
            else {
                ForEach(Array(recent)) { log in
                    if let ex = EyeExercise.all.first(where: { $0.id == log.exerciseType }) {
                        HStack(spacing: 10) {
                            Image(systemName: ex.icon).font(.system(size: 14)).foregroundStyle(ex.color).frame(width: 28)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(ex.name).font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundColor(Theme.text)
                                Text(log.date, style: .relative).font(.system(size: 10, design: .rounded)).foregroundColor(Theme.dim)
                            }; Spacer()
                            if let s = log.score { Text("\(s)%").font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(Theme.amber) }
                            Text("\(log.durationSec)s").font(.system(size: 12, design: .rounded)).foregroundColor(Theme.sub)
                        }.padding(.vertical, 6).padding(.horizontal, 12).background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
        }
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        let unlockedCount = Achievement.all.filter { m.unlockedAchievements.contains($0.type.rawValue) }.count
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "trophy.fill").font(.system(size: 11)).foregroundColor(Theme.amber)
                    Text("ACHIEVEMENTS").font(.system(size: 10, weight: .bold, design: .rounded)).foregroundColor(Theme.sub).tracking(1.5)
                }
                Spacer()
                Text("\(unlockedCount)/\(Achievement.all.count)").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(Theme.cyan)
            }.padding(.horizontal, 4)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(Achievement.all) { a in
                    let unlocked = m.unlockedAchievements.contains(a.type.rawValue)
                    achievementBadge(a, unlocked: unlocked)
                }
            }
        }
    }

    private func achievementBadge(_ a: Achievement, unlocked: Bool) -> some View {
        VStack(spacing: 5) {
            ZStack {
                Circle().fill(unlocked ? a.color.opacity(0.15) : Theme.surface).frame(width: 44, height: 44)
                    .overlay(Circle().stroke(unlocked ? a.color.opacity(0.3) : Theme.border, lineWidth: 1.5))
                if unlocked {
                    Image(systemName: a.icon).font(.system(size: 18)).foregroundStyle(a.color)
                } else {
                    Image(systemName: "lock.fill").font(.system(size: 14)).foregroundStyle(Theme.dim)
                }
            }
            .shadow(color: unlocked ? a.color.opacity(0.3) : .clear, radius: 5)
            Text(a.name).font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundColor(unlocked ? Theme.text : Theme.dim)
                .multilineTextAlignment(.center).lineLimit(2).frame(height: 20)
        }.frame(maxWidth: .infinity).padding(.vertical, 6)
    }

    // MARK: - Monthly Calendar

    private var monthlySection: some View {
        let cal = Calendar.current
        let ref = cal.date(byAdding: .month, value: monthOffset, to: Date())!
        let comps = cal.dateComponents([.year, .month], from: ref)
        let first = cal.date(from: comps)!
        let daysInMonth = cal.range(of: .day, in: .month, for: first)!.count
        let startWeekday = (cal.component(.weekday, from: first) + 5) % 7
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button { monthOffset -= 1 } label: {
                    Image(systemName: "chevron.left").font(.system(size: 12, weight: .semibold)).foregroundColor(Theme.cyan)
                }
                Spacer()
                Text(formatter.string(from: ref).uppercased()).font(.system(size: 10, weight: .bold, design: .rounded)).foregroundColor(Theme.sub).tracking(1.5)
                Spacer()
                Button { if monthOffset < 0 { monthOffset += 1 } } label: {
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(monthOffset < 0 ? Theme.cyan : Theme.dim)
                }.disabled(monthOffset >= 0)
            }.padding(.horizontal, 4)

            VStack(spacing: 3) {
                let dayHeaders = ["M", "T", "W", "T", "F", "S", "S"]
                HStack(spacing: 3) {
                    ForEach(0..<7, id: \.self) { i in
                        Text(dayHeaders[i]).font(.system(size: 9, weight: .bold, design: .rounded)).foregroundColor(Theme.dim)
                            .frame(maxWidth: .infinity)
                    }
                }

                let totalCells = startWeekday + daysInMonth
                let rows = (totalCells + 6) / 7
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 3) {
                        ForEach(0..<7, id: \.self) { col in
                            let day = row * 7 + col - startWeekday + 1
                            if day >= 1 && day <= daysInMonth {
                                let date = cal.date(byAdding: .day, value: day - 1, to: first)!
                                let level = activityLevel(for: date)
                                let isToday = cal.isDateInToday(date)
                                calendarDay(day, level: level, isToday: isToday)
                            } else {
                                Color.clear.frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                }
            }.glassCard(pad: 10, rad: 16)

            HStack(spacing: 16) {
                HStack(spacing: 5) {
                    Image(systemName: "eye.fill").font(.system(size: 11)).foregroundColor(Theme.cyan)
                    Text("\(monthCount(sessions: true, first: first, days: daysInMonth)) breaks").font(.system(size: 11, weight: .semibold, design: .rounded)).foregroundColor(Theme.cyan)
                }
                HStack(spacing: 5) {
                    Image(systemName: "figure.mind.and.body").font(.system(size: 11)).foregroundColor(Theme.violet)
                    Text("\(monthCount(sessions: false, first: first, days: daysInMonth)) exercises").font(.system(size: 11, weight: .semibold, design: .rounded)).foregroundColor(Theme.violet)
                }
                Spacer()
            }.padding(.horizontal, 4)
        }
    }

    private func activityLevel(for date: Date) -> Int {
        let cal = Calendar.current
        let b = m.sessions.filter { cal.isDate($0.date, inSameDayAs: date) }.count
        let e = m.exerciseLogs.filter { cal.isDate($0.date, inSameDayAs: date) }.count
        let total = b + e
        if total == 0 { return 0 }
        if total <= 2 { return 1 }
        if total <= 5 { return 2 }
        return 3
    }

    private func calendarDay(_ day: Int, level: Int, isToday: Bool) -> some View {
        let fill: Color = level == 0 ? Theme.surface : Theme.cyan.opacity(0.2 + Double(level) * 0.25)
        return RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(fill)
            .frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit)
            .overlay(Text("\(day)").font(.system(size: 9, design: .rounded)).foregroundColor(level > 0 ? Theme.text : Theme.dim))
            .overlay(RoundedRectangle(cornerRadius: 4, style: .continuous).stroke(isToday ? Theme.cyan : .clear, lineWidth: 1.5))
    }

    private func monthCount(sessions: Bool, first: Date, days: Int) -> Int {
        let cal = Calendar.current
        return (0..<days).reduce(0) { total, offset in
            let date = cal.date(byAdding: .day, value: offset, to: first)!
            if sessions {
                return total + m.sessions.filter { cal.isDate($0.date, inSameDayAs: date) }.count
            } else {
                return total + m.exerciseLogs.filter { cal.isDate($0.date, inSameDayAs: date) }.count
            }
        }
    }
}
