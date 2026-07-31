//
//  BookDiscussionModels.swift
//  joao-de-barro
//
//  Created by Ilan Cukierman on 28/07/26.
//

import SwiftUI

struct BookChatReply: Identifiable {
    let id = UUID()
    let author: String
    let text: String
    let isCurrentUser: Bool
}

struct BookDiscussionComment: Identifiable {
    let id = UUID()
    let author: String
    let text: String
    let color: Color
    var replies: [BookChatReply]
}

struct BookDiscussionSection: Identifiable {
    let id = UUID()
    let page: Int
    var comments: [BookDiscussionComment]
}

enum BookDiscussionColors {
    static let background = Color(
        red: 0.84,
        green: 0.83,
        blue: 0.72
    )

    static let accent = Color(
        red: 0.57,
        green: 0.72,
        blue: 0.70
    )
}
