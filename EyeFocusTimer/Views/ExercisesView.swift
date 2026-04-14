import SwiftUI

struct ExercisesView: View {
    @EnvironmentObject var m: EyeManager
    @State private var activeExercise: EyeExercise?
    @State private var activeRoutine: ExerciseRoutine?

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

                routinesSection

                HStack {
                    Text("ALL EXERCISES").font(.system(size: 10, weight: .bold, design: .rounded)).foregroundColor(Theme.sub).tracking(1.5)
                    Spacer()
                }.padding(.leading, 4).padding(.top, 4)

                ForEach(EyeExercise.all) { ex in
                    Button { activeExercise = ex } label: { exerciseCard(ex) }.buttonStyle(.plain)
                }
            }.padding(.horizontal, 16).padding(.bottom, 40)
        }
        .fullScreenCover(item: $activeExercise) { ex in
            ExercisePlayerView(exercise: ex).environmentObject(m)
        }
        .fullScreenCover(item: $activeRoutine) { routine in
            RoutinePlayerView(routine: routine).environmentObject(m)
        }
    }

    // MARK: - Routines

    private var routinesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: "bolt.circle.fill").font(.system(size: 11)).foregroundColor(Theme.violet)
                Text("ROUTINES").font(.system(size: 10, weight: .bold, design: .rounded)).foregroundColor(Theme.sub).tracking(1.5)
            }.padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ExerciseRoutine.all) { routine in
                        Button { activeRoutine = routine } label: { routineCard(routine) }.buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func routineCard(_ r: ExerciseRoutine) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(r.color.opacity(0.1)).frame(width: 36, height: 36)
                    Image(systemName: r.icon).font(.system(size: 16)).foregroundStyle(r.color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(r.name).font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
                    Text(r.subtitle).font(.system(size: 10, design: .rounded)).foregroundColor(Theme.sub)
                }
            }
            HStack(spacing: 10) {
                HStack(spacing: 3) {
                    Image(systemName: "list.bullet").font(.system(size: 9)).foregroundColor(Theme.dim)
                    Text("\(r.exercises.count) exercises").font(.system(size: 10, design: .rounded)).foregroundColor(Theme.dim)
                }
                HStack(spacing: 3) {
                    Image(systemName: "clock").font(.system(size: 9)).foregroundColor(Theme.dim)
                    Text("\(r.estimatedSeconds / 60)m \(r.estimatedSeconds % 60)s").font(.system(size: 10, design: .rounded)).foregroundColor(Theme.dim)
                }
            }
        }.padding(12).frame(width: 200, alignment: .leading)
        .background(r.color.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(r.color.opacity(0.15), lineWidth: 1))
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

// MARK: - Routine Player

struct RoutinePlayerView: View {
    @EnvironmentObject var m: EyeManager
    @Environment(\.dismiss) var dismiss
    let routine: ExerciseRoutine

    @State private var currentIndex = 0
    @State private var activeExercise: EyeExercise?
    @State private var completedCount = 0
    @State private var routineCompleted = false

    private var exercises: [EyeExercise] {
        routine.exercises.compactMap { type in EyeExercise.all.first { $0.id == type } }
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 28)).foregroundStyle(Theme.dim)
                    }
                    Spacer()
                    if !routineCompleted {
                        Text("\(completedCount)/\(exercises.count)").font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.sub)
                            .padding(.horizontal, 12).padding(.vertical, 4)
                            .background(Theme.surface).clipShape(Capsule())
                    }
                    Spacer()
                    Color.clear.frame(width: 28)
                }.padding(.horizontal, 20).padding(.top, 12)

                if routineCompleted { routineCompletedView }
                else { routineOverview }
            }
        }
        .fullScreenCover(item: $activeExercise, onDismiss: {
            advanceToNext()
        }) { ex in
            ExercisePlayerView(exercise: ex).environmentObject(m)
        }
    }

    private var routineOverview: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: routine.icon).font(.system(size: 48)).foregroundStyle(routine.color)
                .shadow(color: routine.color.opacity(0.4), radius: 12)
            Text(routine.name).font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
            Text(routine.subtitle).font(.system(size: 14, design: .rounded)).foregroundColor(Theme.sub)

            VStack(spacing: 6) {
                ForEach(Array(exercises.enumerated()), id: \.offset) { index, ex in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(index < completedCount ? Theme.mint.opacity(0.15) : ex.color.opacity(0.1)).frame(width: 34, height: 34)
                                .overlay(Circle().stroke(index < completedCount ? Theme.mint.opacity(0.3) : Theme.border, lineWidth: 1))
                            if index < completedCount {
                                Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundColor(Theme.mint)
                            } else {
                                Text("\(index + 1)").font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(index == currentIndex ? ex.color : Theme.dim)
                            }
                        }
                        Text(ex.name).font(.system(size: 14, weight: index == currentIndex ? .bold : .regular, design: .rounded))
                            .foregroundColor(index < completedCount ? Theme.mint : (index == currentIndex ? Theme.text : Theme.sub))
                        Spacer()
                        Text("\(ex.duration)s").font(.system(size: 12, design: .rounded)).foregroundColor(Theme.dim)
                    }.padding(.horizontal, 14).padding(.vertical, 7)
                    .background(index == currentIndex ? Theme.surface : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }.padding(.horizontal, 24).padding(.top, 4)

            Spacer()

            Button {
                if currentIndex < exercises.count {
                    activeExercise = exercises[currentIndex]
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: completedCount == 0 ? "play.fill" : "arrow.right")
                    Text(completedCount == 0 ? "Start Routine" : "Next Exercise")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(routine.color.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: routine.color.opacity(0.3), radius: 10, y: 4)
            }.padding(.horizontal, 30).padding(.bottom, 40)
        }
    }

    private var routineCompletedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill").font(.system(size: 60)).foregroundStyle(Theme.mint)
                .shadow(color: Theme.mint.opacity(0.4), radius: 15)
            Text("Routine Complete!").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
            Text("\(exercises.count) exercises finished").font(.system(size: 16, design: .rounded)).foregroundColor(Theme.sub)

            let totalDuration = exercises.reduce(0) { $0 + $1.duration }
            HStack(spacing: 4) {
                Image(systemName: "clock").font(.system(size: 13)).foregroundColor(routine.color)
                Text("\(totalDuration / 60)m \(totalDuration % 60)s total").font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundColor(routine.color)
            }

            Spacer()
            Button { dismiss() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                    Text("Done").font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(Theme.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }.padding(.horizontal, 30).padding(.bottom, 40)
        }
    }

    private func advanceToNext() {
        completedCount += 1
        currentIndex = completedCount
        if completedCount >= exercises.count {
            routineCompleted = true
        }
    }
}
