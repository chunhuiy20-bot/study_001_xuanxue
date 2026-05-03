import SwiftUI

struct RootView: View {
    private enum Scene {
        case splash
        case home
        case archives
        case classics
        case casting
        case oracle
    }

    private enum SceneNavDirection {
        case neutral
        case forward
        case backward
    }

    private enum FixedTab {
        case home
        case archives
        case classics
    }

    private let navBackgroundColor = Color.black
    private let navActiveColor = Color(red: 230.0 / 255.0, green: 194.0 / 255.0, blue: 122.0 / 255.0)
    private let navInactiveColor = Color(red: 90.0 / 255.0, green: 96.0 / 255.0, blue: 114.0 / 255.0)

    @State private var scene: Scene = .splash
    @State private var navDirection: SceneNavDirection = .neutral

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            switch scene {
            case .splash:
                LaunchSplashView {
                    navDirection = .neutral
                    withAnimation(.easeInOut(duration: 0.8)) {
                        scene = .home
                    }
                }
                .transition(sceneTransition)
            case .home, .archives, .classics:
                ZStack {
                    DivinationHomeView(
                        onCastingRequested: {
                            navDirection = .forward
                            withAnimation(.easeInOut(duration: 0.6)) {
                                scene = .casting
                            }
                        },
                        onArchiveRequested: {},
                        showsEmbeddedBottomNav: false,
                        isActive: scene == .home
                    )
                    .opacity(scene == .home ? 1 : 0)
                    .allowsHitTesting(scene == .home)

                    ArchiveRecordsView(
                        onBack: {},
                        showsEmbeddedBottomNav: false,
                        isActive: scene == .archives
                    )
                    .opacity(scene == .archives ? 1 : 0)
                    .allowsHitTesting(scene == .archives)

                    JingAstrolabeView()
                        .opacity(scene == .classics ? 1 : 0)
                        .allowsHitTesting(scene == .classics)
                }
                .padding(.bottom, globalBottomInset)
                .animation(.easeInOut(duration: 0.22), value: scene)
                .transition(sceneTransition)
            case .casting:
                HexagramCastingView(
                    onBack: {
                        navDirection = .backward
                        withAnimation(.easeInOut(duration: 0.6)) {
                            scene = .home
                        }
                    },
                    onInterpretationRequested: {
                        navDirection = .forward
                        withAnimation(.easeInOut(duration: 0.6)) {
                            scene = .oracle
                        }
                    }
                )
                .transition(sceneTransition)
            case .oracle:
                OracleDecodeView {
                    navDirection = .backward
                    withAnimation(.easeInOut(duration: 0.6)) {
                        scene = .casting
                    }
                }
                .transition(sceneTransition)
            }

            if let activeTab = activeFixedTab {
                VStack {
                    Spacer()
                    fixedBottomNav(activeTab: activeTab)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .animation(.easeInOut(duration: 0.24), value: scene)
    }

    private var sceneTransition: AnyTransition {
        switch navDirection {
        case .forward:
            return .asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.995)),
                removal: .opacity
            )
        case .backward:
            return .asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.995)),
                removal: .opacity
            )
        case .neutral:
            return .opacity
        }
    }

    private var activeFixedTab: FixedTab? {
        switch scene {
        case .home:
            return .home
        case .archives:
            return .archives
        case .classics:
            return .classics
        default:
            return nil
        }
    }

    private var globalBottomInset: CGFloat {
        104
    }

    private func fixedBottomNav(activeTab: FixedTab) -> some View {
        HStack(spacing: 0) {
            fixedNavItem(title: "卜", active: activeTab == .home) {
                guard scene != .home else { return }
                navDirection = .backward
                withAnimation(.easeInOut(duration: 0.24)) {
                    scene = .home
                }
            }

            fixedNavItem(title: "案", active: activeTab == .archives) {
                guard scene != .archives else { return }
                navDirection = .forward
                withAnimation(.easeInOut(duration: 0.24)) {
                    scene = .archives
                }
            }

            fixedNavItem(title: "盘", active: activeTab == .classics) {
                guard scene != .classics else { return }
                navDirection = .forward
                withAnimation(.easeInOut(duration: 0.24)) {
                    scene = .classics
                }
            }
            fixedNavItem(title: "我", active: false, action: nil)
        }
        .frame(height: 85)
        .padding(.bottom, 20)
        .background(
            navBackgroundColor
                .overlay(
                    Rectangle()
                        .fill(.white.opacity(0.05))
                        .frame(height: 1),
                    alignment: .top
                )
        )
    }

    private func fixedNavItem(title: String, active: Bool, action: (() -> Void)?) -> some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundStyle(active ? navActiveColor : navInactiveColor)
                Circle()
                    .fill(active ? navActiveColor : .clear)
                    .frame(width: 4, height: 4)
                    .shadow(color: active ? navActiveColor : .clear, radius: 8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RootView()
}
