import SwiftUI
import WebKit

private struct SiteLink: Identifiable, Hashable {
    let title: String
    let url: URL

    var id: String { title }
}

private struct EmbeddedWebView: UIViewRepresentable {
    let url: URL
    let isDarkMode: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isDarkMode: isDarkMode)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.isDarkMode = isDarkMode

        if webView.url != url {
            webView.load(URLRequest(url: url))
        } else {
            context.coordinator.injectTheme(into: webView)
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var isDarkMode: Bool

        init(isDarkMode: Bool) {
            self.isDarkMode = isDarkMode
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            injectTheme(into: webView)
        }

        func injectTheme(into webView: WKWebView) {
            let textColor = isDarkMode ? "#FFFFFF" : "#000000"
            let backgroundColor = isDarkMode ? "rgba(20, 20, 20, 0.08)" : "rgba(255, 255, 255, 0.08)"

            let css = """
            html {
                background-color: \(backgroundColor) !important;
            }
            body, * {
                background: transparent !important;
                background-color: transparent !important;
                font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', sans-serif !important;
                color: \(textColor) !important;
                -webkit-text-fill-color: \(textColor) !important;
            }
            """

            let escapedCSS = css
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "`", with: "\\`")

            let script = """
            const css = `\(escapedCSS)`;
            const styleId = 'ice-tag-theme';
            let style = document.getElementById(styleId);
            if (!style) {
                style = document.createElement('style');
                style.id = styleId;
                document.head.appendChild(style);
            }
            style.innerHTML = css;
            """

            webView.evaluateJavaScript(script)
        }
    }
}

struct ContentView: View {
    @AppStorage("usesystemsettings") private var useSystemSettings = true
    @AppStorage("appearancemode") private var appearanceMode = "light"
    @Environment(\.colorScheme) private var systemScheme
    @State private var selectedSite = sites[0]

    private static let sites: [SiteLink] = [
        SiteLink(title: "Home", url: URL(string: "https://sites.google.com/view/icelabs/home")!),
        SiteLink(title: "Mods", url: URL(string: "https://sites.google.com/view/icelabs/mods")!),
        SiteLink(title: "TOS", url: URL(string: "https://sites.google.com/view/icelabs/terms-of-service")!),
        SiteLink(title: "Privacy Policy", url: URL(string: "https://sites.google.com/view/icelabs/privacy-policy")!),
        SiteLink(title: "System Requirements", url: URL(string: "https://sites.google.com/view/icelabs/ice-tag-system-requirements")!),
        SiteLink(title: "Submit A Mod", url: URL(string: "https://forms.gle/aWVrD8SiwuLpYHUr8")!),
        SiteLink(title: "itch", url: URL(string: "https://jackww51.itch.io/iceygame")!),
        SiteLink(title: "GRAB Level", url: URL(string: "https://grabvr.quest/levels/viewer/?level=2dahfrbinl80vn8h8u754:1725132872")!),
        SiteLink(title: "Blog", url: URL(string: "https://sites.google.com/view/icelabs/blog")!)
    ]

    private var isDarkMode: Bool {
        useSystemSettings ? (systemScheme == .dark) : (appearanceMode == "dark")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.36, blue: 0.92),
                        Color(red: 0.02, green: 0.09, blue: 0.24)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    sitePicker

                    EmbeddedWebView(url: selectedSite.url, isDarkMode: isDarkMode)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(.white.opacity(0.18), lineWidth: 1)
                        }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
            .navigationTitle("Ice Labs")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var sitePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Self.sites) { site in
                    Button {
                        selectedSite = site
                    } label: {
                        Text(site.title)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedSite == site ? .white.opacity(0.26) : .white.opacity(0.14))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
