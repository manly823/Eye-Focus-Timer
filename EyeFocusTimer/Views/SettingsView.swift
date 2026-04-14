import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var m: EyeManager
    @State private var showReset = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                HStack {
                    Text("Settings").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(Theme.text); Spacer()
                }.padding(.top, 8)

                section("TIMER", "timer") {
                    HStack {
                        Image(systemName: "clock").foregroundColor(Theme.cyan).frame(width: 22)
                        Text("Break Interval").font(.system(size: 13, design: .rounded)).foregroundColor(Theme.sub); Spacer()
                        Picker("", selection: $m.interval) { ForEach(ReminderInterval.allCases, id: \.self) { i in Text(i.rawValue).tag(i) } }
                            .tint(Theme.cyan).onChange(of: m.interval) { _, _ in m.remainingSeconds = m.interval.seconds }
                    }.settingsRow()
                }

                section("DAILY GOALS", "target") {
                    HStack {
                        Image(systemName: "eye.fill").foregroundColor(Theme.cyan).frame(width: 22)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Break Goal").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(Theme.text)
                            Text("Breaks per day").font(.system(size: 10, design: .rounded)).foregroundColor(Theme.sub)
                        }
                        Spacer()
                        HStack(spacing: 10) {
                            Button { if m.dailyBreakGoal > 1 { m.dailyBreakGoal -= 1 } } label: {
                                Image(systemName: "minus.circle.fill").font(.system(size: 22)).foregroundStyle(Theme.dim)
                            }
                            Text("\(m.dailyBreakGoal)").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(Theme.cyan).frame(width: 24, alignment: .center)
                            Button { if m.dailyBreakGoal < 20 { m.dailyBreakGoal += 1 } } label: {
                                Image(systemName: "plus.circle.fill").font(.system(size: 22)).foregroundStyle(Theme.cyan)
                            }
                        }
                    }.settingsRow()

                    HStack {
                        Image(systemName: "figure.mind.and.body").foregroundColor(Theme.violet).frame(width: 22)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Exercise Goal").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(Theme.text)
                            Text("Exercises per day").font(.system(size: 10, design: .rounded)).foregroundColor(Theme.sub)
                        }
                        Spacer()
                        HStack(spacing: 10) {
                            Button { if m.dailyExerciseGoal > 1 { m.dailyExerciseGoal -= 1 } } label: {
                                Image(systemName: "minus.circle.fill").font(.system(size: 22)).foregroundStyle(Theme.dim)
                            }
                            Text("\(m.dailyExerciseGoal)").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(Theme.violet).frame(width: 24, alignment: .center)
                            Button { if m.dailyExerciseGoal < 15 { m.dailyExerciseGoal += 1 } } label: {
                                Image(systemName: "plus.circle.fill").font(.system(size: 22)).foregroundStyle(Theme.violet)
                            }
                        }
                    }.settingsRow()
                }

                section("FEEDBACK", "bell.badge") {
                    Toggle(isOn: $m.notifEnabled) {
                        HStack(spacing: 10) {
                            Image(systemName: "bell.fill").foregroundColor(Theme.cyan).frame(width: 22)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Push Notifications").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(Theme.text)
                                Text("Alert when break is due").font(.system(size: 10, design: .rounded)).foregroundColor(Theme.sub)
                            }
                        }
                    }.tint(Theme.cyan).settingsRow()
                    .onChange(of: m.notifEnabled) { _, v in if v { m.requestNotifPermission() } }

                    Toggle(isOn: $m.soundEnabled) {
                        HStack(spacing: 10) {
                            Image(systemName: "speaker.wave.2.fill").foregroundColor(Theme.violet).frame(width: 22)
                            Text("Sound Effects").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(Theme.text)
                        }
                    }.tint(Theme.violet).settingsRow()

                    Toggle(isOn: $m.hapticEnabled) {
                        HStack(spacing: 10) {
                            Image(systemName: "hand.tap.fill").foregroundColor(Theme.mint).frame(width: 22)
                            Text("Haptic Feedback").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(Theme.text)
                        }
                    }.tint(Theme.mint).settingsRow()
                }

                section("DATA", "externaldrive") {
                    infoRow("Total Breaks", "\(m.totalBreaks)", Theme.cyan)
                    infoRow("Total Exercises", "\(m.totalExercises)", Theme.violet)
                    infoRow("Current Streak", "\(m.currentStreak) days", Theme.amber)
                    Button { showReset = true } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise").foregroundColor(Theme.rose)
                            Text("Reset All Data").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(Theme.rose); Spacer()
                        }.settingsRow()
                    }
                }

                section("ABOUT", "info.circle") {
                    infoRow("App", "Eye Focus Timer", Theme.cyan)
                    infoRow("Version", Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0", Theme.sub)
                    Text("Eye Focus Timer helps reduce digital eye strain using the 20-20-20 rule combined with eye exercises based on optometric guidelines. All data is stored locally for complete privacy.")
                        .font(.system(size: 11, design: .rounded)).foregroundColor(Theme.dim).lineSpacing(3).padding(.top, 4)
                }

                section("MEDICAL DISCLAIMER", "exclamationmark.triangle") {
                    Text("This app is for informational and wellness purposes only. It does not provide medical diagnoses, treatment, or advice. The Eye Health Score is a habit-tracking metric based on your break and exercise frequency — it is not a clinical measurement.\n\nAlways consult a qualified eye care professional (ophthalmologist or optometrist) before making any decisions about your eye health. If you experience persistent eye discomfort, vision changes, or other symptoms, seek professional medical advice promptly.\n\nThis app is not a substitute for professional medical care.")
                        .font(.system(size: 11, design: .rounded)).foregroundColor(Theme.dim).lineSpacing(3)
                }

                section("SOURCES & REFERENCES", "book.closed") {
                    sourceLink("20-20-20 Rule", "American Academy of Ophthalmology", "https://www.aao.org/eye-health/tips-prevention/computer-usage")
                    sourceLink("Computer Vision Syndrome", "American Optometric Association", "https://www.aoa.org/healthy-eyes/eye-and-vision-conditions/computer-vision-syndrome")
                    sourceLink("Blink Rate & Screens", "Tsubota K. et al., NEJM 1993", "https://pubmed.ncbi.nlm.nih.gov/8421478/")
                    sourceLink("Digital Eye Strain Review", "Sheppard & Wolffsohn, BMJ Open Ophth. 2018", "https://bmjophth.bmj.com/content/3/1/e000146")
                    sourceLink("Computer Vision Syndrome Review", "Rosenfield M., Ophthalmic Physiol Opt 2011", "https://pubmed.ncbi.nlm.nih.gov/21480937/")
                }
            }.padding(.horizontal, 16).padding(.bottom, 40)
        }
        .alert("Reset All Data?", isPresented: $showReset) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { m.resetAllData() }
        } message: { Text("This will restore sample data.") }
    }

    private func section(_ title: String, _ icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) { Image(systemName: icon).font(.system(size: 11)).foregroundColor(Theme.cyan); Text(title).font(.system(size: 10, weight: .bold, design: .rounded)).foregroundColor(Theme.sub).tracking(1.5) }.padding(.leading, 4)
            content()
        }
    }

    private func infoRow(_ l: String, _ v: String, _ c: Color) -> some View {
        HStack { Text(l).font(.system(size: 13, design: .rounded)).foregroundColor(Theme.sub); Spacer(); Text(v).font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundColor(c) }.settingsRow()
    }

    private func sourceLink(_ title: String, _ source: String, _ url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 10) {
                Image(systemName: "link").font(.system(size: 12)).foregroundColor(Theme.cyan).frame(width: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(Theme.text)
                    Text(source).font(.system(size: 10, design: .rounded)).foregroundColor(Theme.sub)
                }
                Spacer()
                Image(systemName: "arrow.up.right.square").font(.system(size: 11)).foregroundColor(Theme.dim)
            }.settingsRow()
        }
    }
}

extension View {
    func settingsRow() -> some View {
        self.padding(12).background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Theme.border, lineWidth: 1))
    }
}
