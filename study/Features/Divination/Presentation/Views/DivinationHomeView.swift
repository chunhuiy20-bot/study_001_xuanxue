import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct DivinationHomeView: View {
    private let backgroundColor = Color(red: 2.0 / 255.0, green: 3.0 / 255.0, blue: 8.0 / 255.0)
    private let goldColor = Color(red: 230.0 / 255.0, green: 194.0 / 255.0, blue: 122.0 / 255.0)
    private let textSubColor = Color(red: 160.0 / 255.0, green: 165.0 / 255.0, blue: 181.0 / 255.0)

    private let trigramPatterns: [[BaguaLine]] = [
        [.yang, .yang, .yang], // ☰
        [.yang, .yang, .yin],  // ☴
        [.yin, .yang, .yin],   // ☵
        [.yang, .yin, .yin],   // ☶
        [.yin, .yin, .yin],    // ☷
        [.yin, .yin, .yang],   // ☳
        [.yang, .yin, .yang],  // ☲
        [.yin, .yang, .yang]   // ☱
    ]
    private let engineChars = Array("0123456789甲乙丙丁戊己庚辛壬癸子丑寅卯辰巳午未申酉戌亥")

    private let starPatterns: [[CGPoint]] = [
        [CGPoint(x: 10, y: 10), CGPoint(x: 20, y: 25), CGPoint(x: 30, y: 15)],
        [CGPoint(x: 15, y: 5), CGPoint(x: 25, y: 20), CGPoint(x: 10, y: 30), CGPoint(x: 35, y: 35)],
        [CGPoint(x: 5, y: 20), CGPoint(x: 20, y: 10), CGPoint(x: 35, y: 25)],
        [CGPoint(x: 10, y: 30), CGPoint(x: 20, y: 5), CGPoint(x: 30, y: 25)],
        [CGPoint(x: 10, y: 15), CGPoint(x: 20, y: 30), CGPoint(x: 35, y: 10)],
        [CGPoint(x: 5, y: 10), CGPoint(x: 15, y: 25), CGPoint(x: 25, y: 15), CGPoint(x: 35, y: 30)],
        [CGPoint(x: 15, y: 35), CGPoint(x: 20, y: 15), CGPoint(x: 30, y: 5)],
        [CGPoint(x: 10, y: 10), CGPoint(x: 15, y: 30), CGPoint(x: 35, y: 20)],
        [CGPoint(x: 5, y: 30), CGPoint(x: 20, y: 20), CGPoint(x: 35, y: 35), CGPoint(x: 25, y: 5)],
        [CGPoint(x: 10, y: 25), CGPoint(x: 20, y: 10), CGPoint(x: 30, y: 30)],
        [CGPoint(x: 5, y: 15), CGPoint(x: 25, y: 5), CGPoint(x: 30, y: 30)],
        [CGPoint(x: 15, y: 10), CGPoint(x: 10, y: 25), CGPoint(x: 25, y: 35), CGPoint(x: 35, y: 15)]
    ]

    let onCastingRequested: () -> Void
    let onArchiveRequested: () -> Void
    let showsEmbeddedBottomNav: Bool
    let isActive: Bool

    @State private var startTime = Date()
    @State private var showHeader = false
    @State private var showFooter = false
    @State private var isCompassAwake = false

    @State private var tiltX = 0.0
    @State private var tiltY = 0.0

    @State private var engineDigits = ["7", "3", "5"]
    @State private var engineTask: Task<Void, Never>?

    @State private var particles: [DustParticle] = []
    @State private var particleCanvasSize: CGSize = .zero
    @State private var rippleScale: CGFloat = 1
    @State private var rippleOpacity = 0.0
    @State private var pendingNavigationTask: Task<Void, Never>?
    @State private var latestRecord: AkashicRecord?

    init(
        onCastingRequested: @escaping () -> Void = {},
        onArchiveRequested: @escaping () -> Void = {},
        showsEmbeddedBottomNav: Bool = true,
        isActive: Bool = true
    ) {
        self.onCastingRequested = onCastingRequested
        self.onArchiveRequested = onArchiveRequested
        self.showsEmbeddedBottomNav = showsEmbeddedBottomNav
        self.isActive = isActive
    }

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: !isActive)) { timeline in
                let elapsed = max(0, timeline.date.timeIntervalSince(startTime))

                ZStack {
                    backgroundColor
                        .ignoresSafeArea()

                    dustLayer(size: proxy.size, elapsed: elapsed)
                        .offset(x: -tiltY * 0.8, y: -tiltX * 0.8)
                        .allowsHitTesting(false)

                    Rectangle()
                        .fill(.white.opacity(0.03))
                        .blendMode(.overlay)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    VStack(spacing: 0) {
                        headerView
                            .opacity(showHeader ? 1 : 0)
                            .offset(y: showHeader ? 0 : -20)
                            .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 1), value: showHeader)

                        mainCompassView(elapsed: elapsed)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        footerView
                            .opacity(showFooter ? 1 : 0)
                            .offset(y: showFooter ? 0 : 20)
                            .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 1), value: showFooter)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .onAppear {
                startTime = Date()
                refreshParticlesIfNeeded(for: proxy.size)
                refreshLatestRecord()
                runEntranceAnimation()
                startEngineLoop()
            }
            .onChange(of: isActive) { _, active in
                if active {
                    refreshLatestRecord()
                }
            }
            .onDisappear {
                engineTask?.cancel()
                engineTask = nil
                pendingNavigationTask?.cancel()
                pendingNavigationTask = nil
            }
            .onChange(of: proxy.size) { _, newSize in
                refreshParticlesIfNeeded(for: newSize)
            }
        }
    }

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("丙辰月 戊戌日")
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .tracking(2)
                    .foregroundStyle(.white)

                Text("谷雨 · 候")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .tracking(4)
                    .foregroundStyle(goldColor)
            }

            Spacer()

            engineDigitsView
                .offset(y: 5)

            Spacer()

            Text("巳时")
                .font(.system(size: 18, weight: .regular, design: .serif))
                .tracking(2)
                .foregroundStyle(.white)
        }
        .padding(.top, 50)
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    private var engineDigitsView: some View {
        HStack(spacing: 12) {
            ForEach(Array(engineDigits.enumerated()), id: \.offset) { _, digit in
                Text(digit)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .frame(width: 14)
                    .foregroundStyle(goldColor.opacity(0.85))
                    .shadow(color: goldColor.opacity(0.6), radius: 8)
            }
        }
    }

    private func mainCompassView(elapsed: Double) -> some View {
        GeometryReader { proxy in
            let drag = DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let width = max(proxy.size.width, 1)
                    let height = max(proxy.size.height, 1)
                    let x = value.location.x - width / 2
                    let y = value.location.y - height / 2

                    let newTiltX = -(y / height) * 35
                    let newTiltY = (x / width) * 35

                    withAnimation(.easeOut(duration: 0.1)) {
                        tiltX = newTiltX
                        tiltY = newTiltY
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.25)) {
                        tiltX = 0
                        tiltY = 0
                    }
                }

            ZStack {
                compassBody(elapsed: elapsed)
                    .scaleEffect(isCompassAwake ? 1 : 0.8)
                    .opacity(isCompassAwake ? 1 : 0)
                    .rotation3DEffect(.degrees(tiltX), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.degrees(tiltY), axis: (x: 0, y: 1, z: 0))
                    .animation(.timingCurve(0.25, 1, 0.2, 1, duration: 1.5), value: isCompassAwake)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(drag)
        }
    }

    private func compassBody(elapsed: Double) -> some View {
        ZStack {
            Circle()
                .fill(Color.clear)
                .frame(width: 357, height: 357)
                .shadow(color: .white.opacity(0.03), radius: 40)
                .overlay {
                    Circle().stroke(.white.opacity(0.03), lineWidth: 1)
                }

            ZStack {
                Circle()
                    .stroke(
                        .white.opacity(0.08),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 5])
                    )

                starPatternsRing(elapsed: elapsed)
            }
            .frame(width: 320, height: 320)
            .rotationEffect(.degrees(elapsed * (360.0 / 150.0)))

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.08), lineWidth: 1)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.02), .clear],
                            center: .center,
                            startRadius: 1,
                            endRadius: 120
                        )
                    )

                ForEach(0..<8, id: \.self) { index in
                    let angle = Double(index) * 45.0 - 90.0
                    let radius = 120.0
                    let x = cos(angle * .pi / 180.0) * radius
                    let y = sin(angle * .pi / 180.0) * radius

                    TrigramSymbolView(lines: trigramPatterns[index])
                        .frame(width: 30, height: 24)
                        .shadow(color: .white.opacity(0.2), radius: 8)
                        .rotationEffect(.degrees(Double(index) * 45))
                        .offset(x: x, y: y)
                }
            }
            .frame(width: 240, height: 240)
            .rotationEffect(.degrees(-elapsed * (360.0 / 45.0)))

            Circle()
                .stroke(.white, lineWidth: 1.5)
                .frame(width: 110, height: 110)
                .scaleEffect(rippleScale)
                .opacity(rippleOpacity)

            Button {
                handleTaijiTap()
            } label: {
                TaijiCenterView(elapsed: elapsed)
            }
            .buttonStyle(.plain)
            .frame(width: 110, height: 110)
            .scaleEffect(1)
            .disabled(pendingNavigationTask != nil)
        }
        .frame(width: 340, height: 340)
    }

    private func starPatternsRing(elapsed: Double) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let orbitRadius = 160.0

            for (patternIndex, pattern) in starPatterns.enumerated() {
                let angleDegrees = Double(patternIndex) * 30.0
                let angle = angleDegrees * .pi / 180.0

                let baseX = center.x + CGFloat(cos(angle) * orbitRadius)
                let baseY = center.y + CGFloat(sin(angle) * orbitRadius)

                var points: [CGPoint] = []
                points.reserveCapacity(pattern.count)

                for (pointIndex, point) in pattern.enumerated() {
                    let localX = (point.x - 20.0) * 0.75
                    let localY = (point.y - 20.0) * 0.75

                    let rotatedX = localX * cos(angle) - localY * sin(angle)
                    let rotatedY = localX * sin(angle) + localY * cos(angle)

                    let finalPoint = CGPoint(x: baseX + rotatedX, y: baseY + rotatedY)
                    points.append(finalPoint)

                    let twinklePhase = elapsed * 2.0 + Double(patternIndex * 7 + pointIndex)
                    let twinkle = (sin(twinklePhase) + 1) / 2
                    let starRadius = 1.0 + 0.8 * twinkle
                    let starOpacity = 0.3 + 0.7 * twinkle

                    let circleRect = CGRect(
                        x: finalPoint.x - starRadius,
                        y: finalPoint.y - starRadius,
                        width: starRadius * 2,
                        height: starRadius * 2
                    )
                    context.fill(Path(ellipseIn: circleRect), with: .color(.white.opacity(starOpacity)))
                }

                if points.count >= 2 {
                    var linePath = Path()
                    linePath.move(to: points[0])
                    for point in points.dropFirst() {
                        linePath.addLine(to: point)
                    }
                    context.stroke(linePath, with: .color(.white.opacity(0.2)), lineWidth: 1)
                }
            }
        }
    }

    private var footerView: some View {
        VStack(spacing: showsEmbeddedBottomNav ? 24 : 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(latestTimeText)
                        .font(.system(size: 13, weight: .regular, design: .serif))
                        .foregroundStyle(textSubColor)

                    Text(latestSummaryText)
                        .font(.system(size: 22, weight: .medium, design: .serif))
                        .tracking(1.5)
                        .foregroundStyle(.white)
                }

                Spacer()

                Text(latestHexSymbol)
                    .font(.system(size: 30, weight: .regular, design: .serif))
                    .foregroundStyle(goldColor.opacity(0.9))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.02))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white.opacity(0.05), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.5), radius: 30, y: 10)
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [goldColor.opacity(0.3), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 60, height: 60)
                            .offset(x: 20, y: -20)
                    }
            }

            if showsEmbeddedBottomNav {
                HStack(spacing: 0) {
                    navItem(title: "卜", active: true, action: nil)
                    navItem(title: "案", active: false, action: onArchiveRequested)
                    navItem(title: "盘", active: false, action: nil)
                    navItem(title: "我", active: false, action: nil)
                }
                .padding(.top, 10)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(.white.opacity(0.03))
                        .frame(height: 1)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, showsEmbeddedBottomNav ? 35 : 14)
    }

    private func navItem(title: String, active: Bool, action: (() -> Void)?) -> some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: active ? .bold : .regular, design: .serif))
                    .foregroundStyle(active ? goldColor : Color(red: 96.0 / 255.0, green: 101.0 / 255.0, blue: 117.0 / 255.0))

                Circle()
                    .fill(active ? goldColor : .clear)
                    .frame(width: 5, height: 5)
                    .shadow(color: active ? goldColor : .clear, radius: 10)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func dustLayer(size: CGSize, elapsed: Double) -> some View {
        Canvas { context, canvasSize in
            for particle in particles {
                let currentYRaw = particle.startY + particle.velocityY * elapsed * 60
                var currentY = currentYRaw.truncatingRemainder(dividingBy: max(canvasSize.height, 1))
                if currentY < 0 { currentY += canvasSize.height }

                let circleRect = CGRect(
                    x: particle.startX - particle.radius,
                    y: currentY - particle.radius,
                    width: particle.radius * 2,
                    height: particle.radius * 2
                )

                context.fill(
                    Path(ellipseIn: circleRect),
                    with: .color(goldColor.opacity(particle.opacity))
                )
            }
        }
        .frame(width: size.width * 1.1, height: size.height * 1.1)
        .position(x: size.width / 2, y: size.height / 2)
    }

    private func refreshParticlesIfNeeded(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let widthChanged = abs(size.width - particleCanvasSize.width) > 2
        let heightChanged = abs(size.height - particleCanvasSize.height) > 2
        guard particles.isEmpty || widthChanged || heightChanged else { return }

        var generator = SeededGenerator(state: 0xBA7A2026)
        particles = (0..<60).map { _ in
            DustParticle(
                startX: Double.random(in: 0...size.width, using: &generator),
                startY: Double.random(in: 0...size.height, using: &generator),
                radius: Double.random(in: 0...1.5, using: &generator),
                velocityY: -(Double.random(in: 0...0.5, using: &generator) + 0.1),
                opacity: Double.random(in: 0...0.5, using: &generator)
            )
        }
        particleCanvasSize = size
    }

    private func runEntranceAnimation() {
        showHeader = false
        showFooter = false
        isCompassAwake = false

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000)
            isCompassAwake = true

            try? await Task.sleep(nanoseconds: 400_000_000)
            showHeader = true

            try? await Task.sleep(nanoseconds: 300_000_000)
            showFooter = true
        }
    }

    private func startEngineLoop() {
        engineTask?.cancel()
        engineTask = Task {
            while Task.isCancelled == false {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                await runEngineCycle()
            }
        }
    }

    @MainActor
    private func runEngineCycle() async {
        let targets = [
            String(Int.random(in: 1...8)),
            String(Int.random(in: 1...8)),
            String(Int.random(in: 1...6))
        ]

        for index in 0..<targets.count {
            if index > 0 {
                try? await Task.sleep(nanoseconds: 200_000_000)
            }
            await decodeDigit(at: index, finalValue: targets[index])
        }
    }

    @MainActor
    private func decodeDigit(at index: Int, finalValue: String) async {
        guard engineDigits.indices.contains(index) else { return }

        for _ in 0..<15 {
            engineDigits[index] = String(engineChars.randomElement() ?? "0")
            try? await Task.sleep(nanoseconds: 50_000_000)
        }

        engineDigits[index] = finalValue
    }

    private func performTaijiTapFeedback() {
#if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
        rippleScale = 1
        rippleOpacity = 0.8

        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8)) {
            rippleScale = 1.8
            rippleOpacity = 0
        }
    }

    private func handleTaijiTap() {
        guard pendingNavigationTask == nil else { return }

        performTaijiTapFeedback()
        pendingNavigationTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 820_000_000)
            onCastingRequested()
            pendingNavigationTask = nil
        }
    }

    private var latestTimeText: String {
        guard let latestRecord else { return "最近一占 · 暂无" }
        return "最近一占 · \(relativeTimeText(from: latestRecord.createdAt))"
    }

    private var latestSummaryText: String {
        guard let latestRecord else { return "暂无占卜记录" }
        return "本卦 \(latestRecord.originalHexagram.name) 变 \(latestRecord.changedHexagram.name)"
    }

    private var latestHexSymbol: String {
        latestRecord?.originalHexagram.symbol ?? "䷿"
    }

    private func refreshLatestRecord() {
        latestRecord = AkashicRecordStore.shared.load().first
    }

    private func relativeTimeText(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "刚刚"
        }
        if interval < 3600 {
            return "\(Int(interval / 60))分钟前"
        }
        if interval < 86400 {
            return "\(Int(interval / 3600))小时前"
        }
        if interval < 172800 {
            return "昨天"
        }
        if interval < 604800 {
            return "\(Int(interval / 86400))天前"
        }
        return DivinationDateFormatters.short.string(from: date)
    }
}

