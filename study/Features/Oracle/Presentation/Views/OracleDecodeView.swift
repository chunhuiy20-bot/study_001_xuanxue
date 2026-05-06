import SwiftUI

struct OracleDecodeView: View {
    private enum YaoType {
        case yang
        case yin
    }

    private enum DecodeTarget {
        case quote
        case desc
        case ai
    }

    private let backgroundColor = Color(red: 2.0 / 255.0, green: 3.0 / 255.0, blue: 8.0 / 255.0)
    private let goldColor = Color(red: 230.0 / 255.0, green: 194.0 / 255.0, blue: 122.0 / 255.0)
    private let subColor = Color(red: 160.0 / 255.0, green: 165.0 / 255.0, blue: 181.0 / 255.0)
    private let fireCoreColor = Color(red: 1.0, green: 226.0 / 255.0, blue: 89.0 / 255.0)
    private let fireMidColor = Color(red: 1.0, green: 126.0 / 255.0, blue: 0)
    private let fireEdgeColor = Color(red: 1.0, green: 0, blue: 0)
    private let talismanBGColor = Color(red: 232.0 / 255.0, green: 211.0 / 255.0, blue: 153.0 / 255.0)
    private let talismanInkColor = Color(red: 163.0 / 255.0, green: 28.0 / 255.0, blue: 28.0 / 255.0)

    private let session: OracleSession
    private let oldHex: [YaoType]
    private let newHex: [YaoType]
    private let movingLineIndex: Int

    private let baguaNames = ["乾", "兑", "离", "震", "巽", "坎", "艮", "坤"]
    private let baguaTrigrams: [[Bool]] = [
        [true, true, true],
        [false, true, true],
        [true, false, true],
        [false, false, true],
        [false, false, false],
        [true, false, false],
        [false, true, false],
        [true, true, false]
    ]
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

    @State private var startTime = Date()
    @State private var stars: [OracleDustParticle] = []
    @State private var constellationGroups: [OracleConstellationGroup] = []
    @State private var canvasSize: CGSize = .zero

    @State private var watermarkText = ""
    @State private var watermarkOpacity = 0.03
    @State private var watermarkScale: CGFloat = 1

    @State private var statusID = "PENDING"
    @State private var hasTransformed = false
    @State private var oldHexOpacity = 1.0
    @State private var oldHexBlur: CGFloat = 0
    @State private var oldHexScaleX: CGFloat = 1
    @State private var centerNameText = ""
    @State private var centerNameColor = Color.white
    @State private var centerNameOpacity = 1.0

    @State private var showTaijiTransition = false
    @State private var taijiBurstStartDate: Date?
    @State private var newHexVisible = false
    @State private var newHexLineProgress = Array(repeating: 0.0, count: 6)

    @State private var phantomGlyphs: [OraclePhantomGlyph] = []
    @State private var phantomOpacity = 1.0

    @State private var terminalActive = false
    @State private var quoteVisible = false
    @State private var descVisible = false
    @State private var quoteRendered = ""
    @State private var quoteGibberish = ""
    @State private var descRendered = ""
    @State private var descGibberish = ""
    @State private var isTypingQuote = false
    @State private var isTypingDesc = false
    @State private var showFinalSeal = false
    @State private var askLayerActive = false
    @State private var askTitle = "上 达 天 听"
    @State private var askTitleOpacity = 1.0
    @State private var askInput = ""
    @State private var askInputSubmitted = false
    @State private var showTalisman = false
    @State private var talismanAppeared = false
    @State private var talismanBurnProgress = 0.0
    @State private var fireLineOpacity = 0.0
    @State private var burnGlowOpacity = 0.0
    @State private var burnParticles: [OracleBurnParticle] = []
    @State private var aiResponseActive = false
    @State private var aiResponseVisible = false
    @State private var aiEchoText = ""
    @State private var aiResponseRendered = ""
    @State private var aiResponseGibberish = ""
    @State private var isTypingAI = false

    @State private var phantomTask: Task<Void, Never>?
    @State private var transformTask: Task<Void, Never>?
    @State private var askTask: Task<Void, Never>?
    @State private var aiStreamTask: Task<Void, Never>?

    init(session: OracleSession = .preview, onBack: @escaping () -> Void) {
        self.session = session
        self.onBack = onBack
        self.oldHex = session.originalLines.map { $0 ? .yang : .yin }
        self.newHex = session.changedLines.map { $0 ? .yang : .yin }
        self.movingLineIndex = session.movingLineIndex
        _watermarkText = State(initialValue: session.originalHexagram.name)
        _centerNameText = State(initialValue: session.originalHexagram.displayName)
    }

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
                let elapsed = max(0, timeline.date.timeIntervalSince(startTime))
                let watermarkFontSize = min(proxy.size.height * 0.58, 460)
                let taijiElapsed = taijiBurstStartDate.map { max(0, timeline.date.timeIntervalSince($0)) } ?? 0

