import WidgetKit
import SwiftUI
import ActivityKit

struct SleepLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SleepAttributes.self) { context in
            // Lock Screen UI - Antigravity (Glassmorphism)
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(context.attributes.babyName) dinleniyor...")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(context.state.sleepStatus)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Lavanta Tonlarında Parlayan Sayaç
                    Text(timerInterval: context.state.startTime...Date.distantFuture, countsDown: false)
                        .font(.system(size: 24, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 1.0)) // Lavanta
                        .shadow(color: Color(red: 0.8, green: 0.6, blue: 1.0).opacity(0.6), radius: 8, x: 0, y: 0)
                }
                .padding(20)
            }
            .activityBackgroundTint(.clear)
            .activitySystemActionForegroundColor(.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Mod
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text(context.attributes.babyName)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(context.state.soundName)
                            .font(.caption)
                            .foregroundColor(Color(red: 0.8, green: 0.6, blue: 1.0))
                    }
                    .padding(.leading, 8)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.state.startTime...Date.distantFuture, countsDown: false)
                        .font(.title3.weight(.medium).monospacedDigit())
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 1.0))
                        .padding(.trailing, 8)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Spacer()
                        // Durdur Butonu (Uygulamayı açıp işlemi tetiklemesi için Deep Link yönlendirmesi)
                        Link(destination: URL(string: "ninniAI://stopSleep")!) {
                            HStack(spacing: 6) {
                                Image(systemName: "stop.fill")
                                Text("Durdur")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.8).gradient)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                // Compact Mod - Sol (Ay İkonu)
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 1.0))
            } compactTrailing: {
                // Compact Mod - Sağ (Sayaç)
                Text(timerInterval: context.state.startTime...Date.distantFuture, countsDown: false)
                    .font(.caption2.weight(.medium).monospacedDigit())
                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 1.0))
                    .frame(width: 40)
            } minimal: {
                // Minimal Mod
                Image(systemName: "moon.fill")
                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 1.0))
            }
            .keylineTint(Color(red: 0.8, green: 0.6, blue: 1.0)) // Dynamic Island dış çerçeve parlaması
        }
    }
}
