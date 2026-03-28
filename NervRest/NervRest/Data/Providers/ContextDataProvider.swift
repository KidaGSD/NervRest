import Foundation

protocol ContextDataProvider {
    var currentContext: UserContext { get }
    var contextChanges: AsyncStream<UserContext> { get }
}
