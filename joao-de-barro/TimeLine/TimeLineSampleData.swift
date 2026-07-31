//
//  TimeLineSampleData.swift
//  joao-de-barro
//
//  Created by Ilan Cukierman on 30/07/26.
//

import SwiftUI

enum TimeLineSampleData {

    static let comments: [BookDiscussionComment] = [
        BookDiscussionComment(
            author: "Elisa",
            text: """
            Cara, ainda não entendi qual a razão desse ranço todo que o Raphael coloca nos personagens em relação à sexualidade alheia. Até agora não teve um com uma reação decente ao fato do Zak ser gay (ou bi, sei lá)...
            """,
            color: .white,
            replies: [
                BookChatReply(
                    author: "Cecília",
                    text: """
                    Eu também percebi isso. Talvez o autor esteja preparando alguma mudança no personagem.
                    """,
                    isCurrentUser: false
                ),
                BookChatReply(
                    author: "Você",
                    text: """
                    Espero que isso seja desenvolvido melhor nos próximos capítulos.
                    """,
                    isCurrentUser: true
                )
            ]
        ),

        BookDiscussionComment(
            author: "Cecília",
            text: """
            “Ninguém morre vazio de sonhos. O morto é enterrado com seus projetos, seus desejos, tudo...”
            """,
            color: .white,
            replies: [
                BookChatReply(
                    author: "Elisa",
                    text: """
                    Essa frase foi uma das partes mais marcantes do capítulo.
                    """,
                    isCurrentUser: false
                )
            ]
        ),

        BookDiscussionComment(
            author: "Rafael",
            text: """
            Essa revelação mudou completamente a forma como eu estava enxergando o personagem. Agora várias atitudes anteriores começaram a fazer sentido.
            """,
            color: .white,
            replies: []
        )
    ]
}
