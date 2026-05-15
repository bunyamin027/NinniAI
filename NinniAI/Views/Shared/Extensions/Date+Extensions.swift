import Foundation

// MARK: - Date Extensions
/// Tarih hesaplama yardımcıları.
/// Baby modelinin yaş hesaplamaları ve ContextEngine'in
/// saat bazlı kararları için kullanılır.
extension Date {
    
    // MARK: - Age Calculation
    
    /// İki tarih arasındaki ay farkı
    func monthsSince(_ date: Date) -> Int {
        Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    /// İki tarih arasındaki gün farkı
    func daysSince(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    /// İki tarih arasındaki hafta farkı
    func weeksSince(_ date: Date) -> Int {
        Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    
    // MARK: - Time of Day
    
    /// Günün saati (0-23)
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }
    
    /// Günün dakikası (0-59)
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }
    
    /// Gece yarısından itibaren toplam dakika
    var minutesSinceMidnight: Int {
        hour * 60 + minute
    }
    
    // MARK: - Day Boundaries
    
    /// Günün başlangıcı (00:00)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Günün sonu (23:59:59)
    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
    
    /// Haftanın başlangıcı (Pazartesi)
    var startOfWeek: Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Pazartesi
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    // MARK: - Relative Dates
    
    /// N gün önceki tarih
    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }
    
    /// N gün sonraki tarih
    func daysLater(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// N ay önceki tarih
    func monthsAgo(_ months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: -months, to: self) ?? self
    }
    
    // MARK: - Checks
    
    /// Bugün mü?
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Dün mü?
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// Bu hafta içinde mi?
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: .now, toGranularity: .weekOfYear)
    }
    
    // MARK: - Formatting
    
    /// "6 aylık" gibi bebek yaşı formatı
    func babyAgeString(from birthDate: Date) -> String {
        let months = self.monthsSince(birthDate)
        let days = self.daysSince(birthDate)
        
        if months < 1 {
            return "\(days) günlük"
        } else if months < 12 {
            return "\(months) aylık"
        } else {
            let years = months / 12
            let remainingMonths = months % 12
            if remainingMonths == 0 {
                return "\(years) yaşında"
            }
            return "\(years) yaş \(remainingMonths) aylık"
        }
    }
    
    /// Kısa tarih formatı (gün.ay.yıl)
    var shortFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: self)
    }
    
    /// Saat formatı (HH:mm)
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}
