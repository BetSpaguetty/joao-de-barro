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

struct BookNote: Identifiable {
    let id = UUID()
    let author: String
    let text: String
    let color: Color
    let position: CGPoint
    let size: CGSize
    let rotation: Double
}

// MARK: - Tela principal

struct BookTimelineView: View {

    private let backgroundColor = Color(
        red: 0.84,
        green: 0.83,
        blue: 0.72
    )

    @State private var currentPageIndex = 0
    @State private var notesByPage: [Int: [BookNote]] = [:]
    @State private var isShowingNoteComposer = false
    @State private var draftNoteText = ""

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let scale = min(size.width / 804, size.height / 1748)
            let horizontalInset = (size.width - 804 * scale) / 2
            let verticalInset = (size.height - 1748 * scale) / 2

            ZStack(alignment: .topLeading) {
                backgroundColor
                    .ignoresSafeArea()

                Group {
                    HeaderView()
                        .frame(width: 804, height: 250)
                        .position(x: 402, y: 127)

                    ReadingTimeline()
                        .frame(width: 710, height: 84)
                        .position(x: 412, y: 304)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Devorador de estrelas")
                            .font(.system(size: 48, weight: .regular))

                        Text("prazo: 30/07")
                            .font(.system(size: 35, weight: .regular))
                    }
                    .foregroundStyle(.black)
                    .frame(width: 650, alignment: .leading)
                    .position(x: 401, y: 434)

                    BookOutlineView(
                        currentPageIndex: $currentPageIndex,
                        notes: notesByPage[currentPageIndex, default: []]
                    )
                        .frame(width: 750, height: 944)
                        .position(x: 430, y: 1000)

                    BottomBarView(
                        onAddNote: openNoteComposer
                    )
                        .frame(width: 804, height: 245)
                        .position(x: 402, y: 1627)
                }
                .scaleEffect(scale, anchor: .topLeading)
                .offset(x: horizontalInset, y: verticalInset)
            }
        }
        .sheet(isPresented: $isShowingNoteComposer) {
            NoteComposerView(
                text: $draftNoteText,
                onCancel: closeNoteComposer,
                onSave: saveDraftNote
            )
        }
    }

    private func openNoteComposer() {
        draftNoteText = ""
        isShowingNoteComposer = true
    }

    private func closeNoteComposer() {
        draftNoteText = ""
        isShowingNoteComposer = false
    }

    private func saveDraftNote() {
        let trimmedText = draftNoteText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            return
        }

        addNoteToCurrentPage(text: trimmedText)
        closeNoteComposer()
    }

    private func addNoteToCurrentPage(text: String) {
        let count = notesByPage[currentPageIndex, default: []].count
        var pageNotes = notesByPage[currentPageIndex, default: []]
        pageNotes.append(makeNote(index: count, text: text))
        notesByPage[currentPageIndex] = pageNotes
    }

    private func makeNote(index: Int, text: String) -> BookNote {
        let colors = [
            Color(red: 0.92, green: 0.32, blue: 0.34),
            Color(red: 0.99, green: 0.66, blue: 0.32),
            Color(red: 0.99, green: 0.84, blue: 0.35),
            Color(red: 0.30, green: 0.47, blue: 0.52)
        ]

        let positions = [
            CGPoint(x: 525, y: 320),
            CGPoint(x: 405, y: 515),
            CGPoint(x: 515, y: 710),
            CGPoint(x: 250, y: 720)
        ]

        let sizes = [
            CGSize(width: 240, height: 260),
            CGSize(width: 140, height: 130),
            CGSize(width: 240, height: 260),
            CGSize(width: 245, height: 270)
        ]

        let templateIndex = index % colors.count

        return BookNote(
            author: "Você",
            text: "Você:\n\(text)",
            color: colors[templateIndex],
            position: positions[templateIndex],
            size: sizes[templateIndex],
            rotation: [-1.5, 0.8, -0.6, 1.2][templateIndex]
        )
    }
}

struct NoteComposerView: View {

    @Binding var text: String
    let onCancel: () -> Void
    let onSave: () -> Void

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                TextEditor(text: $text)
                    .font(.system(size: 22))
                    .padding(12)
                    .frame(minHeight: 220)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.94, green: 0.92, blue: 0.80))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.black, lineWidth: 2)
                    }

                Spacer()
            }
            .padding(24)
            .background(Color(red: 0.84, green: 0.83, blue: 0.72))
            .navigationTitle("Nova nota")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", action: onCancel)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar", action: onSave)
                        .disabled(!canSave)
                }
            }
        }
    }
}

// MARK: - Header

struct HeaderView: View {

    var body: some View {
        ZStack {
            AvatarIcon()
                .stroke(.black, lineWidth: 4)
                .frame(width: 85, height: 85)
                .position(x: 99, y: 178)

            Text("logo")
                .font(.system(size: 48, weight: .regular))
                .foregroundStyle(.black)
                .position(x: 402, y: 178)
        }
    }
}

