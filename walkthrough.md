# 桌面小组件每秒数字刷新 DEMO (NumberTickerWidget) Walkthrough

**日期**：2026-10-13 · **运行环境**：iOS 17.0+ / iOS 27.0 · **架构**：SwiftUI + WidgetKit + AppIntents

---

## 🌟 1. 核心技术原理与实现路径

在 iOS 系统中，小组件进程（Extension）由系统严格监管，**苹果禁止在小组件后台启动 Timer 或死循环轮询**（否则会严重耗电并被系统强行终止或降频节流）。

为了实现“**屏幕上数字每秒平滑跳动**”的视觉效果，本 DEMO 采用了**苹果官方唯一正规途径**：
> **将时间锚点托付给系统底层渲染服务（Render Server / SpringBoard）**：
> 通过 `Text(entry.tickerState.startDate, style: .timer).monospacedDigit()`，由系统 GPU 层在桌面实时按 1Hz 动态刷新绘制数字。小组件代码自身在渲染后立即休眠，实现**零额外耗电、零审核风险**的每秒数字动态走字。

---

## 📁 2. 模块化设计与文件清单

| 文件路径 | 模块角色 | 核心职责说明 |
| :--- | :--- | :--- |
| `ios/Sources/core/Features/Widget/NumberTickerModel.swift` | 核心状态模型 | 封装 `NumberTickerState`，提供正计时基准时间、倒计时目标时间、已过去秒数与剩余秒数计算。 |
| `ios/Sources/core/Intents/ResetTickerIntent.swift` | 交互意图层 | 遵循 `AppIntent` 协议，提供小组件“重置秒数”交互按钮，重置基准时间并通知 WidgetCenter 刷新。 |
| `ios/Sources/widget/NumberTickerWidget.swift` | WidgetKit 渲染层 | 实现 `NumberTickerWidget`、`NumberTickerProvider` 及适配 `.systemSmall` / `.systemMedium` 的荧光仪表盘视图。 |
| `ios/Sources/widget/luDuanWidgetBundle.swift` | 小组件入口 Bundle | 将 `NumberTickerWidget` 挂载至 WidgetBundle，使其可在系统小组件库独立添加。 |
| `ios/Tests/NumberTickerTests/NumberTickerWidgetTests.swift` | 单元测试套件 | 覆盖 `NumberTickerState` 时间计算、边界条件与 `ResetTickerIntent` 执行测试。 |
| `ios/Package.swift` | SwiftPM 配置 | 新增 `NumberTickerTests` 独立测试 Target。 |
| `task.md` | 任务追踪 | 持久化记录任务规划与各项检查完成状态。 |
| `walkthrough.md` | 技术文档 | 本交付文档，包含架构设计、代码细节与验证记录。 |

---

## 🎨 3. UI 视觉与尺寸形态

### 3.1 紧凑尺寸 (`systemSmall`)
- **顶栏状态**：绿点呼吸指示灯 + "秒级动态走字" + 快速重置按钮
- **中心数显**：
  ```swift
  Text(entry.tickerState.startDate, style: .timer)
      .font(.system(size: 30, weight: .black, design: .monospaced))
      .monospacedDigit()
  ```
  数字采用青蓝渐变荧光等宽设计，每秒自动递增（`00:01`, `00:02`, `00:03`...），字体无抖动。
- **底栏说明**：显示 "系统 GPU 原生驱动 · 零耗电"。

### 3.2 仪表盘尺寸 (`systemMedium`)
- **双数字并排卡片**：
  - **左卡片（正向秒表 Count-Up）**：青色数显，实时显示自基准点以来的累计秒数走字。
  - **右卡片（倒计时 Countdown）**：橙色数显，实时显示 10 分钟目标截止倒计时。
- **右上角操作**：毛玻璃胶囊按钮 `[↺ 重置秒数]`，点击通过 `AppIntent` 瞬间重置时间锚点。
- **底栏技术标注**：标注底层原理为 `Render Server 1Hz 零代码唤醒`。

---

## 🧪 4. 自动化测试与构建验证

### 4.1 单元测试（100% 通过）
运行命令：
```bash
cd ios && swift test --test-product NumberTickerTests
```
执行结果：
```text
Test Suite 'NumberTickerWidgetTests' started at 2026-10-13 22:24:39.493.
Test Case '-[NumberTickerTests.NumberTickerWidgetTests testElapsedSecondsCalculation]' passed (0.002 seconds).
Test Case '-[NumberTickerTests.NumberTickerWidgetTests testRemainingSecondsAndFinished]' passed (0.000 seconds).
Test Case '-[NumberTickerTests.NumberTickerWidgetTests testResetTickerIntentExecution]' passed (0.004 seconds).
Test Case '-[NumberTickerTests.NumberTickerWidgetTests testTickerStateCustomDuration]' passed (0.000 seconds).
Test Case '-[NumberTickerTests.NumberTickerWidgetTests testTickerStateDefaultDuration]' passed (0.000 seconds).
Test Suite 'NumberTickerWidgetTests' passed at 2026-10-13 22:24:39.499.
	 Executed 5 tests, with 0 failures (0 unexpected) in 0.006 (0.006) seconds
```

### 4.2 Xcode 目标工程构建验证
1. **小组件目标构建**：
   ```bash
   xcodebuild -scheme luDuanWidget -destination 'platform=iOS Simulator,id=F2B00D73-84B4-4598-9D30-66E98DDF4087' -project ios/luDuan.xcodeproj build
   ```
   👉 **BUILD SUCCEEDED**
2. **主 App 目标构建**：
   ```bash
   xcodebuild -scheme luDuan -destination 'platform=iOS Simulator,id=F2B00D73-84B4-4598-9D30-66E98DDF4087' -project ios/luDuan.xcodeproj build
   ```
   👉 **BUILD SUCCEEDED**

---

## 📱 5. 如何在真机/模拟器体验

1. 在 Xcode 中运行 `luDuan` 或 `luDuanWidget` 到 iOS 17 / iOS 27 模拟器或真机。
2. 回到手机主屏幕，长按空白处进入编辑模式（抖动模式）。
3. 点击左上角 `+` 号进入小组件库，搜索并选择 **“文绉绉”** 或 **“甪端小组件”**。
4. 滑动选择 **“数字每秒刷新 DEMO”**，添加 **小号（Small）** 或 **中号（Medium）** 到桌面。
5. 即可观察到桌面小组件上的数字每秒流畅跳动，点击右上角“重置秒数”按钮即可立即重置基准点！
