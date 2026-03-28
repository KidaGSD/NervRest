import SwiftUI

struct RampDownScreen: View {
    @ObservedObject var viewModel: RampDownViewModel
    var onSuggestionTapped: (RampDownSuggestion) -> Void = { _ in }
    var onFreeTextSubmit: (String) -> Void = { _ in }

    init(viewModel: RampDownViewModel = RampDownViewModel(),
         onSuggestionTapped: @escaping (RampDownSuggestion) -> Void = { _ in },
         onFreeTextSubmit: @escaping (String) -> Void = { _ in }) {
        self.viewModel = viewModel
        self.onSuggestionTapped = onSuggestionTapped
        self.onFreeTextSubmit = onFreeTextSubmit
    }

    @State private var appearAnimation = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: NervRestTheme.Spacing.lg) {
                headerSection
                suggestionsSection
                freeTextSection
                orDivider
                chatWithLunaButton
            }
            .padding(.horizontal, NervRestTheme.Spacing.lg)
            .padding(.top, NervRestTheme.Spacing.xl)
            .padding(.bottom, NervRestTheme.Spacing.xxl)
        }
        .background(
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
        )
        .onAppear {
            viewModel.loadMockSuggestions()
            withAnimation(.easeOut(duration: 0.8)) {
                appearAnimation = true
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: NervRestTheme.Spacing.md) {
            AgentCharacter(mood: "concerned", size: 72)
                .scaleEffect(appearAnimation ? 1.0 : 0.6)
                .opacity(appearAnimation ? 1.0 : 0.0)

            VStack(spacing: NervRestTheme.Spacing.sm) {
                Text("Let's wind down")
                    .font(NervRestTheme.Fonts.displayMedium)
                    .foregroundColor(NervRestTheme.Text.primary)

                Text("Try switching to something calmer")
                    .font(NervRestTheme.Fonts.body)
                    .foregroundColor(NervRestTheme.Text.secondary)
            }
            .multilineTextAlignment(.center)
            .opacity(appearAnimation ? 1.0 : 0.0)
            .offset(y: appearAnimation ? 0 : 12)
        }
        .padding(.bottom, NervRestTheme.Spacing.sm)
    }

    // MARK: - Suggestion Cards

    private var suggestionsSection: some View {
        VStack(spacing: NervRestTheme.Spacing.md) {
            ForEach(Array(viewModel.suggestions.enumerated()), id: \.element.id) { index, suggestion in
                suggestionCard(suggestion: suggestion, index: index)
                    .opacity(appearAnimation ? 1.0 : 0.0)
                    .offset(y: appearAnimation ? 0 : CGFloat(20 + index * 8))
                    .animation(
                        .easeOut(duration: 0.6).delay(Double(index) * 0.12),
                        value: appearAnimation
                    )
            }
        }
    }

    private func suggestionCard(suggestion: RampDownSuggestion, index: Int) -> some View {
        Button {
            viewModel.selectSuggestion(suggestion)
            onSuggestionTapped(suggestion)
        } label: {
            HStack(spacing: NervRestTheme.Spacing.md) {
                // Left: Cover art icon
                RoundedRectangle(cornerRadius: NervRestTheme.Radius.md)
                    .fill(NervRestTheme.Accent.secondary.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: suggestion.coverImageName)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(NervRestTheme.Accent.secondary)
                    )

                // Center: App name, subtitle, play pill
                VStack(alignment: .leading, spacing: NervRestTheme.Spacing.xs) {
                    Text(suggestion.toApp)
                        .font(NervRestTheme.Fonts.headline)
                        .foregroundColor(NervRestTheme.Text.primary)

                    Text("\(suggestion.estimatedMinutesToCalm)m to calm")
                        .font(NervRestTheme.Fonts.caption)
                        .foregroundColor(NervRestTheme.Text.secondary)

                    // Play button pill
                    HStack(spacing: NervRestTheme.Spacing.xs) {
                        Text("▶")
                            .font(.system(size: 10))
                        Text("\(suggestion.durationMinutes)min")
                            .font(NervRestTheme.Fonts.micro)
                    }
                    .foregroundColor(NervRestTheme.Text.primary)
                    .padding(.horizontal, NervRestTheme.Spacing.sm)
                    .padding(.vertical, NervRestTheme.Spacing.xs)
                    .background(
                        Capsule()
                            .fill(NervRestTheme.Accent.primary.opacity(0.2))
                    )
                }

                Spacer()

                // Right: Score ring
                scoreRing(score: suggestion.toAppStimScore)
            }
            .padding(NervRestTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                NervRestTheme.Surface.cardBackground,
                                NervRestTheme.Surface.cardBackground.opacity(0.6)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                            .stroke(NervRestTheme.Surface.cardBorder.opacity(0.3), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func scoreRing(score: Double) -> some View {
        let color = NervRestTheme.Arousal.color(for: score)
        let progress = score / 10.0
        return ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 3)
                .frame(width: 36, height: 36)

            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 36, height: 36)

            Text(String(format: "%.1f", score))
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }

    // MARK: - Free Text Input

    private var freeTextSection: some View {
        VStack(alignment: .leading, spacing: NervRestTheme.Spacing.sm) {
            Text("Or tell me what you'd like to watch")
                .font(NervRestTheme.Fonts.caption)
                .foregroundColor(NervRestTheme.Text.secondary)

            HStack(spacing: NervRestTheme.Spacing.sm) {
                TextField("e.g., nature documentaries, lofi music...", text: $viewModel.freeTextInput)
                    .font(NervRestTheme.Fonts.body)
                    .foregroundColor(NervRestTheme.Text.primary)
                    .focused($isTextFieldFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        guard !viewModel.freeTextInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        onFreeTextSubmit(viewModel.freeTextInput)
                    }

                // Send button (visible when text is non-empty)
                if !viewModel.freeTextInput.trimmingCharacters(in: .whitespaces).isEmpty {
                    Button {
                        onFreeTextSubmit(viewModel.freeTextInput)
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(NervRestTheme.Accent.primary)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(NervRestTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                    .fill(NervRestTheme.Surface.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                            .stroke(
                                isTextFieldFocused
                                    ? NervRestTheme.Accent.secondary.opacity(0.5)
                                    : NervRestTheme.Surface.cardBorder,
                                lineWidth: 1
                            )
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
            .animation(.easeInOut(duration: 0.2), value: viewModel.freeTextInput)
        }
        .opacity(appearAnimation ? 1.0 : 0.0)
        .offset(y: appearAnimation ? 0 : 20)
    }

    // MARK: - Or Divider

    private var orDivider: some View {
        HStack(spacing: NervRestTheme.Spacing.md) {
            Rectangle()
                .fill(NervRestTheme.Surface.cardBorder.opacity(0.4))
                .frame(height: 0.5)

            Text("Or")
                .font(NervRestTheme.Fonts.caption)
                .foregroundColor(NervRestTheme.Text.secondary)

            Rectangle()
                .fill(NervRestTheme.Surface.cardBorder.opacity(0.4))
                .frame(height: 0.5)
        }
        .opacity(appearAnimation ? 1.0 : 0.0)
    }

    // MARK: - Chat with Luna CTA

    private var chatWithLunaButton: some View {
        Button {
            // Navigate to Luna chat
        } label: {
            HStack(spacing: NervRestTheme.Spacing.sm) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 16, weight: .medium))
                Text("Chat with Luna")
                    .font(NervRestTheme.Fonts.headline)
            }
            .foregroundColor(NervRestTheme.Text.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, NervRestTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                    .fill(NervRestTheme.Accent.secondary.opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                            .stroke(NervRestTheme.Accent.secondary.opacity(0.4), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .opacity(appearAnimation ? 1.0 : 0.0)
        .offset(y: appearAnimation ? 0 : 12)
    }
}

// MARK: - Preview

#if DEBUG
struct RampDownScreen_Previews: PreviewProvider {
    static var previews: some View {
        RampDownScreen(viewModel: RampDownViewModel())
            .preferredColorScheme(.dark)
    }
}
#endif