struct AvatarIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))

        path.addEllipse(in: CGRect(
            x: rect.midX - rect.width * 0.13,
            y: rect.minY + rect.height * 0.21,
            width: rect.width * 0.26,
            height: rect.width * 0.26
        ))

        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY + rect.height * 0.17),
            radius: rect.width * 0.43,
            startAngle: .degrees(222),
            endAngle: .degrees(318),
            clockwise: false
        )

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.20, y: rect.maxY * 0.87))
        path.addLine(to: CGPoint(x: rect.midX - rect.width * 0.19, y: rect.midY + rect.height * 0.18))

        path.move(to: CGPoint(x: rect.maxX - rect.width * 0.20, y: rect.maxY * 0.87))
        path.addLine(to: CGPoint(x: rect.midX + rect.width * 0.19, y: rect.midY + rect.height * 0.18))

        return path
    }
}

// MARK: - Timeline superior

struct ReadingTimeline: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(.black)
                .frame(width: 626, height: 2)
                .position(x: 355, y: 48)

            Circle()
                .fill(.black)
                .frame(width: 13, height: 13)
                .position(x: 33, y: 48)

            Circle()
                .fill(.black)
                .frame(width: 24, height: 24)
                .position(x: 52, y: 48)

            Circle()
                .fill(.black)
                .frame(width: 11, height: 11)
                .position(x: 677, y: 48)

            Text("Pág 1")
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(.black)
                .position(x: 35, y: 17)

            Text("Pág 424")
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(.black)
                .position(x: 675, y: 17)

            TimelineAvatarMarker()
                .frame(width: 40, height: 62)
                .position(x: 243, y: 36)

            Circle()
                .fill(Color(red: 0.54, green: 0.66, blue: 0.62).opacity(0.55))
                .frame(width: 78, height: 78)
                .position(x: 327, y: 48)

            Circle()
                .fill(.black.opacity(0.07))
                .frame(width: 37, height: 37)
                .position(x: 462, y: 48)

            Circle()
                .fill(.black.opacity(0.07))
                .frame(width: 47, height: 47)
                .position(x: 499, y: 48)

            Circle()
                .fill(Color(red: 0.54, green: 0.66, blue: 0.62).opacity(0.55))
                .frame(width: 27, height: 27)
                .position(x: 572, y: 48)
        }
    }
}

struct TimelineAvatarMarker: View {
    var body: some View {
        VStack(spacing: 0) {
            AvatarIcon()
                .stroke(.black, lineWidth: 2)
                .frame(width: 29, height: 29)

            Rectangle()
                .fill(.black)
                .frame(width: 2, height: 22)

            Triangle()
                .fill(.black)
                .frame(width: 11, height: 11)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Livro

struct BookOutlineView: View {

    @Binding var currentPageIndex: Int
    let notes: [BookNote]

    private let leftPageRect = CGRect(x: 55, y: 0, width: 675, height: 944)
    private let visibleRightPageWidth: CGFloat = 104
    private let pageTexts = [
        "Não há comentários\nnessa sessão",
        "Página 2",
        "Página 3"
    ]
    private let pageColor = Color(
        red: 0.84,
        green: 0.83,
        blue: 0.72
    )

    @State private var curlProgress: CGFloat = 0

    var body: some View {
        ZStack(alignment: .topLeading) {
            BookLeftPageShape()
                .stroke(.black, lineWidth: 2)
                .frame(width: leftPageRect.width, height: leftPageRect.height)
                .position(x: leftPageRect.midX, y: leftPageRect.midY)

            if notes.isEmpty {
                BookPageText(text: pageTexts[currentPageIndex])
                    .position(x: 335, y: 762)
            } else {
                ForEach(notes) { note in
                    CollageNoteView(note: note)
                        .frame(width: note.size.width, height: note.size.height)
                        .rotationEffect(.degrees(note.rotation))
                        .position(note.position)
                }
            }

            RightPageShape()
                .fill(pageColor)
                .frame(width: visibleRightPageWidth, height: leftPageRect.height)
                .position(
                    x: leftPageRect.maxX + visibleRightPageWidth / 2,
                    y: leftPageRect.midY
                )

            RightPageShape()
                .stroke(.black, lineWidth: 2)
                .frame(width: visibleRightPageWidth, height: leftPageRect.height)
                .position(
                    x: leftPageRect.maxX + visibleRightPageWidth / 2,
                    y: leftPageRect.midY
                )

            if curlProgress > 0 {
                BookPageText(text: pageTexts[nextPageIndex])
                    .position(x: 335, y: 762)

                CurlingPageView(
                    pageColor: pageColor,
                    progress: curlProgress
                )
                .frame(
                    width: max(leftPageRect.width * curlProgress, 1),
                    height: leftPageRect.height
                )
                .position(
                    x: leftPageRect.maxX - (leftPageRect.width * curlProgress / 2),
                    y: leftPageRect.midY
                )
            }

            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .frame(
                    width: visibleRightPageWidth + 80,
                    height: leftPageRect.height
                )
                .position(
                    x: leftPageRect.maxX + visibleRightPageWidth / 2,
                    y: leftPageRect.midY
                )
                .gesture(pageTurnGesture)
                .onTapGesture {
                    turnPage()
                }
        }
    }

    private var nextPageIndex: Int {
        min(currentPageIndex + 1, pageTexts.count - 1)
    }

    private var pageTurnGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                let movement = max(-value.translation.width, 0)
                curlProgress = min(movement / leftPageRect.width, 1)
            }
            .onEnded { _ in
                if curlProgress > 0.28 {
                    turnPage()
                } else {
                    withAnimation(.easeOut(duration: 0.18)) {
                        curlProgress = 0
                    }
                }
            }
    }

    private func turnPage() {
        guard currentPageIndex < pageTexts.count - 1 else {
            withAnimation(.easeOut(duration: 0.18)) {
                curlProgress = 0
            }
            return
        }

        withAnimation(.easeInOut(duration: 0.34)) {
            curlProgress = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
            currentPageIndex = nextPageIndex

            withAnimation(.easeOut(duration: 0.01)) {
                curlProgress = 0
            }
        }
    }
}

struct BookPageText: View {

    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 32, weight: .regular))
            .foregroundStyle(.black)
            .lineSpacing(6)
            .frame(width: 420, alignment: .leading)
    }
}

