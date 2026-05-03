import SwiftUI

struct HexagramCastingView: View {
    private let backgroundColor = Color(red: 2.0 / 255.0, green: 3.0 / 255.0, blue: 8.0 / 255.0)
    private let goldColor = Color(red: 230.0 / 255.0, green: 194.0 / 255.0, blue: 122.0 / 255.0)

    private let holdDuration = 3.0
    private let progressTickNanos: UInt64 = 20_000_000
    private let decayTickNanos: UInt64 = 10_000_000

    private let baguaSymbols = ["☰", "☴", "☵", "☶", "☷", "☳", "☲", "☱"]
    private let baguaNames = ["乾", "兑", "离", "震", "巽", "坎", "艮", "坤"]
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

    let onBack: (() -> Void)?
    let onInterpretationRequested: () -> Void

    @State private var startTime = Date()
    @State private var subtitleText = "放空思绪 · 长按太极聚气"

    @State private var progress = 0.0
    @State private var isPressing = false
    @State private var isCompleted = false

    @State private var generatedLines: [Bool] = Array(repeating: true, count: 6)
    @State private var movingIndex = 0
    @State private var revealedLineCount = 0

    @State private var showQiArea = true
    @State private var showResult = false

    @State private var phantomGlyphs: [PhantomGlyph] = []
    @State private var stars: [CastingDustParticle] = []
    @State private var constellationGroups: [CastingConstellationGroup] = []
    @State private var starCanvasSize: CGSize = .zero

    @State private var progressTask: Task<Void, Never>?
    @State private var decayTask: Task<Void, Never>?
    @State private var phantomTask: Task<Void, Never>?

    init(
        onBack: (() -> Void)? = nil,
        onInterpretationRequested: @escaping () -> Void = {}
    ) {
        self.onBack = onBack
        self.onInterpretationRequested = onInterpretationRequested
    }

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
                let elapsed = max(0, timeline.date.timeIntervalSince(startTime))

                ZStack {
                    backgroundColor
                        .ignoresSafeArea()

                    starField(size: proxy.size, elapsed: elapsed)
                        .ignoresSafeArea()

                    phantomLayer(size: proxy.size, now: timeline.date)
                        .allowsHitTesting(false)

                    Rectangle()
                        .fill(.white.opacity(0.03))
                        .blendMode(.overlay)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    VStack(spacing: 0) {
                        headerView
                            .padding(.top, 48)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 12)

                        Spacer(minLength: 0)
                    }

                    hexagramBoardView
                        .position(x: proxy.size.width / 2, y: proxy.size.height * 0.36)

