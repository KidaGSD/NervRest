import SwiftUI

struct ShieldOverlayScreen: View {
    let arousalScore: Double      // 0-100
    let currentHR: Int
    let alarmTime: String         // e.g. "8:00 AM"
    var onShowAlternatives: () -> Void = {}
    var onFiveMoreMinutes: () -> Void = {}

    @State private var curtainDrop = false
    @State private var contentReveal = false
    @State private var breatheGlow = false

    var body: some View {
        ZStack {
            // Layer 1: Cinematic dark background
            cinematicBackground

            // Layer 2: Breathing glow behind gauge
            agentGlow

            // Layer 3: Content
            VStack(spacing: 0) {
                Spacer()

                // Arousal Gauge (reuse ArousalGauge component)
                ArousalGauge(
                    score: arousalScore,
                    level: arousalLevel,
                    heartRate: currentHR,
                    hrv: 24  // placeholder
                )

                Spacer().frame(height: 32)

                // Title
                Text("Time to wind down")
                    .font(NervRestTheme.Fonts.displayMedium)
                    .foregroundColor(NervRestTheme.Text.primary)

                Spacer().frame(height: 12)

                // Body text
                Text("Your bedtime is approaching and your stimulation level is quite high. Fancy seeing bedtime-ready alternatives?")
                    .font(NervRestTheme.Fonts.body)
                    .foregroundColor(NervRestTheme.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer().frame(height: 24)

                // Alarm info bar
                HStack {
                    Text("Alarm")
                        .font(NervRestTheme.Fonts.headline)
                        .foregroundColor(NervRestTheme.Text.primary)
                    Spacer()
                    Text(alarmTime)
                        .font(NervRestTheme.Fonts.headline)
                        .foregroundColor(NervRestTheme.Text.primary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(NervRestTheme.Surface.cardBackground)
                .cornerRadius(NervRestTheme.Radius.md)
                .padding(.horizontal, 40)

                Spacer().frame(height: 40)

                // Primary button
                Button(action: onShowAlternatives) {
                    Text("Show me alternatives")
                        .font(NervRestTheme.Fonts.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(NervRestTheme.Arousal.color(for: arousalLevel))
                        .cornerRadius(NervRestTheme.Radius.lg)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 16)

                // Ghost button
                Button(action: onFiveMoreMinutes) {
                    Text("5 more minutes")
                        .font(NervRestTheme.Fonts.body)
                        .foregroundColor(NervRestTheme.Text.tertiary)
                }

                Spacer().frame(height: 40)
            }
            .opacity(contentReveal ? 1.0 : 0.0)
            .offset(y: contentReveal ? 0 : 24)
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear {
            performEntranceSequence()
        }
    }

    // MARK: - Arousal Level

    private var arousalLevel: ArousalLevel {
        switch arousalScore {
        case 0..<30: return .calm
        case 30..<50: return .moderate
        case 50..<70: return .elevated
        case 70..<90: return .high
        default: return .critical
        }
    }

    // MARK: - Cinematic Background

    private var cinematicBackground: some View {
        ZStack {
            // Dusk gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(hex: "#171120"),
                    Color(hex: "#402959").opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // Radial vignette: darker at edges
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.6),
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
        }
        .opacity(curtainDrop ? 1.0 : 0.0)
    }

    // MARK: - Breathing Glow

    private var agentGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        NervRestTheme.Accent.glow.opacity(breatheGlow ? 0.12 : 0.06),
                        Color.clear,
                    ]),
                    center: .center,
                    startRadius: 30,
                    endRadius: breatheGlow ? 180 : 140
                )
            )
            .frame(width: 300, height: 300)
            .offset(y: -60)
            .animation(
                .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                value: breatheGlow
            )
    }

    // MARK: - Entrance Animation Sequence

    private func performEntranceSequence() {
        // Phase 1: Curtain drops (background fades in)
        withAnimation(.easeIn(duration: 1.2)) {
            curtainDrop = true
        }

        // Phase 2: Content reveals
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.7)) {
                contentReveal = true
            }
        }

        // Phase 3: Start breathing glow loop
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            breatheGlow = true
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ShieldOverlayScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShieldOverlayScreen(
            arousalScore: 87,
            currentHR: 88,
            alarmTime: "8:00 AM",
            onShowAlternatives: {},
            onFiveMoreMinutes: {}
        )
    }
}
#endif