struct CollageNoteView: View {

    let note: BookNote

    var body: some View {
        ZStack(alignment: .topLeading) {
            StickyNoteShape()
                .fill(note.color)

            Text(note.text)
                .font(.system(size: 21, weight: .regular))
                .foregroundStyle(.black)
                .lineSpacing(2)
                .padding(.top, 30)
                .padding(.leading, 45)
                .padding(.trailing, 22)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            CommentPinShape()
                .fill(.black)
                .frame(width: 42, height: 50)
                .position(x: note.size.width - 22, y: 14)
        }
        .clipped()
    }
}

struct StickyNoteShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.02, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.04, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.height * 0.35),
            control2: CGPoint(x: rect.maxX - rect.width * 0.02, y: rect.height * 0.72)
        )
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.02, y: rect.minY),
            control1: CGPoint(x: rect.minX + rect.width * 0.04, y: rect.maxY - rect.height * 0.18),
            control2: CGPoint(x: rect.minX + rect.width * 0.04, y: rect.height * 0.30)
        )
        path.closeSubpath()

        return path
    }
}

struct CommentPinShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let circleRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width * 0.86,
            height: rect.width * 0.72
        )

        path.addRoundedRect(
            in: circleRect,
            cornerSize: CGSize(width: rect.width * 0.28, height: rect.width * 0.28)
        )
        path.move(to: CGPoint(x: circleRect.maxX - rect.width * 0.15, y: circleRect.maxY - 2))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.42, y: rect.maxY),
            control1: CGPoint(x: circleRect.maxX - rect.width * 0.08, y: rect.maxY - rect.height * 0.20),
            control2: CGPoint(x: rect.minX + rect.width * 0.52, y: rect.maxY - rect.height * 0.02)
        )
        path.addCurve(
            to: CGPoint(x: circleRect.maxX - rect.width * 0.28, y: circleRect.maxY - 1),
            control1: CGPoint(x: rect.minX + rect.width * 0.58, y: rect.maxY - rect.height * 0.20),
            control2: CGPoint(x: circleRect.maxX - rect.width * 0.26, y: circleRect.maxY - rect.height * 0.10)
        )

        return path
    }
}

struct CurlingPageView: View {

    let pageColor: Color
    let progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let curve = min(width * 0.28, 95)