                    qiControlView(elapsed: elapsed)
                        .position(x: proxy.size.width / 2, y: proxy.size.height * 0.76)
                        .opacity(showQiArea ? 1 : 0)
                        .scaleEffect(showQiArea ? 1 : 0.8)
                        .blur(radius: showQiArea ? 0 : 5)
                        .allowsHitTesting(showQiArea && !isCompleted)
                }
            }
            .onAppear {
                startTime = Date()
                refreshStarsIfNeeded(for: proxy.size)
            }
            .onChange(of: proxy.size) { _, newSize in
                refreshStarsIfNeeded(for: newSize)
            }
            .onDisappear {
                progressTask?.cancel()
                decayTask?.cancel()
                progressTask = nil
                decayTask = nil
                stopPhantomLoop(clearGlyphs: true)
            }
        }
    }

    private var headerView: some View {
        HStack {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 34, height: 34)
                        .background(.white.opacity(0.04), in: Circle())
                }
                .buttonStyle(.plain)
            } else {
                Color.clear.frame(width: 34, height: 34)
            }

            Spacer()

            VStack(spacing: 8) {
                Text("一 念 成 卦")
                    .font(.system(size: 22, weight: .regular, design: .serif))
                    .tracking(6)
                    .foregroundStyle(.white)
                    .shadow(color: .white.opacity(0.2), radius: 8)

                Text(subtitleText)
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .tracking(3)
                    .foregroundStyle(isCompleted ? .white : goldColor)
                    .shadow(color: goldColor.opacity(0.35), radius: 8)
                    .animation(.easeInOut(duration: 0.25), value: subtitleText)
            }

            Spacer()
            Color.clear.frame(width: 34, height: 34)
        }
    }

    private var hexagramBoardView: some View {
        VStack(spacing: 18) {
            VStack(spacing: 16) {
                ForEach(Array((0..<revealedLineCount).reversed()), id: \.self) { index in
                    yaoLine(isYang: lineIsYang(at: index), isMoving: index == movingIndex)
                        .transition(.opacity.combined(with: .scale(scale: 1.2)))
                }
            }
            .frame(width: 160)
            .animation(.timingCurve(0.1, 0.8, 0.2, 1, duration: 0.35), value: revealedLineCount)

            if showResult {
                VStack(spacing: 18) {
                    Text("雷 水 解")
                        .font(.system(size: 30, weight: .regular, design: .serif))
                        .tracking(8)
                        .foregroundStyle(.white)
                        .shadow(color: .white.opacity(0.35), radius: 12)

                    Button {
                        onInterpretationRequested()
                    } label: {
                        Text("断 卦")
                            .font(.system(size: 15, weight: .semibold, design: .serif))
                            .tracking(4)
                            .foregroundStyle(.black.opacity(0.9))
                            .padding(.horizontal, 28)
                            .padding(.vertical, 10)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(goldColor)
                                    .shadow(color: goldColor.opacity(0.35), radius: 15)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity)
            }
        }
    }

    private func yaoLine(isYang: Bool, isMoving: Bool) -> some View {
        ZStack(alignment: .trailing) {
            if isYang {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(.white)
                    .frame(height: 14)
                    .shadow(color: .white.opacity(0.25), radius: 10)
            } else {
                HStack(spacing: 18) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 14)
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 14)
                }
                .shadow(color: .white.opacity(0.25), radius: 10)
            }

            if isMoving {
                Text(isYang ? "O" : "X")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(goldColor)
                    .shadow(color: goldColor.opacity(0.6), radius: 8)
                    .offset(x: 24)
            }
        }
        .frame(width: 160, height: 14)
    }

    private func qiControlView(elapsed: Double) -> some View {
        let baguaSpinDegreesPerSecond = isPressing ? -(360.0 / 5.0) : -(360.0 / 45.0)
        let taijiSpinDegreesPerSecond = isPressing ? (360.0 / 3.0) : (360.0 / 30.0)

        return ZStack {
            Circle()
                .stroke(goldColor.opacity(0.25), lineWidth: 2)
                .frame(width: 240, height: 240)

            Circle()
                .trim(from: 0, to: min(max(progress / 100.0, 0), 1))
                .stroke(
                    goldColor,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 240, height: 240)
                .shadow(color: goldColor.opacity(0.5), radius: 8)
                .animation(.linear(duration: 0.05), value: progress)

            ZStack {
                Circle()
                    .stroke(
                        .white.opacity(isPressing ? 0.2 : 0.1),
                        style: StrokeStyle(lineWidth: 1, dash: [3, 4])
                    )
                    .frame(width: 190, height: 190)

                ForEach(0..<8, id: \.self) { index in
                    let angle = (Double(index) * 45.0 - 90.0) * .pi / 180.0
                    let radius = 95.0
                    let x = cos(angle) * radius
                    let y = sin(angle) * radius

                    Text(baguaSymbols[index])
                        .font(.system(size: 22, weight: .regular, design: .serif))
                        .foregroundStyle(isPressing ? goldColor : .white.opacity(0.85))
                        .shadow(color: .white.opacity(0.25), radius: 6)
                        .offset(x: x, y: y)
                }
            }
            .rotationEffect(.degrees(elapsed * baguaSpinDegreesPerSecond))

            CastingTaijiView(elapsed: elapsed, spinDegreesPerSecond: taijiSpinDegreesPerSecond)
                .frame(width: 84, height: 84)
        }
        .frame(width: 240, height: 240)
        .scaleEffect(isPressing ? 0.95 : 1)
        .animation(.easeOut(duration: 0.2), value: isPressing)
        .contentShape(Circle())
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in
                beginGathering()
            }
            .onEnded { _ in
                endGathering()
            }
        )
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

    private func phantomLayer(size: CGSize, now: Date) -> some View {
        ZStack {
            ForEach(phantomGlyphs) { glyph in
                let age = now.timeIntervalSince(glyph.bornAt)
                if age >= 0, age <= glyph.duration {
                    let progress = min(max(age / glyph.duration, 0), 1)
                    let xRange = size.width * 1.2 + 120
                    let x = size.width + 60 - xRange * progress
                    let y = size.height * glyph.yRatio
                    let opacity = phantomOpacity(for: progress) * 0.35
                    let blurRadius = phantomBlur(for: progress)
                    let scale = 0.8 + progress * 0.7

                    Text(glyph.symbol)
                        .font(.system(size: glyph.fontSize, weight: .regular, design: .serif))
                        .foregroundStyle(goldColor.opacity(opacity))
                        .shadow(color: goldColor.opacity(opacity), radius: 10)
                        .scaleEffect(scale)
                        .blur(radius: blurRadius)
                        .position(x: x, y: y)
                }
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func beginGathering() {
        guard showQiArea, !isCompleted else { return }
        guard isPressing == false else { return }

        isPressing = true
        subtitleText = "万象衍化 · 寻真求一"
        decayTask?.cancel()
        decayTask = nil

        if revealedLineCount == 0 {
            generatedLines = (0..<6).map { _ in Bool.random() }
            movingIndex = Int.random(in: 0..<6)
            showResult = false
        }

        startPhantomLoop()
        startProgressLoop()
    }

    private func endGathering() {
        guard isPressing else { return }
        isPressing = false

        guard !isCompleted else { return }
        subtitleText = "放空思绪 · 长按太极聚气"
        progressTask?.cancel()
        progressTask = nil
        stopPhantomLoop(clearGlyphs: true)
        startDecayLoop()
    }

    private func startProgressLoop() {
        progressTask?.cancel()
        progressTask = Task {
            let step = 100.0 / (holdDuration / 0.02)

            while Task.isCancelled == false {
                try? await Task.sleep(nanoseconds: progressTickNanos)

                let shouldStop = await MainActor.run { () -> Bool in
                    guard isPressing, !isCompleted else { return true }

                    progress = min(100, progress + step)
                    syncRevealedLineCount()

                    if progress >= 100 {
                        finishGathering()
                        return true
                    }
                    return false
                }

                if shouldStop { break }
            }
        }
    }

    private func startDecayLoop() {
        decayTask?.cancel()
        decayTask = Task {
            while Task.isCancelled == false {
                try? await Task.sleep(nanoseconds: decayTickNanos)

                let shouldStop = await MainActor.run { () -> Bool in
                    guard !isPressing, !isCompleted else { return true }

                    progress = max(0, progress - 3)
                    syncRevealedLineCount()

                    if progress == 0 {
                        revealedLineCount = 0
                        return true
                    }
                    return false
                }

                if shouldStop { break }
            }
        }
    }

    @MainActor
    private func finishGathering() {
        guard isCompleted == false else { return }

        isPressing = false
        isCompleted = true
        subtitleText = "天机已定"
        progressTask?.cancel()
        decayTask?.cancel()
        stopPhantomLoop(clearGlyphs: true)

        withAnimation(.timingCurve(0.4, 0, 0.2, 1, duration: 0.8)) {
            showQiArea = false
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation(.easeInOut(duration: 0.8)) {
                showResult = true
            }
        }
    }

    @MainActor
    private func syncRevealedLineCount() {
        let target = Int(floor((progress / 100.0) * 6.0))
        if target != revealedLineCount {
            withAnimation(.timingCurve(0.1, 0.8, 0.2, 1, duration: 0.35)) {
                revealedLineCount = target
            }
        }
    }

    private func lineIsYang(at index: Int) -> Bool {
        guard generatedLines.indices.contains(index) else { return true }
        return generatedLines[index]
    }

    private func refreshStarsIfNeeded(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let widthChanged = abs(size.width - starCanvasSize.width) > 2
        let heightChanged = abs(size.height - starCanvasSize.height) > 2
        guard stars.isEmpty || widthChanged || heightChanged else { return }

        var generator = CastingSeededGenerator(state: 0xCA5719AA)
        stars = (0..<260).map { _ in
            CastingDustParticle(
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

                return CastingConstellationPoint(
                    position: CGPoint(x: centerX + rotatedX, y: centerY + rotatedY),
                    radius: Double.random(in: 1.1...2.1, using: &generator),
                    baseOpacity: Double.random(in: 0.55...0.95, using: &generator),
                    phase: Double.random(in: 0...(2 * .pi), using: &generator)
                )
            }

            return CastingConstellationGroup(
                points: points,
                lineOpacity: Double.random(in: 0.18...0.3, using: &generator)
            )
        }

        starCanvasSize = size
    }

    private func startPhantomLoop() {
        phantomTask?.cancel()
        phantomTask = Task {
            while Task.isCancelled == false {
                await MainActor.run {
                    spawnPhantomGlyph()
                }
                try? await Task.sleep(nanoseconds: 120_000_000)
            }
        }
    }

    private func stopPhantomLoop(clearGlyphs: Bool) {
        phantomTask?.cancel()
        phantomTask = nil
        if clearGlyphs {
            phantomGlyphs.removeAll()
        }
    }

    @MainActor
    private func spawnPhantomGlyph() {
        let showHexagramSymbol = Bool.random()
        let symbol: String

        if showHexagramSymbol, let scalar = UnicodeScalar(0x4DC0 + Int.random(in: 0..<64)) {
            symbol = String(scalar)
        } else {
            symbol = baguaNames.randomElement() ?? "乾"
        }

        let glyph = PhantomGlyph(
            symbol: symbol,
            yRatio: Double.random(in: 0.1...0.7),
            fontSize: Double.random(in: showHexagramSymbol ? 36...68 : 26...44),
            duration: Double.random(in: 1.0...2.5),
            bornAt: Date()
        )

        phantomGlyphs.append(glyph)
        let now = Date()
        phantomGlyphs.removeAll { now.timeIntervalSince($0.bornAt) > $0.duration }
    }

    private func wrapped(_ value: Double, maxValue: Double) -> Double {
        guard maxValue > 0 else { return 0 }
        var wrappedValue = value.truncatingRemainder(dividingBy: maxValue)
        if wrappedValue < 0 {
            wrappedValue += maxValue
        }
        return wrappedValue
    }

    private func phantomOpacity(for progress: Double) -> Double {
        switch progress {
        case 0..<0.2:
            return progress / 0.2
        case 0.2..<0.8:
            return 1
        default:
            return max(0, (1 - progress) / 0.2)
        }
    }

    private func phantomBlur(for progress: Double) -> Double {
        if progress < 0.2 {
            return 8 - progress * 30
        }
        if progress < 0.8 {
            return 2
        }
        return 2 + (progress - 0.8) * 30
    }
}

private struct CastingTaijiView: View {
    let elapsed: Double
    let spinDegreesPerSecond: Double

    var body: some View {
        Canvas { context, size in
            context.withCGContext { cg in
                let radius = min(size.width, size.height) / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                cg.saveGState()
                cg.translateBy(x: center.x, y: center.y)
                cg.rotate(by: elapsed * spinDegreesPerSecond * .pi / 180.0)

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

                cg.setStrokeColor(CGColor(gray: 1, alpha: 1))
                cg.setLineWidth(2)
                cg.strokeEllipse(in: CGRect(x: -radius + 1, y: -radius + 1, width: radius * 2 - 2, height: radius * 2 - 2))
                cg.restoreGState()
            }
        }
        .shadow(color: .white.opacity(0.4), radius: 20)
    }
}

private struct PhantomGlyph: Identifiable {
    let id = UUID()
    let symbol: String
    let yRatio: Double
    let fontSize: Double
    let duration: Double
    let bornAt: Date
}

private struct CastingDustParticle {
    let startX: Double
    let startY: Double
    let radius: Double
    let velocityX: Double
    let velocityY: Double
    let opacity: Double
}

private struct CastingConstellationGroup {
    let points: [CastingConstellationPoint]
    let lineOpacity: Double
}

private struct CastingConstellationPoint {
    let position: CGPoint
    let radius: Double
    let baseOpacity: Double
    let phase: Double
}

private struct CastingSeededGenerator: RandomNumberGenerator {
    var state: UInt64

    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

#Preview {
    HexagramCastingView()
}
