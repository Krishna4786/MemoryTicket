import Foundation
import SwiftUI
import Combine
import UIKit

class TicketStore: ObservableObject {
    @Published var tickets: [MemoryTicket] = []
    @Published var books: [MemoryBook] = []

    private let ticketsFile = "memory_tickets.json"
    private let booksFile = "memory_books.json"

    init() {
        loadTickets()
        loadBooks()
    }

    // MARK: - Tickets

    func addTicket(_ ticket: MemoryTicket) {
        tickets.insert(ticket, at: 0)
        saveTickets()
    }

    func deleteTicket(_ ticket: MemoryTicket) {
        tickets.removeAll { $0.id == ticket.id }
        if let fn = ticket.imageFileName { deleteImage(fileName: fn) }
        saveTickets()
    }

    var recentTickets: [MemoryTicket] { Array(tickets.prefix(10)) }

    var streakCount: Int {
        guard !tickets.isEmpty else { return 0 }
        let cal = Calendar.current
        var streak = 0
        var day = Date()
        while tickets.contains(where: { cal.isDate($0.createdAt, inSameDayAs: day) }) {
            streak += 1
            day = cal.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return streak
    }

    // MARK: - Books

    func addBook(_ book: MemoryBook) {
        books.insert(book, at: 0)
        saveBooks()
    }

    // MARK: - Image I/O

    func saveImage(_ image: UIImage, fileName: String) {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        try? data.write(to: docsURL(fileName))
    }

    func loadImage(fileName: String) -> UIImage? {
        guard let data = try? Data(contentsOf: docsURL(fileName)) else { return nil }
        return UIImage(data: data)
    }

    func deleteImage(fileName: String) {
        try? FileManager.default.removeItem(at: docsURL(fileName))
    }

    // MARK: - Persistence

    private func saveTickets() {
        if let d = try? JSONEncoder().encode(tickets) { try? d.write(to: docsURL(ticketsFile)) }
    }
    private func loadTickets() {
        if let d = try? Data(contentsOf: docsURL(ticketsFile)),
           let t = try? JSONDecoder().decode([MemoryTicket].self, from: d) { tickets = t }
    }
    private func saveBooks() {
        if let d = try? JSONEncoder().encode(books) { try? d.write(to: docsURL(booksFile)) }
    }
    private func loadBooks() {
        if let d = try? Data(contentsOf: docsURL(booksFile)),
           let b = try? JSONDecoder().decode([MemoryBook].self, from: d) { books = b }
    }
    private func docsURL(_ name: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(name)
    }
}