            ZStack(alignment: .leading) {
                Path { path in
                    path.move(to: CGPoint(x: width, y: 92))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addCurve(
                        to: CGPoint(x: 0, y: height - 39),
                        control1: CGPoint(x: width - 215 * progress, y: height - 58),
                        control2: CGPoint(x: curve, y: height - 64)
                    )
                    path.addLine(to: CGPoint(x: 0, y: 7))
                    path.addCurve(
                        to: CGPoint(x: width, y: 92),
                        control1: CGPoint(x: curve, y: -34),
                        control2: CGPoint(x: width - 136 * progress, y: 38)
                    )
                    path.closeSubpath()
                }
                .fill(pageColor)
                .shadow(color: .black.opacity(0.24), radius: 10, x: -8, y: 0)

                Path { path in
                    path.move(to: CGPoint(x: 0, y: 7))
                    path.addCurve(
                        to: CGPoint(x: min(curve * 0.9, width), y: height - 36),
                        control1: CGPoint(x: curve * 0.36, y: height * 0.20),
                        control2: CGPoint(x: -curve * 0.12, y: height * 0.70)
                    )
                    path.addLine(to: CGPoint(x: 0, y: height - 39))
                    path.closeSubpath()
                }
                .fill(pageColor)

                Path { path in
                    path.move(to: CGPoint(x: max(curve * 0.35, 1), y: 20))
                    path.addCurve(
                        to: CGPoint(x: max(curve * 0.12, 1), y: height - 42),
                        control1: CGPoint(x: -curve * 0.28, y: height * 0.30),
                        control2: CGPoint(x: curve * 0.24, y: height * 0.72)
                    )
                }
                .stroke(
                    .black.opacity(0.24),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )

                Rectangle()
                    .fill(pageColor)
                    .frame(width: min(width * 0.22, 72))
                    .position(x: min(width * 0.11, 36), y: height / 2)
            }
            .overlay {
                Path { path in
                    path.move(to: CGPoint(x: width, y: 92))
                    path.addLine(to: CGPoint(x: width, y: height))
                }
                .stroke(.black, lineWidth: 2)
            }
        }
    }
}

struct BookLeftPageShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 7))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + 92),
            control1: CGPoint(x: rect.minX + 184, y: rect.minY - 36),
            control2: CGPoint(x: rect.maxX - 136, y: rect.minY + 38)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 1))
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - 39),
            control1: CGPoint(x: rect.maxX - 215, y: rect.maxY - 58),
            control2: CGPoint(x: rect.minX + 176, y: rect.maxY - 64)
        )
        path.closeSubpath()

        return path
    }
}

struct RightPageShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 92))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 70))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 21))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

// MARK: - Navegação

struct BottomBarView: View {

    let onAddNote: () -> Void

    var body: some View {
        ZStack {
            RibbonButton()
                .stroke(.black, lineWidth: 2)
                .frame(width: 135, height: 242)
                .position(x: 122, y: 126)

            OpenBookIcon()
                .stroke(.black, lineWidth: 5)
                .frame(width: 76, height: 60)
                .position(x: 124, y: 142)

            Rectangle()
                .stroke(.black, lineWidth: 2)
                .frame(width: 116, height: 177)
                .position(x: 280, y: 159)

            ChatIcon()
                .stroke(.black, lineWidth: 4)
                .frame(width: 82, height: 66)
                .position(x: 283, y: 163)

            Button(action: onAddNote) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.50, green: 0.68, blue: 0.66))
                        .frame(width: 178, height: 178)

                    FeatherIcon()
                        .stroke(
                            .black,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: 78, height: 116)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 178, height: 178)
                .position(x: 665, y: 152)
        }
    }
}

struct RibbonButton: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.12))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct OpenBookIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.1))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.28))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.1))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.18))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.28))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.18))
        return path
    }
}

struct ChatIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bubble = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: rect.height * 0.78
        )

        path.addRoundedRect(
            in: bubble,
            cornerSize: CGSize(width: 8, height: 8)
        )
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.23, y: bubble.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.38, y: bubble.maxY))

        return path
    }
}

struct FeatherIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.85, y: rect.minY + rect.height * 0.03),
            control1: CGPoint(x: rect.minX + rect.width * 0.24, y: rect.midY),
            control2: CGPoint(x: rect.minX + rect.width * 0.54, y: rect.minY + rect.height * 0.08)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.26, y: rect.minY + rect.height * 0.58),
            control1: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.30),
            control2: CGPoint(x: rect.minX + rect.width * 0.64, y: rect.minY + rect.height * 0.53)
        )

        let ribs: [(CGFloat, CGFloat)] = [
            (0.44, 0.44),
            (0.49, 0.33),
            (0.55, 0.24),
            (0.61, 0.15),
            (0.67, 0.08),
            (0.72, 0.04)
        ]

        for rib in ribs {
            let base = CGPoint(
                x: rect.minX + rect.width * 0.30,
                y: rect.minY + rect.height * rib.0
            )
            let tip = CGPoint(
                x: rect.minX + rect.width * 0.88,
                y: rect.minY + rect.height * rib.1
            )
            path.move(to: base)
            path.addLine(to: tip)
        }

        for rib in ribs {
            let base = CGPoint(
                x: rect.minX + rect.width * 0.34,
                y: rect.minY + rect.height * (rib.0 + 0.03)
            )
            let tip = CGPoint(
                x: rect.minX + rect.width * 0.12,
                y: rect.minY + rect.height * (rib.1 + 0.36)
            )
            path.move(to: base)
            path.addLine(to: tip)
        }

        return path
    }
}

#Preview {
    BookTimelineView()
}
