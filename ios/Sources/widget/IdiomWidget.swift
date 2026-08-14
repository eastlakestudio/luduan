import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct IdiomEntry: TimelineEntry {
    let date: Date
    let level: LevelModel?
}

// MARK: - Timeline Provider

struct IdiomProvider: TimelineProvider {
    static let presetLevels: [LevelModel] = [
        LevelModel(
            id: "level_1",
            theme: .shihan,
            title: "厚德载物",
            categoryName: "易经名句",
            targetPhrase: "厚德载物",
            tileMatrix: [],
            annotation: "地势坤，君子以厚德载物。",
            story: "天行健，君子以自强不息。地势坤，君子以厚德载物。",
            source: "《周易》"
        ),
        LevelModel(
            id: "level_2",
            theme: .shihan,
            title: "温故知新",
            categoryName: "论语名言",
            targetPhrase: "温故知新",
            tileMatrix: [],
            annotation: "温故而知新，可以为师矣。",
            story: "子曰：温故而知新，可以为师矣。",
            source: "《论语·为政》"
        ),
        LevelModel(
            id: "level_3",
            theme: .shijing,
            title: "桃之夭夭",
            categoryName: "诗经经典",
            targetPhrase: "桃之夭夭",
            tileMatrix: [],
            annotation: "桃之夭夭，灼灼其华。之子于归，宜其室家。",
            story: "桃之夭夭，灼灼其华。之子于归，宜其室家。桃之夭夭，有蕡其实。",
            source: "《诗经·周南·桃夭》"
        ),
        LevelModel(
            id: "level_4",
            theme: .tangsong,
            title: "海纳百川",
            categoryName: "中华古训",
            targetPhrase: "海纳百川",
            tileMatrix: [],
            annotation: "海纳百川，有容乃大；壁立千仞，无欲则刚。",
            story: "海纳百川，有容乃大；壁立千仞，无欲则刚。",
            source: "《古训名联》"
        ),
        LevelModel(
            id: "level_5",
            theme: .shihan,
            title: "自强不息",
            categoryName: "易经名句",
            targetPhrase: "自强不息",
            tileMatrix: [],
            annotation: "天行健，君子以自强不息。",
            story: "天行健，君子以自强不息。潜龙勿用，阳在下也。",
            source: "《周易·乾卦》"
        ),
        LevelModel(
            id: "level_6",
            theme: .shijing,
            title: "高山仰止",
            categoryName: "诗经经典",
            targetPhrase: "高山仰止",
            tileMatrix: [],
            annotation: "高山仰止，景行行止。",
            story: "诗云：高山仰止，景行行止。虽不能至，然心向往之。",
            source: "《诗经·小雅·车舝》"
        ),
        LevelModel(
            id: "level_7",
            theme: .shihan,
            title: "上善若水",
            categoryName: "道德经",
            targetPhrase: "上善若水",
            tileMatrix: [],
            annotation: "上善若水。水善利万物而不争。",
            story: "上善若水。水善利万物而不争，处众人之所恶，故几于道。",
            source: "《道德经·第八章》"
        ),
        LevelModel(
            id: "level_8",
            theme: .shihan,
            title: "鹏程万里",
            categoryName: "庄子寓言",
            targetPhrase: "鹏程万里",
            tileMatrix: [],
            annotation: "鹏之徙于南冥也，水击三千里，抟扶摇而上者九万里。",
            story: "鹏之徙于南冥也，水击三千里，抟扶摇而上者九万里，去以六月息者也。",
            source: "《庄子·逍遥游》"
        )
    ]

    func placeholder(in context: Context) -> IdiomEntry {
        IdiomEntry(date: Date(), level: Self.presetLevels[0])
    }

