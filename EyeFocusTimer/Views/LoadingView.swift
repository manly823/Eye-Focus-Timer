import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    @State private var isAnimating = false
    @State private var dotCount = 0

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(Theme.cyan.opacity(0.2), lineWidth: 4)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(
                            Theme.gradient,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 1.0).repeatForever(autoreverses: false),
                            value: isAnimating
                        )

                    Circle()
                        .fill(Theme.cyan.opacity(0.1))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .fill(Theme.gradient)
                                .frame(width: 40, height: 40)
                        )
                        .shadow(color: Theme.cyan.opacity(0.4), radius: 20)
                }

                VStack(spacing: 8) {
                    Text(message + animatedDots)
                        .font(.headline)
                        .foregroundColor(Theme.text)

                    Text("Please wait")
                        .font(.subheadline)
                        .foregroundColor(Theme.sub)
                }

                Spacer()
                Spacer()
            }
            .padding()
        }
        .onAppear {
            isAnimating = true
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }

    private var animatedDots: String {
        String(repeating: ".", count: dotCount)
    }
}
