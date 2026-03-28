import SwiftUI

struct OnboardingPreferencesScreen: View {
    let title: String
    let subtitle: String
    let options: [String]
    @Binding var selections: Set<String>
    let currentStep: Int
    let totalSteps: Int
    let minSelections: Int
    var onContinue: () -> Void = {}

    @State private var appeared = false

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

            VStack(spacing: 0) {
                progressBar
                    .padding(.top, NervRestTheme.Spacing.lg)
                    .padding(.horizontal, NervRestTheme.Spacing.lg)

                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(NervRestTheme.Text.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, NervRestTheme.SectionSpacing.breathe)
                    .padding(.horizontal, NervRestTheme.Spacing.lg)

                Text(subtitle)
                    .font(NervRestTheme.Fonts.body)
                    .foregroundColor(NervRestTheme.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, NervRestTheme.Spacing.sm)
                    .padding(.horizontal, NervRestTheme.Spacing.xl)

                optionsGrid
                    .padding(.top, NervRestTheme.SectionSpacing.breathe)
                    .padding(.horizontal, NervRestTheme.Spacing.lg)

                Spacer()

                Button(action: onContinue) {
                    Text("Continue")
                        .font(NervRestTheme.Fonts.headline)
                        .foregroundColor(selections.count >= minSelections ? .white : NervRestTheme.Text.tertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, NervRestTheme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                                .fill(selections.count >= minSelections
                                      ? NervRestTheme.Surface.cardBorder
                                      : NervRestTheme.Surface.cardBackground)
                        )
                }
                .disabled(selections.count < minSelections)
                .padding(.horizontal, NervRestTheme.Spacing.lg)
                .padding(.bottom, NervRestTheme.SectionSpacing.breathe)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appeared = true }
        }
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? Color.white : Color.white.opacity(0.2))
                    .frame(height: 3)
            }
        }
    }

    private var optionsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: NervRestTheme.Spacing.md),
            GridItem(.flexible(), spacing: NervRestTheme.Spacing.md)
        ], spacing: NervRestTheme.Spacing.md) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                optionCard(option, index: index)
            }
        }
    }

    private func optionCard(_ option: String, index: Int) -> some View {
        let isSelected = selections.contains(option)
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if isSelected { selections.remove(option) } else { selections.insert(option) }
            }
        } label: {
            VStack {
                Spacer()
                Text(option)
                    .font(NervRestTheme.Fonts.body)
                    .foregroundColor(NervRestTheme.Text.primary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                    .fill(isSelected
                          ? NervRestTheme.Surface.cardBorder.opacity(0.6)
                          : NervRestTheme.Surface.cardBackground.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: NervRestTheme.Radius.lg)
                            .stroke(isSelected
                                    ? NervRestTheme.Accent.secondary.opacity(0.5)
                                    : Color.white.opacity(0.08),
                                    lineWidth: isSelected ? 1.5 : 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08), value: appeared)
    }
}
