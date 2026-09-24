import SwiftUI

/// Renders a String written in a small SwiftUI-like DSL, currently supporting
/// `Text`, `Image` (loaded from a `url:` parameter, scaled to fit), `VStack`
/// and `HStack` (with optional `alignment:` and `spacing:` parameters),
/// `ZStack` (with an optional `alignment:` parameter), `Button` (whose action
/// opens a `url:` parameter), and chainable `.padding()` / `.padding(_ length: Double)`,
/// `.background(Color(hex: "#RRGGBB"))`, `.fontSize(_ size: Double)`,
/// `.cornerRadius(_ radius: Double)`, `.tint(Color(hex: "#RRGGBB"))`,
/// `.foregroundStyle(Color(hex: "#RRGGBB"))`, `.frame(width:height:)`, and
/// `.clipShape(.circle)` modifiers on any view. Example:
///
/// ```
/// ZStack(alignment: .bottomTrailing) {
///     Image(url: "https://example.com/photo.png")
///     VStack(alignment: .leading, spacing: 16) {
///         Text("Hello").padding(4)
///         HStack(spacing: 4) {
///             Text("World")
///             Text("!")
///         }
///         Button("Learn more", url: "https://example.com")
///     }
///     .padding()
///     .background(Color(hex: "#1A1A1A"))
/// }
/// ```
public struct FluidSwiftUIView: View {
    let code: String

    @Environment(\.openURL) private var openURL

    public init(code: String) {
        self.code = code
    }

    public var body: some View {
        switch Result(catching: { try SwiftUIParser.parse(code) }) {
        case .success(let nodes):
            renderNodes(nodes)
        case .failure(let error):
            Text(error.localizedDescription)
                .foregroundStyle(.red)
        }
    }

    private func renderNodes(_ nodes: [SwiftUINode]) -> AnyView {
        AnyView(
            ForEach(Array(nodes.enumerated()), id: \.offset) { _, node in
                renderNode(node)
            }
        )
    }

    private func renderNode(_ node: SwiftUINode) -> AnyView {
        switch node {
        case .text(let value):
            return AnyView(Text(markdown(value)))
        case .image(let url):
            return AnyView(
                AsyncImage(url: URL(string: url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
            )
        case .vstack(let alignment, let spacing, let children):
            return AnyView(
                VStack(alignment: horizontalAlignment(alignment), spacing: spacing.map { CGFloat($0) }) {
                    renderNodes(children)
                }
            )
        case .hstack(let alignment, let spacing, let children):
            return AnyView(
                HStack(alignment: verticalAlignment(alignment), spacing: spacing.map { CGFloat($0) }) {
                    renderNodes(children)
                }
            )
        case .zstack(let alignment, let children):
            return AnyView(
                ZStack(alignment: zstackAlignment(alignment)) {
                    renderNodes(children)
                }
            )
        case .button(let title, let url):
            return AnyView(
                Button {
                    guard let destination = URL(string: url) else { return }
                    openURL(destination)
                } label: {
                    Text(markdown(title))
                }
            )
        case .padding(let amount, let child):
            if let amount {
                return AnyView(renderNode(child).padding(CGFloat(amount)))
            } else {
                return AnyView(renderNode(child).padding())
            }
        case .background(let hex, let child):
            return AnyView(renderNode(child).background(color(fromHex: hex)))
        case .fontSize(let size, let child):
            return AnyView(renderNode(child).font(.system(size: CGFloat(size))))
        case .cornerRadius(let radius, let child):
            return AnyView(renderNode(child).cornerRadius(CGFloat(radius)))
        case .tint(let hex, let child):
            return AnyView(renderNode(child).tint(color(fromHex: hex)))
        case .foregroundStyle(let hex, let child):
            return AnyView(renderNode(child).foregroundStyle(color(fromHex: hex)))
        case .frame(let width, let height, let child):
            return AnyView(
                renderNode(child).frame(width: width.map { CGFloat($0) }, height: height.map { CGFloat($0) })
            )
        case .clipShape(let shape, let child):
            switch shape {
            case .circle:
                return AnyView(renderNode(child).clipShape(Circle()))
            }
        }
    }

    private func horizontalAlignment(_ value: HorizontalAlignmentValue) -> HorizontalAlignment {
        switch value {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }

    private func verticalAlignment(_ value: VerticalAlignmentValue) -> VerticalAlignment {
        switch value {
        case .top: return .top
        case .center: return .center
        case .bottom: return .bottom
        }
    }

    private func zstackAlignment(_ value: AlignmentValue) -> Alignment {
        switch value {
        case .topLeading: return .topLeading
        case .top: return .top
        case .topTrailing: return .topTrailing
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        case .bottomLeading: return .bottomLeading
        case .bottom: return .bottom
        case .bottomTrailing: return .bottomTrailing
        }
    }

    /// Parses inline Markdown (`**bold**`, `*italic*`, `` `code` ``, links, ...) without
    /// going through `LocalizedStringKey`, which would otherwise route arbitrary parsed
    /// text through Xcode's string-catalog lookup and `%`-style format-specifier parsing.
    private func markdown(_ value: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return (try? AttributedString(markdown: value, options: options)) ?? AttributedString(value)
    }

    /// Converts a `"#RRGGBB"` or `"#RRGGBBAA"` (leading `#` optional) hex string into a
    /// `Color`. Falls back to `.clear` for malformed input.
    private func color(fromHex hex: String) -> Color {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("#") {
            sanitized.removeFirst()
        }

        var value: UInt64 = 0
        guard Scanner(string: sanitized).scanHexInt64(&value) else { return .clear }

        let red, green, blue, alpha: Double
        switch sanitized.count {
        case 6:
            red = Double((value & 0xFF0000) >> 16) / 255
            green = Double((value & 0x00FF00) >> 8) / 255
            blue = Double(value & 0x0000FF) / 255
            alpha = 1
        case 8:
            red = Double((value & 0xFF00_0000) >> 24) / 255
            green = Double((value & 0x00FF_0000) >> 16) / 255
            blue = Double((value & 0x0000_FF00) >> 8) / 255
            alpha = Double(value & 0x0000_00FF) / 255
        default:
            return .clear
        }

        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}
