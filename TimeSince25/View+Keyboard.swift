import SwiftUI

public enum KeyboardKind: Sendable {
  case `default`
  case number
  case decimal
  case email
  case url
  case phone
}

public extension View {
  /// Apply an appropriate keyboard configuration for the given kind on platforms that support it.
  /// On macOS this is a no-op because SwiftUI's TextField does not expose keyboard types.
  func applyKeyboard(_ kind: KeyboardKind) -> some View {
    #if os(iOS) || os(tvOS)
    switch kind {
    case .default:
      return AnyView(self.keyboardType(.default))
    case .number:
      return AnyView(self.keyboardType(.numberPad))
    case .decimal:
      return AnyView(self.keyboardType(.decimalPad))
    case .email:
      return AnyView(self.keyboardType(.emailAddress))
    case .url:
      return AnyView(self.keyboardType(.URL))
    case .phone:
      return AnyView(self.keyboardType(.phonePad))
    }
    #else
    // macOS and other platforms: no-op
    return AnyView(self)
    #endif
  }
}
