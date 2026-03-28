import SwiftUI

struct RampDownScreen: View {
    @StateObject private var viewModel = RampDownViewModel()
    var onSuggestionTapped: (RampDownSuggestion) -> Void = { _ in }
    var onFreeTextSubmit: (String) -> Void = { _ in }

    @State private var appearAnimation = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: NervRestTheme.Spacing.lg) {
                headerSection
                suggestionsSection
                freeTextSection
            }
            .padding(.horizontal, NervRestTheme.Spacing.lg)
            .padding(.top, NervRestTheme.Spacing.xl)
            .padding(.bottom, NervRestTheme.Spacing.xxl)
        }
        .background(NervRestTheme.Surface.background.ignoresSafeArea())
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
            onSuggestionTapped(suggestion)
        } label: {
            HStack(spacing: 0) {
                // Teal accent left edge
                RoundedRectangle(cornerRadius: 2)
                    .fill(NervRestTheme.Arousal.calm)
                    .frame(width: 4)
                    .padding(.vertical, NervRestTheme.Spacing.sm)

                // Card content
                VStack(alignment: .leading, spacing: NervRestTheme.Spacing.sm) {
                    // App name + stim score
                    HStack {
                        Text(suggestion.toApp)
                            .font(NervRestTheme.Fonts.headline)
                            .foregroundColor(NervRestTheme.Text.primary)

                        Spacer()

                        // Stim score pill
                        stimPill(score: suggestion.toAppStimScore)
                    }

                    // Metrics row
                    HStack(spacing: NervRestTheme.Spacing.lg) {
                        metricView(
                            icon: "heart.fill",
                            value: "-\(Int(suggestion.predictedHRDrop))",
                            label: "BPM",
                            color: NervRestTheme.Arousal.calm
                        )

                        metricView(
                            icon: "clock.fill",
                            value: "\(suggestion.estimatedMinutesToCalm)",
                            label: "min to calm",
                            color: NervRestTheme.Text.secondary
                        )
                    }
                }
                .padding(.horizontal, NervRestTheme.Spacing.md)
                .padding(.vertical, NervRestTheme.Spacing.md)
            }
            .background(
                RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                    .fill(NervRestTheme.Surface.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                            .stroke(NervRestTheme.Surface.cardBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func stimPill(score: Double) -> some View {
        let color = NervRestTheme.Arousal.color(for: score)
        return HStack(spacing: NervRestTheme.Spacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text(String(format: "%.1f", score))
                .font(NervRestTheme.Fonts.micro)
                .foregroundColor(color)
        }
        .padding(.horizontal, NervRestTheme.Spacing.sm)
        .padding(.vertical, NervRestTheme.Spacing.xs)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }

    private func metricView(
        icon: String,
        value: String,
        label: String,
        color: Color
    ) -> some View {
        HStack(spacing: NervRestTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(NervRestTheme.Fonts.headline)
                .foregroundColor(NervRestTheme.Text.primary)

            Text(label)
                .font(NervRestTheme.Fonts.micro)
                .foregroundColor(NervRestTheme.Text.tertiary)
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
                            .foregroundColor(NervRestTheme.Arousal.calm)
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
                                    ? NervRestTheme.Arousal.calm.opacity(0.5)
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
}

// MARK: - Preview

#if DEBUG
struct RampDownScreen_Previews: PreviewProvider {
    static var previews: some View {
        RampDownScreen()
            .preferredColorScheme(.dark)
    }
}
#endif
