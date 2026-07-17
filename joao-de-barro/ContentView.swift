//
//  ContentView.swift
//  testePagina
//
//  Created by Ilan Cukierman on 17/07/26.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        PageCurlView(
            pages: [
                AnyView(
                    BookPage(
                        pageNumber: 1,
                        title: "Capítulo 1",
                        text: "Esta é a primeira página."
                    )
                ),

                AnyView(
                    BookPage(
                        pageNumber: 2,
                        title: "Capítulo 2",
                        text: "Agora você virou a página!"
                    )
                ),

                AnyView(
                    BookPage(
                        pageNumber: 3,
                        title: "Capítulo 3",
                        text: "Fim do teste."
                    )
                )
            ]
        )
        .ignoresSafeArea()
    }
}

struct BookPage: View {

    let pageNumber: Int
    let title: String
    let text: String

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.93, blue: 0.85)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 30) {

                Text(title)
                    .font(.largeTitle)
                    .bold()

                Text(text)
                    .font(.title2)

                Spacer()

                Text("\(pageNumber)")
                    .frame(maxWidth: .infinity)
            }
            .padding(40)
        }
    }
}

#Preview {
    ContentView()
}
