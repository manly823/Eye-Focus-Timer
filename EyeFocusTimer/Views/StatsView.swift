import SwiftUI

struct StatsView: View {
    @EnvironmentObject var m: EyeManager
    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                header
                scoreCard
                weeklySection
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
}
