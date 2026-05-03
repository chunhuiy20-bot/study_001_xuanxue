import SwiftUI

struct LaunchSplashView: View {
    private let backgroundColor = Color(red: 2.0 / 255.0, green: 4.0 / 255.0, blue: 10.0 / 255.0)
    private let targetFPS = 60.0
    private let stage2Frame = 80.0
    private let stage3Frame = 220.0
    private let alphaRevealFrames = 100.0
    private let brandWriteDuration = 4.0
    private let brandFadeDuration = 1.5
    private let totalSplashDuration = 9.5

    let onCompleted: () -> Void

    @State private var startTime = Date()
    @State private var scene = SplashScene.empty
    @State private var didRequestCompletion = false

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1.0 / targetFPS, paused: false)) { timeline in
                let frame = max(0, timeline.date.timeIntervalSince(startTime) * targetFPS)
                let brandStartFrame = stage3Frame + alphaRevealFrames
                let brandStartTime = brandStartFrame / targetFPS
                let elapsedSeconds = frame / targetFPS

                let brandFadeProgress = progress(
                    current: elapsedSeconds,
                    start: brandStartTime,
                    duration: brandFadeDuration
                )
                let writeProgress = progress(
                    current: elapsedSeconds,
                    start: brandStartTime,
                    duration: brandWriteDuration
                )

                ZStack {
                    backgroundColor
                        .ignoresSafeArea()

                    Canvas { context, size in
                        scene.draw(in: &context, size: size, frame: frame, stage2Frame: stage2Frame, stage3Frame: stage3Frame)
                    }
                    .ignoresSafeArea()

                    BrandOverlayView(
                        opacity: brandFadeProgress,
                        writeProgress: writeProgress,
                        elapsedSinceBrandStart: max(0, elapsedSeconds - brandStartTime),
                        baseBackground: backgroundColor
                    )
                }
            }
            .onAppear {
                startTime = Date()
                scene = SplashScene.build(for: proxy.size)
            }
            .onChange(of: proxy.size) { _, newSize in
                scene = SplashScene.build(for: newSize)
            }
            .task {
                guard didRequestCompletion == false else { return }
                didRequestCompletion = true
                try? await Task.sleep(nanoseconds: UInt64(totalSplashDuration * 1_000_000_000))
                onCompleted()
            }
        }
    }

    private func progress(current: Double, start: Double, duration: Double) -> Double {
        guard duration > 0 else { return current >= start ? 1 : 0 }
        return min(max((current - start) / duration, 0), 1)
    }
}

private struct BrandOverlayView: View {
    let opacity: Double
    let writeProgress: Double
    let elapsedSinceBrandStart: Double
    let baseBackground: Color

