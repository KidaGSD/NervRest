//
//  TikTokMockScreen.swift
//  NervRest
//
//  Full-screen TikTok-style video carousel with
//  a NervRest biometric overlay (heart rate + arousal score pills).
//

import SwiftUI

struct TikTokMockScreen: View {
    let arousalScore: Double     // 0-100
    let heartRate: Int
    let hrv: Int
    let currentApp: String
    let isMonitoring: Bool

    var body: some View {
        ZStack {
            // Full-screen TikTok-style video carousel
            VideoCarouselWrapper()
                .ignoresSafeArea()

            // Fake Dynamic Island pill (top center)
            VStack {
                fakeDynamicIsland
                    .padding(.top, 12)

                Spacer()
            }

            // NervRest biometric overlay (top-left, below island)
            VStack {
                HStack(alignment: .top) {
                    biometricOverlay
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.leading, 16)

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Fake Dynamic Island

    private var fakeDynamicIsland: some View {
        HStack(spacing: 0) {
            // Left: agent mood
            Text(agentEmoji)
                .font(.system(size: 16))
                .padding(.leading, 14)

            Spacer()

            // Right: arousal score with color
            Text(String(format: "%.0f", arousalScore))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(arousalColor)
                .padding(.trailing, 14)
        }
        .frame(width: 126, height: 37)
        .background(Color.black)
        .cornerRadius(19)
        .animation(.easeInOut(duration: 0.5), value: arousalScore)
    }

    private var agentEmoji: String {
        switch arousalScore {
        case ..<30: return "😊"
        case 30..<50: return "😊"
        case 50..<70: return "😐"
        case 70..<90: return "😟"
        default: return "😟"
        }
    }

    // MARK: - Biometric Overlay

    private var biometricOverlay: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Heart rate pill
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 10))
                Text("\(heartRate) bpm")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
            }
            .foregroundColor(heartRate > 75 ? Color(hex: "#E24B4A") : Color(hex: "#1D9E75"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial)
            .cornerRadius(14)

            // Arousal score pill
            HStack(spacing: 4) {
                Circle()
                    .fill(arousalColor)
                    .frame(width: 6, height: 6)
                Text(String(format: "%.0f", arousalScore))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(arousalColor.opacity(0.7))
            .cornerRadius(14)

            // HRV pill (small secondary indicator)
            if isMonitoring {
                HStack(spacing: 4) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 9))
                    Text("HRV \(hrv)ms")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Arousal Color

    private var arousalColor: Color {
        switch arousalScore {
        case ..<30:
            return Color(hex: "#1D9E75")
        case 30..<50:
            return Color(hex: "#4CAF50")
        case 50..<70:
            return Color(hex: "#EF9F27")
        case 70..<90:
            return Color(hex: "#D85A30")
        default:
            return Color(hex: "#E24B4A")
        }
    }
}

// MARK: - Preview

#Preview("TikTok Mock - Low Arousal") {
    TikTokMockScreen(
        arousalScore: 25,
        heartRate: 62,
        hrv: 48,
        currentApp: "TikTok",
        isMonitoring: true
    )
}

#Preview("TikTok Mock - High Arousal") {
    TikTokMockScreen(
        arousalScore: 82,
        heartRate: 88,
        hrv: 32,
        currentApp: "TikTok",
        isMonitoring: true
    )
}
