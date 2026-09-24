import ActivityKit
import Foundation

@available(iOS 16.2, *)
struct DaydreamTimerAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    var startedAt: Date
  }
}