    var body: some View {
        VStack {
            WritingBrandText(writeProgress: writeProgress, glowProgress: glowProgress)
                .opacity(opacity)
                .padding(.vertical, 100)
                .frame(maxWidth: .infinity)
                .background {
                    RadialGradient(
                        colors: [
                            baseBackground.opacity(0.9),
                            baseBackground.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 320
                    )
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }

    private var glowProgress: Double {
        guard elapsedSinceBrandStart > 4 else { return 0 }
        return (sin((elapsedSinceBrandStart - 4) * .pi * 0.8) + 1) / 2
    }
}

private struct WritingBrandText: View {
    let writeProgress: Double
    let glowProgress: Double

    var body: some View {
        Text("极数知来之谓占")
            .font(.system(size: 40, weight: .regular, design: .serif))
            .tracking(12)
            .foregroundStyle(.white)
            .blur(radius: (1 - writeProgress) * 5)
            .shadow(color: .white.opacity(0.4 + 0.5 * glowProgress), radius: 15 + 15 * glowProgress)
            .fixedSize()
            .mask(alignment: .leading) {
                GeometryReader { proxy in
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(width: proxy.size.width * writeProgress)
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.leading, 12)
    }
}

private struct SplashScene {
    static let empty = SplashScene(stars: [], coreCenter: .zero)

    let stars: [SplashStar]
    let coreCenter: CGPoint

    private static let fourSymbolsColors: [SIMD3<Double>] = [
        SIMD3(100, 220, 200),
        SIMD3(200, 180, 255),
        SIMD3(255, 255, 255),
        SIMD3(255, 120, 100)
    ]

    private static let constellationShapes: [[SIMD2<Double>]] = [
        [SIMD2(0, 0), SIMD2(15, 20)],
        [SIMD2(0, 0), SIMD2(-20, 10), SIMD2(-10, -15)],
        [SIMD2(0, 0), SIMD2(25, 0), SIMD2(12, 15), SIMD2(12, -15)],
        [SIMD2(0, 0), SIMD2(15, 20), SIMD2(30, 40)],
        [SIMD2(0, 0), SIMD2(20, 10), SIMD2(15, -15)],
        [SIMD2(0, 0), SIMD2(10, 15), SIMD2(20, 30), SIMD2(25, 45)],
        [SIMD2(0, 0), SIMD2(20, -10), SIMD2(35, -5)],
        [SIMD2(0, 0), SIMD2(20, -10), SIMD2(40, -5), SIMD2(55, 10), SIMD2(55, 30)],
        [SIMD2(0, 0), SIMD2(15, 20)],
        [SIMD2(0, 0), SIMD2(-20, 10), SIMD2(-10, -15)],
        [SIMD2(0, 0), SIMD2(25, 0)],
        [SIMD2(0, 0), SIMD2(15, 20), SIMD2(30, 40)],
        [SIMD2(0, 0), SIMD2(20, 10), SIMD2(15, -15)],
        [SIMD2(0, 0), SIMD2(10, 15), SIMD2(20, 30)],
        [SIMD2(0, 0), SIMD2(20, -10), SIMD2(40, -5)],
        [SIMD2(0, 0), SIMD2(15, 20)],
        [SIMD2(0, 0), SIMD2(-20, 10), SIMD2(-10, -15)],
        [SIMD2(0, 0), SIMD2(25, 0), SIMD2(12, 15), SIMD2(12, -15), SIMD2(5, 20), SIMD2(-5, 10)],
        [SIMD2(0, 0), SIMD2(15, 20), SIMD2(30, 40)],
        [SIMD2(0, 0), SIMD2(20, 10), SIMD2(15, -15)],
        [SIMD2(0, 0), SIMD2(10, 15), SIMD2(20, 30), SIMD2(25, 45)],
        [SIMD2(0, 0), SIMD2(20, -10), SIMD2(40, -5), SIMD2(55, 10)],
        [SIMD2(0, 0), SIMD2(15, 20), SIMD2(20, -10), SIMD2(-15, -10)],
        [SIMD2(0, 0), SIMD2(-20, 10), SIMD2(-10, -15)],
        [SIMD2(0, 0), SIMD2(25, 0), SIMD2(12, 15)],
        [SIMD2(0, 0), SIMD2(15, 20), SIMD2(30, 40)],
        [SIMD2(0, 0), SIMD2(20, 10), SIMD2(15, -15)],
        [SIMD2(0, 0), SIMD2(10, 15), SIMD2(20, 30), SIMD2(25, 45)]
    ]

    private static let hexagrams: [[Int]] = [
        [1, 1, 1], [0, 1, 1], [1, 0, 1], [0, 0, 1],
        [1, 1, 0], [0, 1, 0], [1, 0, 0], [0, 0, 0]
    ]

    static func build(for size: CGSize) -> SplashScene {
        guard size.width > 0, size.height > 0 else {
            return .empty
        }

        var generator = SeededGenerator(state: 0xD11A710A)
        var stars: [SplashStar] = []
        stars.reserveCapacity(500)

        for _ in 0..<250 {
            let x = Double.random(in: 0...size.width, using: &generator)
            let y = Double.random(in: 0...size.height, using: &generator)
            let maxOpacity = 0.1 + Double.random(in: 0...0.3, using: &generator)
            let pointSize = 0.5 + Double.random(in: 0...1.0, using: &generator)
            let ease = 0.02 + Double.random(in: 0...0.03, using: &generator)

            stars.append(
                SplashStar(
                    startX: x,
                    startY: y,
                    targetX: nil,
                    targetY: nil,
                    isCore: false,
                    groupIndex: -1,
                    baseColor: SIMD3(255, 255, 255),
                    maxOpacity: maxOpacity,
                    size: pointSize,
                    ease: ease
                )
            )
        }

        let radius = Double(min(size.width, size.height)) * 0.38

        for index in 0..<28 {
            let angle = (Double(index) / 28.0) * Double.pi * 2 - Double.pi / 2
            let centerX = Double(size.width) / 2 + cos(angle) * radius
            let centerY = Double(size.height) / 2 + sin(angle) * radius

            for offset in constellationShapes[index] {
                let cosA = cos(angle + Double.pi / 2)
                let sinA = sin(angle + Double.pi / 2)

                let rotatedX = offset.x * cosA - offset.y * sinA
                let rotatedY = offset.x * sinA + offset.y * cosA

                let x = Double.random(in: 0...size.width, using: &generator)
                let y = Double.random(in: 0...size.height, using: &generator)
                let maxOpacity = 0.7 + Double.random(in: 0...0.3, using: &generator)
                let pointSize = 1.5 + Double.random(in: 0...1.0, using: &generator)
                let ease = 0.02 + Double.random(in: 0...0.03, using: &generator)

                stars.append(
                    SplashStar(
                        startX: x,
                        startY: y,
                        targetX: centerX + rotatedX,
                        targetY: centerY + rotatedY,
                        isCore: true,
                        groupIndex: index,
                        baseColor: fourSymbolsColors[index / 7],
                        maxOpacity: maxOpacity,
                        size: pointSize,
                        ease: ease
                    )
                )
            }
        }

        let coreTargets = stars.compactMap { star -> CGPoint? in
            guard star.isCore, let targetX = star.targetX, let targetY = star.targetY else { return nil }
            return CGPoint(x: targetX, y: targetY)
        }

        let center: CGPoint
        if coreTargets.isEmpty {
            center = CGPoint(x: size.width / 2, y: size.height / 2)
        } else {
            let totalX = coreTargets.reduce(0.0) { $0 + $1.x }
            let totalY = coreTargets.reduce(0.0) { $0 + $1.y }
            center = CGPoint(
                x: totalX / Double(coreTargets.count),
                y: totalY / Double(coreTargets.count)
            )
        }

        return SplashScene(stars: stars, coreCenter: center)
    }

    func draw(in context: inout GraphicsContext, size: CGSize, frame: Double, stage2Frame: Double, stage3Frame: Double) {
        let stage: Int
        if frame > stage3Frame {
            stage = 3
        } else if frame > stage2Frame {
            stage = 2
        } else {
            stage = 1
        }

        var coreGroups: [Int: [CGPoint]] = [:]
        coreGroups.reserveCapacity(28)

        for star in stars {
            let starState = star.state(frame: frame, stage2Frame: stage2Frame, stage3Frame: stage3Frame)
            let opacity = starState.opacity
            if opacity <= 0.001 { continue }

            let red = star.baseColor.x / 255
            let green = star.baseColor.y / 255
            let blue = star.baseColor.z / 255
            let color = Color(red: red, green: green, blue: blue).opacity(opacity)
            let rect = CGRect(
                x: starState.position.x - star.size / 2,
                y: starState.position.y - star.size / 2,
                width: star.size,
                height: star.size
            )

            if star.isCore {
                context.drawLayer { layer in
                    layer.addFilter(.shadow(color: Color(red: red, green: green, blue: blue).opacity(0.8), radius: 6))
                    layer.fill(Path(ellipseIn: rect), with: .color(color))
                }

                coreGroups[star.groupIndex, default: []].append(starState.position)
            } else {
                context.fill(Path(ellipseIn: rect), with: .color(color))
            }
        }

        if stage >= 3 {
            for groupIndex in 0..<28 {
                guard let points = coreGroups[groupIndex], points.count > 1 else { continue }
                let base = SplashScene.fourSymbolsColors[groupIndex / 7]

                var path = Path()
                path.move(to: points[0])
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }

                context.stroke(
                    path,
                    with: .color(
                        Color(
                            red: base.x / 255,
                            green: base.y / 255,
                            blue: base.z / 255
                        )
                        .opacity(0.2)
                    ),
                    lineWidth: 0.5
                )
            }

            let alpha = min(max((frame - stage3Frame) / 100.0, 0), 1)
            drawBagua(in: &context, center: coreCenter, frame: frame, alpha: alpha)
            drawTaiji(in: &context, center: coreCenter, radius: 45, frame: frame, alpha: alpha)
        }
    }

    private func drawTaiji(in context: inout GraphicsContext, center: CGPoint, radius: CGFloat, frame: Double, alpha: Double) {
        context.withCGContext { cg in
            cg.saveGState()
            cg.setAlpha(alpha)
            cg.translateBy(x: center.x, y: center.y)
            cg.rotate(by: frame * 0.005)

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
            cg.fillEllipse(in: CGRect(x: -radius / 2, y: radius / 2 - radius / 2, width: radius, height: radius))
            cg.setFillColor(CGColor(gray: 0, alpha: 1))
            cg.fillEllipse(in: CGRect(x: -radius / 6, y: radius / 2 - radius / 6, width: radius / 3, height: radius / 3))

            cg.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.8))
            cg.fillEllipse(in: CGRect(x: -radius / 2, y: -radius / 2 - radius / 2, width: radius, height: radius))
            cg.setFillColor(CGColor(gray: 1, alpha: 1))
            cg.fillEllipse(in: CGRect(x: -radius / 6, y: -radius / 2 - radius / 6, width: radius / 3, height: radius / 3))

            cg.restoreGState()
        }
    }

    private func drawBagua(in context: inout GraphicsContext, center: CGPoint, frame: Double, alpha: Double) {
        context.withCGContext { cg in
            cg.saveGState()
            cg.setAlpha(alpha)
            cg.translateBy(x: center.x, y: center.y)
            cg.rotate(by: -frame * 0.002)

            let gold = CGColor(red: 230.0 / 255.0, green: 194.0 / 255.0, blue: 122.0 / 255.0, alpha: 0.9)
            cg.setStrokeColor(gold)
            cg.setShadow(offset: .zero, blur: 10, color: CGColor(red: 230.0 / 255.0, green: 194.0 / 255.0, blue: 122.0 / 255.0, alpha: 0.5))

            let radius: CGFloat = 90
            let lineWidth: CGFloat = 30
            let gap: CGFloat = 8

            for index in 0..<8 {
                let angle = CGFloat(index) * .pi / 4 - .pi / 2
                guard let hexagram = SplashScene.hexagrams[safe: index] else { continue }

                cg.saveGState()
                cg.rotate(by: angle)
                cg.translateBy(x: 0, y: -radius)
                cg.setLineWidth(3)

                for lineIndex in 0..<3 {
                    let y = -CGFloat(lineIndex) * 12
                    let isYang = hexagram[2 - lineIndex] == 1

                    if isYang {
                        cg.move(to: CGPoint(x: -lineWidth / 2, y: y))
                        cg.addLine(to: CGPoint(x: lineWidth / 2, y: y))
                        cg.strokePath()
                    } else {
                        cg.move(to: CGPoint(x: -lineWidth / 2, y: y))
                        cg.addLine(to: CGPoint(x: -gap / 2, y: y))
                        cg.strokePath()

                        cg.move(to: CGPoint(x: gap / 2, y: y))
                        cg.addLine(to: CGPoint(x: lineWidth / 2, y: y))
                        cg.strokePath()
                    }
                }

                cg.restoreGState()
            }

            cg.restoreGState()
        }
    }
}

private struct SplashStar {
    let startX: Double
    let startY: Double
    let targetX: Double?
    let targetY: Double?
    let isCore: Bool
    let groupIndex: Int
    let baseColor: SIMD3<Double>
    let maxOpacity: Double
    let size: CGFloat
    let ease: Double

    func state(frame: Double, stage2Frame: Double, stage3Frame: Double) -> (position: CGPoint, opacity: Double) {
        var x = startX
        var y = startY

        if frame >= stage2Frame, let targetX, let targetY {
            let moveSteps = frame - stage2Frame
            let remain = pow(max(0.0, 1.0 - ease), moveSteps)
            x = targetX + (startX - targetX) * remain
            y = targetY + (startY - targetY) * remain
        }

        let baseOpacity = min(maxOpacity, frame * 0.005)
        let opacity: Double

        if frame >= stage3Frame {
            if isCore {
                opacity = maxOpacity * (0.8 + sin(frame * 0.05 + x) * 0.2)
            } else {
                opacity = baseOpacity * pow(0.96, frame - stage3Frame)
            }
        } else {
            opacity = baseOpacity
        }

        return (CGPoint(x: x, y: y), max(0, opacity))
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64

    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    LaunchSplashView {}
}