private enum DivinationDateFormatters {
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM-dd"
        return formatter
    }()
}

private struct TaijiCenterView: View {
    let elapsed: Double

    var body: some View {
        let breathe = (sin(elapsed * (.pi / 2.0)) + 1) / 2
        let shadowRadius = 20 + 20 * breathe
        let splashRotationSpeed = 0.3 // Matches splash: frame * 0.005 with ~60 FPS.

        Canvas { context, size in
            context.withCGContext { cg in
                let radius = min(size.width, size.height) / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                cg.saveGState()
                cg.translateBy(x: center.x, y: center.y)
                cg.rotate(by: elapsed * splashRotationSpeed)

                // Standard yin-yang fish: same geometry as splash animation.
                cg.setFillColor(CGColor(gray: 1, alpha: 1))
                let yang = CGMutablePath()
                yang.move(to: .zero)
                yang.addArc(center: .zero, radius: radius, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: false)
                yang.closeSubpath()
                cg.addPath(yang)
                cg.fillPath()

                cg.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.8))
                let yin = CGMutablePath()
                yin.move(to: .zero)
                yin.addArc(center: .zero, radius: radius, startAngle: .pi / 2, endAngle: -.pi / 2, clockwise: false)
                yin.closeSubpath()
                cg.addPath(yin)
                cg.fillPath()

                cg.setFillColor(CGColor(gray: 1, alpha: 1))
                cg.fillEllipse(in: CGRect(x: -radius / 2, y: 0, width: radius, height: radius))
                cg.setFillColor(CGColor(gray: 0, alpha: 1))
                cg.fillEllipse(in: CGRect(x: -radius / 6, y: radius / 3, width: radius / 3, height: radius / 3))

                cg.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.8))
                cg.fillEllipse(in: CGRect(x: -radius / 2, y: -radius, width: radius, height: radius))
                cg.setFillColor(CGColor(gray: 1, alpha: 1))
                cg.fillEllipse(in: CGRect(x: -radius / 6, y: -2 * radius / 3, width: radius / 3, height: radius / 3))
                cg.restoreGState()
            }
        }
        .frame(width: 110, height: 110)
        .clipShape(Circle())
        .shadow(color: .white.opacity(0.2 + 0.4 * breathe), radius: shadowRadius)
    }
}

private enum BaguaLine {
    case yang
    case yin
}

private struct TrigramSymbolView: View {
    let lines: [BaguaLine]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                switch lines[index] {
                case .yang:
                    Capsule(style: .continuous)
                        .fill(.white.opacity(0.95))
                        .frame(width: 22, height: 3.2)
                case .yin:
                    HStack(spacing: 4.5) {
                        Capsule(style: .continuous)
                            .fill(.white.opacity(0.95))
                            .frame(width: 8.75, height: 3.2)
                        Capsule(style: .continuous)
                            .fill(.white.opacity(0.95))
                            .frame(width: 8.75, height: 3.2)
                    }
                }
            }
        }
    }
}

private struct DustParticle {
    let startX: Double
    let startY: Double
    let radius: Double
    let velocityY: Double
    let opacity: Double
}

private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64

    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

#Preview {
    DivinationHomeView()
}
