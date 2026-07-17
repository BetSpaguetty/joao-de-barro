import SwiftUI

// MARK: - Modelo

struct TimelineComment: Identifiable {

    let id = UUID()
    let author: String
    let text: String
    let page: Int
    let color: Color

    // Posição horizontal dentro do livro
    let xPosition: CGFloat

    // Altura da parte com texto
    let cardHeight: CGFloat
}

// MARK: - Tela principal

struct BookTimelineView: View {

    private let backgroundColor = Color(
        red: 0.88,
        green: 0.87,
        blue: 0.76
    )
    //oieee

    // Largura total da área explorável
    private let contentWidth: CGFloat = 2000

    // Posição atual do scroll
    @State private var scrollOffset: CGFloat = 0

    private let comments: [TimelineComment] = [
        TimelineComment(
            author: "Cecília",
            text: "Nasci em uma cidade pequena e esse trecho me lembrou bastante...",
            page: 12,
            color: Color(
                red: 0.97,
                green: 0.34,
                blue: 0.38
            ),
            xPosition: 220,
            cardHeight: 165
        ),

        TimelineComment(
            author: "Lucas",
            text: "Achei interessante a decisão que o personagem tomou.",
            page: 25,
            color: Color(
                red: 1.00,
                green: 0.80,
                blue: 0.28
            ),
            xPosition: 390,
            cardHeight: 145
        ),

        TimelineComment(
            author: "Marina",
            text: "Essa parte mudou completamente a minha interpretação.",
            page: 39,
            color: Color(
                red: 0.32,
                green: 0.53,
                blue: 0.59
            ),
            xPosition: 650,
            cardHeight: 180
        ),

        TimelineComment(
            author: "Pedro",
            text: "Talvez exista uma pista importante escondida aqui.",
            page: 58,
            color: Color(
                red: 0.96,
                green: 0.61,
                blue: 0.29
            ),
            xPosition: 930,
            cardHeight: 155
        ),

        TimelineComment(
            author: "Ana",
            text: "Foi uma das partes que mais gostei até agora.",
            page: 76,
            color: Color(
                red: 0.48,
                green: 0.70,
                blue: 0.68
            ),
            xPosition: 1210,
            cardHeight: 190
        ),

        TimelineComment(
            author: "João",
            text: "Agora comecei a entender melhor o personagem.",
            page: 94,
            color: Color(
                red: 0.62,
                green: 0.48,
                blue: 0.70
            ),
            xPosition: 1500,
            cardHeight: 165
        ),

        TimelineComment(
            author: "Clara",
            text: "Essa frase se conecta bastante com o começo do livro.",
            page: 112,
            color: Color(
                red: 0.91,
                green: 0.48,
                blue: 0.61
            ),
            xPosition: 1780,
            cardHeight: 180
        )
    ]

