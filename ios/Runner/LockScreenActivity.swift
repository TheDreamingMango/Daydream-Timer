import ActivityKit
import Flutter
import Foundation

enum LockScreenActivity {
  static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else {
      result(nil)
      return
    }
    switch call.method {
    case "start":
      let args = call.arguments as? [String: Any]
      let ms = (args?["startedAtMs"] as? NSNumber)?.doubleValue
      guard let ms else {
        result(nil)
        return
      }
      let startedAt = Date(timeIntervalSince1970: ms / 1000)
      LiveActivitySession.enqueue {
        await LiveActivitySession.start(startedAt)
        result(nil)
      }
    case "end":
      LiveActivitySession.enqueue {
        await LiveActivitySession.endAll()
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

@available(iOS 16.2, *)
private enum LiveActivitySession {
  private static let lock = NSLock()
  private static var chain: Task<Void, Never> = Task {}

  static func enqueue(_ work: @escaping @MainActor () async -> Void) {
    lock.lock()
    let previous = chain
    chain = Task { @MainActor in
      await previous.value
      await work()
    }
    lock.unlock()
  }

  @MainActor
  static func start(_ startedAt: Date) async {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
    await endAll()
    let state = DaydreamTimerAttributes.ContentState(startedAt: startedAt)
    do {
      _ = try Activity.request(
        attributes: DaydreamTimerAttributes(),
        content: ActivityContent(state: state, staleDate: nil),
        pushType: nil
      )
    } catch {
      // The in-app clock still runs if Live Activities are off.
    }
  }

  @MainActor
  static func endAll() async {
    for activity in Activity<DaydreamTimerAttributes>.activities {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
  }
}
