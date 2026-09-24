import ActivityKit
import SwiftUI
import WidgetKit

@main
struct DaydreamTimerWidgetBundle: WidgetBundle {
  var body: some Widget {
    DaydreamTimerLiveActivity()
  }
}

struct DaydreamTimerLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: DaydreamTimerAttributes.self) { context in
      LockScreenClockView(startedAt: context.state.startedAt)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          StatusLabel()
        }
        DynamicIslandExpandedRegion(.trailing) {
          ElapsedClock(startedAt: context.state.startedAt)
            .font(.title3.weight(.medium))
        }
      } compactLeading: {
        Text("running")
          .font(.caption2)
          .foregroundStyle(DaydreamClockPalette.muted)
      } compactTrailing: {
        ElapsedClock(startedAt: context.state.startedAt)
          .font(.caption.weight(.medium))
      } minimal: {
        ElapsedClock(startedAt: context.state.startedAt)
          .font(.caption2.weight(.medium))
      }
      .keylineTint(DaydreamClockPalette.accent)
    }
  }
}

private struct LockScreenClockView: View {
  let startedAt: Date

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      StatusLabel()
      Spacer(minLength: 8)
      ElapsedClock(startedAt: startedAt)
        .font(.title2.weight(.medium))
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .activityBackgroundTint(DaydreamClockPalette.background)
  }
}

private struct StatusLabel: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text("daydream timer")
        .font(.caption)
        .foregroundStyle(DaydreamClockPalette.muted)
      Text("running")
        .font(.subheadline.weight(.medium))
        .foregroundStyle(DaydreamClockPalette.text)
    }
  }
}

/// Counts up on the lock screen without a push for every second.
private struct ElapsedClock: View {
  let startedAt: Date

  var body: some View {
    Text(
      timerInterval: startedAt...startedAt.addingTimeInterval(24 * 60 * 60),
      countsDown: false
    )
    .monospacedDigit()
    .foregroundStyle(DaydreamClockPalette.accent)
    .multilineTextAlignment(.trailing)
    .frame(minWidth: 72, alignment: .trailing)
  }
}

private enum DaydreamClockPalette {
  static let background = Color(red: 0.039, green: 0.039, blue: 0.039)
  static let muted = Color(red: 0.604, green: 0.604, blue: 0.604)
  static let text = Color(red: 0.949, green: 0.949, blue: 0.949)
  static let accent = Color(red: 0, green: 0.898, blue: 0.765)
}
