import SwiftUI

struct ProfileMeView: View {
    private let bgBase = Color.black
    private let textMain = Color(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0)
    private let textSub = Color(red: 115.0 / 255.0, green: 115.0 / 255.0, blue: 115.0 / 255.0)
    private let accentGold = Color(red: 203.0 / 255.0, green: 160.0 / 255.0, blue: 82.0 / 255.0)
    private let borderLine = Color.white.opacity(0.1)
    private let inputBorderLine = Color.white.opacity(0.26)

    @State private var showConfigModal = false
    @State private var baseURL = "https://api.deepseek.com/v1"
    @State private var apiKey = ""
    @State private var configStatus = "已配置"
    @State private var cacheSizeText = "12.4 MB"
    @State private var isTestingConnection = false
    @State private var availableModels: [String] = []
    @State private var selectedModel = ""
    @State private var isModelListExpanded = false

    @State private var toastMessage = ""
    @State private var showToast = false

    @State private var startTime = Date()
    @State private var stars: [ProfileStar] = []
    @State private var constellationGroups: [ProfileConstellationGroup] = []
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
                let elapsed = max(0, timeline.date.timeIntervalSince(startTime))

                ZStack {
                    bgBase
                        .ignoresSafeArea()

                    starField(size: proxy.size, elapsed: elapsed)
                        .ignoresSafeArea()
                        .opacity(0.82)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 36) {
                            profileSection
                            configGroup
                            systemGroup
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 50)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.never)

                    if showConfigModal {
                        configModal
                    }

                    toastView
                }
                .onAppear {
                    loadStoredConfig()
                    startTime = Date()
                    refreshStarsIfNeeded(for: proxy.size)
                }
                .onChange(of: proxy.size) { _, newSize in
                    refreshStarsIfNeeded(for: newSize)
                }
            }
        }
    }

    private var profileSection: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(red: 10.0 / 255.0, green: 10.0 / 255.0, blue: 10.0 / 255.0).opacity(0.85))
                    .overlay(
                        Circle().stroke(borderLine, lineWidth: 1)
                    )

                Text("辉")
                    .font(.system(size: 30, weight: .regular, design: .serif))
                    .foregroundStyle(accentGold)
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 6) {
                Text("李辉")
                    .font(.system(size: 22, weight: .semibold, design: .default))
                    .foregroundStyle(textMain)

                Text("ID: 884812 · 终身授权")
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundStyle(textSub)
            }
        }
    }

    private var configGroup: some View {
        VStack(alignment: .leading, spacing: 8) {
            groupTitle("配置面板")

            listItem(
                label: "AI 推演引擎配置",
                value: configStatus,
                valueColor: configStatus == "已更新" ? accentGold : textSub,
                tappable: true
            ) {
                withAnimation(.easeOut(duration: 0.22)) {
                    showConfigModal = true
                }
            }

            listItem(
                label: "排盘算法校准",
                value: "真太阳时",
                tappable: true
            ) {
                showToastText("进入底层算法校准模块")
            }
        }
    }

    private var systemGroup: some View {
        VStack(alignment: .leading, spacing: 8) {
            groupTitle("系统选项")

            listItem(
                label: "清除本地缓存",
                value: cacheSizeText,
                tappable: true,
                showArrow: false
            ) {
                cacheSizeText = "0 KB"
                showToastText("缓存清理完成")
            }

            listItem(
                label: "当前版本",
                value: "v2.1.0",
                tappable: false,
                showArrow: false,
                bottomLine: false
            ) { }
        }
    }

    private func groupTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .regular, design: .default))
            .foregroundStyle(textSub)
            .tracking(1)
            .padding(.bottom, 8)
    }

    private func listItem(
        label: String,
        value: String,
        valueColor: Color? = nil,
        tappable: Bool,
        showArrow: Bool = true,
        bottomLine: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            if tappable { action() }
        } label: {
            HStack {
                Text(label)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundStyle(textMain)

                Spacer(minLength: 12)

                HStack(spacing: 8) {
                    Text(value)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .foregroundStyle(valueColor ?? textSub)

                    if showArrow {
                        Text("›")
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundStyle(textSub)
                    }
                }
            }
            .padding(.vertical, 16)
            .overlay(alignment: .bottom) {
                if bottomLine {
                    Rectangle()
                        .fill(borderLine)
                        .frame(height: 1)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(tappable ? 1 : 0.92)
    }

    private var configModal: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.7))
                .ignoresSafeArea()
                .overlay(
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.22)) {
                                showConfigModal = false
                            }
                        }
                )

            VStack(alignment: .leading, spacing: 0) {
                Text("AI 推演引擎配置")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(textMain)
                    .padding(.bottom, 24)

                formField(title: "BASE URL", text: $baseURL, placeholder: "https://api.deepseek.com/v1", isSecure: false)
                    .padding(.bottom, 16)

                formField(title: "API KEY", text: $apiKey, placeholder: "sk-...", isSecure: true)
                    .padding(.bottom, 16)

                modelPickerSection
                    .padding(.bottom, 6)

                HStack(spacing: 12) {
                    Button(isTestingConnection ? "测试中..." : "测试连通") {
                        testConnection()
                    }
                    .foregroundStyle(.white.opacity(isTestingConnection ? 0.55 : 0.82))
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.26), lineWidth: 1)
                    )
                    .disabled(isTestingConnection)

                    Spacer()

                    Button("取消") {
                        withAnimation(.easeOut(duration: 0.22)) {
                            showConfigModal = false
                        }
                    }
                    .foregroundStyle(textSub)
                    .font(.system(size: 14, weight: .regular, design: .default))

                    Button("保存") {
                        saveConfig()
                    }
                    .foregroundStyle(accentGold)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(accentGold, lineWidth: 1)
                    )
                }
                .padding(.top, 32)
            }
            .padding(24)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 10.0 / 255.0, green: 10.0 / 255.0, blue: 10.0 / 255.0).opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderLine, lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.8), radius: 40, x: 0, y: 20)
            .padding(.horizontal, 28)
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
        .zIndex(40)
    }

    private func formField(title: String, text: Binding<String>, placeholder: String, isSecure: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(textSub)

            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                }
            }
            .font(.system(size: 14, weight: .regular, design: .monospaced))
            .foregroundStyle(textMain)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(inputBorderLine, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    private var modelPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("可用模型")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(textSub)

            VStack(spacing: 6) {
                Button {
                    guard availableModels.isEmpty == false else {
                        showToastText("请先测试连通拉取模型")
                        return
                    }
                    withAnimation(.easeOut(duration: 0.18)) {
                        isModelListExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text(selectedModel.isEmpty ? "请先测试连通拉取模型" : selectedModel)
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundStyle(selectedModel.isEmpty ? textSub : textMain)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer(minLength: 8)

                        Text(isModelListExpanded ? "▴" : "▾")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundStyle(textSub)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(inputBorderLine, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)

                if isModelListExpanded {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 0) {
                            ForEach(availableModels, id: \.self) { model in
                                Button {
                                    selectedModel = model
                                    withAnimation(.easeOut(duration: 0.18)) {
                                        isModelListExpanded = false
                                    }
                                } label: {
                                    HStack {
                                        Text(model)
                                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                                            .foregroundStyle(model == selectedModel ? accentGold : textMain)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                        Spacer()
                                        if model == selectedModel {
                                            Text("✓")
                                                .foregroundStyle(accentGold)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                if model != availableModels.last {
                                    Rectangle()
                                        .fill(borderLine)
                                        .frame(height: 1)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 132)
                    .background(Color.black.opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(inputBorderLine, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    private var toastView: some View {
        VStack {
            if showToast {
                Text(toastMessage)
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundStyle(bgBase)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(accentGold)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 20)
            }
            Spacer()
        }
        .animation(.easeOut(duration: 0.22), value: showToast)
        .zIndex(50)
    }

    private func saveConfig() {
        let trimmedURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedURL.isEmpty, !trimmedKey.isEmpty else {
            showToastText("请填写完整的 Base URL 和 API Key")
            return
        }

        guard URL(string: trimmedURL) != nil else {
            showToastText("Base URL 格式不正确")
            return
        }

        let modelToSave: String? = {
            let trimmed = selectedModel.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { return trimmed }
            return availableModels.first
        }()

        if let modelToSave {
            selectedModel = modelToSave
        }

        AppConfigStore.shared.baseURLString = trimmedURL
        let saved = APIKeyStore.shared.save(trimmedKey)
        guard saved else {
            showToastText("API Key 保存失败")
            return
        }
        AppConfigStore.shared.selectedModel = modelToSave

        configStatus = "已更新"
        withAnimation(.easeOut(duration: 0.22)) {
            showConfigModal = false
        }
        showToastText("引擎配置已保存")
    }

    private func loadStoredConfig() {
        baseURL = AppConfigStore.shared.baseURLString
        if let key = APIKeyStore.shared.load(), !key.isEmpty {
            apiKey = key
            configStatus = "已配置"
        } else {
            apiKey = ""
            configStatus = "未配置"
        }
        selectedModel = AppConfigStore.shared.selectedModel ?? ""
        isModelListExpanded = false
    }

    private func testConnection() {
        let trimmedURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedURL.isEmpty, !trimmedKey.isEmpty else {
            showToastText("请先填写 Base URL 和 API Key")
            return
        }
        guard let base = URL(string: trimmedURL) else {
            showToastText("Base URL 格式不正确")
            return
        }

        isTestingConnection = true

        Task {
            defer {
                Task { @MainActor in
                    isTestingConnection = false
                }
            }

            let endpoint = base.appendingPathComponent("models")
            var request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.timeoutInterval = 12
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(trimmedKey)", forHTTPHeaderField: "Authorization")

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse else {
                    await MainActor.run {
                        showToastText("连接失败：响应无效")
                    }
                    return
                }

                await MainActor.run {
                    switch http.statusCode {
                    case 200...299:
                        let models = parseModelIDs(from: data)
                        availableModels = models
                        isModelListExpanded = false
                        if selectedModel.isEmpty || !models.contains(selectedModel) {
                            selectedModel = models.first ?? ""
                        }
                        if models.isEmpty {
                            showToastText("连通成功，但未拉取到可用模型")
                        } else {
                            showToastText("连通成功，拉取到 \(models.count) 个模型")
                        }
                    case 401, 403:
                        showToastText("已连通，但 API Key 无效或无权限")
                    case 404:
                        showToastText("已连通，但接口路径不存在")
                    default:
                        showToastText("已连通，状态码 \(http.statusCode)")
                    }
                }
            } catch {
                let message: String
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .timedOut:
                        message = "连接超时"
                    case .notConnectedToInternet:
                        message = "当前无网络连接"
                    case .cannotFindHost, .cannotConnectToHost:
                        message = "无法连接到服务器"
                    default:
                        message = "连接失败：\(urlError.localizedDescription)"
                    }
                } else {
                    message = "连接失败：\(error.localizedDescription)"
                }

                await MainActor.run {
                    showToastText(message)
                }
            }
        }
    }

    private func parseModelIDs(from data: Data) -> [String] {
        guard
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let rawList = object["data"] as? [[String: Any]]
        else {
            return []
        }

        let ids = rawList.compactMap { item in
            (item["id"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }

        return Array(Set(ids)).sorted()
    }

    private func showToastText(_ message: String) {
        toastMessage = message
        withAnimation(.easeOut(duration: 0.2)) {
            showToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.2)) {
                showToast = false
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

                let rect = CGRect(x: x - star.radius, y: y - star.radius, width: star.radius * 2, height: star.radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(star.opacity)))
            }

            for group in constellationGroups {
                guard let first = group.points.first else { continue }

                if group.points.count >= 2 {
                    var linePath = Path()
                    linePath.move(to: first.position)
                    for point in group.points.dropFirst() {
                        linePath.addLine(to: point.position)
                    }
                    context.stroke(linePath, with: .color(.white.opacity(group.lineOpacity)), lineWidth: 0.6)
                }

                for point in group.points {
                    let rect = CGRect(
                        x: point.position.x - point.radius,
                        y: point.position.y - point.radius,
                        width: point.radius * 2,
                        height: point.radius * 2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(point.baseOpacity)))
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

        var generator = ProfileSeededGenerator(state: 0x1234ABCD)

        stars = (0..<350).map { _ in
            ProfileStar(
                startX: Double.random(in: 0...size.width, using: &generator),
                startY: Double.random(in: 0...size.height, using: &generator),
                radius: Double.random(in: 0.2...1.2, using: &generator),
                velocityX: Double.random(in: -0.07...0.07, using: &generator),
                velocityY: Double.random(in: -0.05...0.05, using: &generator),
                opacity: Double.random(in: 0.05...0.4, using: &generator)
            )
        }

        let constellationShapes: [[CGPoint]] = [
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
            [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 15), CGPoint(x: 20, y: 30)]
        ]

        constellationGroups = constellationShapes.enumerated().map { idx, shape in
            let centerX = Double.random(in: size.width * 0.1...size.width * 0.9, using: &generator)
            let centerY = Double.random(in: size.height * 0.1...size.height * 0.9, using: &generator)
            let angle = Double.random(in: 0...(2 * .pi), using: &generator)
            let scale = Double.random(in: 1.2...2.6, using: &generator)

            let cosA = cos(angle)
            let sinA = sin(angle)
            let points = shape.map { offset -> ProfileConstellationPoint in
                let rotatedX = (Double(offset.x) * cosA - Double(offset.y) * sinA) * scale
                let rotatedY = (Double(offset.x) * sinA + Double(offset.y) * cosA) * scale
                return ProfileConstellationPoint(
                    position: CGPoint(x: centerX + rotatedX, y: centerY + rotatedY),
                    radius: Double.random(in: 0.9...1.8, using: &generator),
                    baseOpacity: Double.random(in: 0.35...0.78, using: &generator)
                )
            }

            return ProfileConstellationGroup(index: idx, points: points, lineOpacity: Double.random(in: 0.1...0.2, using: &generator))
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

private struct ProfileStar {
    let startX: Double
    let startY: Double
    let radius: Double
    let velocityX: Double
    let velocityY: Double
    let opacity: Double
}

private struct ProfileConstellationGroup {
    let index: Int
    let points: [ProfileConstellationPoint]
    let lineOpacity: Double
}

private struct ProfileConstellationPoint {
    let position: CGPoint
    let radius: Double
    let baseOpacity: Double
}

private struct ProfileSeededGenerator: RandomNumberGenerator {
    var state: UInt64

    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

#Preview {
    ProfileMeView()
        .background(.black)
}
