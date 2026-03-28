import SwiftUI

struct ShieldOverlayScreen: View {
    let arousalScore: Double
    let currentHR: Int
    var onShowAlternatives: () -> Void = {}
    var onFiveMoreMinutes: () -> Void = {}

    @State private var curtainDrop = false
    @State private var contentReveal = false
    @State private var pulseAgent = false
    @State private var breatheGlow = false

    var body: some View {
        ZStack {
            // Layer 1: Cinematic dark gradient — theater lights dimming
            cinematicBackground

            // Layer 2: Subtle radial glow behind agent
            agentGlow

            // Layer 3: Content
            VStack(spacing: 0) {
                Spacer()

                agentSection
                    .padding(.bottom, NervRestTheme.Spacing.xl)

                titleSection
                    .padding(.bottom, NervRestTheme.Spacing.lg)

                subtitleSection
                    .padding(.bottom, NervRestTheme.Spacing.xxl)

                buttonsSection
                    .padding(.bottom, NervRestTheme.Spacing.xl)

                Spacer()
                    .frame(height: NervRestTheme.Spacing.xxl)
            }
            .padding(.horizontal, NervRestTheme.Spacing.xl)
        }
        .ignoresSafeArea()
        .onAppear {
            performEntranceSequence()
        }
    }

    // MARK: - Cinematic Background

    private var cinematicBackground: some View {
        ZStack {
            // Base: near-black with purple tint
            Color(hex: "#0A0510")

            // Vertical gradient: subtle dark-blue at top fading to pure black
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "#171120").opacity(0.8), location: 0.0),
                    .init(color: Color(hex: "#0A0510").opacity(1.0), location: 0.4),
                    .init(color: Color(hex: "#0A0510"), location: 1.0),
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

    // MARK: - Agent Glow (breathing aura)

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

    // MARK: - Agent Character

    private var agentSection: some View {
        AgentCharacter(mood: "worried", size: 120)
            .scaleEffect(pulseAgent ? 1.0 : 0.4)
            .opacity(contentReveal ? 1.0 : 0.0)
            .scaleEffect(breatheGlow ? 1.02 : 0.98)
            .animation(
                .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                value: breatheGlow
            )
    }

    // MARK: - Title

    private var titleSection: some View {
        Text("Time to wind down")
            .font(NervRestTheme.Fonts.displayLarge)
            .foregroundColor(NervRestTheme.Text.primary)
            .multilineTextAlignment(.center)
            .opacity(contentReveal ? 1.0 : 0.0)
            .offset(y: contentReveal ? 0 : 24)
    }

    // MARK: - Subtitle (arousal score + HR)

    private var subtitleSection: some View {
        HStack(spacing: NervRestTheme.Spacing.lg) {
            // Arousal score pill
            HStack(spacing: NervRestTheme.Spacing.sm) {
                Circle()
                    .fill(NervRestTheme.Arousal.color(for: arousalScore))
                    .frame(width: 8, height: 8)

                Text(String(format: "%.1f", arousalScore))
                    .font(NervRestTheme.Fonts.headline)
                    .foregroundColor(NervRestTheme.Text.primary)

                Text("arousal")
                    .font(NervRestTheme.Fonts.micro)
                    .foregroundColor(NervRestTheme.Text.tertiary)
            }

            // Divider dot
            Circle()
                .fill(NervRestTheme.Text.tertiary)
                .frame(width: 3, height: 3)

            // Heart rate pill
            HStack(spacing: NervRestTheme.Spacing.sm) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(NervRestTheme.Arousal.high)

                Text("\(currentHR)")
                    .font(NervRestTheme.Fonts.headline)
                    .foregroundColor(NervRestTheme.Text.primary)

                Text("BPM")
                    .font(NervRestTheme.Fonts.micro)
                    .foregroundColor(NervRestTheme.Text.tertiary)
            }
        }
        .padding(.horizontal, NervRestTheme.Spacing.lg)
        .padding(.vertical, NervRestTheme.Spacing.md)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.04))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .opacity(contentReveal ? 1.0 : 0.0)
        .offset(y: contentReveal ? 0 : 16)
    }

    // MARK: - Buttons

    private var buttonsSection: some View {
        VStack(spacing: NervRestTheme.Spacing.md) {
            // Primary: Show me alternatives
            Button(action: onShowAlternatives) {
                HStack(spacing: NervRestTheme.Spacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Show me alternatives")
                        .font(NervRestTheme.Fonts.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, NervRestTheme.Spacing.md + 2)
                .background(
                    RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                        .fill(NervRestTheme.Accent.primary)
                        .shadow(
                            color: NervRestTheme.Accent.primary.opacity(0.5),
                            radius: 20,
                            y: 6
                        )
                )
            }

            // Secondary: 5 more minutes (ghost button)
            Button(action: onFiveMoreMinutes) {
                Text("5 more minutes")
                    .font(NervRestTheme.Fonts.body)
                    .foregroundColor(NervRestTheme.Text.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, NervRestTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            }
        }
        .opacity(contentReveal ? 1.0 : 0.0)
        .offset(y: contentReveal ? 0 : 24)
    }

    // MARK: - Entrance Animation Sequence

    private func performEntranceSequence() {
        // Phase 1: Curtain drops (background fades in like theater dimming)
        withAnimation(.easeIn(duration: 1.2)) {
            curtainDrop = true
        }

        // Phase 2: Agent appears with spring
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
                pulseAgent = true
            }
        }

        // Phase 3: Content reveals
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.7)) {
                contentReveal = true
            }
        }

        // Phase 4: Start breathing glow loop
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            breatheGlow = true
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ShieldOverlayScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShieldOverlayScreen(
            arousalScore: 8.3,
            currentHR: 88,
            onShowAlternatives: {},
            onFiveMoreMinutes: {}
        )
        .preferredColorScheme(.dark)
    }
}
#endif
