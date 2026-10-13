import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Timeline Entry
public struct NumberTickerEntry: TimelineEntry {
    public let date: Date
    public let tickerState: NumberTickerState

    public init(date: Date = Date(), tickerState: NumberTickerState) {
        self.date = date
        self.tickerState = tickerState
    }
}

// MARK: - Provider
public struct NumberTickerProvider: TimelineProvider {
    public typealias Entry = NumberTickerEntry

    public init() {}

    public func placeholder(in context: Context) -> NumberTickerEntry {
        let now = Date()
        return NumberTickerEntry(
            date: now,
            tickerState: NumberTickerState(startDate: now.addingTimeInterval(-125))
        )
    }

    public func getSnapshot(in context: Context, completion: @escaping (NumberTickerEntry) -> Void) {
        completion(makeCurrentEntry())
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<NumberTickerEntry>) -> Void) {
        let entry = makeCurrentEntry()
        // 系统渲染引擎会自动驱动 Text(..., style: .timer) 逐秒刷新，
        // 小组件自身代码无需每秒唤醒。这里设置 15 分钟后刷新 Timeline 作为保底策略。
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    public func makeCurrentEntry() -> NumberTickerEntry {
        let defaults = UserDefaults(suiteName: "group.com.eastlakestudio.luduan") ?? UserDefaults.standard
        let storedTimestamp = defaults.double(forKey: "numberTickerBaseTimestamp")
        let startDate: Date
        if storedTimestamp > 0 {
            startDate = Date(timeIntervalSince1970: storedTimestamp)
        } else {
            startDate = Date()
            defaults.set(startDate.timeIntervalSince1970, forKey: "numberTickerBaseTimestamp")
        }
        let state = NumberTickerState(startDate: startDate)
        return NumberTickerEntry(date: Date(), tickerState: state)
    }
}

// MARK: - Widget Views
public struct NumberTickerWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    public let entry: NumberTickerEntry

    public init(entry: NumberTickerEntry) {
        self.entry = entry
    }

    public var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallView
            default:
                mediumView
            }
        }
        .unredacted()
        .containerBackground(for: .widget) {
            backgroundLayer
        }
    }

    // MARK: - Small View (纯数字聚焦)
    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 7, height: 7)
                Text("秒级动态走字")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button(intent: ResetTickerIntent()) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 22, height: 22)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text("已过去秒数")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)

                // 核心：由系统渲染器（Render Server）每秒动态跳动的数字
                Text(entry.tickerState.startDate, style: .timer)
                    .font(.system(size: 30, weight: .black, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.yellow)
                Text("系统 GPU 原生驱动 · 零耗电")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(.secondary.opacity(0.8))
            }
        }
        .padding(4)
    }

    // MARK: - Medium View (正计时 + 倒计时 双数字仪表盘)
    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 顶栏
            HStack {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("iOS 桌面每秒动态数字 DEMO")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.primary)
                }

                Spacer()

                Button(intent: ResetTickerIntent()) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 10, weight: .bold))
                        Text("重置秒数")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
            }

            // 双数字卡片并排
            HStack(spacing: 10) {
                // 卡片 1：正计时秒表
                VStack(alignment: .leading, spacing: 3) {
                    Text("正向秒表 (Count-Up)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)

                    Text(entry.tickerState.startDate, style: .timer)
                        .font(.system(size: 26, weight: .heavy, design: .monospaced))
                        .monospacedDigit()
                        .foregroundStyle(Color.cyan)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                // 卡片 2：倒计时
                VStack(alignment: .leading, spacing: 3) {
                    Text("10分倒计 (Countdown)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)

                    Text(entry.tickerState.targetDate, style: .timer)
                        .font(.system(size: 26, weight: .heavy, design: .monospaced))
                        .monospacedDigit()
                        .foregroundStyle(Color.orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // 底栏技术标注
            HStack(spacing: 6) {
                Text("技术原理：Text(_:style: .timer)")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Render Server 1Hz 零代码唤醒")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary.opacity(0.8))
            }
        }
        .padding(2)
    }

    // MARK: - 背景微质感
    private var backgroundLayer: some View {
        ZStack {
            Rectangle()
                .fill(Color(white: 0.08))

            // 精致冷光渐变背景
            LinearGradient(
                colors: [
                    Color.cyan.opacity(0.12),
                    Color.purple.opacity(0.06),
                    Color.black.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 边缘内发光边框
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
}

// MARK: - Widget Declaration
public struct NumberTickerWidget: Widget {
    public static let kind: String = "NumberTickerWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: NumberTickerProvider()) { entry in
            NumberTickerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("数字每秒刷新 DEMO")
        .description("展示 iOS 桌面小组件通过系统动态文本引擎实现的每秒数字跳动效果")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
