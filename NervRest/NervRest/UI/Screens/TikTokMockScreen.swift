import SwiftUI

struct TikTokMockScreen: View {
    let arousalScore: Double     // 0-100
    let heartRate: Int
    let hrv: Int
    let currentApp: String
    let isMonitoring: Bool

    var body: some View {
        ZStack {
            // Full-screen video
            VideoCarouselWrapper()
                .ignoresSafeArea()

            // Biometric overlay (top-left)
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

    private var biometricOverlay: some View {
        VStack(alignment: .leading, spacing: 6) {
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
        }
    }

    private var arousalColor: Color {
        switch arousalScore {
        case ..<30: return Color(hex: "#1D9E75")
        case 30..<50: return Color(hex: "#4CAF50")
        case 50..<70: return Color(hex: "#EF9F27")
        case 70..<90: return Color(hex: "#D85A30")
        default: return Color(hex: "#E24B4A")
        }
    }
}
