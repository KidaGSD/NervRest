import Foundation
import Combine
import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

class LunaChatViewModel: ObservableObject {
    @Published var userName: String = "there"
    @Published var greeting: String = ""
    @Published var subtitle: String = "How can I help you today?"
    @Published var inputText: String = ""
    @Published var showGreeting: Bool = false
    @Published var showInput: Bool = false
    @Published var messages: [ChatMessage] = []

    func loadGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        switch hour {
        case 5..<12:  timeGreeting = "Good Morning"
        case 12..<17: timeGreeting = "Good Afternoon"
        case 17..<22: timeGreeting = "Good Evening"
        default:      timeGreeting = "Good Night"
        }
        greeting = "\(timeGreeting), \(userName)"

        // Staggered reveal: moon springs in → greeting fades → input slides up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                self.showGreeting = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.4)) {
                self.showInput = true
            }
        }
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(text: text, isUser: true))
        inputText = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.messages.append(ChatMessage(
                text: "I hear you. Let me find something calming for you.",
                isUser: false
            ))
        }
    }
}