                ZStack {
                    backgroundColor
                        .ignoresSafeArea()

                    oracleStarField(size: proxy.size, elapsed: elapsed)
                        .ignoresSafeArea()

                    phantomLayer(size: proxy.size, now: timeline.date)
                        .opacity(phantomOpacity)
                        .allowsHitTesting(false)

                    Text(watermarkText)
                        .font(.system(size: watermarkFontSize, weight: .bold, design: .serif))
                        .foregroundStyle(.white.opacity(watermarkOpacity))
                        .scaleEffect(watermarkScale)
                        .position(x: proxy.size.width / 2, y: proxy.size.height * 0.4)
                        .allowsHitTesting(false)

                    Rectangle()
                        .fill(.white.opacity(0.05))
                        .blendMode(.overlay)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    VStack(spacing: 0) {
                        navHeader
                            .padding(.top, 24)
                            .padding(.horizontal, 24)
                        Spacer()
                    }

                    centerHexView
                        .position(x: proxy.size.width / 2, y: proxy.size.height * 0.35)
                        .blur(radius: askLayerActive ? 8 : 0)
                        .brightness(askLayerActive ? -0.4 : 0)
                        .scaleEffect(askLayerActive ? 0.98 : 1)

                    if showTaijiTransition {
                        TaijiTransitionView(
                            elapsed: taijiElapsed,
                            baguaTrigrams: baguaTrigrams,
                            goldColor: goldColor
                        )
                            .frame(width: 190, height: 190)
                            .position(x: proxy.size.width / 2, y: proxy.size.height * 0.35)
                            .transition(.opacity.combined(with: .scale(scale: 0.7)))
                    }

                    Button(action: openAskLayer) {
                        finalSealView(elapsed: elapsed)
                    }
                    .buttonStyle(.plain)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.52)
                    .opacity(showFinalSeal ? 1 : 0)
                    .allowsHitTesting(showFinalSeal)
                    .blur(radius: askLayerActive ? 8 : 0)
                    .brightness(askLayerActive ? -0.4 : 0)
                    .scaleEffect(askLayerActive ? 0.98 : 1)

                    oracleTerminalView
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .blur(radius: askLayerActive ? 8 : 0)
                        .brightness(askLayerActive ? -0.4 : 0)
                        .scaleEffect(askLayerActive ? 0.98 : 1)

