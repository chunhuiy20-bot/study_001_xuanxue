import SwiftUI

struct ArchiveRecordsView: View {
    private let backgroundColor = Color(red: 2.0 / 255.0, green: 3.0 / 255.0, blue: 8.0 / 255.0)
    private let goldColor = Color(red: 230.0 / 255.0, green: 194.0 / 255.0, blue: 122.0 / 255.0)
    private let textSubColor = Color(red: 160.0 / 255.0, green: 165.0 / 255.0, blue: 181.0 / 255.0)
    private let textDarkColor = Color(red: 90.0 / 255.0, green: 96.0 / 255.0, blue: 114.0 / 255.0)
    private let fireCoreColor = Color(red: 1.0, green: 226.0 / 255.0, blue: 89.0 / 255.0)
    private let fireMidColor = Color(red: 1.0, green: 126.0 / 255.0, blue: 0)
    private let fireEdgeColor = Color(red: 1.0, green: 0, blue: 0)

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

    let onBack: () -> Void
    let showsEmbeddedBottomNav: Bool
    let isActive: Bool

    @State private var startTime = Date()
    @State private var stars: [ArchiveDustStar] = []
    @State private var constellationGroups: [ArchiveConstellationGroup] = []
    @State private var canvasSize: CGSize = .zero

    @State private var tokens: [ArchiveToken] = ArchiveToken.makeInitial()
    @State private var currentAngle = 0.0
    @State private var dragStartAngle = 0.0
    @State private var dragStartPoint: CGPoint?
    @State private var isDragging = false
    @State private var isAutoDrifting = true
    @State private var autoDriftDirection = -1.0

    @State private var selectedToken: ArchiveToken?
    @State private var showDetail = false
    @State private var hintOpacity = 0.65
    @State private var isBurning = false
    @State private var burningTokenID: String?
    @State private var burnProgressByID: [String: Double] = [:]
    @State private var burnParticles: [ArchiveBurnParticle] = []

    @State private var toastMessage = ""
    @State private var showToast = false

    @State private var decodedName1 = ""
    @State private var decodedName2 = ""
    @State private var decodedQuestion = ""
    @State private var decodedVerdict = ""
    @State private var isDecoding = false

    @State private var driftTask: Task<Void, Never>?
    @State private var resumeDriftTask: Task<Void, Never>?
    @State private var burnTask: Task<Void, Never>?
    @State private var toastTask: Task<Void, Never>?
    @State private var decodeTask: Task<Void, Never>?

    init(
        onBack: @escaping () -> Void = {},
        showsEmbeddedBottomNav: Bool = true,
        isActive: Bool = true
    ) {
        self.onBack = onBack
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

                    starField(size: proxy.size, elapsed: elapsed)
                        .ignoresSafeArea()

                    Rectangle()
                        .fill(.white.opacity(0.05))
                        .blendMode(.overlay)
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        headerView
                            .opacity(showDetail ? 0 : 1)

                        Text("拨动圆柱 · 下拉解读 · 长按焚毁")
                            .font(.system(size: 12, weight: .regular, design: .serif))
                            .tracking(4)
                            .foregroundStyle(goldColor)
                            .opacity(hintOpacity)
                            .padding(.top, 16)

                        Spacer()
                    }

                    tokenUniverseView(size: proxy.size)
                        .blur(radius: showDetail ? 18 : 0)
                        .brightness(showDetail ? -0.3 : 0)
                        .scaleEffect(showDetail ? 0.7 : 1)
                        .animation(.timingCurve(0.16, 1, 0.3, 1, duration: 1.2), value: showDetail)

                    burnParticleLayer(size: proxy.size, now: timeline.date)

                    if let token = selectedToken, showDetail {
                        detailOverlayView(token: token, canvasSize: proxy.size)
                            .transition(.opacity)
                    }

                    if showToast {
                        toastView
                    }

