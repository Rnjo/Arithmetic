import Foundation
import SwiftUI

struct TimerHelper {
    static func startTimer(duration: Int, onTick: @escaping (Int) -> Void, onComplete: @escaping () -> Void) {
        var timeRemaining = duration
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
                onTick(timeRemaining)
            } else {
                timer.invalidate()
                onComplete()
            }
        }
    }
}
