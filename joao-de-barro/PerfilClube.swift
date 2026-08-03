import SwiftUI

struct ClubMember: Identifiable {
    let id = UUID()
    let name: String
    var avatarAsset: String? = nil
}

enum ClubBookStatus {
    case current
    case finished
}

struct ClubBook: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    var coverAsset: String? = nil
    var deadline: String? = nil
    let status: ClubBookStatus
}

struct PerfilClube: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    let members: [ClubMember]
    let books: [ClubBook]

    init(
        members: [ClubMember] = [],
        books: [ClubBook] = []
    ) {
        self.members = members
        self.books = books
    }

    private var currentBook: ClubBook? {
        books.first { $0.status == .current }
    }

    private var previousBooks: [ClubBook] {
        books.filter { $0.status == .finished }
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 0) {
                    header

                    clubTitle
                        .padding(.top, 31)

                    membersRow
                        .padding(.top, 18)

                    currentReading
                        .padding(.top, 48)

                    previousReadings(
                        availableWidth: geometry.size.width
                    )
                    .padding(.top, 22)

                    Spacer(minLength: 28)
                }
                .padding(.horizontal, 52)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.light)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 23))
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 15) {
                Button {
                    // Abrir configurações do clube.
                } label: {
                    Image(systemName: "gearshape")
                }

                Button {
                    // Abrir perfil.
                } label: {
                    Image(systemName: "person")
                }
            }
            .font(.system(size: 23))
        }
        .foregroundStyle(.black)
        .padding(.top, 17)
    }

    // MARK: - Club

    private var clubTitle: some View {
        Text("Nome do seu clube")
            .font(
                .system(
                    size: 30,
                    weight: .medium,
                    design: .serif
                )
            )
            .italic()
            .foregroundStyle(.black)
    }

    private var membersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(members) { member in
                    Group {
                        if let avatarAsset = member.avatarAsset {
                            Image(avatarAsset)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                        }
                    }
                    .frame(width: 38, height: 38)
                    .accessibilityLabel(member.name)
                }

                Button {
                    // Convidar novo membro.
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 21))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Adicionar membro")
            }
        }
        .foregroundStyle(.black)
    }

    // MARK: - Current reading

    private var currentReading: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionTitle("Leitura atual:")

            if let currentBook {
                HStack(alignment: .top, spacing: 22) {
                    Button {
                        if let url = googleBooksURL(for: currentBook) {
                            openURL(url)
                        }
                    } label: {
                        ClubBookCover(
                            book: currentBook,
                            width: 116,
                            height: 152
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Buscar \(currentBook.title) no Google Books")

                    VStack(alignment: .leading, spacing: 6) {
                        Text(currentBook.title)
                            .font(
                                .system(
                                    size: 16,
                                    weight: .bold,
                                    design: .monospaced
                                )
                            )

                        Text(currentBook.author)

                        Spacer(minLength: 24)

                        if let deadline = currentBook.deadline {
                            Text(deadline)
                        }
                    }
                    .font(.system(size: 14, design: .monospaced))
                    .frame(height: 152, alignment: .topLeading)
                }
            } else {
                Button {
                    // Escolher a primeira leitura do clube.
                } label: {
                    BookCoverPlaceholder(
                        title: "",
                        width: 100,
                        height: 130,
                        showsAddButton: true
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Adicionar leitura atual")
            }
        }
    }

    // MARK: - Previous readings

    private func previousReadings(
        availableWidth: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("leituras anteriores:")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(
                        Array(previousBooks.enumerated()),
                        id: \.element.id
                    ) { index, book in
                        PreviousBookSpine(
                            book: book,
                            index: index,
                            angle: index == 2 ? 13 : 0
                        )
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 8)
            }
            .frame(height: 202)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(.black)
                    .frame(height: 4)
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 15, design: .monospaced))
            .tracking(1)
            .foregroundStyle(.black)
    }

    private func googleBooksURL(for book: ClubBook) -> URL? {
        var components = URLComponents(
            string: "https://www.googleapis.com/books/v1/volumes"
        )
        components?.queryItems = [
            URLQueryItem(name: "q", value: "intitle:\(book.title)")
        ]
        return components?.url
    }
}

// MARK: - Book components

private struct BookCoverPlaceholder: View {

    let title: String
    let width: CGFloat
    let height: CGFloat
    var showsAddButton = false

    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.15))
            .frame(width: width, height: height)
            .overlay {
                if showsAddButton {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 19))
                        .foregroundStyle(.black)
                } else {
                    Text(title)
                        .font(.system(size: 11, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.black)
                }
            }
    }
}

private struct PreviousBookSpine: View {

    let book: ClubBook
    let index: Int
    let angle: Double

    private var width: CGFloat { 46 }

    private var height: CGFloat {
        [196, 166, 188][index % 3]
    }

    private var opacity: Double {
        [0.16, 0.12, 0.16][index % 3]
    }

    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(opacity))
            .frame(width: width, height: height)
            .overlay {
                Text(book.title.uppercased())
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.black)
                    .rotationEffect(.degrees(-90))
                    .fixedSize()
            }
            .rotationEffect(
                .degrees(angle),
                anchor: .bottom
            )
    }
}

private struct ClubBookCover: View {

    let book: ClubBook
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Group {
            if let coverAsset = book.coverAsset {
                Image(coverAsset)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                BookCoverPlaceholder(
                    title: "capa do\nlivro",
                    width: width,
                    height: height
                )
            }
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    NavigationStack {
        PerfilClube(
            members: [
                ClubMember(name: "Você"),
                ClubMember(name: "Elisa")
            ],
            books: [
                ClubBook(
                    title: "Título do livro",
                    author: "Autor(a)",
                    deadline: "prazo da leitura",
                    status: .current
                ),
                ClubBook(
                    title: "Livro concluído",
                    author: "Autor(a)",
                    status: .finished
                )
            ]
        )
    }
}
