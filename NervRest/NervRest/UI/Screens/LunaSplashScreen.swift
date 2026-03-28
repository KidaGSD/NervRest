import SwiftUI

struct LunaSplashScreen: View {
    @State private var moonScale: CGFloat = 0.5
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

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                NervRestTheme.Accent.glow.opacity(glowPulse ? 0.3 : 0.15),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)

                Image("moon_waxing_crescent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .scaleEffect(moonScale)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
                moonScale = 1.0
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

#if DEBUG
struct LunaSplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        LunaSplashScreen()
            .preferredColorScheme(.dark)
    }
}
#endif
