import ActivityKit
import Foundation

struct SleepAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startTime: Date
        var sleepStatus: String
        var soundName: String
    }

    var babyName: String
}
