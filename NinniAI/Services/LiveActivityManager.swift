import Foundation
import ActivityKit
import Observation
import SwiftUI
@Observable
class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var sleepActivity: Activity<SleepAttributes>?
    
    private init() {}
    
    func startLiveActivity(babyName: String, soundName: String, startTime: Date = Date()) {
        print("--- Live Activity Başlatma Tetiklendi (Bebek: \(babyName), Ses: \(soundName)) ---")
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("HATA: ActivityAuthorizationInfo().areActivitiesEnabled == false. Cihaz/Simülatör ayarlarından Live Activities kapalı olabilir!")
            return
        }
        print("Live Activities izni doğrulandı. Eklenti başlatılıyor...")
        
        let attributes = SleepAttributes(babyName: babyName)
        let initialContentState = SleepAttributes.ContentState(
            startTime: startTime,
            sleepStatus: "Derin Uykuda",
            soundName: soundName
        )
        
        do {
            sleepActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialContentState, staleDate: nil),
                pushType: nil
            )
            print("Live Activity Başlatıldı: \(sleepActivity?.id ?? "")")
        } catch {
            print("Live Activity Başlatılamadı: \(error.localizedDescription)")
        }
    }
    
    func stopLiveActivity() {
        Task {
            guard let activity = sleepActivity else { return }
            
            let finalContentState = SleepAttributes.ContentState(
                startTime: activity.content.state.startTime,
                sleepStatus: "Uyandı",
                soundName: activity.content.state.soundName
            )
            
            await activity.end(
                ActivityContent(state: finalContentState, staleDate: nil),
                dismissalPolicy: .immediate
            )
            
            sleepActivity = nil
            print("Live Activity Sonlandırıldı.")
        }
    }
}
