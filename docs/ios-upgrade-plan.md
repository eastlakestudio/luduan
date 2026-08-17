# iOS 版本升级计划（v1.3.0）

> 基于 2026-08-16~17 Android 更新（见 changelog.md）与 iOS 代码全量 Review 制定。
> 目标：功能对齐 Android，修复 iOS 独有缺陷，版本升至 **1.3.0 (Build 13)**。

---

## P0 — 数据正确性（必须，影响所有玩法）

### 1. 清除 PresetData 硬编码勋章（缺陷最重）
- **问题**：`PresetData.swift:5-646` 硬编码 64 个旧勋章（id=`badge_char_kongzi` 式），与 badges.json 的新 id（`badge_char_N`）不匹配 → `defaultBadges` 全量追加 → 61 个重名勋章 + 包拯/鲁迅/韩非子僵尸勋章，且全部走 bug 兜底逻辑
- **方案**：删除硬编码列表，`defaultBadges` 仅从 badges.json 加载
- **文件**：`Sources/core/Data/Preset/PresetData.swift`
- **验收**：勋章馆人物名将 62 个、无重名、无包拯

### 2. 移除 source+story 兜底匹配
- **问题**：`GameDataRepository.swift:125-131` 人物词池为空时用 `source.contains || story.contains` + `prefix(5)` 匹配——story 注释误关联（Android 已修复的同款 bug：魏征误收三国志词）
- **方案**：兜底删除，仅用 badge_word_map 索引（与 Android 一致）
- **验收**：魏征词池 67 词全为《隋书》；刘向词池全为《战国策》

### 3. 清理关汉卿残留空词池
- **问题**：badges.json 中四块玉/大德歌/天净沙/拨不断 4 个典籍 badge 词池为空（删词不删卡）
- **方案**：从 badges.json 删除这 4 个 badge（shared/data 同步改）
- **验收**：典籍名篇无 0 词卡片

---

## P1 — 游戏流程对齐

### 4. 弹窗优先级链（勋章分享 > 里程碑 > 故事）
- **问题**：`PuzzleGameView.swift:90-113` 完成后只弹里程碑/故事；`completeLevel` 返回的解锁勋章被丢弃
- **方案**：解锁勋章时只弹勋章分享；无勋章才按 `count%10` 弹里程碑或故事
- **验收**：解锁勋章不再同时弹两层分享窗

### 5. 勋章解锁分享弹窗（新增）
- **对齐**：Android `BadgeShareDialog`
- **内容**：APP 图标 + 「文绉绉 甪端」品牌头 + 徽章图 88pt + "勋章解锁·名号" + 该词池随机已完成词的原文/出处 + App Store 二维码；关闭自动进下一关
- **文件**：新建 `Components/BadgeShareDialog.swift`；改 `PuzzleGameView.swift`
- **复用**：`MilestoneCelebrationModalView` 的 ImageRenderer 分享、`QRCodeView`

### 6. 词池耗尽 → "本卷已全部完成"
- **问题**：`nextLevelForBadge`（GameDataRepository.swift:258-276）wrap 回已学词（幽灵关卡）
- **方案**：全部完成返回 nil；UI 弹"本卷已全部完成·返回书架"
- **验收**：打通冬十月 3 词后不再循环

### 7. 分享弹窗关闭 → 自动下一关
- **对齐**：Android 修复（未分享直接关闭也推进）
- **文件**：`MilestoneCelebrationModalView.swift` onDismiss 链

---

## P2 — UI 对齐

### 8. 主界面标题
- **现状**：`MainDashboardView.swift:85` = "文绉绉-甪端字游" 单色
- **目标**："文绉绉"（竹青 #78923F）+ "甪端"（朱砂 #8B1A1A）双色并排，22pt serif bold

### 9. 勋章详情【代表词句】
- **对齐**：Android 勋章馆详情——显示词池代表词（已学优先）+ 原文 + 出处
- **文件**：`BadgeGalleryView.swift:169-244` 详情弹窗加区块

### 10. 启用 SharePosterCardView 或删除
- **现状**：完整海报组件但零引用（死代码）
- **方案**：接 milestones 分享或删除，二选一

---

## P3 — 小组件与体验

### 11. 小组件尺寸扩展
- **现状**：仅 small/medium；Android 已有 5 档响应式
- **方案**：加 `.systemLarge`（词+原文+出处大字排版）；评估 StandBy
- **文件**：`widget/IdiomWidget.swift:373`

### 12. 稳定 level id（深链可靠性）
- **问题**：`String.hashValue` 每进程随机 → 小组件深链 `luduan://level/{id}` 跨启动失效
- **方案**：改 djb2 等稳定 hash 生成 id
- **文件**：`Classic10000LevelsEngine.swift:57`

### 13. 修复测试套件
- macOS 构建失败（MainDashboardView:55 toolbar 位置）；`TileMatrixTests` 引用已删除的 `repository.levels`、断言 16 字块
- **方案**：toolbar 移入 os(iOS)；测试改 12 字块、删 levels 引用

---

## 数据侧（shared/data，一次改两端）

| 项 | 动作 |
|---|---|
| badges.json | 删 4 个关汉卿空词池 badge |
| BadgeImages | 删 badge_baozheng.jpg / badge_luxun.jpg / badge_hanfeizi.jpg |

## 版本号

| 字段 | 旧 → 新 |
|---|---|
| CFBundleShortVersionString | 1.2.0 → **1.3.0** |
| CFBundleVersion | 12 → **13** |
| 同步 | App + Widget + project.yml |

## 实施顺序与验收

1. **P0 数据**（1-3）→ 模拟器验证勋章馆 62 人、词池纯净
2. **P1 流程**（4-7）→ 冬十月通关全链路测试
3. **P2 UI**（8-10）→ 截图比对 Android
4. **P3**（11-13）→ swift test 全绿
5. 打包 TestFlight → 真机回归 → App Store 提审