                    if showsEmbeddedBottomNav {
                        VStack {
                            Spacer()
                            bottomNav
                                .offset(y: showDetail ? 120 : 0)
                                .animation(.timingCurve(0.16, 1, 0.3, 1, duration: 1.2), value: showDetail)
                        }
                    }
                }
            }
            .onAppear {
                startTime = Date()
                refreshStarsIfNeeded(for: proxy.size)
                startAutoDriftLoop()
            }
            .onChange(of: proxy.size) { _, newSize in
                refreshStarsIfNeeded(for: newSize)
            }
            .onDisappear {
                driftTask?.cancel()
                resumeDriftTask?.cancel()
                burnTask?.cancel()
                toastTask?.cancel()
                decodeTask?.cancel()
                driftTask = nil
                resumeDriftTask = nil
                burnTask = nil
                toastTask = nil
                decodeTask = nil
                burnParticles.removeAll()
                burnProgressByID.removeAll()
            }
        }
    }

    private var anglePerItem: Double {
        guard tokens.isEmpty == false else { return 45 }
        return 360.0 / Double(tokens.count)
    }

    private var activeIndex: Int {
        guard tokens.isEmpty == false else { return 0 }
        let idx = Int(round(-currentAngle / anglePerItem))
        let fixed = ((idx % tokens.count) + tokens.count) % tokens.count
        return fixed
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("天机秘档")
                .font(.system(size: 22, weight: .medium, design: .serif))
                .tracking(12)
                .foregroundStyle(goldColor)

            Text("AKASHIC RECORDS")
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .tracking(4)
                .foregroundStyle(textSubColor.opacity(0.5))
        }
        .padding(.top, 50)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [backgroundColor, backgroundColor.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func tokenUniverseView(size: CGSize) -> some View {
        let centerY = size.height * 0.53

        return ZStack {
            ForEach(tokens.indices, id: \.self) { index in
                if let visual = tokenVisualState(index: index, size: size) {
                    ArchiveTokenCardView(
                        token: tokens[index],
                        active: index == activeIndex,
                        isBurning: burningTokenID == tokens[index].id,
                        burnProgress: burnProgressByID[tokens[index].id] ?? 0,
                        goldColor: goldColor,
                        textDarkColor: textDarkColor,
                        fireCoreColor: fireCoreColor,
                        fireMidColor: fireMidColor,
                        fireEdgeColor: fireEdgeColor
                    )
                    .frame(width: 64, height: 190)
                    .scaleEffect(visual.scale)
                    .opacity(visual.opacity)
                    .blur(radius: visual.blur)
                    .offset(x: visual.x, y: 0)
                    .onTapGesture {
                        guard showDetail == false, isBurning == false else { return }
                        guard index == activeIndex else { return }
                        openDetail(tokens[index])
                    }
                    .onLongPressGesture(minimumDuration: 0.8, maximumDistance: 16) {
                        guard showDetail == false, isBurning == false else { return }
                        guard index == activeIndex else { return }
                        triggerBurn(at: index)
                    }
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .position(x: size.width / 2, y: centerY)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard showDetail == false, isBurning == false else { return }
                    if dragStartPoint == nil {
                        dragStartPoint = value.startLocation
                        dragStartAngle = currentAngle
                        isDragging = true
                        pauseAutoDrift()
                    }

                    let dx = value.location.x - (dragStartPoint?.x ?? value.startLocation.x)
                    let dy = value.location.y - (dragStartPoint?.y ?? value.startLocation.y)

                    currentAngle = dragStartAngle + Double(dx) * 0.25
                    if abs(dx) > 10 || abs(dy) > 10 {
                        withAnimation(.easeOut(duration: 0.25)) {
                            hintOpacity = 0
                        }
                    }
                }
                .onEnded { value in
                    guard showDetail == false, isBurning == false else {
                        dragStartPoint = nil
                        isDragging = false
                        return
                    }
                    let dx = value.location.x - (dragStartPoint?.x ?? value.startLocation.x)
                    let dy = value.location.y - (dragStartPoint?.y ?? value.startLocation.y)

                    if dy > 80, abs(dy) > abs(dx), tokens.indices.contains(activeIndex) {
                        openDetail(tokens[activeIndex])
                    } else {
                        snapToNearestToken()
                    }

                    if dx > 5 { autoDriftDirection = 1 }
                    if dx < -5 { autoDriftDirection = -1 }

                    dragStartPoint = nil
                    isDragging = false
                    resumeAutoDriftLater()

                    withAnimation(.easeOut(duration: 0.4)) {
                        hintOpacity = 0.65
                    }
                }
        )
    }

    private func tokenOrbitRadius(for size: CGSize) -> Double {
        max(min(size.width * 1.06, 460), 360)
    }

    private var tokenVisibleAngleLimit: Double {
        62.0
    }

    private func tokenVisualState(index: Int, size: CGSize) -> ArchiveTokenVisualState? {
        guard tokens.indices.contains(index) else { return nil }
        let orbitRadius = tokenOrbitRadius(for: size)
        let itemAngle = Double(index) * anglePerItem + currentAngle
        let normalized = normalizedAngle(itemAngle)
        guard abs(normalized) <= tokenVisibleAngleLimit else { return nil }

        let rad = normalized * .pi / 180.0
        let x = sin(rad) * orbitRadius
        let depth = max(0, cos(rad))
        let scale = 0.42 + 0.58 * depth
        let opacity = 0.05 + 0.95 * depth
        let blur = (1 - depth) * 8

        return ArchiveTokenVisualState(
            x: x,
            depth: depth,
            scale: scale,
            opacity: opacity,
            blur: blur
        )
    }

    private func openDetail(_ token: ArchiveToken) {
        pauseAutoDrift()
        selectedToken = token
        resetDecodedText()
        withAnimation(.easeInOut(duration: 0.6)) {
            showDetail = true
        }
        if let record = token.record {
            startDecodeSequence(for: record)
        }
    }

    private func closeDetail() {
        decodeTask?.cancel()
        isDecoding = false
        withAnimation(.easeInOut(duration: 0.6)) {
            showDetail = false
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 650_000_000)
            if showDetail == false {
                selectedToken = nil
            }
        }
        resumeAutoDriftLater()
    }

    private func detailOverlayView(token: ArchiveToken, canvasSize: CGSize) -> some View {
        let cardWidth = min(canvasSize.width * 0.85, 400)
        let cardHeight = min(canvasSize.height * 0.7, 650)

        return ZStack {
            backgroundColor.opacity(0.6)
                .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 25.0 / 255.0, green: 30.0 / 255.0, blue: 40.0 / 255.0).opacity(0.8),
                            Color(red: 5.0 / 255.0, green: 7.0 / 255.0, blue: 12.0 / 255.0).opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(goldColor.opacity(0.4), lineWidth: 1)
                )
                .overlay {
                    if let record = token.record {
                        detailCardBody(record: record)
                    } else {
                        dummyDetailCardBody(token: token)
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .shadow(color: .black.opacity(0.9), radius: 40, y: 20)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onEnded { value in
                            if value.translation.height < -80 {
                                closeDetail()
                            }
                        }
                )
                .overlay(alignment: .top) {
                    Text("↑ 向上滑动推回虚空")
                        .font(.system(size: 12, weight: .regular, design: .serif))
                        .tracking(4)
                        .foregroundStyle(textSubColor.opacity(0.6))
                        .offset(y: -30)
                }
        }
    }

    @ViewBuilder
    private func detailCardBody(record: ArchiveRecord) -> some View {
        let isPending = record.status == "待叩问"

        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(record.dateAncient)
                        .font(.system(size: 17, weight: .regular, design: .serif))
                        .foregroundStyle(goldColor)
                    Text(record.dateModern)
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(textDarkColor)
                }

                Spacer()

                Text(record.status)
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .foregroundStyle(isPending ? textDarkColor : Color(red: 163.0 / 255.0, green: 28.0 / 255.0, blue: 28.0 / 255.0))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(isPending ? textDarkColor : Color(red: 163.0 / 255.0, green: 28.0 / 255.0, blue: 28.0 / 255.0), lineWidth: 1)
                    )
                    .rotationEffect(.degrees(isPending ? 0 : -5))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Divider()
                .background(.white.opacity(0.08))

            HStack(alignment: .top, spacing: 20) {
                VStack(spacing: 14) {
                    ArchiveHexBox(lines: record.hex1Lines, name: decodedName1, highlight: false, goldColor: goldColor, subColor: textSubColor)
                    Text("↓")
                        .font(.system(size: 22, weight: .regular, design: .serif))
                        .foregroundStyle(textDarkColor)
                    ArchiveHexBox(lines: record.hex2Lines, name: decodedName2, highlight: true, goldColor: goldColor, subColor: textSubColor)
                }
                .frame(width: 72)

                ScrollView(.vertical, showsIndicators: false) {
                    Text(decodedQuestion + (isDecoding ? "▋" : ""))
                        .font(
                            isPending
                            ? .system(size: 20, weight: .regular, design: .serif).italic()
                            : .system(size: 20, weight: .regular, design: .serif)
                        )
                        .lineSpacing(10)
                        .foregroundStyle(isPending ? textDarkColor : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 22)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(isPending ? textDarkColor : goldColor)
                        .frame(width: 4, height: 12)
                        .cornerRadius(2)
                    Text(isPending ? "神谕空缺" : "天机判词")
                        .font(.system(size: 12, weight: .regular, design: .serif))
                        .tracking(4)
                        .foregroundStyle(isPending ? textDarkColor : goldColor)
                }

                Text(decodedVerdict + (isDecoding ? "▋" : ""))
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .lineSpacing(6)
                    .foregroundStyle(isPending ? textDarkColor : textSubColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 22)
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.55), .black.opacity(0.2)],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .overlay(alignment: .bottomTrailing) {
            Text(record.hex2Sym)
                .font(.system(size: 220, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.02))
                .offset(x: 30, y: 40)
        }
    }

    private func dummyDetailCardBody(token: ArchiveToken) -> some View {
        VStack(spacing: 24) {
            Text(token.hexSymbol)
                .font(.system(size: 96, weight: .regular, design: .serif))
                .foregroundStyle(textDarkColor.opacity(0.4))
            Text("残卷已毁 · 无法解读")
                .font(.system(size: 22, weight: .regular, design: .serif))
                .tracking(8)
                .foregroundStyle(textDarkColor)
        }
    }

    private var bottomNav: some View {
        HStack(spacing: 0) {
            archiveNavItem(title: "卜", active: false) {
                onBack()
            }
            archiveNavItem(title: "案", active: true, action: nil)
            archiveNavItem(title: "盘", active: false, action: nil)
            archiveNavItem(title: "我", active: false, action: nil)
        }
        .frame(height: 85)
        .padding(.bottom, 20)
        .background(
            backgroundColor.opacity(0.85)
                .overlay(
                    Rectangle()
                        .fill(.white.opacity(0.05))
                        .frame(height: 1),
                    alignment: .top
                )
        )
    }

    private var toastView: some View {
        Text(toastMessage)
            .font(.system(size: 14, weight: .regular, design: .serif))
            .tracking(4)
            .foregroundStyle(goldColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(backgroundColor.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(goldColor.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.8), radius: 12, y: 8)
            .transition(.opacity.combined(with: .scale(scale: 0.96)))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(false)
    }

    private func archiveNavItem(title: String, active: Bool, action: (() -> Void)?) -> some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundStyle(active ? goldColor : textDarkColor)
                Circle()
                    .fill(active ? goldColor : .clear)
                    .frame(width: 4, height: 4)
                    .shadow(color: active ? goldColor : .clear, radius: 8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func resetDecodedText() {
        decodedName1 = ""
        decodedName2 = ""
        decodedQuestion = ""
        decodedVerdict = ""
        isDecoding = false
    }

    private func startDecodeSequence(for record: ArchiveRecord) {
        decodeTask?.cancel()
        resetDecodedText()

        decodeTask = Task { @MainActor in
            isDecoding = true

            try? await Task.sleep(nanoseconds: 1_400_000_000)
            await typewriter(record.hex1Name) { decodedName1 = $0 }

            try? await Task.sleep(nanoseconds: 100_000_000)
            await typewriter(record.hex2Name) { decodedName2 = $0 }

            try? await Task.sleep(nanoseconds: 200_000_000)
            let questionText = record.status == "待叩问" ? record.question : "「 问：\(record.question) 」"
            await typewriter(questionText, stepNs: 28_000_000) { decodedQuestion = $0 }

            try? await Task.sleep(nanoseconds: 120_000_000)
            await typewriter(record.verdict) { decodedVerdict = $0 }

            isDecoding = false
        }
    }

    @MainActor
    private func typewriter(_ text: String, stepNs: UInt64 = 32_000_000, update: (String) -> Void) async {
        var current = ""
        for char in text {
            if Task.isCancelled { return }
            current.append(char)
            update(current)
            try? await Task.sleep(nanoseconds: stepNs)
        }
    }

    private func triggerBurn(at index: Int) {
        guard tokens.indices.contains(index), isBurning == false else { return }
        let token = tokens[index]
        guard token.record != nil else {
            showSystemToast("残卷不可焚毁")
            return
        }

        isBurning = true
        pauseAutoDrift()
        burningTokenID = token.id
        burnProgressByID[token.id] = 0

        burnTask?.cancel()
        burnTask = Task { @MainActor in
            let intervalNanoseconds: UInt64 = 30_000_000
            let durationNanoseconds: UInt64 = 2_100_000_000
            let steps = max(1, Int(durationNanoseconds / intervalNanoseconds))

            for step in 0...steps {
                guard Task.isCancelled == false else {
                    clearBurnState(tokenID: token.id)
                    return
                }
                let progress = Double(step) / Double(steps)
                burnProgressByID[token.id] = progress
                spawnBurnParticles(tokenID: token.id, progress: progress)
                try? await Task.sleep(nanoseconds: intervalNanoseconds)
            }

            guard let removalIndex = tokens.firstIndex(where: { $0.id == token.id }) else {
                clearBurnState(tokenID: token.id)
                resumeAutoDriftLater()
                return
            }

            var healed = false
            _ = withAnimation(.easeInOut(duration: 0.25)) {
                tokens.remove(at: removalIndex)
            }

            if tokens.count < 18 {
                tokens.append(makeDummyToken())
                healed = true
            }

            if tokens.isEmpty == false {
                let newActive = min(removalIndex, tokens.count - 1)
                currentAngle = -Double(newActive) * anglePerItem
            } else {
                currentAngle = 0
            }

            clearBurnState(tokenID: token.id)
            resumeAutoDriftLater()
            showSystemToast(healed ? "天机已散，虚空重组" : "因果已抹除，星轨收缩")
        }
    }

    private func clearBurnState(tokenID: String) {
        burningTokenID = nil
        burnProgressByID[tokenID] = nil
        burnParticles.removeAll { $0.tokenID == tokenID }
        isBurning = false
    }

    @MainActor
    private func spawnBurnParticles(tokenID: String, progress: Double) {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return }
        guard let index = tokens.firstIndex(where: { $0.id == tokenID }) else { return }
        guard let visual = tokenVisualState(index: index, size: canvasSize) else { return }

        let centerX = Double(canvasSize.width / 2) + visual.x
        let centerY = Double(canvasSize.height * 0.53)
        let tokenWidth = 64.0 * visual.scale
        let tokenHeight = 190.0 * visual.scale
        let currentBurnY = centerY + tokenHeight * 0.5 - tokenHeight * progress
        let count = Int.random(in: 3...5)

        for _ in 0..<count {
            let isSpark = Double.random(in: 0...1) > 0.35
            let startX = centerX + Double.random(in: -(tokenWidth * 0.55)...(tokenWidth * 0.55))
            let duration = Double.random(in: 1.0...2.3)
            let moveX = Double.random(in: -42...42)
            let moveY = Double.random(in: 55...145)
            let size = Double.random(in: isSpark ? 1.8...3.5 : 2.5...4.8)

            burnParticles.append(
                ArchiveBurnParticle(
                    tokenID: tokenID,
                    isSpark: isSpark,
                    startX: startX,
                    startY: currentBurnY,
                    moveX: moveX,
                    moveY: moveY,
                    size: size,
                    duration: duration,
                    bornAt: Date()
                )
            )
        }

        let now = Date()
        burnParticles.removeAll { now.timeIntervalSince($0.bornAt) > $0.duration }
    }

    private func makeDummyToken() -> ArchiveToken {
        let value = Int.random(in: 0..<64)
        let fallback = UnicodeScalar(0x4DC0)!
        let scalar = UnicodeScalar(0x4DC0 + value) ?? fallback
        return ArchiveToken(
            id: "dummy-regen-\(UUID().uuidString)",
            hexSymbol: String(scalar),
            name: "虚空残影",
            record: nil
        )
    }

    private func showSystemToast(_ text: String) {
        toastTask?.cancel()
        toastMessage = text
        withAnimation(.easeOut(duration: 0.35)) {
            showToast = true
        }

        toastTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            withAnimation(.easeIn(duration: 0.35)) {
                showToast = false
            }
        }
    }

    private func burnParticleLayer(size: CGSize, now: Date) -> some View {
        ZStack {
            ForEach(burnParticles) { particle in
                let age = now.timeIntervalSince(particle.bornAt)
                if age >= 0, age <= particle.duration {
                    let progress = min(max(age / particle.duration, 0), 1)
                    let x = particle.startX + particle.moveX * progress
                    let y = particle.startY - particle.moveY * progress
                    let scale = particle.isSpark ? max(0, 1 - progress) : (1 + 0.5 * progress)
                    let opacity = (particle.isSpark ? 1.0 : 0.82) * (1 - progress)
                    let rotation = particle.isSpark ? 0 : (360 * progress)

                    Circle()
                        .fill(particle.isSpark ? fireCoreColor : Color(red: 34.0 / 255.0, green: 34.0 / 255.0, blue: 34.0 / 255.0))
                        .frame(width: CGFloat(particle.size), height: CGFloat(particle.size))
                        .shadow(color: particle.isSpark ? fireMidColor : .black, radius: particle.isSpark ? 9 : 4)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                        .opacity(opacity)
                        .position(x: CGFloat(x), y: CGFloat(y))
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }

    private func normalizedAngle(_ angle: Double) -> Double {
        var value = angle.truncatingRemainder(dividingBy: 360)
        if value > 180 { value -= 360 }
        if value < -180 { value += 360 }
        return value
    }

    private func pauseAutoDrift() {
        isAutoDrifting = false
        resumeDriftTask?.cancel()
        resumeDriftTask = nil
    }

    private func resumeAutoDriftLater() {
        resumeDriftTask?.cancel()
        resumeDriftTask = Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            await MainActor.run {
                if isDragging == false, showDetail == false {
                    isAutoDrifting = true
                }
            }
        }
    }

    private func snapToNearestToken() {
        guard tokens.isEmpty == false else { return }
        let snapped = round(-currentAngle / anglePerItem) * anglePerItem
        withAnimation(.easeOut(duration: 0.25)) {
            currentAngle = -snapped
        }
    }

    private func startAutoDriftLoop() {
        driftTask?.cancel()
        driftTask = Task {
            while Task.isCancelled == false {
                try? await Task.sleep(nanoseconds: 16_000_000)
                await MainActor.run {
                    guard isAutoDrifting, isDragging == false, showDetail == false, isBurning == false else { return }
                    currentAngle += 0.08 * autoDriftDirection
                }
            }
        }
    }

    private func refreshStarsIfNeeded(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let widthChanged = abs(size.width - canvasSize.width) > 2
        let heightChanged = abs(size.height - canvasSize.height) > 2
        guard stars.isEmpty || widthChanged || heightChanged else { return }

        var generator = ArchiveSeededGenerator(state: 0xBEEF2026)
        stars = (0..<150).map { _ in
            ArchiveDustStar(
                x: Double.random(in: -(size.width * 0.5)...(size.width * 1.5), using: &generator),
                y: Double.random(in: -(size.height * 0.5)...(size.height * 1.5), using: &generator),
                radius: Double.random(in: 0.2...1.4, using: &generator),
                phase: Double.random(in: 0...(2 * .pi), using: &generator),
                baseOpacity: Double.random(in: 0.1...0.5, using: &generator)
            )
        }

        constellationGroups = constellationShapes.map { shape in
            let centerX = Double.random(in: -(size.width * 0.4)...(size.width * 1.4), using: &generator)
            let centerY = Double.random(in: -(size.height * 0.4)...(size.height * 1.4), using: &generator)
            let angle = Double.random(in: 0...(2 * .pi), using: &generator)
            let scale = Double.random(in: 1.0...2.5, using: &generator)

            let cosA = cos(angle)
            let sinA = sin(angle)

            let points = shape.map { p in
                let ox = Double(p.x) * scale
                let oy = Double(p.y) * scale
                let rx = ox * cosA - oy * sinA
                let ry = ox * sinA + oy * cosA
                return ArchiveConstellationPoint(
                    position: CGPoint(x: centerX + rx, y: centerY + ry),
                    radius: Double.random(in: 0.8...1.8, using: &generator),
                    baseOpacity: Double.random(in: 0.3...0.75, using: &generator),
                    phase: Double.random(in: 0...(2 * .pi), using: &generator)
                )
            }

            return ArchiveConstellationGroup(points: points)
        }

        canvasSize = size
    }

    private func starField(size: CGSize, elapsed: Double) -> some View {
        Canvas { context, canvasSize in
            context.translateBy(x: canvasSize.width / 2, y: canvasSize.height / 2)
            context.rotate(by: .radians(elapsed * 0.0003 * 60.0))
            context.translateBy(x: -canvasSize.width / 2, y: -canvasSize.height / 2)

            for group in constellationGroups {
                if group.points.count >= 2 {
                    var path = Path()
                    path.move(to: group.points[0].position)
                    for point in group.points.dropFirst() {
                        path.addLine(to: point.position)
                    }
                    context.stroke(path, with: .color(.white.opacity(0.12)), lineWidth: 0.5)
                }

                for point in group.points {
                    let twinkle = (sin(elapsed * 2.0 + point.phase) + 1) / 2
                    let opacity = point.baseOpacity * (0.6 + twinkle * 0.4)
                    let radius = point.radius * (0.8 + twinkle * 0.2)

                    let rect = CGRect(x: point.position.x - radius, y: point.position.y - radius, width: radius * 2, height: radius * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(goldColor.opacity(opacity)))
                }
            }

            for star in stars {
                let twinkle = (sin(elapsed * 1.5 + star.phase) + 1) / 2
                let opacity = star.baseOpacity * (0.6 + twinkle * 0.4)
                let rect = CGRect(x: star.x - star.radius, y: star.y - star.radius, width: star.radius * 2, height: star.radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

private struct ArchiveTokenCardView: View {
    let token: ArchiveToken
    let active: Bool
    let isBurning: Bool
    let burnProgress: Double
    let goldColor: Color
    let textDarkColor: Color
    let fireCoreColor: Color
    let fireMidColor: Color
    let fireEdgeColor: Color

    var body: some View {
        let clampedBurn = min(max(burnProgress, 0), 1)
        let vanishProgress = min(max((clampedBurn - 0.82) / 0.18, 0), 1)

        return RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(
                LinearGradient(
                    colors: active ? [goldColor.opacity(0.25), .white.opacity(0.05)] : [goldColor.opacity(0.15), .white.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(active ? goldColor : .white.opacity(token.isDummy ? 0.08 : 0.3), lineWidth: 1)
            )
            .overlay(
                VStack(spacing: 14) {
                    Text(token.hexSymbol)
                        .font(.system(size: 40, weight: .regular, design: .serif))
                        .foregroundStyle(token.isDummy ? textDarkColor : goldColor)
                        .shadow(color: token.isDummy ? .clear : goldColor.opacity(0.5), radius: 12)

                    ArchiveVerticalText(
                        text: token.name,
                        foregroundColor: token.isDummy ? textDarkColor : .white.opacity(0.9)
                    )
                }
            )
            .overlay(alignment: .center) {
                if isBurning {
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [fireCoreColor, fireMidColor, fireEdgeColor, .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 42
                            )
                        )
                        .frame(width: 120, height: 56)
                        .blur(radius: 7)
                        .offset(y: 95 - (190 * clampedBurn))
                        .blendMode(.screen)
                }
            }
            .mask(
                isBurning
                ? AnyView(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .clear, location: clampedBurn),
                            .init(color: .black, location: min(1, clampedBurn + 0.14)),
                            .init(color: .black, location: 1)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                : AnyView(Rectangle().fill(.black))
            )
            .opacity(1 - (0.96 * vanishProgress))
            .scaleEffect(1 - (0.85 * vanishProgress))
            .blur(radius: 14 * vanishProgress)
            .animation(.linear(duration: 0.03), value: burnProgress)
    }
}

private struct ArchiveHexBox: View {
    let lines: [Bool]
    let name: String
    let highlight: Bool
    let goldColor: Color
    let subColor: Color

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, isYang in
                    if isYang {
                        Capsule(style: .continuous)
                            .fill(highlight ? goldColor : subColor)
                            .frame(width: 40, height: 4)
                            .shadow(color: highlight ? goldColor.opacity(0.7) : .clear, radius: 8)
                    } else {
                        HStack(spacing: 6) {
                            Capsule(style: .continuous)
                                .fill(highlight ? goldColor : subColor)
                                .frame(width: 17, height: 4)
                                .shadow(color: highlight ? goldColor.opacity(0.7) : .clear, radius: 8)
                            Capsule(style: .continuous)
                                .fill(highlight ? goldColor : subColor)
                                .frame(width: 17, height: 4)
                                .shadow(color: highlight ? goldColor.opacity(0.7) : .clear, radius: 8)
                        }
                    }
                }
            }

            Text(name)
                .font(.system(size: 13, weight: highlight ? .bold : .regular, design: .serif))
                .foregroundStyle(highlight ? goldColor : .white.opacity(0.8))
                .tracking(2)
        }
        .opacity(highlight ? 1 : 0.4)
    }
}

private struct ArchiveVerticalText: View {
    let text: String
    let foregroundColor: Color

    var body: some View {
        VStack(spacing: 2) {
            ForEach(Array(text).map(String.init), id: \.self) { char in
                Text(char)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundStyle(foregroundColor)
                    .lineLimit(1)
            }
        }
    }
}

private struct ArchiveRecord {
    let id: String
    let dateAncient: String
    let dateModern: String
    let status: String
    let question: String
    let hex1Sym: String
    let hex1Name: String
    let hex1Lines: [Bool]
    let hex2Sym: String
    let hex2Name: String
    let hex2Lines: [Bool]
    let verdict: String
}

private struct ArchiveToken: Identifiable {
    let id: String
    let hexSymbol: String
    let name: String
    let record: ArchiveRecord?

    var isDummy: Bool { record == nil }

    static func makeInitial() -> [ArchiveToken] {
        let real: [ArchiveRecord] = [
            ArchiveRecord(
                id: "1",
                dateAncient: "丙辰月 戊戌日 巳时",
                dateModern: "2026-04-23 10:15",
                status: "已解",
                question: "下半年的事业是否会迎来转机，需不需要跳槽？而且如果我长篇大论问了很多很多很多很多问题，这里会不会自动换行呢？",
                hex1Sym: "䷧",
                hex1Name: "雷水解",
                hex1Lines: [false, false, true, false, true, false],
                hex2Sym: "䷲",
                hex2Name: "震为雷",
                hex2Lines: [false, false, true, false, false, true],
                verdict: "雷霆万钧，困局将破。摒弃杂念，直击核心，无需优柔寡断，必有大成。"
            ),
            ArchiveRecord(
                id: "2",
                dateAncient: "丙辰月 丁酉日 辰时",
                dateModern: "2026-04-22 08:30",
                status: "已解",
                question: "最近总是心神不宁，家里的风水布局是否有问题？",
                hex1Sym: "䷌",
                hex1Name: "天火同人",
                hex1Lines: [true, true, true, true, false, true],
                hex2Sym: "䷍",
                hex2Name: "火天大有",
                hex2Lines: [true, false, true, true, true, true],
                verdict: "同人转大有，阳气极盛。非风水之过，乃近期思虑过盛所致，宜多静心休养。"
            ),
            ArchiveRecord(
                id: "3",
                dateAncient: "乙卯月 辛亥日 子时",
                dateModern: "2026-03-15 23:45",
                status: "待叩问",
                question: "近期财运如何？",
                hex1Sym: "䷁",
                hex1Name: "坤为地",
                hex1Lines: [false, false, false, false, false, false],
                hex2Sym: "䷖",
                hex2Name: "山地剥",
                hex2Lines: [true, false, false, false, false, false],
                verdict: "天机未显，无法解读。"
            )
        ]

        var result = real.map {
            ArchiveToken(id: $0.id, hexSymbol: $0.hex1Sym, name: $0.hex1Name, record: $0)
        }

        var generator = ArchiveSeededGenerator(state: 0xAA55AA55)
        for idx in 0..<27 {
            let value = Int.random(in: 0..<64, using: &generator)
            let scalar = UnicodeScalar(0x4DC0 + value) ?? "䷀"
            result.append(
                ArchiveToken(
                    id: "dummy-\(idx)",
                    hexSymbol: String(scalar),
                    name: "天机残卷",
                    record: nil
                )
            )
        }

        return result
    }
}

private struct ArchiveDustStar {
    let x: Double
    let y: Double
    let radius: Double
    let phase: Double
    let baseOpacity: Double
}

private struct ArchiveConstellationPoint {
    let position: CGPoint
    let radius: Double
    let baseOpacity: Double
    let phase: Double
}

private struct ArchiveConstellationGroup {
    let points: [ArchiveConstellationPoint]
}

private struct ArchiveTokenVisualState {
    let x: Double
    let depth: Double
    let scale: Double
    let opacity: Double
    let blur: Double
}

private struct ArchiveBurnParticle: Identifiable {
    let id = UUID()
    let tokenID: String
    let isSpark: Bool
    let startX: Double
    let startY: Double
    let moveX: Double
    let moveY: Double
    let size: Double
    let duration: Double
    let bornAt: Date
}

private struct ArchiveSeededGenerator: RandomNumberGenerator {
    var state: UInt64

    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

#Preview {
    ArchiveRecordsView {}
}
