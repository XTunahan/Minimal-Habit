import UIKit

struct StreakStats { let current: Int; let best: Int; let completion: Double }

enum ShareImageRenderer {
    static func renderStreakCard(for habit: Habit, stats: StreakStats, pro: Bool) -> UIImage {
        // Placeholder white image
        let size = CGSize(width: 800, height: 450)
        UIGraphicsBeginImageContextWithOptions(size, true, 2)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }
}

