import SwiftUI

struct NoInternetView: View {
    var onRetry: () async -> Void

    @State private var isRetrying = false
    @State private var iconOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Theme.surface)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle().stroke(Theme.border, lineWidth: 1)
                        )

                    Image(systemName: "wifi.slash")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(Theme.gradient)
                        .offset(y: iconOffset)
                }
                .shadow(color: Theme.cyan.opacity(0.15), radius: 15)

                VStack(spacing: 8) {
                    Text("No Internet Connection")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.text)

                    Text("Please check your connection and try again")
                        .font(.subheadline)
                        .foregroundColor(Theme.sub)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                Button {
                    Task {
                        isRetrying = true
                        await onRetry()
                        isRetrying = false
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isRetrying {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text(isRetrying ? "Connecting..." : "Try Again")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(isRetrying)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
            ) {
                iconOffset = -5
            }
        }
    }
}
