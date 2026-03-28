import SwiftUI

struct OnboardingSplashScreen: View {
    var onContinue: () -> Void = {}
    @State private var moonAppeared = false
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(hex: "#171120"),
                    Color(hex: "#402959").opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    NervRestTheme.Accent.glow.opacity(glowPulse ? 0.25 : 0.15),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 30,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)

                    Image("moon_waxing_crescent")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .scaleEffect(moonAppeared ? 1.0 : 0.3)
                        .opacity(moonAppeared ? 1.0 : 0.0)
                }
                Spacer()
                Spacer()
            }
        }
        .onTapGesture { onContinue() }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) { moonAppeared = true }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { glowPulse = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { onContinue() }
        }
    }
}
