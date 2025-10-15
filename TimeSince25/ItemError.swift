import Foundation

enum ItemError: Error, LocalizedError, Equatable {
  case duplicateName

  var errorDescription: String? {
    switch self {
    case .duplicateName:
      return "An item with this name already exists."
    }
  }
}