    func getSnapshot(in context: Context, completion: @escaping (IdiomEntry) -> Void) {
        completion(IdiomEntry(date: Date(), level: Self.presetLevels[0]))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<IdiomEntry>) -> Void) {
        let repo = GameDataRepository.shared
        let total = repo.allWords.count
        var entries: [IdiomEntry] = []
        let base = Date()
        var lastSource: String? = nil

        let defaults = UserDefaults(suiteName: "group.com.eastlakestudio.luduan") ?? UserDefaults.standard
        if let pinnedPhrase = defaults.string(forKey: "widgetPinnedPhrase"),
           let word = repo.allWords.first(where: { $0.phrase == pinnedPhrase }) {
            let pinnedLevel = Classic10000LevelsEngine.levelFromWord(word)
            entries.append(IdiomEntry(date: base, level: pinnedLevel))
            lastSource = pinnedLevel.source
            defaults.removeObject(forKey: "widgetPinnedPhrase")
        }

        let startIdx = entries.count
        for i in startIdx ..< 4 {
            let level = pickRandom(repo: repo, total: total, excludingSource: lastSource)
            lastSource = level.source
            let entryDate = Calendar.current.date(byAdding: .hour, value: i * 2, to: base) ?? base
            entries.append(IdiomEntry(date: entryDate, level: level))
        }

        if entries.isEmpty {
            entries.append(IdiomEntry(date: base, level: Self.presetLevels[0]))
        }

        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 2, to: base) ?? base.addingTimeInterval(7200)
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }

    /// 随机选词：优先选未学，跨出处
    func pickRandom(repo: GameDataRepository, total: Int, excludingSource: String? = nil) -> LevelModel {
        if total == 0 {
            let presets = Self.presetLevels
            if let exc = excludingSource {
                let filtered = presets.filter { $0.source != exc }
                return (filtered.isEmpty ? presets : filtered).randomElement() ?? presets[0]
            }
            return presets.randomElement() ?? presets[0]
        }
        
        var last = repo.allWords[Int.random(in: 0 ..< total)]
        for _ in 0 ..< 4 {
            let candidate = repo.allWords[Int.random(in: 0 ..< total)]
            let diffSource = excludingSource == nil || candidate.source != excludingSource
            let unlearned = !repo.isLevelCompleted(candidate.phrase)
            if unlearned && diffSource {
                return Classic10000LevelsEngine.levelFromWord(candidate)
            }
            if unlearned {
                last = candidate
            }
        }
        return Classic10000LevelsEngine.levelFromWord(last)
    }
}

// MARK: - Entry View

struct IdiomWidgetEntryView: View {
    var entry: IdiomProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if let level = entry.level {
                switch family {
                case .systemSmall:
                    smallView(level: level)
                default:
                    mediumView(level: level)
                }
            } else {
                VStack(spacing: 6) {
                    Text("甪端字游")
                        .font(.system(size: 17, weight: .bold, design: .serif))
                    Text("成语博览 · 每日精选")
                        .font(.system(size: 12, design: .serif))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .unredacted()
        .containerBackground(for: .widget) {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                
                // 模拟 Liquid Glass 边缘高光与液态反光
                LinearGradient(
                    colors: [
                        .white.opacity(0.4),
                        .white.opacity(0.0),
                        .white.opacity(0.0),
                        .white.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
}

// MARK: - Small Widget

private extension IdiomWidgetEntryView {
    func smallView(level: LevelModel) -> some View {
        ZStack(alignment: .bottomTrailing) {
            // 词语和出处垂直居中
            VStack(spacing: 4) {
                Text(level.targetPhrase)
                    .font(.system(size: smallPhraseFontSize(for: level.targetPhrase), weight: .bold, design: .serif))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Text(level.source)
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            // 操作按钮：换下一个 (悬浮在右下角)
            Button(intent: NextIdiomIntent(targetPhrase: level.targetPhrase, currentSource: level.source)) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .background(.regularMaterial)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(.plain)
            .padding([.trailing, .bottom], 2)
            .zIndex(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: "luduan://level/\(level.id)"))
    }
}

// MARK: - Medium / Large Widget

private extension IdiomWidgetEntryView {
    func mediumView(level: LevelModel) -> some View {
        // 优先使用原文故事，若为空则降级展示白话释义
        let rawStory = level.story.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalText = !rawStory.isEmpty ? rawStory : level.annotation.trimmingCharacters(in: .whitespacesAndNewlines)

        return VStack(alignment: .leading, spacing: 6) {
            // 顶部：词句与出处
            HStack(alignment: .firstTextBaseline) {
                Text(level.targetPhrase)
                    .font(.system(size: level.targetPhrase.count > 6 ? 19 : 23, weight: .bold, design: .serif))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                
                Spacer(minLength: 6)
                
                Text(level.source)
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }

            // 中部：原文/释义与底部操作区
            ZStack(alignment: .bottomTrailing) {
                if !originalText.isEmpty {
                    Text(originalText)
                        .font(.system(size: adaptiveFontSize(for: originalText),
                                      weight: .regular, design: .serif))
                        .foregroundStyle(.primary.opacity(0.88))
                        .lineSpacing(adaptiveLineSpacing(for: originalText))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    Spacer()
                }

                // 底部右下角操作按钮：换下一个 (悬浮叠在原文上)
                Button(intent: NextIdiomIntent(targetPhrase: level.targetPhrase, currentSource: level.source)) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 30, height: 30)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(.plain)
                .padding([.trailing, .bottom], 2)
                .zIndex(10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(URL(string: "luduan://level/\(level.id)"))
    }
}

// MARK: - Helpers

private extension IdiomWidgetEntryView {

    func smallPhraseFontSize(for text: String) -> CGFloat {
        return text.count >= 5 ? 18 : 24
    }

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
