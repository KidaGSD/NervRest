import SwiftUI

struct ShieldTransitionView: View {
    @Binding var phase: TransitionPhase

    enum TransitionPhase: Equatable {
        case hidden
        case dimming
        case moonReveal
        case shieldReady
    }

    // MARK: - Animation State

    @State private var moonScale: CGFloat = 0.3
    @State private var moonOpacity: Double = 0
    @State private var glowPulse: Bool = false
    @State private var glowRadius: CGFloat = 100
    @State private var vignetteDarkness: Double = 0
    @State private var moonYOffset: CGFloat = 20

    var body: some View {
        ZStack {
            // MARK: Layer 1 — Theater Dimming Overlay
            //
            // This is the "house lights going down" effect. A multi-stop
            // gradient gives depth instead of a flat black rectangle:
            // edges darken first (vignette), then the center catches up.
            if phase != .hidden {
                ZStack {
                    // Base fill — simple opacity ramp for the overall dim level
                    Color.black
                        .opacity(dimmingOpacity)

                    // Radial vignette — edges go dark faster than center,
                    // like looking down a narrowing tunnel
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(vignetteDarkness)
                        ]),
                        center: .center,
                        startRadius: 80,
                        endRadius: 400
                    )

                    // Top-down curtain gradient — subtle theater-curtain feel
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(dimmingOpacity * 0.6), location: 0.0),
                            .init(color: Color.clear, location: 0.5),
                            .init(color: Color.black.opacity(dimmingOpacity * 0.4), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2.0), value: phase)
            }

            // MARK: Layer 2 — Moon Reveal
            if phase == .moonReveal || phase == .shieldReady {
                ZStack {
                    // Outer atmospheric haze — large, soft, barely visible
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    NervRestTheme.Accent.glow.opacity(glowPulse ? 0.06 : 0.02),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 20,
                                endRadius: glowPulse ? 180 : 140
                            )
                        )
                        .frame(width: 320, height: 320)
                        .animation(
                            .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                            value: glowPulse
                        )

                    // Inner warm glow — tighter, more saturated
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    NervRestTheme.Arousal.high.opacity(glowPulse ? 0.18 : 0.08),
                                    NervRestTheme.Accent.glow.opacity(glowPulse ? 0.06 : 0.02),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 10,
                                endRadius: glowRadius
                            )
                        )
                        .frame(width: 220, height: 220)
                        .animation(
                            .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                            value: glowPulse
                        )

                    // Moon mascot — springs in with personality
                    AgentCharacter(mood: "worried", size: 120)
                        .scaleEffect(moonScale)
                        .opacity(moonOpacity)
                        .offset(y: moonYOffset)
                }
                .opacity(phase == .shieldReady ? 0.6 : 1.0)
                .animation(.easeOut(duration: 0.5), value: phase)
                .onAppear {
                    performMoonEntrance()
                }
            }
        }
        .allowsHitTesting(phase != .hidden)
        .onChange(of: phase) { _, newPhase in
            handlePhaseChange(newPhase)
        }
    }

    // MARK: - Dimming Opacity

    /// Maps each phase to a target overlay opacity.
    /// The values progress like theater lights dimming to blackout.
    private var dimmingOpacity: Double {
        switch phase {
        case .hidden:      return 0
        case .dimming:     return 0.75
        case .moonReveal:  return 0.92
        case .shieldReady: return 1.0
        }
    }

    // MARK: - Moon Entrance Animation

    /// Spring the moon in from below-center with scale + opacity + vertical drift.
    /// The spring parameters give it a bouncy, characterful arrival.
    private func performMoonEntrance() {
        // Scale + opacity: bouncy spring
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.1)) {
            moonScale = 1.0
            moonOpacity = 1.0
        }
        // Vertical float: ease the moon upward to its resting position
        withAnimation(.easeOut(duration: 1.0)) {
            moonYOffset = 0
        }
        // Start the breathing glow loop after the moon settles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            glowPulse = true
        }
        // Expand glow radius slightly after entrance
        withAnimation(.easeInOut(duration: 1.2)) {
            glowRadius = 130
        }
    }

    // MARK: - Phase Change Handler

    /// Responds to phase changes driven by the parent.
    /// The vignette deepens as phases progress.
    private func handlePhaseChange(_ newPhase: TransitionPhase) {
        switch newPhase {
        case .hidden:
            resetState()
        case .dimming:
            withAnimation(.easeInOut(duration: 2.0)) {
                vignetteDarkness = 0.4
            }
        case .moonReveal:
            withAnimation(.easeInOut(duration: 0.5)) {
                vignetteDarkness = 0.7
            }
        case .shieldReady:
            withAnimation(.easeInOut(duration: 0.5)) {
                vignetteDarkness = 0.9
            }
        }
    }

    /// Resets all animation state so the transition can replay cleanly.
    private func resetState() {
        moonScale = 0.3
        moonOpacity = 0
        glowPulse = false
        glowRadius = 100
        vignetteDarkness = 0
        moonYOffset = 20
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        // Simulated TikTok feed background
        LinearGradient(
            colors: [.blue, .purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay {
            VStack(spacing: NervRestTheme.Spacing.md) {
                Text("TikTok Feed")
                    .font(NervRestTheme.Fonts.displayMedium)
                    .foregroundColor(.white)
                Text("Content playing behind the overlay...")
                    .font(NervRestTheme.Fonts.body)
                    .foregroundColor(.white.opacity(0.7))
            }
        }

        ShieldTransitionView(phase: .constant(.moonReveal))
    }
}