    var body: some View {
        GeometryReader { geometry in

            let screenWidth = geometry.size.width

            VStack(spacing: 0) {

                Text("logo")
                    .font(.system(size: 17))
                    .foregroundStyle(.black)
                    .padding(.top, 24)
                    .padding(.bottom, 8)

                TimelineIndicator(
                    scrollOffset: scrollOffset,
                    screenWidth: screenWidth,
                    contentWidth: contentWidth,
                    commentCounts: commentCounts
                )
                .padding(.horizontal, 30)

                Spacer()

                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {
                    ZStack(alignment: .topLeading) {

                        SevenLineBook(
                            width: contentWidth
                        )

                        ForEach(comments) { comment in
                            CommentBookmark(comment: comment)
                                .position(
                                    x: comment.xPosition,
                                    y: markerY(for: comment)
                                )
                        }
                    }
                    .frame(
                        width: contentWidth,
                        height: 600
                    )
                }
                .onScrollGeometryChange(
                    for: CGFloat.self,
                    of: { scrollGeometry in
                        scrollGeometry.contentOffset.x
                    },
                    action: { _, newOffset in
                        scrollOffset = max(0, newOffset)
                    }
                )
            }
            .background(backgroundColor)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // Pequenas diferenças de altura entre os marcadores
    private func markerY(
        for comment: TimelineComment
    ) -> CGFloat {

        let positions: [CGFloat] = [
            275,
            290,
            260,
            282
        ]

        let index = comment.page % positions.count

        return positions[index]
    }

    // Divide o livro em sete partes
    // e conta os comentários de cada região
    private var commentCounts: [Int] {

        let sections = 7

        return (0..<sections).map { section in

            let start =
                CGFloat(section) /
                CGFloat(sections)

            let end =
                CGFloat(section + 1) /
                CGFloat(sections)

            return comments.filter { comment in

                let normalizedPosition =
                    comment.xPosition /
                    contentWidth

                return normalizedPosition >= start &&
                       normalizedPosition < end
            }
            .count
        }
    }
}

// MARK: - Livro feito com sete linhas

struct SevenLineBook: View {

    let width: CGFloat

    private let startX: CGFloat = 75
    private let curveEndX: CGFloat = 190

    private let topY: CGFloat = 355
    private let curveEndY: CGFloat = 410

    private let lineSpacing: CGFloat = 13

    var body: some View {
        ZStack(alignment: .topLeading) {

            // Primeira linha com a curva do começo do livro
            Path { path in

                path.move(
                    to: CGPoint(
                        x: startX,
                        y: topY
                    )
                )

                path.addCurve(
                    to: CGPoint(
                        x: curveEndX,
                        y: curveEndY
                    ),
                    control1: CGPoint(
                        x: 105,
                        y: 390
                    ),
                    control2: CGPoint(
                        x: 150,
                        y: 410
                    )
                )

                path.addLine(
                    to: CGPoint(
                        x: width - 40,
                        y: 240
                    )
                )
            }
            .stroke(
                .black,
                style: StrokeStyle(
                    lineWidth: 3.5,
                    lineCap: .round,
                    lineJoin: .round
                )
            )

            // Outras seis linhas
            ForEach(1..<7, id: \.self) { index in

                Path { path in

                    let offset =
                        CGFloat(index) *
                        lineSpacing

                    path.move(
                        to: CGPoint(
                            x: curveEndX,
                            y: curveEndY + offset
                        )
                    )

                    path.addLine(
                        to: CGPoint(
                            x: width - 40,
                            y: 240 + offset
                        )
                    )
                }
                .stroke(
                    .black.opacity(0.48),
                    style: StrokeStyle(
                        lineWidth: 1.4,
                        lineCap: .round
                    )
                )
            }

            // Pequena linha vertical indicando o começo/lombada
            Path { path in

                path.move(
                    to: CGPoint(
                        x: curveEndX,
                        y: curveEndY
                    )
                )

                path.addCurve(
                    to: CGPoint(
                        x: curveEndX,
                        y: 555
                    ),
                    control1: CGPoint(
                        x: 202,
                        y: 455
                    ),
                    control2: CGPoint(
                        x: 202,
                        y: 515
                    )
                )
            }
            .stroke(
                .black,
                style: StrokeStyle(
                    lineWidth: 3,
                    lineCap: .round
                )
            )
        }
    }
}

// MARK: - Marcadores

struct CommentBookmark: View {

    let comment: TimelineComment

    @State private var isExpanded = false

    var body: some View {
        Button {
            withAnimation(
                .spring(
                    response: 0.35,
                    dampingFraction: 0.78
                )
            ) {
                isExpanded.toggle()
            }
        } label: {

            VStack(spacing: 0) {

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text("\(comment.author.lowercased()):")
                        .font(
                            .system(
                                size: isExpanded ? 13 : 11,
                                weight: .semibold
                            )
                        )

                    Text(comment.text)
                        .font(
                            .system(
                                size: isExpanded ? 12 : 10
                            )
                        )
                        .multilineTextAlignment(.leading)
                        .lineLimit(
                            isExpanded ? 10 : 7
                        )

                    if isExpanded {
                        Text("Página \(comment.page)")
                            .font(.system(size: 9))
                            .opacity(0.6)
                    }
                }
                .foregroundStyle(.black)
                .padding(10)
                .frame(
                    width: isExpanded ? 145 : 105,
                    height: isExpanded
                        ? comment.cardHeight + 35
                        : comment.cardHeight,
                    alignment: .topLeading
                )
                .background(comment.color)

                // Parte inserida entre as páginas
                Rectangle()
                    .fill(comment.color)
                    .frame(
                        width: isExpanded ? 95 : 78,
                        height: 80
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Timeline superior

struct TimelineIndicator: View {

    let scrollOffset: CGFloat
    let screenWidth: CGFloat
    let contentWidth: CGFloat
    let commentCounts: [Int]

    private var maximumScroll: CGFloat {
        max(
            contentWidth - screenWidth,
            1
        )
    }

    private var progress: CGFloat {
        min(
            max(
                scrollOffset / maximumScroll,
                0
            ),
            1
        )
    }

    var body: some View {
        GeometryReader { geometry in

            let timelineWidth =
                geometry.size.width

            let blackDotSize: CGFloat = 9

            let availableWidth =
                timelineWidth -
                blackDotSize

            let blackDotPosition =
                progress *
                availableWidth

            ZStack(alignment: .leading) {

                Rectangle()
                    .fill(.black.opacity(0.7))
                    .frame(height: 1.5)

                // Bolhas que representam os comentários
                HStack(spacing: 0) {

                    ForEach(
                        Array(
                            commentCounts.enumerated()
                        ),
                        id: \.offset
                    ) { index, count in

                        Circle()
                            .fill(
                                .black.opacity(
                                    bubbleOpacity(
                                        for: count
                                    )
                                )
                            )
                            .frame(
                                width: bubbleSize(
                                    for: count
                                ),
                                height: bubbleSize(
                                    for: count
                                )
                            )

                        if index <
                            commentCounts.count - 1 {

                            Spacer()
                        }
                    }
                }

                // Bolinha preta que acompanha o scroll
                Circle()
                    .fill(.black)
                    .frame(
                        width: blackDotSize,
                        height: blackDotSize
                    )
                    .offset(
                        x: blackDotPosition
                    )
            }
        }
        .frame(height: 48)
    }

    private func bubbleSize(
        for count: Int
    ) -> CGFloat {

        switch count {
        case 0:
            return 7

        case 1:
            return 18

        case 2:
            return 28

        case 3:
            return 37

        default:
            return 44
        }
    }

    private func bubbleOpacity(
        for count: Int
    ) -> Double {

        switch count {
        case 0:
            return 0.06

        case 1:
            return 0.14

        case 2:
            return 0.20

        case 3:
            return 0.26

        default:
            return 0.32
        }
    }
}

#Preview {
    BookTimelineView()
}
