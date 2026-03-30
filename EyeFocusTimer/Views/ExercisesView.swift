import SwiftUI

struct ExercisesView: View {
    @EnvironmentObject var m: EyeManager
    @State private var activeExercise: EyeExercise?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Eye Exercises").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
                        Text("6 interactive workouts").font(.system(size: 13, design: .rounded)).foregroundColor(Theme.sub)
                    }; Spacer()
                    VStack(spacing: 1) {
                        Text("\(m.todayExercises)").font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(Theme.violet)
                        Text("today").font(.system(size: 10, design: .rounded)).foregroundColor(Theme.dim)
                    }
                }.padding(.top, 8).padding(.horizontal, 4)

                ForEach(EyeExercise.all) { ex in
                    Button { activeExercise = ex } label: { exerciseCard(ex) }.buttonStyle(.plain)
                }
            }.padding(.horizontal, 16).padding(.bottom, 40)
        }
        .fullScreenCover(item: $activeExercise) { ex in
            ExercisePlayerView(exercise: ex).environmentObject(m)
        }
    }

    private func exerciseCard(_ ex: EyeExercise) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous).fill(ex.color.opacity(0.1)).frame(width: 52, height: 52)
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(ex.color.opacity(0.2), lineWidth: 1))
                Image(systemName: ex.icon).font(.system(size: 22)).foregroundStyle(ex.color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(ex.name).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
                Text(ex.subtitle).font(.system(size: 12, design: .rounded)).foregroundColor(Theme.sub)
            }; Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(ex.duration)s").font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundColor(ex.color)
                Image(systemName: "play.circle.fill").font(.system(size: 20)).foregroundStyle(ex.color.opacity(0.6))
            }
        }.glassCard(pad: 14, rad: 18)
    }
}
