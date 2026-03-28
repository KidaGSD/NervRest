import SwiftUI

struct LunaChatScreen: View {
    @ObservedObject var viewModel: LunaChatViewModel

    var body: some View {
        ZStack {
            // Background: deep dusk with subtle radial glow
            NervRestTheme.Surface.background.ignoresSafeArea()

            // Warm accent glow behind the moon area
            RadialGradient(
                gradient: Gradient(colors: [
                    NervRestTheme.Accent.glow.opacity(0.06),
                    Color.clear
                ]),
                center: .center,
                startRadius: 20,
                endRadius: 260
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // MARK: - Moon mascot
                AgentCharacter(mood: "happy", size: 80)
                    .scaleEffect(viewModel.showGreeting ? 1.0 : 0.4)
                    .opacity(viewModel.showGreeting ? 1.0 : 0.3)
                    .animation(
                        .spring(response: 0.7, dampingFraction: 0.6),
                        value: viewModel.showGreeting
                    )

                Spacer().frame(height: NervRestTheme.Spacing.lg)

                // MARK: - Greeting text
                if viewModel.showGreeting {
                    Text(viewModel.greeting)
                        .font(NervRestTheme.Fonts.displayMedium)
                        .foregroundColor(NervRestTheme.Text.primary)
                        .multilineTextAlignment(.center)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                    Spacer().frame(height: NervRestTheme.Spacing.sm)

                    Text(viewModel.subtitle)
                        .font(NervRestTheme.Fonts.body)
                        .foregroundColor(NervRestTheme.Text.secondary)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }

                Spacer()

                // MARK: - Chat input bar
                if viewModel.showInput {
                    HStack(spacing: NervRestTheme.Spacing.md) {
                        TextField("Chat with Luna", text: $viewModel.inputText)
                            .font(NervRestTheme.Fonts.body)
                            .foregroundColor(NervRestTheme.Text.primary)

                        if !viewModel.inputText.isEmpty {
                            Button(action: {}) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(NervRestTheme.Accent.primary)
                            }
                        }
                    }
                    .padding(.horizontal, NervRestTheme.Spacing.md)
                    .padding(.vertical, NervRestTheme.Spacing.md - 4)
                    .background(
                        RoundedRectangle(cornerRadius: NervRestTheme.Radius.xl)
                            .fill(NervRestTheme.Surface.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: NervRestTheme.Radius.xl)
                                    .stroke(
                                        NervRestTheme.Surface.cardBorder.opacity(0.5),
                                        lineWidth: 0.5
                                    )
                            )
                    )
                    .padding(.horizontal, NervRestTheme.Spacing.lg)
                    .padding(.bottom, NervRestTheme.Spacing.md)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { viewModel.loadGreeting() }
    }
}

#Preview {
    LunaChatScreen(viewModel: LunaChatViewModel())
}