                    askLayerView(size: proxy.size, now: timeline.date)
                        .opacity(askLayerActive ? 1 : 0)
                        .allowsHitTesting(askLayerActive)
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
                phantomTask?.cancel()
                transformTask?.cancel()
                askTask?.cancel()
                aiStreamTask?.cancel()
                phantomTask = nil
                transformTask = nil
                askTask = nil
                aiStreamTask = nil
            }
        }
    }

    private var navHeader: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(subColor)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("ORACLE // \(statusID)")
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .tracking(1.8)
                .foregroundStyle(.white.opacity(0.45))
        }
    }

    private var centerHexView: some View {
        VStack(spacing: 18) {
            Text(centerNameText)
                .font(.system(size: 26, weight: .regular, design: .serif))
                .tracking(8)
                .foregroundStyle(centerNameColor)
                .opacity(centerNameOpacity)
                .shadow(color: centerNameColor.opacity(0.4), radius: 18)

            VStack(spacing: 25) {
                if newHexVisible {
                    ForEach(Array((0..<newHex.count).reversed()), id: \.self) { index in
                        oracleYaoLine(type: newHex[index], moving: false, revealProgress: newHexLineProgress[index])
                    }
                } else {
                    ForEach(Array(oldHex.enumerated()), id: \.offset) { index, type in
                        Button {
                            if index == movingLineIndex {
                                triggerOracle()
                            }
                        } label: {
                            oracleYaoLine(type: type, moving: index == movingLineIndex && !hasTransformed)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .opacity(newHexVisible ? 1 : oldHexOpacity)
            .blur(radius: newHexVisible ? 0 : oldHexBlur)
            .scaleEffect(x: newHexVisible ? 1 : oldHexScaleX, y: 1, anchor: .center)
            .frame(width: 260)
        }
    }

    private func oracleYaoLine(type: YaoType, moving: Bool, revealProgress: Double? = nil) -> some View {
        let progress = min(max(revealProgress ?? 1, 0), 1)
        let revealBlur = (1 - progress) * 10
        let revealScale = 1 + (1 - progress) * 0.5
        let revealGlow = (1 - progress) * 30

        return ZStack(alignment: .trailing) {
            if type == .yang {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(moving ? goldColor : .white)
                    .frame(height: 18)
                    .shadow(color: (moving ? goldColor : .white).opacity(0.45), radius: moving ? 25 : 12)
            } else {
                HStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(moving ? goldColor : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 18)
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(moving ? goldColor : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 18)
                }
                .shadow(color: (moving ? goldColor : .white).opacity(0.45), radius: moving ? 25 : 12)
            }

            if moving {
                Text("触碰演化")
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .tracking(2)
                    .foregroundStyle(goldColor.opacity(0.85))
                    .offset(x: 76)
            }
        }
        .frame(height: 18)
        .opacity(progress)
        .blur(radius: revealBlur)
        .scaleEffect(x: revealScale, y: 1, anchor: .center)
        .shadow(color: .white.opacity((1 - progress) * 0.5), radius: revealGlow)
    }

    private var oracleTerminalView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 14) {
                    Text(session.changedHexagram.displayName)
                        .font(.system(size: 40, weight: .regular, design: .serif))
                        .tracking(6)
                        .foregroundStyle(goldColor)
                        .shadow(color: goldColor.opacity(0.3), radius: 12)

                    HStack(spacing: 6) {
                        Image(systemName: "circle.hexagongrid.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text("变卦已成")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                    }
                    .foregroundStyle(goldColor.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(goldColor.opacity(0.35), lineWidth: 1)
                    )
                }

                HStack(spacing: 0) {
                    Text(quoteRendered)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundStyle(.white)
                    if isTypingQuote, quoteGibberish.isEmpty == false {
                        Text(quoteGibberish)
                            .font(.system(size: 18, weight: .regular, design: .monospaced))
                            .foregroundStyle(goldColor.opacity(0.7))
                    }
                    if isTypingQuote {
                        Rectangle()
                            .fill(goldColor)
                            .frame(width: 8, height: 18)
                    }
                }
                .opacity(quoteVisible ? 1 : 0)

                HStack(alignment: .top, spacing: 0) {
                    Text(descRendered)
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .foregroundStyle(subColor)
                        .lineSpacing(6)
                    if isTypingDesc, descGibberish.isEmpty == false {
                        Text(descGibberish)
                            .font(.system(size: 15, weight: .regular, design: .monospaced))
                            .foregroundStyle(goldColor.opacity(0.7))
                            .lineSpacing(6)
                    }
                    if isTypingDesc {
                        Rectangle()
                            .fill(goldColor)
                            .frame(width: 7, height: 15)
                            .padding(.top, 1)
                    }
                }
                .opacity(descVisible ? 1 : 0)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 54)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [backgroundColor.opacity(0), backgroundColor.opacity(1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .offset(y: terminalActive ? 0 : 20)
            .opacity(terminalActive ? 1 : 0)
            .animation(.easeOut(duration: 0.9), value: terminalActive)
        }
    }

    private func finalSealView(elapsed: Double) -> some View {
        let baguaSpin = -elapsed * 6
        let taijiSpin = elapsed * 9

        return VStack(spacing: 8) {
            Text("触碰印记 · 叩问天机")
                .font(.system(size: 12, weight: .regular, design: .serif))
                .tracking(4)
                .foregroundStyle(goldColor.opacity(0.6))
                .shadow(color: goldColor.opacity(0.6), radius: 10)

            ZStack {
                Circle()
                    .stroke(goldColor.opacity(0.55), lineWidth: 1.5)
                    .frame(width: 220, height: 220)
                    .shadow(color: goldColor.opacity(0.35), radius: 8)

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                        .frame(width: 176, height: 176)

                    ForEach(0..<8, id: \.self) { index in
                        let angle = (Double(index) * 45.0 - 90.0) * .pi / 180.0
                        let radius = 88.0
                        let x = cos(angle) * radius
                        let y = sin(angle) * radius

                        TrigramGraphicView(pattern: baguaTrigrams[index], color: .white)
                            .frame(width: 24, height: 20)
                            .offset(x: x, y: y)
                    }
                }
                .rotationEffect(.degrees(baguaSpin))

                OracleTaijiView(rotationDegrees: taijiSpin)
                    .frame(width: 80, height: 80)
            }
        }
        .frame(width: 240, height: 260)
        .animation(.easeInOut(duration: 2.5), value: showFinalSeal)
    }

    private func askLayerView(size: CGSize, now: Date) -> some View {
        let elapsed = max(0, now.timeIntervalSince(startTime))

        return ZStack {
            backgroundColor
                .ignoresSafeArea()

            oracleStarField(
                size: size,
                elapsed: elapsed,
                starOpacityMultiplier: 1.35,
                constellationOpacityMultiplier: 1.85,
                rotationSpeed: 0.01
            )
                .ignoresSafeArea()

            LinearGradient(
                colors: [backgroundColor.opacity(0.5), backgroundColor.opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Rectangle()
                .fill(.white.opacity(0.03))
                .blendMode(.overlay)
                .ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        colors: [fireEdgeColor.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 300, height: 400)
                .position(x: size.width / 2, y: size.height * 0.5)
                .blur(radius: 30)
                .opacity(burnGlowOpacity)

            burnParticleLayer(size: size, now: now)

            Text(askTitle)
                .font(.system(size: 20, weight: .regular, design: .serif))
                .tracking(12)
                .foregroundStyle(goldColor)
                .shadow(color: goldColor.opacity(0.8), radius: 15)
                .opacity(askTitleOpacity)
                .position(x: size.width / 2, y: size.height * 0.26)

            VStack(spacing: 22) {
                TextField("默念所求，落笔问天", text: $askInput)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .font(.system(size: 22, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.vertical, 10)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(.white.opacity(0.2))
                            .frame(height: 1)
                    }
                    .submitLabel(.done)
                    .onSubmit(submitToAI)

                Button(action: submitToAI) {
                    Text("敕 令 焚 符")
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .tracking(8)
                        .foregroundStyle(goldColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(goldColor, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .frame(width: min(size.width * 0.8, 400))
            .position(x: size.width / 2, y: size.height * 0.5)
            .opacity(askInputSubmitted ? 0 : 1)
            .offset(y: askInputSubmitted ? 20 : 0)
            .blur(radius: askInputSubmitted ? 5 : 0)
            .allowsHitTesting(askInputSubmitted == false)
            .animation(.easeInOut(duration: 0.5), value: askInputSubmitted)

            if showTalisman {
                talismanView(size: size)
                    .position(x: size.width / 2, y: size.height * 0.48)
                    .transition(.opacity)
            }

            if aiResponseActive {
                aiResponseView(size: size)
                    .position(x: size.width / 2, y: size.height * 0.55)
                    .transition(.opacity)
            }

            VStack {
                HStack {
                    Button(action: closeAskLayer) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(subColor)
                            .frame(width: 36, height: 36)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    private func talismanView(size: CGSize) -> some View {
        let burn = min(max(talismanBurnProgress, 0), 1)
        let fireY = CGFloat(380 - (380 * burn))

        return ZStack {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [talismanBGColor, Color(red: 212.0 / 255.0, green: 184.0 / 255.0, blue: 114.0 / 255.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .stroke(talismanInkColor, lineWidth: 2)
                )
                .overlay(
                    VStack(spacing: 8) {
                        Text("敕令")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundStyle(talismanInkColor)

                        talismanRuneView
                            .frame(width: 50, height: 60)

                        VStack(spacing: 5) {
                            ForEach(0..<6, id: \.self) { idx in
                                talismanYaoLine(type: newHex[5 - idx])
                                    .frame(width: 40, height: 4)
                            }
                        }
                        .padding(.bottom, 4)

                        Text(session.changedHexagram.displayName)
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .tracking(2)
                            .foregroundStyle(talismanInkColor)
                            .padding(.bottom, 6)

                        talismanVerticalText(talismanCoreText)
                            .frame(height: 80)

                        Spacer(minLength: 0)

                        Text("天机\n神鉴")
                            .font(.system(size: 11, weight: .regular, design: .serif))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(talismanInkColor)
                            .frame(width: 36, height: 36)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .stroke(talismanInkColor, lineWidth: 2)
                            )
                            .rotationEffect(.degrees(-5))
                            .opacity(0.8)
                    }
                    .padding(.top, 15)
                    .padding(.horizontal, 5)
                    .padding(.bottom, 14)
                )
                .frame(width: 90, height: 380)
                .opacity(talismanAppeared ? 1 : 0)
                .offset(y: talismanAppeared ? 0 : -20)
                .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8), value: talismanAppeared)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [fireCoreColor, fireMidColor, fireEdgeColor, .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 126, height: 60)
                .blur(radius: 8)
                .position(x: 45, y: fireY)
                .opacity(fireLineOpacity)
        }
        .frame(width: 130, height: 380)
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .clear, location: burn),
                    .init(color: .black, location: min(1, burn + 0.15)),
                    .init(color: .black, location: 1)
                ],
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }

    private var talismanRuneView: some View {
        Path { path in
            path.move(to: CGPoint(x: 30, y: 5))
            path.addCurve(to: CGPoint(x: 30, y: 40), control1: CGPoint(x: 10, y: 15), control2: CGPoint(x: 50, y: 25))
            path.addCurve(to: CGPoint(x: 30, y: 60), control1: CGPoint(x: 15, y: 50), control2: CGPoint(x: 45, y: 55))
        }
        .stroke(talismanInkColor, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
    }

    private func talismanYaoLine(type: YaoType) -> some View {
        Group {
            if type == .yang {
                Capsule(style: .continuous)
                    .fill(talismanInkColor)
            } else {
                HStack(spacing: 4) {
                    Capsule(style: .continuous)
                        .fill(talismanInkColor)
                    Capsule(style: .continuous)
                        .fill(talismanInkColor)
                }
            }
        }
    }

    private func talismanVerticalText(_ text: String) -> some View {
        let chars = Array(text)
        return VStack(spacing: 2) {
            ForEach(chars.indices, id: \.self) { index in
                Text(String(chars[index]))
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .foregroundStyle(.black.opacity(0.8))
            }
        }
    }

    private func aiResponseView(size: CGSize) -> some View {
        let responseMaxHeight = min(size.height * 0.45, 360)

        return VStack(spacing: 20) {
            Text("· \(aiEchoText) ·")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .italic()
                .foregroundStyle(.white.opacity(0.8))

            ScrollView(.vertical, showsIndicators: true) {
                HStack(alignment: .top, spacing: 0) {
                    Text(aiResponseRendered)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundStyle(.white)
                        .lineSpacing(8)

                    if isTypingAI, aiResponseGibberish.isEmpty == false {
                        Text(aiResponseGibberish)
                            .font(.system(size: 18, weight: .regular, design: .monospaced))
                            .foregroundStyle(goldColor.opacity(0.7))
                            .lineSpacing(8)
                    }

                    if isTypingAI {
                        Rectangle()
                            .fill(goldColor)
                            .frame(width: 8, height: 18)
                            .padding(.top, 4)
                            .padding(.leading, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: responseMaxHeight, alignment: .top)
            .padding(20)
            .background(.white.opacity(0.03))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.white.opacity(0.05), lineWidth: 1)
            )
        }
        .frame(width: min(size.width * 0.85, 500))
        .opacity(aiResponseVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.8), value: aiResponseVisible)
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
                    let opacity = (particle.isSpark ? 1.0 : 0.8) * (1 - progress)
                    let rotation = particle.isSpark ? 0 : (360 * progress)

                    Circle()
                        .fill(particle.isSpark ? fireCoreColor : Color(red: 34.0 / 255.0, green: 34.0 / 255.0, blue: 34.0 / 255.0))
                        .frame(width: CGFloat(particle.size), height: CGFloat(particle.size))
                        .shadow(color: particle.isSpark ? fireMidColor : .black, radius: particle.isSpark ? 10 : 4)
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

    private var talismanCoreText: String {
        let trimmed = askInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return "" }
        if trimmed.count > 8 {
            return String(trimmed.prefix(8)) + "..."
        }
        return trimmed
    }

    private func openAskLayer() {
        guard askLayerActive == false else { return }
        askTask?.cancel()
        aiStreamTask?.cancel()
        aiStreamTask = nil
        askTitle = "上 达 天 听"
        askTitleOpacity = 1
        askInput = ""
        askInputSubmitted = false
        showTalisman = false
        talismanAppeared = false
        talismanBurnProgress = 0
        fireLineOpacity = 0
        burnGlowOpacity = 0
        burnParticles.removeAll()
        aiResponseActive = false
        aiResponseVisible = false
        aiEchoText = ""
        aiResponseRendered = ""
        aiResponseGibberish = ""
        isTypingAI = false

        withAnimation(.easeInOut(duration: 0.8)) {
            askLayerActive = true
        }
    }

    private func closeAskLayer() {
        askTask?.cancel()
        aiStreamTask?.cancel()
        aiStreamTask = nil
        askTask = nil
        withAnimation(.easeInOut(duration: 0.35)) {
            askLayerActive = false
        }
    }

    private func submitToAI() {
        let question = askInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard question.isEmpty == false else { return }
        guard askInputSubmitted == false else { return }

        askTask?.cancel()
        askTask = Task {
            await MainActor.run {
                askInputSubmitted = true
                withAnimation(.easeInOut(duration: 0.5)) {
                    askTitleOpacity = 0
                }
                showTalisman = true
                talismanBurnProgress = 0
                fireLineOpacity = 0
                burnGlowOpacity = 0
            }

            try? await Task.sleep(nanoseconds: 20_000_000)
            await MainActor.run {
                talismanAppeared = true
            }

            try? await Task.sleep(nanoseconds: 1_200_000_000)
            await MainActor.run {
                askTitle = "化 气 入 虚 · 上 达 天 听"
                withAnimation(.easeInOut(duration: 0.5)) {
                    askTitleOpacity = 1
                    burnGlowOpacity = 1
                    fireLineOpacity = 1
                }
            }

            let intervalNanoseconds: UInt64 = 30_000_000
            let steps = Int(3_000_000_000 / intervalNanoseconds)
            for step in 0...steps {
                guard Task.isCancelled == false else { return }
                let progress = Double(step) / Double(steps)
                await MainActor.run {
                    talismanBurnProgress = progress
                    spawnBurnParticles(progress: progress)
                }
                try? await Task.sleep(nanoseconds: intervalNanoseconds)
            }

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.5)) {
                    fireLineOpacity = 0
                    burnGlowOpacity = 0
                }
            }

            try? await Task.sleep(nanoseconds: 500_000_000)
            await MainActor.run {
                showTalisman = false
                talismanAppeared = false
                withAnimation(.easeInOut(duration: 0.3)) {
                    askTitleOpacity = 0
                }
            }

            try? await Task.sleep(nanoseconds: 500_000_000)
            await MainActor.run {
                askTitle = "天 机 窥 探"
                withAnimation(.easeInOut(duration: 0.5)) {
                    askTitleOpacity = 1
                }
                aiResponseActive = true
                aiEchoText = question
                aiResponseVisible = false
                aiResponseRendered = ""
                aiResponseGibberish = ""
                isTypingAI = true
            }

            await streamAIAnswer(question: question)
        }
    }

    private func streamAIAnswer(question: String) async {
        guard let config = try? AIConfigProvider.current() else {
            await MainActor.run {
                aiResponseVisible = true
                isTypingAI = false
                aiResponseRendered = "未检测到可用 AI 配置，请先在“我”页面完成 Base URL、API Key 和模型配置。"
            }
            return
        }

        guard let model = config.model?.trimmingCharacters(in: .whitespacesAndNewlines), model.isEmpty == false else {
            await MainActor.run {
                aiResponseVisible = true
                isTypingAI = false
                aiResponseRendered = "未选择模型，请先在“我”页面测试连通并选择可用模型。"
            }
            return
        }

        let userPrompt = """
        请基于以下卦象上下文，解答用户的问题。
        卦象上下文：
        - 本卦：\(session.originalHexagram.displayName)（\(session.originalHexagram.name)，第\(session.originalHexagram.index)卦，意涵：\(session.originalHexagram.meaning)）
        - 变卦：\(session.changedHexagram.displayName)（\(session.changedHexagram.name)，第\(session.changedHexagram.index)卦，意涵：\(session.changedHexagram.meaning)）
        - 动爻序号（自下而上，0基）：\(session.movingLineIndex)
        
        用户的问题是：\(question)
        """

        await MainActor.run {
            aiResponseVisible = true
            isTypingAI = true
            aiResponseRendered = ""
        }

        let task = Task {
            do {
                let finishReason = try await OpenAICompatibleStreamer.streamChatCompletion(
                    baseURL: config.baseURL,
                    apiKey: config.apiKey,
                    model: model,
                    messages: [
                        ["role": "user", "content": userPrompt]
                    ],
                    temperature: 0.7
                ) { token in
                    await MainActor.run {
                        aiResponseRendered += token
                    }
                }

                await MainActor.run {
                    isTypingAI = false
                    if aiResponseRendered.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        aiResponseRendered = "天机未显：模型返回为空，请稍后重试。"
                    } else if finishReason == "length" {
                        aiResponseRendered += "\n\n（本次回复触发长度上限，若需完整解读可继续追问“请续写”。）"
                    }
                }
            } catch is CancellationError {
                await MainActor.run {
                    isTypingAI = false
                }
            } catch {
                await MainActor.run {
                    isTypingAI = false
                    let description = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    aiResponseRendered = "天机受阻：\(description)"
                }
            }
        }

        await MainActor.run {
            aiStreamTask = task
        }
    }

    @MainActor
    private func spawnBurnParticles(progress: Double) {
        let centerX = Double(canvasSize.width / 2)
        let centerY = Double(canvasSize.height * 0.48)
        let rectX = centerX - 45
        let rectBottomY = centerY + 190
        let currentBurnY = rectBottomY - (380 * progress)
        let count = Int.random(in: 3...5)

        for _ in 0..<count {
            let isSpark = Double.random(in: 0...1) > 0.3
            let startX = rectX + Double.random(in: -9...99)
            let duration = Double.random(in: 1...2.5)
            let moveX = Double.random(in: -40...40)
            let moveY = Double.random(in: 50...150)
            let size = Double.random(in: 1...4)

            burnParticles.append(
                OracleBurnParticle(
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

    private func oracleStarField(
        size: CGSize,
        elapsed: Double,
        starOpacityMultiplier: Double = 1.0,
        constellationOpacityMultiplier: Double = 1.0,
        rotationSpeed: Double = 0.018
    ) -> some View {
        Canvas { context, canvasSize in
            context.translateBy(x: canvasSize.width / 2, y: canvasSize.height / 2)
            context.rotate(by: .radians(elapsed * rotationSpeed))
            context.translateBy(x: -canvasSize.width / 2, y: -canvasSize.height / 2)

            for star in stars {
                var x = star.startX + star.velocityX * elapsed * 60.0
                var y = star.startY + star.velocityY * elapsed * 60.0
                x = wrapped(x, maxValue: canvasSize.width)
                y = wrapped(y, maxValue: canvasSize.height)

                let rect = CGRect(x: x - star.radius, y: y - star.radius, width: star.radius * 2, height: star.radius * 2)
                let opacity = min(1.0, star.opacity * starOpacityMultiplier)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
            }

            for (groupIndex, group) in constellationGroups.enumerated() {
                guard let first = group.points.first else { continue }
                if group.points.count >= 2 {
                    var path = Path()
                    path.move(to: first.position)
                    for point in group.points.dropFirst() {
                        path.addLine(to: point.position)
                    }
                    let lineOpacity = min(1.0, group.lineOpacity * constellationOpacityMultiplier)
                    context.stroke(path, with: .color(.white.opacity(lineOpacity)), lineWidth: 0.6)
                }

                for (pointIndex, point) in group.points.enumerated() {
                    let twinkle = (sin(elapsed * 2.0 + point.phase + Double(groupIndex + pointIndex)) + 1) / 2
                    let radius = point.radius * (0.8 + 0.4 * twinkle)
                    let opacity = min(1.0, point.baseOpacity * (0.55 + 0.45 * twinkle) * constellationOpacityMultiplier)
                    let rect = CGRect(x: point.position.x - radius, y: point.position.y - radius, width: radius * 2, height: radius * 2)
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
                    let opacity = phantomOpacityFor(progress: progress) * 0.35
                    let blur = phantomBlurFor(progress: progress)
                    let scale = 0.8 + progress * 0.7

                    Text(glyph.symbol)
                        .font(.system(size: glyph.fontSize, weight: .regular, design: .serif))
                        .foregroundStyle(goldColor.opacity(opacity))
                        .shadow(color: goldColor.opacity(opacity), radius: 10)
                        .scaleEffect(scale)
                        .blur(radius: blur)
                        .position(x: x, y: y)
                }
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func triggerOracle() {
        guard hasTransformed == false else { return }
        hasTransformed = true

        startPhantomLoop()

        withAnimation(.timingCurve(0.25, 1, 0.5, 1, duration: 0.5)) {
            centerNameOpacity = 0
            oldHexOpacity = 0
            oldHexBlur = 8
            oldHexScaleX = 1.2
        }

        transformTask?.cancel()
        transformTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            await MainActor.run {
                showTaijiTransition = true
                taijiBurstStartDate = Date()
                withAnimation(.timingCurve(0.25, 1, 0.5, 1, duration: 1.0)) {
                    watermarkOpacity = 0
                    watermarkScale = 1.2
                }
            }

            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                watermarkText = "震"
                withAnimation(.timingCurve(0.25, 1, 0.5, 1, duration: 1.0)) {
                    watermarkOpacity = 0.03
                    watermarkScale = 1
                }
            }

            try? await Task.sleep(nanoseconds: 1_300_000_000)
            await MainActor.run {
                stopPhantomLoop()
                withAnimation(.easeOut(duration: 0.4)) {
                    phantomOpacity = 0
                }
                newHexVisible = true
                newHexLineProgress = Array(repeating: 0, count: 6)
            }

            await MainActor.run {
                withAnimation(.timingCurve(0.1, 0.8, 0.2, 1, duration: 0.6)) {
                    newHexLineProgress[0] = 1
                }
            }

            try? await Task.sleep(nanoseconds: 200_000_000)
            await MainActor.run {
                showTaijiTransition = false
                taijiBurstStartDate = nil
            }

            try? await Task.sleep(nanoseconds: 100_000_000)
            for index in 1..<6 {
                await MainActor.run {
                    withAnimation(.timingCurve(0.1, 0.8, 0.2, 1, duration: 0.6)) {
                        newHexLineProgress[index] = 1
                    }
                }
                if index < 5 {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                }
            }

            try? await Task.sleep(nanoseconds: 700_000_000)
            await MainActor.run {
                centerNameText = session.changedHexagram.displayName
                centerNameColor = goldColor
                withAnimation(.easeInOut(duration: 0.4)) {
                    centerNameOpacity = 1
                }
                statusID = "DECODED"
            }

            await startDecoding()
        }
    }

    @MainActor
    private func startDecoding() async {
        terminalActive = true
        quoteVisible = false
        descVisible = false
        quoteRendered = ""
        quoteGibberish = ""
        descRendered = ""
        descGibberish = ""

        let quote = "「本卦：\(session.originalHexagram.displayName)；变卦：\(session.changedHexagram.displayName)。」"
        let desc = "天机初步推演：\(session.originalHexagram.displayName) 变 \(session.changedHexagram.displayName)。\(session.changedHexagram.meaning)。"

        await decodeText(text: quote, delayNanoseconds: 200_000_000, target: .quote)
        await decodeText(text: desc, delayNanoseconds: 400_000_000, target: .desc)

        try? await Task.sleep(nanoseconds: 800_000_000)
        withAnimation(.easeInOut(duration: 2.0)) {
            showFinalSeal = true
        }
    }

    @MainActor
    private func decodeText(text: String, delayNanoseconds: UInt64, target: DecodeTarget) async {
        try? await Task.sleep(nanoseconds: delayNanoseconds)
        guard Task.isCancelled == false else { return }

        setDecodeVisible(target: target, visible: true)
        setDecodeTyping(target: target, typing: true)
        setDecodeRendered(target: target, rendered: "", gibberish: "")

        let chars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%&*")
        let finalChars = Array(text)
        var currentText = ""

        for index in finalChars.indices {
            guard Task.isCancelled == false else { return }
            var gibberish = ""
            for offset in 0..<3 where index + offset < finalChars.count {
                gibberish.append(chars.randomElement() ?? "A")
            }

            currentText.append(finalChars[index])
            setDecodeRendered(target: target, rendered: currentText, gibberish: gibberish)
            try? await Task.sleep(nanoseconds: 40_000_000)
        }

        setDecodeRendered(target: target, rendered: text, gibberish: "")
        setDecodeTyping(target: target, typing: false)
    }

    @MainActor
    private func setDecodeVisible(target: DecodeTarget, visible: Bool) {
        switch target {
        case .quote:
            quoteVisible = visible
        case .desc:
            descVisible = visible
        case .ai:
            aiResponseVisible = visible
        }
    }

    @MainActor
    private func setDecodeTyping(target: DecodeTarget, typing: Bool) {
        switch target {
        case .quote:
            isTypingQuote = typing
        case .desc:
            isTypingDesc = typing
        case .ai:
            isTypingAI = typing
        }
    }

    @MainActor
    private func setDecodeRendered(target: DecodeTarget, rendered: String, gibberish: String) {
        switch target {
        case .quote:
            quoteRendered = rendered
            quoteGibberish = gibberish
        case .desc:
            descRendered = rendered
            descGibberish = gibberish
        case .ai:
            aiResponseRendered = rendered
            aiResponseGibberish = gibberish
        }
    }

    private func refreshStarsIfNeeded(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let widthChanged = abs(size.width - canvasSize.width) > 2
        let heightChanged = abs(size.height - canvasSize.height) > 2
        guard stars.isEmpty || widthChanged || heightChanged else { return }

        var generator = OracleSeededGenerator(state: 0x0A2AC1E5)
        stars = (0..<200).map { _ in
            OracleDustParticle(
                startX: Double.random(in: -(size.width * 0.25)...(size.width * 1.25), using: &generator),
                startY: Double.random(in: -(size.height * 0.25)...(size.height * 1.25), using: &generator),
                radius: Double.random(in: 0.5...1.3, using: &generator),
                velocityX: Double.random(in: -0.06...0.06, using: &generator),
                velocityY: Double.random(in: -0.06...0.06, using: &generator),
                opacity: Double.random(in: 0.1...0.35, using: &generator)
            )
        }

        constellationGroups = constellationShapes.map { shape in
            let centerX = Double.random(in: -(size.width * 0.25)...(size.width * 1.25), using: &generator)
            let centerY = Double.random(in: -(size.height * 0.25)...(size.height * 1.25), using: &generator)
            let angle = Double.random(in: 0...(2 * .pi), using: &generator)
            let cosA = cos(angle)
            let sinA = sin(angle)

            let points = shape.map { offset in
                let rx = Double(offset.x) * cosA - Double(offset.y) * sinA
                let ry = Double(offset.x) * sinA + Double(offset.y) * cosA
                return OracleConstellationPoint(
                    position: CGPoint(x: centerX + rx, y: centerY + ry),
                    radius: Double.random(in: 1.2...2.2, using: &generator),
                    baseOpacity: Double.random(in: 0.5...0.9, using: &generator),
                    phase: Double.random(in: 0...(2 * .pi), using: &generator)
                )
            }

            return OracleConstellationGroup(
                points: points,
                lineOpacity: Double.random(in: 0.2...0.32, using: &generator)
            )
        }

        canvasSize = size
    }

    private func startPhantomLoop() {
        phantomTask?.cancel()
        phantomOpacity = 1
        phantomTask = Task {
            while Task.isCancelled == false {
                await MainActor.run {
                    spawnPhantomGlyph()
                }
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
    }

    private func stopPhantomLoop() {
        phantomTask?.cancel()
        phantomTask = nil
    }

    @MainActor
    private func spawnPhantomGlyph() {
        let isText = Bool.random()
        let symbol: String
        if isText {
            symbol = baguaNames.randomElement() ?? "乾"
        } else if let scalar = UnicodeScalar(0x4DC0 + Int.random(in: 0..<64)) {
            symbol = String(scalar)
        } else {
            symbol = "䷀"
        }

        phantomGlyphs.append(
            OraclePhantomGlyph(
                symbol: symbol,
                yRatio: Double.random(in: 0.1...0.7),
                fontSize: Double.random(in: isText ? 26...44 : 36...68),
                duration: Double.random(in: 1.0...2.5),
                bornAt: Date()
            )
        )

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

    private func phantomOpacityFor(progress: Double) -> Double {
        switch progress {
        case 0..<0.2:
            return progress / 0.2
        case 0.2..<0.8:
            return 1
        default:
            return max(0, (1 - progress) / 0.2)
        }
    }

    private func phantomBlurFor(progress: Double) -> Double {
        if progress < 0.2 { return 8 - progress * 30 }
        if progress < 0.8 { return 2 }
        return 2 + (progress - 0.8) * 30
    }
}

private struct TaijiTransitionView: View {
    let elapsed: Double
    let baguaTrigrams: [[Bool]]
    let goldColor: Color

    var body: some View {
        let clamped = min(max(elapsed / 2.5, 0), 1)
        let opacity: Double = {
            if clamped < 0.2 { return clamped / 0.2 }
            if clamped < 0.75 { return 1 }
            return max(0, (1 - clamped) / 0.25)
        }()
        let scale: CGFloat = {
            if clamped < 0.2 { return CGFloat(0.6 + (clamped / 0.2) * 0.4) }
            if clamped < 0.75 { return 1.0 }
            return CGFloat(1.0 + ((clamped - 0.75) / 0.25) * 0.6)
        }()
        let blurRadius: CGFloat = {
            if clamped < 0.2 { return CGFloat(10 - (clamped / 0.2) * 10) }
            if clamped < 0.75 { return 0 }
            return CGFloat(((clamped - 0.75) / 0.25) * 15)
        }()
        let burstRotation: Double = {
            if clamped < 0.2 {
                return (clamped / 0.2) * 360
            }
            if clamped < 0.75 {
                return 360 + ((clamped - 0.2) / 0.55) * 720
            }
            return 1080 + ((clamped - 0.75) / 0.25) * 540
        }()

        ZStack {
            Circle()
                .stroke(goldColor.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .frame(width: 190, height: 190)

            ForEach(0..<8, id: \.self) { index in
                let angle = (Double(index) * 45.0 - 90.0) * .pi / 180.0
                let radius = 95.0
                let x = cos(angle) * radius
                let y = sin(angle) * radius
                TrigramGraphicView(pattern: baguaTrigrams[index], color: goldColor)
                    .frame(width: 24, height: 20)
                    .offset(x: x, y: y)
            }

            OracleTaijiView(rotationDegrees: 0)
                .frame(width: 80, height: 80)
        }
        .rotationEffect(.degrees(burstRotation))
        .scaleEffect(scale)
        .opacity(opacity)
        .blur(radius: blurRadius)
        .shadow(color: .white.opacity(0.35), radius: 35)
    }
}

private struct TrigramGraphicView: View {
    let pattern: [Bool]
    let color: Color

    var body: some View {
        VStack(spacing: 3.8) {
            ForEach(0..<3, id: \.self) { idx in
                if pattern.indices.contains(idx), pattern[idx] {
                    Capsule(style: .continuous)
                        .fill(color)
                        .frame(height: 3)
                        .shadow(color: color.opacity(0.5), radius: 5)
                } else {
                    HStack(spacing: 3.6) {
                        Capsule(style: .continuous)
                            .fill(color)
                            .frame(width: 10, height: 3)
                            .shadow(color: color.opacity(0.5), radius: 4)
                        Capsule(style: .continuous)
                            .fill(color)
                            .frame(width: 10, height: 3)
                            .shadow(color: color.opacity(0.5), radius: 4)
                    }
                }
            }
        }
    }
}

private struct OracleTaijiView: View {
    let rotationDegrees: Double

    var body: some View {
        Canvas { context, size in
            context.withCGContext { cg in
                let radius = min(size.width, size.height) / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                cg.saveGState()
                cg.translateBy(x: center.x, y: center.y)
                cg.rotate(by: rotationDegrees * .pi / 180.0)

                cg.setFillColor(CGColor(gray: 1, alpha: 1))
                let yang = CGMutablePath()
                yang.move(to: .zero)
                yang.addArc(center: .zero, radius: radius, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: false)
                yang.closeSubpath()
                cg.addPath(yang)
                cg.fillPath()

                cg.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.9))
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

                cg.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.9))
                cg.fillEllipse(in: CGRect(x: -radius / 2, y: -radius, width: radius, height: radius))
                cg.setFillColor(CGColor(gray: 1, alpha: 1))
                cg.fillEllipse(in: CGRect(x: -radius / 6, y: -2 * radius / 3, width: radius / 3, height: radius / 3))

                cg.setStrokeColor(CGColor(gray: 1, alpha: 1))
                cg.setLineWidth(1.6)
                cg.strokeEllipse(in: CGRect(x: -radius + 1, y: -radius + 1, width: radius * 2 - 2, height: radius * 2 - 2))
                cg.restoreGState()
            }
        }
        .shadow(color: .white.opacity(0.3), radius: 18)
    }
}

private struct OraclePhantomGlyph: Identifiable {
    let id = UUID()
    let symbol: String
    let yRatio: Double
    let fontSize: Double
    let duration: Double
    let bornAt: Date
}

private struct OracleBurnParticle: Identifiable {
    let id = UUID()
    let isSpark: Bool
    let startX: Double
    let startY: Double
    let moveX: Double
    let moveY: Double
    let size: Double
    let duration: Double
    let bornAt: Date
}

private struct OracleDustParticle {
    let startX: Double
    let startY: Double
    let radius: Double
    let velocityX: Double
    let velocityY: Double
    let opacity: Double
}

private struct OracleConstellationGroup {
    let points: [OracleConstellationPoint]
    let lineOpacity: Double
}

private struct OracleConstellationPoint {
    let position: CGPoint
    let radius: Double
    let baseOpacity: Double
    let phase: Double
}

private struct OracleSeededGenerator: RandomNumberGenerator {
    var state: UInt64

    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

#Preview {
    OracleDecodeView(session: .preview, onBack: {})
}
