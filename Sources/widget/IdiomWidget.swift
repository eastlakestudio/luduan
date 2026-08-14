import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct IdiomEntry: TimelineEntry {
    let date: Date
    let level: LevelModel?
}

// MARK: - Timeline Provider

struct IdiomProvider: TimelineProvider {
    func placeholder(in context: Context) -> IdiomEntry {
        IdiomEntry(date: Date(), level: getSampleLevel())
    }

    func getSnapshot(in context: Context, completion: @escaping (IdiomEntry) -> Void) {
        completion(IdiomEntry(date: Date(), level: getRandomUnlearnedLevel(excludingSource: nil)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<IdiomEntry>) -> Void) {
        let repo = GameDataRepository.shared
        let total = repo.levels.count
        var entries: [IdiomEntry] = []
        let base = Date()
        var lastSource: String? = nil

        for i in 0 ..< 6 {
            let level = pickRandom(repo: repo, total: total, excludingSource: lastSource)
            lastSource = level.source
            let entryDate = Calendar.current.date(byAdding: .hour, value: i * 4, to: base)!
            entries.append(IdiomEntry(date: entryDate, level: level))
        }

        completion(Timeline(entries: entries, policy: .atEnd))
    }

    /// 随机选词：生成随机序号，若已学则最多再试 3 次，共 4 次机会；四次都已学则用最后一个
    func pickRandom(repo: GameDataRepository, total: Int, excludingSource: String? = nil) -> LevelModel {
        var last = repo.levels[Int.random(in: 0 ..< total)]
        for _ in 0 ..< 4 {
            let candidate = repo.levels[Int.random(in: 0 ..< total)]
            // 优先跨出处
            let diffSource = excludingSource == nil || candidate.source != excludingSource
            let unlearned = !repo.isLevelCompleted(candidate.id)
            if unlearned && diffSource {
                return candidate
            }
            if unlearned {
                last = candidate
            }
        }
        return last
    }

    private func getRandomUnlearnedLevel(excludingSource: String?) -> LevelModel {
        let repo = GameDataRepository.shared
        let unlearned = repo.levels.filter { !repo.isLevelCompleted($0.id) }
        let pool = unlearned.isEmpty ? repo.levels : unlearned
        if let exc = excludingSource {
            let filtered = pool.filter { $0.source != exc }
            return (filtered.isEmpty ? pool : filtered).randomElement() ?? getSampleLevel()
        }
        return pool.randomElement() ?? getSampleLevel()
    }

    private func getSampleLevel() -> LevelModel {
        GameDataRepository.shared.levels.first ?? LevelModel(
            id: "level_1",
            theme: .shihan,
            title: "第一关",
            targetPhrase: "厚德载物",
            tileMatrix: [],
            annotation: "地势坤，君子以厚德载物。",
            story: "",
            source: "《周易》"
        )
    }
}

// MARK: - Entry View

struct IdiomWidgetEntryView: View {
    var entry: IdiomProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            if let level = entry.level {
                switch family {
                case .systemSmall:
                    smallView(level: level)
                default:
                    mediumView(level: level)
                }
            } else {
                VStack(spacing: 4) {
                    Text("甪端字游")
                        .font(.system(size: 17, weight: .bold, design: .serif))
                    Text("已学完全部成语！")
                        .font(.system(size: 12, design: .serif))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Small Widget

private extension IdiomWidgetEntryView {
    func smallView(level: LevelModel) -> some View {
        ZStack(alignment: .bottomTrailing) {
            // 成语居中展示（单行不折行，5字及以上自动适配字号）
            VStack(spacing: 5) {
                Spacer()
                Text(level.targetPhrase)
                    .font(.system(size: smallPhraseFontSize(for: level.targetPhrase), weight: .bold, design: .serif))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Text(level.source)
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // chevron.right 叠加在右下角，不占独立空间
            Button(intent: NextIdiomIntent(levelId: level.id, currentSource: level.source)) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.primary.opacity(0.28))
            }
            .buttonStyle(.plain)
        }
        .widgetURL(URL(string: "luduan://level/\(level.id)"))
    }
}

// MARK: - Medium / Large Widget

private extension IdiomWidgetEntryView {
    func mediumView(level: LevelModel) -> some View {
        // story = 古文原文；annotation = 白话释义（不显示）
        let originalText = level.story.trimmingCharacters(in: .whitespacesAndNewlines)

        return VStack(alignment: .leading, spacing: 6) {
            // 顶部：词句占 2/3，出处占 1/3
            GeometryReader { geo in
                HStack(spacing: 0) {
                    Text(level.targetPhrase)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(width: geo.size.width * 2 / 3, alignment: .leading)
                    Text(level.source)
                        .font(.system(size: 11, weight: .regular, design: .serif))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(width: geo.size.width / 3, alignment: .trailing)
                }
            }
            .frame(height: 30)

            // 中部：原文居中，chevron.right 叠加在文字区域右下角
            ZStack(alignment: .bottomTrailing) {
                if !originalText.isEmpty {
                    Text(originalText)
                        .font(.system(size: adaptiveFontSize(for: originalText),
                                      weight: .regular, design: .serif))
                        .foregroundStyle(.primary.opacity(0.88))
                        .lineSpacing(adaptiveLineSpacing(for: originalText))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }

                // chevron.right 浮层叠加，不占独立布局空间
                Button(intent: NextIdiomIntent(levelId: level.id, currentSource: level.source)) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(.primary.opacity(0.25))
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(URL(string: "luduan://level/\(level.id)"))
    }
}

// MARK: - Helpers

private extension IdiomWidgetEntryView {

    /// 根据原文字数动态调节字号：字少字大，字多字小
    func adaptiveFontSize(for text: String) -> CGFloat {
        switch text.count {
        case ..<15:  return 22
        case 15..<30: return 19
        case 30..<60: return 16
        default:      return 14
        }
    }

    func adaptiveLineSpacing(for text: String) -> CGFloat {
        adaptiveFontSize(for: text) < 16 ? 5 : 7
    }

    func cleanAnnotation(_ text: String) -> String {
        var cleaned = text
        if let colonRange = cleaned.range(of: "：") {
            let prefix = String(cleaned[..<colonRange.lowerBound])
            if prefix.contains("出自") || prefix.contains("有云") ||
               prefix.contains("曰") || prefix.contains("云") {
                cleaned = String(cleaned[colonRange.upperBound...])
            }
        }
        if cleaned.hasPrefix("出自"), let end = cleaned.range(of: "》") {
            cleaned = String(cleaned[end.upperBound...])
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Widget Declaration

struct IdiomWidget: Widget {
    let kind: String = "IdiomWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IdiomProvider()) { entry in
            IdiomWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("随机未学成语")
        .description("在桌面随时学习一个新成语典故。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
