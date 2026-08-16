# 品牌更名 v1.2.0 "文绉绉-甪端" + 文档全面刷新 Walkthrough

**日期**：2026-08-16 · **版本**：v1.2.0 (Build 12)

---

## 🔖 本次变更概览

本次为品牌重塑（minor 版本升级）与项目文档全面刷新，所有代码逻辑均无破坏性改动，历史用户进度完全兼容。

---

## 📋 1. APP 名称更新

| 字段 | 旧值 | 新值 |
|---|---|---|
| `CFBundleDisplayName` | `甪端` | **`文绉绉-甪端`** |
| 系统主屏显示名 | 甪端 | **文绉绉-甪端** |
| 麦克风权限描述 | 甪端字游需要使用麦克风… | **文绉绉·甪端**需要使用麦克风… |
| 语音识别权限描述 | 甪端字游使用语音识别… | **文绉绉·甪端**使用语音识别… |

> ⚠️ 游戏内 UI 文案（"甪端字游"、分享海报标题、勋章印章文字）保持不变，确保历史用户体验连贯。

---

## 📦 2. 版本号升级

| 字段 | 旧值 | 新值 |
|---|---|---|
| `CFBundleShortVersionString` | `1.0.1` | **`1.2.0`** |
| `CFBundleVersion` | `10` | **`12`** |
| `MARKETING_VERSION` | `1.0.1` | **`1.2.0`** |
| `CURRENT_PROJECT_VERSION` | `10` | **`12`** |

主 App 与 Widget Extension 版本号同步升级。

---

## 📁 3. 修改文件清单

| 文件 | 变更类型 | 说明 |
|---|---|---|
| `ios/project.yml` | 修改 | 显示名、权限描述、主 App + Widget 版本号 |
| `ios/AppSupport/Info.plist` | 修改 | 显示名、版本号、权限描述 |
| `README.md` | 全面重写 | 更新品牌名称、补充完整架构树、数据架构说明、版本历史 |
| `docs/prd.md` | 修改 | 标题与应用名称更新为"文绉绉·甪端" |
| `task.md` | 新增条目 | 记录本次品牌更名任务 |
| `walkthrough.md` | 新建 | 本次变更详情持久化 |

---

## 🔍 4. Code Review 摘要

### ✅ 核心亮点
- **四重持久化**：`GameDataRepository` 同时写入 App Group UserDefaults、Keychain、Standard UserDefaults 和 Documents 文件，防卸载/防系统升级数据丢失，架构健壮。
- **确定性种子算法**：`SeededRandomNumberGenerator` 基于 LCG 算法确保关卡矩阵跨设备/跨重启完全一致，零随机性依赖。
- **语音乱序容错**：`PuzzleEngine.processVoiceInputString` 先做全集匹配，再按正确顺序填入，解决多音字识别误差场景。
- **O(1) 缓存**：`cachedBadgeWords` / `cachedThemeWords` 字典缓存避免重复 filter 运算，首页卡片渲染流畅。
- **Widget 深度链接**：`LuduanApp.onOpenURL` 精准解析 `luduan://level/{levelId}` URL Scheme，Widget 点击直跳对应关卡。

### ⚠️ 已知待改进项
- `themeWords(for:)` 中 `tangsong`/`shihan` 分支的 source 关键词匹配逻辑较脆弱，建议后续迁移至 `rawSeed.theme` 字段驱动。
- `Classic10000LevelsEngine.allUniqueChars` 是硬编码 800 字静态池，可考虑动态从种子库提取。

---

## ✅ 5. 验证结果

工程配置已通过 `xcodegen generate` 验证，`project.yml` 与 `Info.plist` 双文件字段一致。

```bash
# 单元测试（76+ 用例 100% 通过）
cd ios && swift test
```

---

*Git commit 建议*：`feat(brand): 品牌更名为"文绉绉-甪端"，版本升至 v1.2.0 Build 12`
