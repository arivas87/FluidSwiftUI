# FluidSwiftUI

FluidSwiftUI renders a small, controlled subset of SwiftUI-like source code as native SwiftUI views. It is useful when a view hierarchy needs to be described as a string while limiting the elements and modifiers that can be used.

## Requirements

- Swift 6.4 or later
- A platform that supports SwiftUI and `AsyncImage`

## Installation

Add the package in Xcode with **File > Add Package Dependencies**, then add the `FluidSwiftUI` library product to your app target.

For another Swift package, add FluidSwiftUI to the package dependencies and target dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/arivas87/FluidSwiftUI.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["FluidSwiftUI"]
    )
]
```

Replace the example URL and version with the repository's published location and release.

## Usage

Pass a SwiftUI-like string to `FluidSwiftUIView`:

```swift
import SwiftUI
import FluidSwiftUI

struct ContentView: View {
    private let code = #"""
    VStack(alignment: .leading, spacing: 12) {
        Text("**Welcome** to FluidSwiftUI")
            .fontSize(28)
            .foregroundStyle(Color(hex: "#FFFFFF"))

        Image(url: "https://example.com/photo.png")
            .frame(width: 240, height: 160)
            .clipShape(.circle)

        Button("Learn more", url: "https://example.com")
            .padding(12)
            .background(Color(hex: "#3366FFFF"))
            .cornerRadius(10)
            .tint(Color(hex: "#FFFFFF"))
    }
    .padding()
    .background(Color(hex: "#1A1A1A"))
    """#

    var body: some View {
        FluidSwiftUIView(code: code)
    }
}
```

Parsing errors are rendered in red in place of the requested content. Multiple top-level elements are allowed, and whitespace—including newlines—is ignored outside string literals.

## Supported elements

| Element | Syntax | Parameters | Behavior |
| --- | --- | --- | --- |
| `Text` | `Text("Hello")` | One required string | Renders text. Inline Markdown is supported. |
| `Image` | `Image(url: "https://…")` | Required `url` string | Loads a remote image asynchronously, makes it resizable, and scales it to fit. A progress indicator is shown while loading. |
| `VStack` | `VStack { … }` | Optional `alignment` and `spacing` | Arranges child elements vertically. |
| `HStack` | `HStack { … }` | Optional `alignment` and `spacing` | Arranges child elements horizontally. |
| `ZStack` | `ZStack { … }` | Optional `alignment` | Overlays child elements. |
| `Button` | `Button("Open", url: "https://…")` | Required title and `url` strings | Renders a button that opens the URL through SwiftUI's `openURL` environment action. The title supports inline Markdown. |

### Element parameters

#### `Text`

```swift
Text("A string")
```

The string supports inline Markdown such as `**bold**`, `*italic*`, `` `code` ``, and links. Markdown block syntax is not enabled.

#### `Image`

```swift
Image(url: "https://example.com/image.png")
```

Only the named `url` parameter is supported. Local asset names and SF Symbols are not supported.

#### `VStack`

```swift
VStack(alignment: .leading, spacing: 16) {
    Text("First")
    Text("Second")
}
```

- `alignment`: `.leading`, `.center`, or `.trailing`; defaults to `.center`.
- `spacing`: a non-negative integer or decimal number; when omitted, SwiftUI chooses the default spacing.
- Both parameters are optional and may appear in either order.

#### `HStack`

```swift
HStack(alignment: .top, spacing: 8) {
    Text("Left")
    Text("Right")
}
```

- `alignment`: `.top`, `.center`, or `.bottom`; defaults to `.center`.
- `spacing`: a non-negative integer or decimal number; when omitted, SwiftUI chooses the default spacing.
- Both parameters are optional and may appear in either order.

#### `ZStack`

```swift
ZStack(alignment: .bottomTrailing) {
    Image(url: "https://example.com/background.png")
    Text("Caption")
}
```

The optional `alignment` parameter accepts `.topLeading`, `.top`, `.topTrailing`, `.leading`, `.center`, `.trailing`, `.bottomLeading`, `.bottom`, or `.bottomTrailing`. It defaults to `.center`.

#### `Button`

```swift
Button("Open website", url: "https://example.com")
```

The positional title and named `url` are both required. If the URL cannot be constructed, tapping the button has no effect.

## Supported modifiers

Modifiers can be applied to any supported element or container and chained in source order.

| Modifier | Accepted arguments | Effect |
| --- | --- | --- |
| `.padding()` | None | Applies SwiftUI's default padding on all edges. |
| `.padding(12)` | One number | Applies the specified padding on all edges. |
| `.background(Color(hex: "#RRGGBB"))` | One hex color | Places the color behind the view. |
| `.fontSize(20)` | One number | Sets a system font with the specified point size. |
| `.cornerRadius(8)` | One number | Clips the view using the specified corner radius. |
| `.tint(Color(hex: "#RRGGBB"))` | One hex color | Applies the SwiftUI tint. |
| `.foregroundStyle(Color(hex: "#RRGGBB"))` | One hex color | Applies the color as the foreground style. |
| `.frame(width: 100, height: 80)` | Optional `width` and/or `height` | Sets a fixed width, height, or both. Parameters may appear in either order. |
| `.clipShape(.circle)` | `.circle` | Clips the view to a circle. |

Examples:

```swift
Text("Status")
    .fontSize(18)
    .foregroundStyle(Color(hex: "#FFFFFF"))
    .padding(8)
    .background(Color(hex: "#228B22"))
    .cornerRadius(6)

Image(url: "https://example.com/avatar.png")
    .frame(height: 96, width: 96)
    .clipShape(.circle)
```

## Colors

Color modifiers accept only this syntax:

```swift
Color(hex: "#RRGGBB")
Color(hex: "#RRGGBBAA")
```

The leading `#` is optional. Six digits specify red, green, and blue; eight digits additionally specify alpha as the final two digits. Invalid values render as clear rather than producing a parser error.

## DSL rules and limitations

- Element, parameter, modifier, and enum-case names are case-sensitive.
- Numeric values may be unsigned integers or decimals. Negative numbers, signs, and exponent notation are not supported.
- Strings use double quotes. A backslash escapes the following character, including `\"` for a quote and `\\` for a backslash.
- Stack children are enclosed in braces and do not use commas.
- Multiple elements may appear next to one another at the root or inside a stack.
- Only the elements, parameters, alignment values, shapes, and modifiers documented above are accepted.
- This is a SwiftUI-like DSL, not a Swift compiler. Variables, expressions, conditionals, loops, arbitrary SwiftUI views, trailing closures other than supported stack children, and general Swift code are not supported.
- Modifier order matters, just as it does in SwiftUI.

## Error handling

Unsupported syntax and malformed input produce a parser error. `FluidSwiftUIView` catches that error and displays its localized message in red. Common messages include unsupported views, modifiers, parameters, or alignments, unexpected characters or tokens, and an unexpected end of input.

## Examples

The `FluidSwiftUIExamples` library target contains ready-to-preview examples for common layouts:

- `WelcomeCardExample` — introductory card with styled text and a link button.
- `ProfileCardExample` — profile layout with a remote, circular image.
- `PricingCardExample` — pricing and call-to-action card.
- `ArticleHeroExample` — image-led editorial layout.
- `StatusDashboardExample` — nested stacks with status badges.

Open a file in the `Example` directory and use its `#Preview` to see the rendered DSL without integrating it into an app first.

## Development

Run the parser, lexer, and node test suites with:

```shell
swift test
```

## Next steps

Potential enhancements include:

- Supporting more SwiftUI elements (nodes), such as `Spacer`, `Divider`, `ScrollView`, and additional controls.
- Expanding modifier coverage for typography, layout, borders, shadows, opacity, and accessibility.
- Accepting more parameters and parameter combinations on existing elements and modifiers.
- Supporting additional image sources, shapes, colors, and alignment options.
- Improving diagnostics with source locations and more actionable parsing errors.
- Adding extensibility points for applications to register custom nodes and behaviors.
