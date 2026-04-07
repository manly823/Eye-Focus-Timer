import SwiftUI

struct PushPermissionView: View {
    var onAccept: () async -> Void
    var onSkip: () async -> Void

    @State private var isProcessing = false
    @State private var bellOffset: CGFloat = 0
    @State private var bellRotation: Double = 0

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Theme.cyan.opacity(0.1))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)

                    Circle()
                        .fill(Theme.surface)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle().stroke(Theme.cyan.opacity(0.3), lineWidth: 2)
                        )

                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(Theme.gradient)
                        .offset(y: bellOffset)
                        .rotationEffect(.degrees(bellRotation))
                }
                .shadow(color: Theme.cyan.opacity(0.3), radius: 15)

                VStack(spacing: 12) {
                    Text("Stay Updated")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.text)

                    Text("Enable notifications to receive important updates and never miss anything")
                        .font(.body)
                        .foregroundColor(Theme.sub)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        Task {
                            isProcessing = true
                            await onAccept()
                            isProcessing = false
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "bell.fill")
                            }
                            Text("Enable Notifications")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .disabled(isProcessing)

                    Button {
                        Task {
                            await onSkip()
                        }
                    } label: {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundColor(Theme.sub)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .disabled(isProcessing)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            startBellAnimation()
        }
    }

    private func startBellAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        ) {
            bellOffset = -3
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(
                Animation.easeInOut(duration: 0.15).repeatCount(3, autoreverses: true)
            ) {
                bellRotation = 10
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.1)) {
                    bellRotation = 0
                }
            }
        }
    }
}
