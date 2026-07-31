//
//  BookDiscussionSampleData.swift
//  joao-de-barro
//
//  Created by Ilan Cukierman on 28/07/26.
//

import SwiftUI

extension BookDiscussionSection {

    static let sampleData: [BookDiscussionSection] = [
        BookDiscussionSection(
            page: 32,
            comments: [
                BookDiscussionComment(
                    author: "Dani",
                    text: """
                    Essa parte me deixou muito curiosa sobre o que vai acontecer.
                    """,
                    color: Color(
                        red: 0.30,
                        green: 0.47,
                        blue: 0.52
                    ),
                    replies: [
                        BookChatReply(
                            author: "Ceci",
                            text: "Também fiquei curiosa!",
                            isCurrentUser: false
                        )
                    ]
                )
            ]
        ),

        BookDiscussionSection(
            page: 78,
            comments: [
                BookDiscussionComment(
                    author: "Diogo",
                    text: """
                    Se alguma coisa acontecer com o Rocky eu não respondo por mim!
                    """,
                    color: Color(
                        red: 0.96,
                        green: 0.63,
                        blue: 0.32
                    ),
                    replies: [
                        BookChatReply(
                            author: "Dani",
                            text: "Eu também estou muito preocupada!",
                            isCurrentUser: false
                        ),
                        BookChatReply(
                            author: "Você",
                            text: "Acho que ele vai conseguir escapar.",
                            isCurrentUser: true
                        )
                    ]
                ),

                BookDiscussionComment(
                    author: "Dani",
                    text: """
                    Essa parte me deixou muito nervosa. Parece que algo ruim vai acontecer.
                    """,
                    color: Color(
                        red: 0.30,
                        green: 0.47,
                        blue: 0.52
                    ),
                    replies: []
                ),

                BookDiscussionComment(
                    author: "Ceci",
                    text: """
                    Talvez essa situação seja importante para o desenvolvimento dele.
                    """,
                    color: Color(
                        red: 0.98,
                        green: 0.82,
                        blue: 0.31
                    ),
                    replies: []
                )
            ]
        ),

        BookDiscussionSection(
            page: 196,
            comments: [
                BookDiscussionComment(
                    author: "Georgia",
                    text: """
                    Sempre que eu leio ficção científica fico pensando como nossa ideia de vida fora da Terra é limitada...
                    """,
                    color: Color(
                        red: 0.50,
                        green: 0.68,
                        blue: 0.66
                    ),
                    replies: [
                        BookChatReply(
                            author: "Carina",
                            text: """
                            A gente sempre imagina vida parecida com a nossa.
                            """,
                            isCurrentUser: false
                        )
                    ]
                ),

                BookDiscussionComment(
                    author: "Carina",
                    text: """
                    Chorei muito, mas estou esperançosa com o que vai acontecer.
                    """,
                    color: Color(
                        red: 0.93,
                        green: 0.33,
                        blue: 0.35
                    ),
                    replies: []
                ),

                BookDiscussionComment(
                    author: "Diogo",
                    text: """
                    Essa foi uma das partes mais interessantes do livro até agora.
                    """,
                    color: Color(
                        red: 0.96,
                        green: 0.63,
                        blue: 0.32
                    ),
                    replies: []
                ),

                BookDiscussionComment(
                    author: "Dani",
                    text: """
                    A história está mostrando que o universo é muito maior do que imaginamos.
                    """,
                    color: Color(
                        red: 0.30,
                        green: 0.47,
                        blue: 0.52
                    ),
                    replies: []
                )
            ]
        ),

        BookDiscussionSection(
            page: 310,
            comments: [
                BookDiscussionComment(
                    author: "Ceci",
                    text: """
                    Eu não esperava por essa revelação. Agora várias partes anteriores fazem sentido.
                    """,
                    color: Color(
                        red: 0.98,
                        green: 0.82,
                        blue: 0.31
                    ),
                    replies: []
                )
            ]
        )
    ]
}
