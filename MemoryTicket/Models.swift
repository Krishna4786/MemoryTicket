import Foundation
import SwiftUI

// MARK: - Ticket Category

enum TicketCategory: String, Codable, CaseIterable, Identifiable {
    case travel = "Travel"
    case concert = "Concerts"
    case family = "Family"
    case friends = "Friends"
    case food = "Food"
    case birthday = "Birthday"
    case milestone = "Milestone"
    case custom = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .travel:    return "airplane"
        case .concert:   return "music.mic"
        case .family:    return "house.fill"
        case .friends:   return "person.2.fill"
        case .food:      return "fork.knife"
        case .birthday:  return "birthday.cake.fill"
        case .milestone: return "star.fill"
        case .custom:    return "ticket.fill"
        }
    }

    var color: Color {
        switch self {
        case .travel:    return Color(hex: "3B82F6")
        case .concert:   return Color(hex: "8B5CF6")
        case .family:    return Color(hex: "F59E0B")
        case .friends:   return Color(hex: "10B981")
        case .food:      return Color(hex: "EF4444")
        case .birthday:  return Color(hex: "EC4899")
        case .milestone: return Color(hex: "F97316")
        case .custom:    return Color(hex: "6B7280")
        }
    }

    var badgeColor: Color {
        switch self {
        case .travel:    return Color(hex: "DBEAFE")
        case .concert:   return Color(hex: "EDE9FE")
        case .family:    return Color(hex: "FEF3C7")
        case .friends:   return Color(hex: "D1FAE5")
        case .food:      return Color(hex: "FEE2E2")
        case .birthday:  return Color(hex: "FCE7F3")
        case .milestone: return Color(hex: "FFEDD5")
        case .custom:    return Color(hex: "F3F4F6")
        }
    }
}

// MARK: - Location Info

struct LocationInfo: Codable, Equatable {
    var name: String
    var city: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?

    var displayName: String {
        if let city = city, let country = country { return "\(city), \(country)" }
        return name
    }
}

// MARK: - Memory Ticket

struct MemoryTicket: Identifiable, Codable {
    let id: UUID
    var title: String
    var imageFileName: String?
    var date: Date
    var location: LocationInfo?
    var notes: String
    var category: TicketCategory
    var mood: String            // MoodType rawValue
    var bookId: UUID?
    let createdAt: Date

    init(
        id: UUID = UUID(), title: String, imageFileName: String? = nil,
        date: Date = Date(), location: LocationInfo? = nil, notes: String = "",
        category: TicketCategory = .custom, mood: String = "happy",
        bookId: UUID? = nil, createdAt: Date = Date()
    ) {
        self.id = id; self.title = title; self.imageFileName = imageFileName
        self.date = date; self.location = location; self.notes = notes
        self.category = category; self.mood = mood; self.bookId = bookId
        self.createdAt = createdAt
    }

    var moodType: MoodType { MoodType.from(mood) }

    var formattedDate: String {
        let f = DateFormatter(); f.dateFormat = "MMMM d, yyyy"; return f.string(from: date)
    }
    var shortDate: String {
        let f = DateFormatter(); f.dateFormat = "MMM ''yy"; return f.string(from: date)
    }
}

// MARK: - Memory Book

struct MemoryBook: Identifiable, Codable {
    let id: UUID
    var title: String
    var accentColorHex: String
    let createdAt: Date

    init(id: UUID = UUID(), title: String, accentColorHex: String = "3B82F6", createdAt: Date = Date()) {
        self.id = id; self.title = title; self.accentColorHex = accentColorHex; self.createdAt = createdAt
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
