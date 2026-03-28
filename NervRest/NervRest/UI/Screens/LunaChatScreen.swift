import SwiftUI

struct LunaChatScreen: View {
    @ObservedObject var viewModel: LunaChatViewModel

    var body: some View {
        ZStack {
            // Background: deep dusk with subtle radial glow
            NervRestTheme.Surface.background.ignoresSafeArea()

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

            if viewModel.messages.isEmpty {
                emptyStateView
            } else {
                conversationView
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { viewModel.loadGreeting() }
    }

    // MARK: - Empty State (Greeting)

    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Moon mascot
            AgentCharacter(mood: "happy", size: 80)
                .scaleEffect(viewModel.showGreeting ? 1.0 : 0.4)
                .opacity(viewModel.showGreeting ? 1.0 : 0.3)
                .animation(
                    .spring(response: 0.7, dampingFraction: 0.6),
                    value: viewModel.showGreeting
                )

            Spacer().frame(height: NervRestTheme.Spacing.lg)

            // Greeting text
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

            // Chat input bar
            if viewModel.showInput {
                chatInputBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Conversation State

    private var conversationView: some View {
        VStack(spacing: 0) {
            // Top header
            HStack {
                Button(action: {}) {
                    HStack(spacing: NervRestTheme.Spacing.xs) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Chat")
                            .font(NervRestTheme.Fonts.headline)
                    }
                    .foregroundColor(NervRestTheme.Accent.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, NervRestTheme.Spacing.lg)
            .padding(.top, NervRestTheme.Spacing.sm)
            .padding(.bottom, NervRestTheme.Spacing.md)

            // Greeting title
            HStack {
                Text(viewModel.greeting)
                    .font(NervRestTheme.Fonts.displayMedium)
                    .foregroundColor(NervRestTheme.Text.primary)
                Spacer()
            }
            .padding(.horizontal, NervRestTheme.Spacing.lg)
            .padding(.bottom, NervRestTheme.Spacing.md)

            // Message list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: NervRestTheme.Spacing.md) {
                        ForEach(viewModel.messages) { message in
                            messageBubble(for: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, NervRestTheme.Spacing.lg)
                    .padding(.vertical, NervRestTheme.Spacing.sm)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let last = viewModel.messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Chat input bar
            chatInputBar
        }
    }

    // MARK: - Message Bubble

    private func messageBubble(for message: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: NervRestTheme.Spacing.sm) {
            if message.isUser {
                Spacer(minLength: 60)
            } else {
                // Luna avatar
                AgentCharacter(mood: "happy", size: 24)
            }

            Text(message.text)
                .font(NervRestTheme.Fonts.body)
                .foregroundColor(NervRestTheme.Text.primary)
                .padding(.horizontal, NervRestTheme.Spacing.md)
                .padding(.vertical, NervRestTheme.Spacing.sm + 4)
                .background(
                    RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                        .fill(
                            message.isUser
                                ? NervRestTheme.Surface.cardBackground
                                : NervRestTheme.Surface.background
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                                .stroke(
                                    message.isUser
                                        ? NervRestTheme.Surface.cardBorder.opacity(0.7)
                                        : NervRestTheme.Surface.cardBorder.opacity(0.4),
                                    lineWidth: 0.5
                                )
                        )
                )

            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
    }

    // MARK: - Chat Input Bar

    private var chatInputBar: some View {
        HStack(spacing: NervRestTheme.Spacing.md) {
            TextField("Chat with Luna", text: $viewModel.inputText)
                .font(NervRestTheme.Fonts.body)
                .foregroundColor(NervRestTheme.Text.primary)
                .onSubmit {
                    viewModel.sendMessage()
                }

            if !viewModel.inputText.isEmpty {
                Button(action: { viewModel.sendMessage() }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(NervRestTheme.Accent.primary)
                }
            }
        }
        .padding(.horizontal, NervRestTheme.Spacing.md)
        .padding(.vertical, NervRestTheme.Spacing.md - 4)
        .background(
            Capsule()
                .fill(NervRestTheme.Surface.cardBackground)
                .overlay(
                    Capsule()
                        .stroke(
                            NervRestTheme.Surface.cardBorder.opacity(0.5),
                            lineWidth: 0.5
                        )
                )
        )
        .padding(.horizontal, NervRestTheme.Spacing.lg)
        .padding(.bottom, NervRestTheme.Spacing.md)
    }
}

#Preview {
    LunaChatScreen(viewModel: LunaChatViewModel())
}
