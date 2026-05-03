import SwiftUI
import WebKit

struct JingAstrolabeView: View {
    private let backgroundColor = Color(red: 2.0 / 255.0, green: 3.0 / 255.0, blue: 8.0 / 255.0)
    private let constellationShapes: [[CGPoint]] = [
        [CGPoint(x: 0, y: 0), CGPoint(x: 15, y: 20)],
        [CGPoint(x: 0, y: 0), CGPoint(x: -20, y: 10), CGPoint(x: -10, y: -15)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 25, y: 0), CGPoint(x: 12, y: 15), CGPoint(x: 12, y: -15)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 15, y: 20), CGPoint(x: 30, y: 40)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 20, y: 10), CGPoint(x: 15, y: -15)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 15), CGPoint(x: 20, y: 30), CGPoint(x: 25, y: 45)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 20, y: -10), CGPoint(x: 35, y: -5)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 20, y: -10), CGPoint(x: 40, y: -5), CGPoint(x: 55, y: 10), CGPoint(x: 55, y: 30)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 15, y: 20)],
        [CGPoint(x: 0, y: 0), CGPoint(x: -20, y: 10), CGPoint(x: -10, y: -15)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 25, y: 0)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 15, y: 20), CGPoint(x: 30, y: 40)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 20, y: 10), CGPoint(x: 15, y: -15)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 15), CGPoint(x: 20, y: 30)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 20, y: -10), CGPoint(x: 40, y: -5)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 15, y: 20)],
        [CGPoint(x: 0, y: 0), CGPoint(x: -20, y: 10), CGPoint(x: -10, y: -15)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 25, y: 0), CGPoint(x: 12, y: 15), CGPoint(x: 12, y: -15), CGPoint(x: 5, y: 20), CGPoint(x: -5, y: 10)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 15, y: 20), CGPoint(x: 30, y: 40)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 20, y: 10), CGPoint(x: 15, y: -15)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 15), CGPoint(x: 20, y: 30), CGPoint(x: 25, y: 45)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 20, y: -10), CGPoint(x: 40, y: -5), CGPoint(x: 55, y: 10)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 15, y: 20), CGPoint(x: 20, y: -10), CGPoint(x: -15, y: -10)],
        [CGPoint(x: 0, y: 0), CGPoint(x: -20, y: 10), CGPoint(x: -10, y: -15)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 25, y: 0), CGPoint(x: 12, y: 15)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 15, y: 20), CGPoint(x: 30, y: 40)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 20, y: 10), CGPoint(x: 15, y: -15)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 15), CGPoint(x: 20, y: 30), CGPoint(x: 25, y: 45)]
    ]

    @State private var startTime = Date()
    @State private var stars: [JingDustParticle] = []
    @State private var constellationGroups: [JingConstellationGroup] = []
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
                let elapsed = max(0, timeline.date.timeIntervalSince(startTime))

                ZStack {
                    backgroundColor
                        .ignoresSafeArea()

                    starField(size: proxy.size, elapsed: elapsed)
                        .ignoresSafeArea()

                    Rectangle()
                        .fill(.white.opacity(0.03))
                        .blendMode(.overlay)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    if let htmlURL = Bundle.main.url(forResource: "JingAstrolabePage", withExtension: "html") {
                        JingHTMLWebView(htmlURL: htmlURL)
                            .background(Color.clear)
                    } else {
                        VStack(spacing: 10) {
                            Text("经页面加载失败")
                                .font(.system(size: 18, weight: .semibold, design: .serif))
                                .foregroundStyle(.white)
                            Text("未找到 JingAstrolabePage.html")
                                .font(.system(size: 13, weight: .regular, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
                .onAppear {
                    startTime = Date()
                    refreshStarsIfNeeded(for: proxy.size)
                }
                .onChange(of: proxy.size) { _, newSize in
                    refreshStarsIfNeeded(for: newSize)
                }
            }
        }
    }

    private func starField(size: CGSize, elapsed: Double) -> some View {
        Canvas { context, canvasSize in
            context.translateBy(x: canvasSize.width / 2, y: canvasSize.height / 2)
            context.rotate(by: .radians(elapsed * 0.018))
            context.translateBy(x: -canvasSize.width / 2, y: -canvasSize.height / 2)

            for star in stars {
                var x = star.startX + star.velocityX * elapsed * 60.0
                var y = star.startY + star.velocityY * elapsed * 60.0

                x = wrapped(x, maxValue: canvasSize.width)
                y = wrapped(y, maxValue: canvasSize.height)

                let rect = CGRect(
                    x: x - star.radius,
                    y: y - star.radius,
                    width: star.radius * 2,
                    height: star.radius * 2
                )
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(star.opacity)))
            }

            for (groupIndex, group) in constellationGroups.enumerated() {
                guard let first = group.points.first else { continue }

                if group.points.count >= 2 {
                    var linePath = Path()
                    linePath.move(to: first.position)
                    for point in group.points.dropFirst() {
                        linePath.addLine(to: point.position)
                    }
                    context.stroke(linePath, with: .color(.white.opacity(group.lineOpacity)), lineWidth: 0.6)
                }

                for (pointIndex, point) in group.points.enumerated() {
                    let twinklePhase = elapsed * 2.0 + point.phase + Double(groupIndex * 7 + pointIndex)
                    let twinkle = (sin(twinklePhase) + 1) / 2
                    let radius = point.radius * (0.8 + 0.4 * twinkle)
                    let opacity = point.baseOpacity * (0.55 + 0.45 * twinkle)

                    let rect = CGRect(
                        x: point.position.x - radius,
                        y: point.position.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
                }
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func refreshStarsIfNeeded(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let widthChanged = abs(size.width - canvasSize.width) > 2
        let heightChanged = abs(size.height - canvasSize.height) > 2
        guard stars.isEmpty || widthChanged || heightChanged else { return }

        var generator = JingSeededGenerator(state: 0xCA5719AA)
        stars = (0..<260).map { _ in
            JingDustParticle(
                startX: Double.random(in: 0...size.width, using: &generator),
                startY: Double.random(in: 0...size.height, using: &generator),
                radius: Double.random(in: 0.4...1.5, using: &generator),
                velocityX: Double.random(in: -0.07...0.07, using: &generator),
                velocityY: Double.random(in: -0.05...0.05, using: &generator),
                opacity: Double.random(in: 0.07...0.5, using: &generator)
            )
        }

        constellationGroups = constellationShapes.map { shape in
            let centerX = Double.random(in: size.width * 0.05...size.width * 0.95, using: &generator)
            let centerY = Double.random(in: size.height * 0.06...size.height * 0.94, using: &generator)
            let angle = Double.random(in: 0...(2 * .pi), using: &generator)
            let cosA = cos(angle)
            let sinA = sin(angle)

            let points = shape.map { offset in
                let rotatedX = Double(offset.x) * cosA - Double(offset.y) * sinA
                let rotatedY = Double(offset.x) * sinA + Double(offset.y) * cosA

                return JingConstellationPoint(
                    position: CGPoint(x: centerX + rotatedX, y: centerY + rotatedY),
                    radius: Double.random(in: 1.1...2.1, using: &generator),
                    baseOpacity: Double.random(in: 0.55...0.95, using: &generator),
                    phase: Double.random(in: 0...(2 * .pi), using: &generator)
                )
            }

            return JingConstellationGroup(
                points: points,
                lineOpacity: Double.random(in: 0.18...0.3, using: &generator)
            )
        }

        canvasSize = size
    }

    private func wrapped(_ value: Double, maxValue: Double) -> Double {
        guard maxValue > 0 else { return 0 }
        var wrappedValue = value.truncatingRemainder(dividingBy: maxValue)
        if wrappedValue < 0 {
            wrappedValue += maxValue
        }
        return wrappedValue
    }
}

#if canImport(UIKit)
private struct JingHTMLWebView: UIViewRepresentable {
    let htmlURL: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let script = WKUserScript(
            source: Self.injectionScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(script)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false

        webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url == nil {
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        }
    }

    private static let injectionScript = """
    (function() {
      function apply() {
        const styleId = 'codex-hide-jing-bottom-nav';
        if (!document.getElementById(styleId)) {
          const style = document.createElement('style');
          style.id = styleId;
          style.innerHTML = '\\n            .bottom-nav{display:none !important;height:0 !important;min-height:0 !important;}\\n            #bottomNav{display:none !important;height:0 !important;min-height:0 !important;}\\n            #starCanvas{display:none !important;}\\n            :root{--c-bg: transparent !important;}\\n            html, body { background: transparent !important; }\\n          ';
          (document.head || document.documentElement).appendChild(style);
        }

        const nav = document.getElementById('bottomNav');
        if (nav && nav.parentNode) {
          nav.parentNode.removeChild(nav);
        }
      }

      apply();
      document.addEventListener('DOMContentLoaded', apply, { once: true });
      window.addEventListener('load', apply, { once: true });
    })();
    """
}
#else
private struct JingHTMLWebView: View {
    let htmlURL: URL

    var body: some View {
        Text("当前平台不支持网页渲染")
            .foregroundStyle(.white)
    }
}
#endif

private struct JingDustParticle {
    let startX: Double
    let startY: Double
    let radius: Double
    let velocityX: Double
    let velocityY: Double
    let opacity: Double
}

private struct JingConstellationGroup {
    let points: [JingConstellationPoint]
    let lineOpacity: Double
}

private struct JingConstellationPoint {
    let position: CGPoint
    let radius: Double
    let baseOpacity: Double
    let phase: Double
}

private struct JingSeededGenerator: RandomNumberGenerator {
    var state: UInt64

    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

#Preview {
    JingAstrolabeView()
}
