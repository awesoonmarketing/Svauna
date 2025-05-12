//
//  WatchDateUtils.swift
//  Svauna Watch App
//
//  Created by Rasoul Rasouli on 2025-04-27.
//

import Foundation

struct WatchDateUtils {
    
    /// Formats elapsed time as "MM:SS"
    static func formatElapsedTime(seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    /// Formats a Date into a short time string (like "3:45 PM")
    static func formatShortTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Formats a Date into a full timestamp (like "April 27, 2025 at 3:45 PM")
    static func formatFullTimestamp(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Calculates the duration between two dates as seconds
    static func secondsBetween(_ start: Date, _ end: Date) -> TimeInterval {
        return end.timeIntervalSince(start)
    }
    
    /// Formats a time interval nicely for a session summary (like "32 minutes")
    static func formatDurationPretty(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        if minutes == 1 {
            return "1 minute"
        } else {
            return "\(minutes) minutes"
        }
    }
}
