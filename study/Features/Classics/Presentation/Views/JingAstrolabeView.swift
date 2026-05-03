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

    private var chartDataBase64: String? { nil }

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
                        JingHTMLWebView(htmlURL: htmlURL, chartDataBase64: chartDataBase64)
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
    let chartDataBase64: String?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var lastLoadSignature: String?
    }

    private var loadSignature: String {
        // Bump this when JS behavior changes to force a full reload of local HTML.
        "jing-empty-state-v13"
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let script = WKUserScript(
            source: buildInjectionScript(),
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

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastLoadSignature != loadSignature {
            context.coordinator.lastLoadSignature = loadSignature
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        }
    }

    private func buildInjectionScript() -> String {
        let dataPart = chartDataBase64 ?? ""
        return """
        (function() {
          const DATA_B64 = '\(dataPart)';
          const TG = ['甲','乙','丙','丁','戊','己','庚','辛','壬','癸'];
          const DZ = ['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥'];
          const EOT = [-3, -14, -8, 0, 3, 2, -3, -6, -8, 16, 14, 2];
          const BEIJING_LON = 120;
          const LUCUN = [2,3,5,6,5,6,8,9,10,0];
          const KUIYUE = [[1,7],[0,8],[11,9],[11,9],[1,7],[0,8],[1,7],[6,2],[3,5],[3,5]];
          const HUO_START = [2,3,2,9,3,3,2,10,9,9,2,9];
          const LING_START = [10,3,10,10,10,10,3,3,10,10,10,10];
          const TIANMA_MAP = { 0:2, 4:2, 8:2, 1:10, 5:10, 9:10, 3:11, 7:11, 11:11, 2:5, 6:5, 10:5 };
          const NAYIN = [4,6,3,5,4, 6,2,5,4,3, 2,5,6,3,2, 4,6,3,5,4, 6,2,5,4,3, 2,5,6,3,2];
          const JU_NAMES = {2:'水二局',3:'木三局',4:'金四局',5:'土五局',6:'火六局'};
          const SIHUA_TABLE = [
            ['廉贞','破军','武曲','太阳'],
            ['天机','天梁','紫微','太阴'],
            ['天同','天机','文昌','廉贞'],
            ['太阴','天同','天机','巨门'],
            ['贪狼','太阴','右弼','天机'],
            ['武曲','贪狼','天梁','文曲'],
            ['太阳','武曲','太阴','天同'],
            ['巨门','太阳','文曲','文昌'],
            ['天梁','紫微','左辅','武曲'],
            ['破军','巨门','太阴','贪狼']
          ];
          const ZIWEI_OFFSETS = { '紫微':0, '天机':-1, '太阳':-3, '武曲':-4, '天同':-5, '廉贞':-8 };
          const TIANFU_OFFSETS = { '天府':0, '太阴':1, '贪狼':2, '巨门':3, '天相':4, '天梁':5, '七杀':6, '破军':10 };
          const SIHUA_TEXT = { lu: '禄', quan: '权', ke: '科', ji: '忌' };
          const SIHUA_CLASS = { lu: 's-gold', quan: 's-gold', ke: 's-gold', ji: 's-red' };
          const TG_TO_ELEMENT = {
            '甲': '木', '乙': '木',
            '丙': '火', '丁': '火',
            '戊': '土', '己': '土',
            '庚': '金', '辛': '金',
            '壬': '水', '癸': '水'
          };
          const ELEMENT_TO_TONE = {
            '木': '角',
            '火': '徵',
            '土': '宫',
            '金': '商',
            '水': '羽'
          };
          const TONE_AUDIO = {
            '宫': 'gong_C4_ancient.wav',
            '商': 'shang_D4_ancient.wav',
            '角': 'jue_E4_ancient.wav',
            '徵': 'zhi_G4_ancient.wav',
            '羽': 'yu_A4_ancient.wav'
          };
          const LUNAR_MONTHS = ['', '正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', '腊'];
          const LUNAR_DAYS = ['', '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
            '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
            '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'];
          const PALACE_NAMES = ['命宫','兄弟','夫妻','子女','财帛','疾厄','迁移','奴仆','官禄','田宅','福德','父母'];
          let currentChart = null;
          let toneAudio = null;

          function text(el, value) {
            if (el) el.textContent = value == null ? '' : String(value);
          }

          function two(value) {
            return String(value).padStart(2, '0');
          }

          function chartFromBase64() {
            if (!DATA_B64) return null;
            try {
              const binary = atob(DATA_B64);
              const bytes = Uint8Array.from(binary, (char) => char.charCodeAt(0));
              const jsonText = new TextDecoder('utf-8').decode(bytes);
              return JSON.parse(jsonText);
            } catch (error) {
              return null;
            }
          }

          function showToastSafe(message) {
            if (typeof window.showToast === 'function') {
              window.showToast(message);
            }
          }

          function playToneByStem(stem) {
            const element = TG_TO_ELEMENT[stem];
            const tone = ELEMENT_TO_TONE[element];
            const filename = TONE_AUDIO[tone];
            if (!filename) return;
            try {
              const src = new URL(filename, window.location.href).toString();
              if (!toneAudio) {
                toneAudio = new Audio(src);
              } else {
                toneAudio.pause();
                toneAudio.currentTime = 0;
                toneAudio.src = src;
              }
              toneAudio.play().catch(() => {});
              showToastSafe(`天干${stem} · ${element}行${tone}音`);
            } catch (error) {
            }
          }

          function hasChartData() {
            const byModel = !!(currentChart && Array.isArray(currentChart.palaces) && currentChart.palaces.some((palace) => palace && palace.tg));
            if (byModel) return true;
            const userName = (document.getElementById('currentUserName')?.textContent || '').trim();
            const hasNamedOwner = userName && userName !== '未创建';
            const hasBranchData = Array.from(document.querySelectorAll('.palace .p-branch'))
              .some((el) => {
                const value = (el.textContent || '').trim();
                return value && value !== '--';
              });
            return !!(hasNamedOwner && hasBranchData);
          }

          function buildOracleColumns(chart) {
            const ming = (chart.palaces || []).find((palace) => palace && palace.isMing) || {};
            const shen = (chart.palaces || []).find((palace) => palace && palace.isShen) || {};
            const liunian = chart.liunian || {};
            const activeLimit = (chart.limits || []).find((item) => {
              const age = liunian.age;
              return typeof age === 'number' && age >= item.startAge && age <= item.endAge;
            }) || null;
            const sihua = chart.sihua || {};

            const sihuaText = ['lu', 'quan', 'ke', 'ji']
              .map((key) => {
                const item = sihua[key];
                if (!item || !item.star) return '';
                const label = SIHUA_TEXT[key] || key;
                return `${label}：${item.star}`;
              })
              .filter(Boolean)
              .join('，');

            const columns = [
              {
                title: `命宫 · ${ming.tg || ''}${ming.dz || ''}`,
                body: `主星：${(ming.mainStars || []).join('、') || '暂无'}。辅星：${(ming.auxStars || []).join('、') || '暂无'}。${ming.name ? `宫位：${ming.name}。` : ''}${chart.meta?.juName ? `命局：${chart.meta.juName}。` : ''}`
              },
              {
                title: `身宫 · ${shen.tg || ''}${shen.dz || ''}`,
                body: `${shen.name ? `身宫落于「${shen.name}」。` : ''}${chart.meta?.label ? `命主信息：${chart.meta.label}。` : ''}${chart.meta?.trueTime ? `真太阳时：${chart.meta.trueTime.year}-${two(chart.meta.trueTime.month)}-${two(chart.meta.trueTime.day)} ${two(chart.meta.trueTime.hour)}:${two(chart.meta.trueTime.minute)}。` : ''}`
              },
              {
                title: `流年 · ${liunian.year || '--'}年`,
                body: `${liunian.tg ? `流年天干：${liunian.tg}。` : ''}${typeof liunian.age === 'number' ? `当前虚岁：${liunian.age}。` : ''}${activeLimit ? `所处大限：${activeLimit.startAge}~${activeLimit.endAge}岁（${activeLimit.startYear}~${activeLimit.endYear}）。` : '当前大限待推演。'}`
              },
              {
                title: '四化与总论',
                body: `${sihuaText || '四化信息暂缺。'}${chart.meta?.yinYang ? `命盘阴阳：${chart.meta.yinYang}${chart.meta.gender || ''}。` : ''}${chart.meta?.mingGong ? `命宫在${chart.meta.mingGong.dz}。` : ''}${chart.meta?.shenGong ? `身宫在${chart.meta.shenGong.dz}。` : ''}`
              }
            ];

            return columns.map((item) => {
              return `<div class=\"codex-data-column\"><h2>${item.title}</h2><p>${item.body}</p></div>`;
            }).join('');
          }

          function closeCenterOracleEffect() {
            const overlay = document.getElementById('codex-oracle-overlay');
            const stage = document.getElementById('codex-oracle-stage');
            const loader = document.getElementById('codex-bagua-loader');
            if (!overlay || !stage || !loader) return;
            stage.classList.remove('active');
            loader.classList.add('codex-rotating');
            setTimeout(() => {
              overlay.style.display = 'none';
            }, 260);
          }

          function showOraclePositionDebug(loaderTop, bookTop) {
            let debug = document.getElementById('codex-oracle-pos-debug');
            if (!debug) {
              debug = document.createElement('div');
              debug.id = 'codex-oracle-pos-debug';
              debug.style.cssText = 'position:fixed;left:50%;top:12px;transform:translateX(-50%);z-index:1600;padding:6px 10px;border:1px solid rgba(230,211,163,0.5);border-radius:12px;background:rgba(0,0,0,0.72);color:#e6d3a3;font-size:11px;letter-spacing:1px;';
              document.body.appendChild(debug);
            }
            debug.textContent = `动效定位: 八卦Y=${loaderTop}px 古卷Y=${bookTop}px`;
            clearTimeout(window.__codexOracleDebugTimer);
            window.__codexOracleDebugTimer = setTimeout(() => {
              const node = document.getElementById('codex-oracle-pos-debug');
              if (node && node.parentNode) node.parentNode.removeChild(node);
            }, 1600);
          }

          function triggerCenterOracleEffect() {
            if (!hasChartData()) {
              showToastSafe('请先建立命盘');
              return;
            }
            const oldOverlay = document.getElementById('codex-oracle-overlay');
            if (oldOverlay && oldOverlay.parentNode) {
              oldOverlay.parentNode.removeChild(oldOverlay);
            }
            const oldStyle = document.getElementById('codex-oracle-effect-style');
            if (oldStyle && oldStyle.parentNode) {
              oldStyle.parentNode.removeChild(oldStyle);
            }
            ensureCenterOracleEffect();
            const overlay = document.getElementById('codex-oracle-overlay');
            const stage = document.getElementById('codex-oracle-stage');
            const loader = document.getElementById('codex-bagua-loader');
            const book = document.querySelector('.codex-book-frame');
            const content = document.getElementById('codex-oracle-content');
            const viewport = document.getElementById('codex-oracle-scroll');
            if (!overlay || !stage || !loader || !book || !content) return;

            content.innerHTML = buildOracleColumns(currentChart);
            if (viewport) viewport.scrollLeft = 0;
            overlay.style.display = 'flex';
            stage.classList.remove('active');
            loader.classList.add('codex-rotating');

            const safeTop = Math.max(64, Math.round(window.innerHeight * 0.12));
            const loaderTop = safeTop;
            const bookTop = safeTop;
            loader.style.top = `${loaderTop}px`;
            book.style.top = `${bookTop}px`;
            loader.style.bottom = 'auto';
            book.style.bottom = 'auto';
            requestAnimationFrame(() => {
              showOraclePositionDebug(
                Math.round(loader.getBoundingClientRect().top),
                Math.round(book.getBoundingClientRect().top)
              );
            });

            setTimeout(() => {
              loader.classList.remove('codex-rotating');
              stage.classList.add('active');
            }, 1200);
          }

          function ensureCenterOracleEffect() {
            if (document.getElementById('codex-oracle-overlay')) return;
            const styleId = 'codex-oracle-effect-style';
            if (!document.getElementById(styleId)) {
              const style = document.createElement('style');
              style.id = styleId;
              style.textContent = `
                .codex-oracle-overlay{position:fixed;inset:0;z-index:1500;background:rgba(0,0,0,0.92);display:none;align-items:center;justify-content:center;padding:14px;}
                .codex-main-stage{position:relative;width:100%;height:100%;perspective:1000px;}
                .codex-bagua-loader{position:fixed;left:50%;top:0;width:180px;height:180px;z-index:4;transform:translateX(-50%);transition:all 1.2s cubic-bezier(0.7,0,0.3,1);}
                .codex-bagua-ring{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;border:1px solid rgba(230,211,163,0.65);border-radius:50%;}
                .codex-bagua-glyph{position:absolute;color:var(--c-gold);font-size:18px;text-shadow:0 0 10px rgba(230,211,163,0.45);}
                .codex-bagua-glyph.g0{transform:translate(0,-76px);}
                .codex-bagua-glyph.g1{transform:translate(54px,-54px);}
                .codex-bagua-glyph.g2{transform:translate(76px,0);}
                .codex-bagua-glyph.g3{transform:translate(54px,54px);}
                .codex-bagua-glyph.g4{transform:translate(0,76px);}
                .codex-bagua-glyph.g5{transform:translate(-54px,54px);}
                .codex-bagua-glyph.g6{transform:translate(-76px,0);}
                .codex-bagua-glyph.g7{transform:translate(-54px,-54px);}
                .codex-rotating{animation:codexRotate 2s linear infinite;}
                @keyframes codexRotate{
                  from{transform:translateX(-50%) rotate(0deg);}
                  to{transform:translateX(-50%) rotate(-360deg);}
                }
                .codex-book-frame{position:fixed;left:50%;top:0;width:min(90%,860px);height:min(62vh,500px);opacity:0;transform:translateX(-50%) rotateX(10deg) scale(0.8) translateY(50px);transition:all 1.5s ease-out;display:flex;flex-direction:column;align-items:center;}
                .codex-book-bg{position:absolute;width:100%;height:100%;background:#0d0d0d;border:1px solid rgba(230,211,163,0.42);box-shadow:0 0 50px rgba(0,0,0,0.9),inset 0 0 100px rgba(230,211,163,0.1);border-radius:8px;overflow:hidden;}
                .codex-book-bg::before{content:'';position:absolute;inset:0;opacity:.09;background-image:radial-gradient(rgba(230,211,163,.7) 1px,transparent 1px);background-size:42px 42px;}
                .codex-scroll-viewport{position:relative;width:90%;height:85%;margin-top:5%;overflow-x:auto;overflow-y:hidden;display:flex;scroll-behavior:smooth;mask-image:linear-gradient(to right,transparent,black 5%,black 95%,transparent);-webkit-mask-image:linear-gradient(to right,transparent,black 5%,black 95%,transparent);}
                .codex-scroll-viewport::-webkit-scrollbar{display:none;}
                .codex-data-content{display:flex;writing-mode:vertical-rl;padding:20px 40px;gap:56px;}
                .codex-data-column{display:flex;flex-direction:column;gap:14px;height:100%;}
                .codex-data-column h2{color:var(--c-gold);font-size:24px;border-left:1px solid rgba(230,211,163,0.75);padding-left:8px;margin:0;white-space:nowrap;}
                .codex-data-column p{color:#cfcfcf;font-size:17px;line-height:1.8;letter-spacing:2px;width:320px;}
                .codex-nav-hint{position:absolute;bottom:18px;color:var(--c-gold);font-size:12px;letter-spacing:2px;opacity:.65;animation:codexBreath 2s infinite;}
                @keyframes codexBreath{0%,100%{opacity:.35}50%{opacity:.8}}
                .codex-main-stage.active .codex-bagua-loader{transform:translateX(-50%) scale(0) rotate(-720deg);opacity:0;}
                .codex-main-stage.active .codex-book-frame{opacity:1;transform:translateX(-50%) rotateX(0deg) scale(1) translateY(0);}
                .codex-close-btn{position:absolute;right:12px;top:12px;height:34px;padding:0 14px;border:1px solid rgba(230,211,163,0.55);background:rgba(0,0,0,0.45);color:var(--c-gold);border-radius:18px;font-family:var(--font-serif);letter-spacing:2px;font-size:12px;cursor:pointer;z-index:6;}
              `;
              (document.head || document.documentElement).appendChild(style);
            }

            const overlay = document.createElement('div');
            overlay.id = 'codex-oracle-overlay';
            overlay.innerHTML = `
              <div class=\"codex-main-stage\" id=\"codex-oracle-stage\">
                <button class=\"codex-close-btn\" id=\"codex-oracle-close\">返回命盘</button>
                <div class=\"codex-bagua-loader codex-rotating\" id=\"codex-bagua-loader\">
                  <div class=\"codex-bagua-ring\">
                    <span class=\"codex-bagua-glyph g0\">☰</span><span class=\"codex-bagua-glyph g1\">☱</span>
                    <span class=\"codex-bagua-glyph g2\">☲</span><span class=\"codex-bagua-glyph g3\">☴</span>
                    <span class=\"codex-bagua-glyph g4\">☷</span><span class=\"codex-bagua-glyph g5\">☶</span>
                    <span class=\"codex-bagua-glyph g6\">☵</span><span class=\"codex-bagua-glyph g7\">☳</span>
                  </div>
                  <svg viewBox=\"0 0 100 100\" style=\"position:absolute;inset:34px;width:112px;height:112px;\">
                    <circle cx=\"50\" cy=\"50\" r=\"48\" fill=\"none\" stroke=\"#d4af37\" stroke-width=\"0.6\" />
                    <path d=\"M 50 5 A 22.5 22.5 0 0 1 50 50 A 22.5 22.5 0 0 0 50 95 A 45 45 0 0 1 50 5\" fill=\"#d4af37\" />
                    <circle cx=\"50\" cy=\"27.5\" r=\"4\" fill=\"#050505\" />
                    <circle cx=\"50\" cy=\"72.5\" r=\"4\" fill=\"#d4af37\" />
                  </svg>
                </div>
                <div class=\"codex-book-frame\">
                  <div class=\"codex-book-bg\"></div>
                  <div class=\"codex-scroll-viewport\" id=\"codex-oracle-scroll\">
                    <div class=\"codex-data-content\" id=\"codex-oracle-content\"></div>
                  </div>
                  <div class=\"codex-nav-hint\">〈 左右滑动 · 拨动命盘 〉</div>
                </div>
              </div>
            `;
            document.body.appendChild(overlay);

            const closeBtn = document.getElementById('codex-oracle-close');
            if (closeBtn) {
              closeBtn.addEventListener('click', closeCenterOracleEffect);
            }
            overlay.addEventListener('click', (event) => {
              if (event.target === overlay) {
                closeCenterOracleEffect();
              }
            });

            const scrollBox = document.getElementById('codex-oracle-scroll');
            if (scrollBox) {
              scrollBox.addEventListener('wheel', (event) => {
                if (Math.abs(event.deltaY) >= Math.abs(event.deltaX)) {
                  event.preventDefault();
                  scrollBox.scrollLeft += event.deltaY;
                }
              }, { passive: false });
            }
          }

          function bindCenterHubEffect() {
            const hub = document.querySelector('.center-hub');
            if (!hub || hub.dataset.codexHubBound === '1') return;
            hub.dataset.codexHubBound = '1';
            hub.style.cursor = 'pointer';
            hub.addEventListener('click', (event) => {
              event.preventDefault();
              event.stopPropagation();
              triggerCenterOracleEffect();
            }, false);
          }

          function installCenterHubGlobalTrigger() {
            if (window.__codexCenterHubTriggerInstalled) return;
            window.__codexCenterHubTriggerInstalled = true;
            document.addEventListener('click', (event) => {
              const target = event.target && event.target.closest
                ? event.target.closest('.center-hub')
                : null;
              if (!target) return;
              event.preventDefault();
              event.stopPropagation();
              event.stopImmediatePropagation();
              triggerCenterOracleEffect();
            }, true);
          }

          function parseLunarMonth(raw) {
            const value = String(raw || '').replace('月', '');
            const isLeap = value.includes('闰');
            const core = value.replace('闰', '');
            const monthMap = { '正': 1, '一': 1, '二': 2, '三': 3, '四': 4, '五': 5, '六': 6, '七': 7, '八': 8, '九': 9, '十': 10, '冬': 11, '腊': 12 };
            const num = Number(core);
            const month = Number.isFinite(num) && num > 0 ? num : (monthMap[core] || 1);
            return { month, isLeap };
          }

          function parseLunarDay(raw) {
            const day = Number(raw);
            if (Number.isFinite(day) && day > 0) return day;
            const map = {
              '初一':1,'初二':2,'初三':3,'初四':4,'初五':5,'初六':6,'初七':7,'初八':8,'初九':9,'初十':10,
              '十一':11,'十二':12,'十三':13,'十四':14,'十五':15,'十六':16,'十七':17,'十八':18,'十九':19,'二十':20,
              '廿一':21,'廿二':22,'廿三':23,'廿四':24,'廿五':25,'廿六':26,'廿七':27,'廿八':28,'廿九':29,'三十':30
            };
            return map[String(raw || '').trim()] || 1;
          }

          function lunarFromDate(date, hour, minute) {
            const fmt = new Intl.DateTimeFormat('zh-Hans-u-ca-chinese', {
              year: 'numeric',
              month: 'long',
              day: 'numeric'
            });
            const parts = fmt.formatToParts(date);
            const relatedYear = parts.find((p) => p.type === 'relatedYear')?.value;
            const yearValue = relatedYear || parts.find((p) => p.type === 'year')?.value || '';
            const monthValue = parts.find((p) => p.type === 'month')?.value || '';
            const dayValue = parts.find((p) => p.type === 'day')?.value || '';
            const monthInfo = parseLunarMonth(monthValue);
            return {
              year: Number(yearValue),
              month: monthInfo.month,
              day: parseLunarDay(dayValue),
              isLeap: monthInfo.isLeap,
              hour,
              minute
            };
          }

          function getBirthInfo(year, month, day, hour, minute, longitude) {
            const lonOffset = (longitude - BEIJING_LON) * 4;
            const eot = EOT[Math.max(0, Math.min(11, month - 1))];
            const trueDate = new Date(year, month - 1, day, hour, minute);
            trueDate.setMinutes(trueDate.getMinutes() + lonOffset + eot);
            const trueTime = {
              year: trueDate.getFullYear(),
              month: trueDate.getMonth() + 1,
              day: trueDate.getDate(),
              hour: trueDate.getHours(),
              minute: trueDate.getMinutes()
            };
            const lunar = lunarFromDate(trueDate, trueTime.hour, trueTime.minute);
            const birthDate = new Date(year, month - 1, day, hour, minute);
            const lunarBirth = lunarFromDate(birthDate, hour, minute);
            return { trueTime, lunar, lunarBirth };
          }

          function getYearGZ(lunarYear) {
            const tg = ((lunarYear - 4) % 10 + 10) % 10;
            const dz = ((lunarYear - 4) % 12 + 12) % 12;
            return { tg: TG[tg], dz: DZ[dz], tgIdx: tg, dzIdx: dz };
          }

          function getMonthGZ(lunarYear, lunarMonth) {
            const yearTg = ((lunarYear - 4) % 10 + 10) % 10;
            const yinTg = [2, 4, 6, 8, 0, 2, 4, 6, 8, 0][yearTg];
            const tg = (yinTg + lunarMonth - 1) % 10;
            const dz = (lunarMonth + 1) % 12;
            return { tg: TG[tg], dz: DZ[dz], tgIdx: tg, dzIdx: dz };
          }

          function getDayGZ(year, month, day) {
            const base = new Date(1900, 0, 1);
            const cur = new Date(year, month - 1, day);
            const days = Math.round((cur - base) / 86400000);
            const offset = ((days + 10) % 60 + 60) % 60;
            return { tg: TG[offset % 10], dz: DZ[offset % 12], tgIdx: offset % 10, dzIdx: offset % 12 };
          }

          function getHourDZ(hour) {
            return ((hour + 1) % 24) >> 1;
          }

          function getHourGZ(dayTgIdx, hour) {
            const ziTg = [0, 2, 4, 6, 8, 0, 2, 4, 6, 8][dayTgIdx];
            const dzIdx = getHourDZ(hour);
            const tgIdx = (ziTg + dzIdx) % 10;
            return { tg: TG[tgIdx], dz: DZ[dzIdx], tgIdx, dzIdx };
          }

          function getWuxingJu(tgIdx, dzIdx) {
            let gz60 = 0;
            for (let n = 0; n < 60; n += 1) {
              if (n % 10 === tgIdx && n % 12 === dzIdx) {
                gz60 = n;
                break;
              }
            }
            return NAYIN[Math.floor(gz60 / 2)];
          }

          function getGanzhiFromLunar(lunarBirth, gender, trueHour) {
            const hour = trueHour;
            const yearGZ = getYearGZ(lunarBirth.year);
            const monthGZ = getMonthGZ(lunarBirth.year, lunarBirth.month);
            const dayGZ = getDayGZ(lunarBirth.solarYear, lunarBirth.solarMonth, lunarBirth.solarDay);
            const hourGZ = getHourGZ(dayGZ.tgIdx, hour);
            const hourDZ = DZ[getHourDZ(hour)];

            const yangYear = yearGZ.tgIdx % 2 === 0;
            const yinYang = yangYear ? '阳' : '阴';
            const genderLabel = gender === 'M' ? '男' : '女';

            const yinTgIdx = [2, 4, 6, 8, 0, 2, 4, 6, 8, 0][yearGZ.tgIdx];
            const palaceTG = {};
            for (let i = 0; i < 12; i += 1) {
              const dzIdx = (2 + i) % 12;
              palaceTG[DZ[dzIdx]] = TG[(yinTgIdx + i) % 10];
            }

            const hourDzIdx = getHourDZ(hour);
            const monthPalace = (lunarBirth.month + 1) % 12;
            const mingGong = ((monthPalace - hourDzIdx) % 12 + 12) % 12;
            const shenGong = (monthPalace + hourDzIdx) % 12;

            const palaces = {};
            for (let i = 0; i < 12; i += 1) {
              const dzIdx = (mingGong + i) % 12;
              palaces[DZ[dzIdx]] = { name: PALACE_NAMES[i], dz: DZ[dzIdx], tg: palaceTG[DZ[dzIdx]] };
            }

            const mingTgIdx = TG.indexOf(palaceTG[DZ[mingGong]]);
            const ju = getWuxingJu(mingTgIdx, mingGong);

            return {
              year: yearGZ,
              month: monthGZ,
              day: dayGZ,
              hour: hourGZ,
              yinYang,
              gender: genderLabel,
              palaceTG,
              palaces,
              mingGong: { dzIdx: mingGong, dz: DZ[mingGong], tg: palaceTG[DZ[mingGong]] },
              shenGong: { dzIdx: shenGong, dz: DZ[shenGong], tg: palaceTG[DZ[shenGong]] },
              ju,
              juName: JU_NAMES[ju],
              label: `${yearGZ.tg}${yearGZ.dz}年${LUNAR_MONTHS[lunarBirth.month]}月${LUNAR_DAYS[lunarBirth.day]}日${hourDZ}时 ${yinYang}${genderLabel}`
            };
          }

          function getZiweiPos(ju, day) {
            let x = 0;
            while ((day + x) % ju !== 0) x += 1;
            const y = (day + x) / ju;
            let pos = (2 + y - 1) % 12;
            if (x % 2 === 0) {
              pos = (pos + x) % 12;
            } else {
              pos = ((pos - x) % 12 + 12) % 12;
            }
            return pos;
          }

          function place14Stars(ju, day) {
            const ziwei = getZiweiPos(ju, day);
            const tianfu = (ziwei + 8) % 12;
            const stars = {};
            Object.entries(ZIWEI_OFFSETS).forEach(([name, offset]) => {
              stars[name] = ((ziwei + offset) % 12 + 12) % 12;
            });
            Object.entries(TIANFU_OFFSETS).forEach(([name, offset]) => {
              stars[name] = (tianfu + offset) % 12;
            });
            return stars;
          }

          function getZuofu(month)  { return (month + 3) % 12; }
          function getYoubi(month)  { return (11 - month + 12) % 12; }
          function getWenqu(hourDz) { return (3 + hourDz) % 12; }
          function getWenchang(hourDz) { return (11 - hourDz + 12) % 12; }
          function getDijie(hourDz) { return (10 + hourDz) % 12; }
          function getDikong(hourDz) { return (12 - hourDz) % 12; }
          function getLucun(tgIdx) { return LUCUN[tgIdx]; }
          function getQingyang(tgIdx) { return (LUCUN[tgIdx] + 1) % 12; }
          function getTuoluo(tgIdx) { return (LUCUN[tgIdx] - 1 + 12) % 12; }
          function getTiankui(tgIdx) { return KUIYUE[tgIdx][0]; }
          function getTianyue(tgIdx) { return KUIYUE[tgIdx][1]; }
          function getHuoxing(yearDzIdx, hourDz) { return (HUO_START[yearDzIdx] + hourDz - 2 + 12) % 12; }
          function getLingxing(yearDzIdx, hourDz) { return (LING_START[yearDzIdx] + hourDz - 1 + 12) % 12; }
          function getTianma(yearDzIdx) { return TIANMA_MAP[yearDzIdx]; }

          function getSihua(tgIdx, allStars) {
            const [lu, quan, ke, ji] = SIHUA_TABLE[tgIdx];
            return {
              lu: { star: lu, pos: allStars[lu] ?? null },
              quan: { star: quan, pos: allStars[quan] ?? null },
              ke: { star: ke, pos: allStars[ke] ?? null },
              ji: { star: ji, pos: allStars[ji] ?? null }
            };
          }

          function getDaxian(ju, yangYear, gender, mingGongDz, birthYear) {
            const forward = (gender === 'M' && yangYear) || (gender === 'F' && !yangYear);
            return Array.from({ length: 12 }, (_, i) => {
              const startAge = ju + i * 10;
              const dzIdx = (mingGongDz + (forward ? i : -i) + 12) % 12;
              return {
                index: i + 1,
                startAge,
                endAge: startAge + 9,
                dzIdx,
                startYear: birthYear + startAge,
                endYear: birthYear + startAge + 9
              };
            });
          }

          function getLiunian(mingGongDz, birthYear, currentYear) {
            const age = currentYear - birthYear + 1;
            const dzIdx = (mingGongDz + age - 1) % 12;
            const tgIdx = ((currentYear - 4) % 10 + 10) % 10;
            return { year: currentYear, age, dzIdx, tg: TG[tgIdx] };
          }

          function calcChart(params) {
            const year = Number(params.year);
            const month = Number(params.month);
            const day = Number(params.day);
            const hour = Number(params.hour);
            const minute = Number(params.minute);
            const longitude = Number(params.longitude ?? 120);
            const gender = params.gender === 'F' ? 'F' : 'M';
            const currentYear = Number(params.currentYear || new Date().getFullYear());

            const info = getBirthInfo(year, month, day, hour, minute, longitude);

            const trueDateForDay = new Date(info.trueTime.year, info.trueTime.month - 1, info.trueTime.day);
            const lunarBirth = {
              ...info.lunarBirth,
              solarYear: trueDateForDay.getFullYear(),
              solarMonth: trueDateForDay.getMonth() + 1,
              solarDay: trueDateForDay.getDate()
            };
            const gz = getGanzhiFromLunar(lunarBirth, gender, info.trueTime.hour);
            const lunarMonth = info.lunarBirth.month;
            const hourDz = Math.floor(((info.trueTime.hour + 1) % 24) / 2);
            const yearTgIdx = gz.year.tgIdx;
            const yearDzIdx = gz.year.dzIdx;

            const stars = place14Stars(gz.ju, info.lunarBirth.day);
            const aux = {
              '左辅': getZuofu(lunarMonth), '右弼': getYoubi(lunarMonth),
              '文曲': getWenqu(hourDz), '文昌': getWenchang(hourDz),
              '地劫': getDijie(hourDz), '地空': getDikong(hourDz),
              '禄存': getLucun(yearTgIdx), '擎羊': getQingyang(yearTgIdx), '陀罗': getTuoluo(yearTgIdx),
              '天魁': getTiankui(yearTgIdx), '天钺': getTianyue(yearTgIdx),
              '火星': getHuoxing(yearDzIdx, hourDz), '铃星': getLingxing(yearDzIdx, hourDz),
              '天马': getTianma(yearDzIdx)
            };

            const allStars = { ...stars, ...aux };
            const sihua = getSihua(yearTgIdx, allStars);
            const sihuaMap = {};
            Object.entries(sihua).forEach(([type, data]) => {
              if (data.pos !== null) {
                if (!sihuaMap[data.pos]) sihuaMap[data.pos] = [];
                sihuaMap[data.pos].push({ star: data.star, type });
              }
            });

            const yangYear = yearTgIdx % 2 === 0;
            const limits = getDaxian(gz.ju, yangYear, gender, gz.mingGong.dzIdx, year);
            const liunian = getLiunian(gz.mingGong.dzIdx, year, currentYear);

            const palaces = DZ.map((dz, dzIdx) => {
              const offset = (dzIdx - gz.mingGong.dzIdx + 12) % 12;
              const liunianAges = Array.from({ length: 10 }, (_, i) => 1 + offset + i * 12).filter((a) => a <= 120);
              return {
                dz,
                tg: gz.palaceTG[dz],
                name: gz.palaces[dz]?.name || '',
                isMing: dzIdx === gz.mingGong.dzIdx,
                isShen: dzIdx === gz.shenGong.dzIdx,
                mainStars: Object.entries(stars).filter(([, p]) => p === dzIdx).map(([n]) => n),
                auxStars: Object.entries(aux).filter(([, p]) => p === dzIdx).map(([n]) => n),
                sihua: sihuaMap[dzIdx] || [],
                daxian: limits.find((l) => l.dzIdx === dzIdx) || null,
                liunianAges
              };
            });

            return {
              meta: {
                label: gz.label,
                trueTime: info.trueTime,
                lunar: info.lunarBirth,
                ganzhi: { year: gz.year, month: gz.month, day: gz.day, hour: gz.hour },
                mingGong: gz.mingGong,
                shenGong: gz.shenGong,
                ju: gz.ju,
                juName: gz.juName,
                yinYang: gz.yinYang,
                gender: gz.gender
              },
              palaces,
              sihua,
              liunian,
              limits
            };
          }

          function ensureCreatePanel() {
            if (document.getElementById('codex-create-chart-modal')) return;
            const root = document.createElement('div');
            root.id = 'codex-create-chart-modal';
            root.style.cssText = 'position:fixed;inset:0;z-index:1200;background:rgba(0,0,0,0.68);display:none;align-items:center;justify-content:center;padding:20px;';
            root.innerHTML = `
              <div style="width:min(480px,100%);background:rgba(10,10,10,0.95);border:1px solid rgba(238,238,238,0.2);border-radius:10px;padding:18px 16px;backdrop-filter:blur(14px);">
                <div style="font-family:var(--font-serif);font-size:1rem;color:var(--c-gold);letter-spacing:1px;margin-bottom:12px;">建立新命盘</div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;">
                  <label style="grid-column:1/3;color:var(--c-gray);font-size:12px;">姓名<input id="codex-name" type="text" placeholder="请输入姓名" style="margin-top:6px;width:100%;height:36px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.2);border-radius:6px;color:#fff;padding:0 10px;"></label>
                  <label style="color:var(--c-gray);font-size:12px;">公历年<input id="codex-year" type="number" value="2000" style="margin-top:6px;width:100%;height:36px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.2);border-radius:6px;color:#fff;padding:0 10px;"></label>
                  <label style="color:var(--c-gray);font-size:12px;">月<input id="codex-month" type="number" value="2" min="1" max="12" style="margin-top:6px;width:100%;height:36px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.2);border-radius:6px;color:#fff;padding:0 10px;"></label>
                  <label style="color:var(--c-gray);font-size:12px;">日<input id="codex-day" type="number" value="22" min="1" max="31" style="margin-top:6px;width:100%;height:36px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.2);border-radius:6px;color:#fff;padding:0 10px;"></label>
                  <label style="color:var(--c-gray);font-size:12px;">时<input id="codex-hour" type="number" value="3" min="0" max="23" style="margin-top:6px;width:100%;height:36px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.2);border-radius:6px;color:#fff;padding:0 10px;"></label>
                  <label style="color:var(--c-gray);font-size:12px;">分<input id="codex-minute" type="number" value="40" min="0" max="59" style="margin-top:6px;width:100%;height:36px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.2);border-radius:6px;color:#fff;padding:0 10px;"></label>
                  <label style="color:var(--c-gray);font-size:12px;">经度<input id="codex-lon" type="number" step="0.001" value="110.917" style="margin-top:6px;width:100%;height:36px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.2);border-radius:6px;color:#fff;padding:0 10px;"></label>
                  <label style="color:var(--c-gray);font-size:12px;">性别
                    <select id="codex-gender" style="margin-top:6px;width:100%;height:36px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.2);border-radius:6px;color:#fff;padding:0 10px;">
                      <option value="M">男</option>
                      <option value="F">女</option>
                    </select>
                  </label>
                </div>
                <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:16px;">
                  <button id="codex-cancel" style="height:34px;padding:0 16px;background:transparent;border:1px solid rgba(255,255,255,0.22);border-radius:6px;color:var(--c-gray);">取消</button>
                  <button id="codex-submit" style="height:34px;padding:0 16px;background:var(--c-gold);border:none;border-radius:6px;color:#111;font-weight:700;">计算命盘</button>
                </div>
              </div>`;
            document.body.appendChild(root);

            root.addEventListener('click', (event) => {
              if (event.target === root) {
                root.style.display = 'none';
              }
            });
            root.querySelector('#codex-cancel').addEventListener('click', () => {
              root.style.display = 'none';
            });
            root.querySelector('#codex-submit').addEventListener('click', () => {
              const name = root.querySelector('#codex-name').value.trim();
              const year = Number(root.querySelector('#codex-year').value);
              const month = Number(root.querySelector('#codex-month').value);
              const day = Number(root.querySelector('#codex-day').value);
              const hour = Number(root.querySelector('#codex-hour').value);
              const minute = Number(root.querySelector('#codex-minute').value);
              const longitude = Number(root.querySelector('#codex-lon').value);
              const gender = root.querySelector('#codex-gender').value === 'F' ? 'F' : 'M';

              if (!name) {
                showToastSafe('请输入姓名');
                return;
              }

              if (!Number.isFinite(year) || !Number.isFinite(month) || !Number.isFinite(day) || !Number.isFinite(hour) || !Number.isFinite(minute) || !Number.isFinite(longitude)) {
                showToastSafe('输入有误，请检查参数');
                return;
              }

              try {
                const chart = calcChart({
                  year, month, day, hour, minute,
                  longitude, gender,
                  currentYear: new Date().getFullYear()
                });
                chart.meta.ownerName = name;
                currentChart = chart;
                applyChart(chart);
                root.style.display = 'none';
                showToastSafe(`命盘已生成：${name}`);
              } catch (error) {
                showToastSafe('命盘计算失败，请检查输入');
              }
            });
          }

          function openCreatePanel() {
            ensureCreatePanel();
            const panel = document.getElementById('codex-create-chart-modal');
            if (panel) panel.style.display = 'flex';
          }

          function installGlobalCreateTrigger() {
            if (window.__codexCreateTriggerInstalled) return;
            window.__codexCreateTriggerInstalled = true;
            document.addEventListener('click', (event) => {
              const target = event.target && event.target.closest
                ? event.target.closest('#btnAddNew, .u-add')
                : null;
              if (!target) return;
              const label = (target.textContent || '').trim();
              if (!label.includes('建立新命盘')) return;
              event.preventDefault();
              event.stopPropagation();
              event.stopImmediatePropagation();
              openCreatePanel();
            }, true);
          }

          function lockTimelineHorizontalOnly() {
            const containers = Array.from(document.querySelectorAll('.tl-content'));
            containers.forEach((container) => {
              if (container.dataset.codexLocked === '1') return;
              container.dataset.codexLocked = '1';
              let startX = 0;
              let startY = 0;
              container.addEventListener('touchstart', (event) => {
                const touch = event.touches && event.touches[0];
                if (!touch) return;
                startX = touch.clientX;
                startY = touch.clientY;
              }, { passive: true });
              container.addEventListener('touchmove', (event) => {
                const touch = event.touches && event.touches[0];
                if (!touch) return;
                const deltaX = Math.abs(touch.clientX - startX);
                const deltaY = Math.abs(touch.clientY - startY);
                if (deltaY > deltaX) {
                  event.preventDefault();
                }
              }, { passive: false });
              container.addEventListener('wheel', (event) => {
                if (Math.abs(event.deltaY) > Math.abs(event.deltaX)) {
                  event.preventDefault();
                }
              }, { passive: false });
            });
          }

          function setupCreateButton() {
            const oldBtn = document.getElementById('btnAddNew');
            if (!oldBtn) return;

            let btn = oldBtn;
            if (oldBtn.dataset.codexReplaced !== '1' && oldBtn.parentNode) {
              const cloned = oldBtn.cloneNode(true);
              cloned.dataset.codexReplaced = '1';
              oldBtn.parentNode.replaceChild(cloned, oldBtn);
              btn = cloned;
            }

            if (btn.dataset.codexBound === '1') return;
            btn.dataset.codexBound = '1';
            btn.addEventListener('click', (event) => {
              event.preventDefault();
              event.stopPropagation();
              event.stopImmediatePropagation();
              openCreatePanel();
            }, true);
          }

          function renderMainStars(stars, sihua) {
            const list = Array.isArray(stars) ? stars : [];
            const marks = Array.isArray(sihua) ? sihua : [];
            return list.map((starName) => {
              const mark = marks.find((item) => item && item.star === starName);
              const badge = mark
                ? `<span class=\"s-sihua ${SIHUA_CLASS[mark.type] || 's-gold'}\">${SIHUA_TEXT[mark.type] || mark.type || ''}</span>`
                : '';
              return `<div class=\"star-col\"><span class=\"s-name\">${starName}</span>${badge}</div>`;
            }).join('');
          }

          function renderAuxStars(stars) {
            const list = Array.isArray(stars) ? stars : [];
            if (!list.length) return '';
            const rows = [];
            for (let i = 0; i < list.length; i += 2) {
              rows.push(`<div class=\"minor-col\">${list.slice(i, i + 2).join(' ')}</div>`);
            }
            return rows.join('');
          }

          function clearChartDisplay() {
            currentChart = null;
            const currentUserName = document.getElementById('currentUserName');
            const hubName = document.getElementById('hubName');
            text(currentUserName, '未创建');
            text(hubName, '未创建');

            const dateSub = document.querySelector('.date-sub');
            if (dateSub) dateSub.textContent = '尚未创建命盘';

            const headerRight = document.querySelector('.header-right');
            if (headerRight) headerRight.textContent = '--时';

            const hubTag = document.querySelector('.hub-tag');
            if (hubTag) hubTag.textContent = '待创建';

            const hubJu = document.getElementById('hubJu');
            if (hubJu) hubJu.textContent = '--局';

            const hubInfos = document.querySelectorAll('.center-hub .hub-info');
            if (hubInfos.length > 0) hubInfos[0].innerHTML = '<span>真太阳时</span> <span style=\"color:var(--c-white)\">--</span>';
            if (hubInfos.length > 1) hubInfos[1].innerHTML = '<span>命宫</span> <span style=\"color:var(--c-gold)\">--</span> <span style=\"margin-left:10px;\">身宫</span> <span style=\"color:var(--c-gold)\">--</span>';
            if (hubInfos.length > 2) hubInfos[2].textContent = '点击“建立新命盘”开始';

            document.querySelectorAll('.four-pillars .pillar-col').forEach((col) => {
              text(col.querySelector('.c-stem'), '--');
              text(col.querySelector('.c-branch'), '--');
            });

            document.querySelectorAll('.palace').forEach((palaceEl) => {
              palaceEl.classList.remove('ming-gong', 'active', 'trine');
              const major = palaceEl.querySelector('.p-major-stars');
              if (major) major.innerHTML = '';
              const minor = palaceEl.querySelector('.p-minor-stars');
              if (minor) minor.innerHTML = '';
              const gods = palaceEl.querySelector('.p-gods');
              if (gods) gods.style.display = 'none';
              const ageEl = palaceEl.querySelector('.p-age');
              if (ageEl) text(ageEl, '--');
              const nameEl = palaceEl.querySelector('.p-name');
              if (nameEl) text(nameEl, '--');
              const branchEl = palaceEl.querySelector('.p-branch');
              if (branchEl) text(branchEl, '--');
            });

            document.querySelectorAll('.limit-btn').forEach((btn) => {
              btn.classList.remove('active');
              btn.style.display = 'none';
            });

            document.querySelectorAll('.tl-row:nth-of-type(2) .tl-cell').forEach((cell) => {
              cell.classList.remove('active');
              text(cell.querySelector('.t-top'), '--');
              text(cell.querySelector('.t-bot'), '--');
            });

            document.querySelectorAll('.palace').forEach((palaceEl) => {
              palaceEl.removeAttribute('data-tg-stem');
              palaceEl.removeAttribute('data-tone');
            });
          }

          function applyChart(chart) {
            if (!chart || !Array.isArray(chart.palaces)) return;
            currentChart = chart;

            const dateSub = document.querySelector('.date-sub');
            if (dateSub && chart.meta && chart.meta.label) {
              dateSub.textContent = chart.meta.label;
            }

            const headerRight = document.querySelector('.header-right');
            if (headerRight && chart.meta && chart.meta.ganzhi && chart.meta.ganzhi.hour) {
              headerRight.textContent = `${chart.meta.ganzhi.hour.dz}时`;
            }

            const hubTag = document.querySelector('.hub-tag');
            if (hubTag && chart.meta) {
              hubTag.textContent = `${chart.meta.yinYang || ''}${chart.meta.gender || ''}`;
            }

            const hubJu = document.getElementById('hubJu');
            if (hubJu && chart.meta && chart.meta.juName) {
              hubJu.textContent = chart.meta.juName;
            }
            const ownerName = chart.meta?.ownerName;
            if (ownerName) {
              const userName = document.getElementById('currentUserName');
              const hubName = document.getElementById('hubName');
              text(userName, ownerName);
              text(hubName, ownerName);
            }

            const hubInfos = document.querySelectorAll('.center-hub .hub-info');
            if (hubInfos.length > 0 && chart.meta && chart.meta.trueTime) {
              const t = chart.meta.trueTime;
              hubInfos[0].innerHTML = `<span>真太阳时</span> <span style=\"color:var(--c-white)\">${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}</span>`;
            }
            if (hubInfos.length > 1 && chart.meta) {
              const ming = chart.meta.mingGong || {};
              const shen = chart.meta.shenGong || {};
              hubInfos[1].innerHTML = `<span>命宫</span> <span style=\"color:var(--c-gold)\">${ming.dz || ''}</span> <span style=\"margin-left:10px;\">身宫</span> <span style=\"color:var(--c-gold)\">${shen.dz || ''}</span>`;
            }
            if (hubInfos.length > 2 && Array.isArray(chart.limits) && chart.limits.length > 0) {
              hubInfos[2].textContent = `出生后 ${chart.limits[0].startAge} 岁起运`;
            }

            const pillarValues = [
              chart.meta?.ganzhi?.year,
              chart.meta?.ganzhi?.month,
              chart.meta?.ganzhi?.day,
              chart.meta?.ganzhi?.hour,
            ];
            document.querySelectorAll('.four-pillars .pillar-col').forEach((col, index) => {
              const value = pillarValues[index] || {};
              text(col.querySelector('.c-stem'), value.tg || '');
              text(col.querySelector('.c-branch'), value.dz || '');
            });

            chart.palaces.forEach((palace, dzIdx) => {
              const palaceEl = document.querySelector(`.palace[data-idx=\"${dzIdx}\"]`);
              if (!palaceEl) return;

              palaceEl.classList.toggle('ming-gong', !!palace.isMing);

              const major = palaceEl.querySelector('.p-major-stars');
              if (major) {
                major.innerHTML = renderMainStars(palace.mainStars, palace.sihua);
              }

              const minor = palaceEl.querySelector('.p-minor-stars');
              if (minor) {
                minor.innerHTML = renderAuxStars(palace.auxStars);
              }

              const gods = palaceEl.querySelector('.p-gods');
              if (gods) {
                gods.style.display = 'none';
              }

              const ageText = palace.daxian ? `${palace.daxian.startAge}~${palace.daxian.endAge}` : '--';
              const ageEl = palaceEl.querySelector('.p-age');
              if (ageEl) text(ageEl, ageText);

              const nameEl = palaceEl.querySelector('.p-name');
              if (nameEl) {
                const shenMark = palace.isShen ? '·身' : '';
                text(nameEl, `${palace.name || ''}${shenMark}`);
              }

              const branchEl = palaceEl.querySelector('.p-branch');
              if (branchEl) text(branchEl, `${palace.tg || ''}${palace.dz || ''}`);

              const stem = String(palace.tg || '').slice(0, 1);
              const element = TG_TO_ELEMENT[stem] || '';
              const tone = ELEMENT_TO_TONE[element] || '';
              palaceEl.setAttribute('data-tg-stem', stem);
              palaceEl.setAttribute('data-tone', tone);
            });

            const limitBtns = Array.from(document.querySelectorAll('.limit-btn'));
            const limits = Array.isArray(chart.limits) ? chart.limits : [];
            limitBtns.forEach((btn, index) => {
              if (index === 0) {
                btn.style.display = 'none';
                return;
              }

              const limit = limits[index - 1];
              if (!limit) {
                btn.style.display = 'none';
                return;
              }

              btn.style.display = '';
              btn.setAttribute('data-age', `${limit.startAge}~${limit.endAge}`);
              const top = btn.querySelector('.t-top');
              const bot = btn.querySelector('.t-bot');
              const dz = DZ[limit.dzIdx] || '';
              const palace = chart.palaces.find((item) => item && item.dz === dz);
              text(top, `${palace?.tg || ''}${dz}`);
              text(bot, `${limit.startAge}~${limit.endAge}`);

              const liuAge = chart.liunian?.age;
              const active = typeof liuAge === 'number' && liuAge >= limit.startAge && liuAge <= limit.endAge;
              btn.classList.toggle('active', !!active);
            });

            const liuCells = Array.from(document.querySelectorAll('.tl-row:nth-of-type(2) .tl-cell'));
            if (liuCells.length > 0 && chart.liunian && chart.liunian.year) {
              const startYear = chart.liunian.year - 2;
              liuCells.forEach((cell, index) => {
                const year = startYear + index;
                const tg = TG[((year - 4) % 10 + 10) % 10];
                const dz = DZ[((year - 4) % 12 + 12) % 12];
                text(cell.querySelector('.t-top'), year);
                text(cell.querySelector('.t-bot'), `${tg}${dz}`);
                cell.classList.toggle('active', year === chart.liunian.year);
              });
            }

            const mingIdx = chart.palaces.findIndex((item) => item && item.isMing);
            if (mingIdx >= 0 && typeof window.highlightPalace === 'function') {
              window.highlightPalace(mingIdx);
            }

            bindPalaceToneHandlers();
          }

          function bindPalaceToneHandlers() {
            document.querySelectorAll('.palace').forEach((palaceEl) => {
              if (palaceEl.dataset.codexToneBound === '1') return;
              palaceEl.dataset.codexToneBound = '1';
              palaceEl.addEventListener('click', () => {
                const stem = palaceEl.getAttribute('data-tg-stem') || '';
                if (!stem) return;
                playToneByStem(stem);
              }, false);
            });
          }

          function apply() {
            const styleId = 'codex-hide-jing-bottom-nav';
            if (!document.getElementById(styleId)) {
              const style = document.createElement('style');
              style.id = styleId;
              style.innerHTML = '\\n                .bottom-nav{display:none !important;height:0 !important;min-height:0 !important;}\\n                #bottomNav{display:none !important;height:0 !important;min-height:0 !important;}\\n                #starCanvas{display:none !important;}\\n                html, body { background: transparent !important; overflow: hidden !important; overscroll-behavior-y: none !important; }\\n                .tl-cell.active .t-top, .tl-cell.active .t-bot { color: #050505 !important; font-weight: 700 !important; }\\n                .timeline-section, .tl-row { overflow-y: hidden !important; }\\n                .tl-content { overflow-y: hidden !important; touch-action: pan-x !important; -webkit-overflow-scrolling: touch !important; }\\n              ';
              (document.head || document.documentElement).appendChild(style);
            }

            const nav = document.getElementById('bottomNav');
            if (nav && nav.parentNode) {
              nav.parentNode.removeChild(nav);
            }

            document.querySelectorAll('.u-item').forEach((item) => item.remove());
            const selector = document.getElementById('userSelector');
            if (selector) selector.classList.remove('open');

            installGlobalCreateTrigger();
            installCenterHubGlobalTrigger();
            setupCreateButton();
            ensureCreatePanel();
            lockTimelineHorizontalOnly();
            bindPalaceToneHandlers();
            bindCenterHubEffect();
            currentChart = null;
            clearChartDisplay();
            setTimeout(setupCreateButton, 0);
            setTimeout(setupCreateButton, 200);
            setTimeout(lockTimelineHorizontalOnly, 0);
            setTimeout(bindCenterHubEffect, 0);
          }

          apply();
          document.addEventListener('DOMContentLoaded', apply, { once: true });
          window.addEventListener('load', apply, { once: true });
        })();
        """
    }
}
#else
private struct JingHTMLWebView: View {
    let htmlURL: URL
    let chartDataBase64: String?

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
