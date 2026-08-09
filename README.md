# 甪端字游 (luDuan) — 中国传统典籍语音拼字与名肖游赏

<p align="center">
  <img src="docs/appstore_screenshot_iphone.png" width="45%" alt="iPhone App Store 宣传海报 (1242x2688)">
  &nbsp; &nbsp;
  <img src="docs/appstore_screenshot_ipad.png" width="45%" alt="iPad App Store 宣传海报 (2064x2752)">
</p>

---

## 🌟 核心特色与产品亮点

《甪端字游》是一款融合**中国传统典籍美学、工笔重彩彩绘与智能语音交互**的古风汉字成语诗词拼字闯关应用。

### 1. 📖 离散典籍库与万关生成
- **39+ 离散典籍拆分**：收录《诗经》《史记》《道德经》《周易》《尚书》《三国志》《战国策》《后汉书》及唐诗宋词等全量典籍名篇。
- **10,000+ 动态关卡**：基于独立种子词库与拼音校核，自动生成富有挑战的矩阵拼字关卡。

### 2. 🎨 全量 62 位工笔肖像彩绘勋章馆
- 覆盖 **王阳明（知行合一）、司马迁（太史公记）、庄子（逍遥游）、范仲淹（先忧后乐）** 以及老子、孙武、陶渊明、陆游、王安石、司马光、李白、苏轼等全量 62 位历史名人名肖。
- 每枚勋章均匹配高精 **1024×1024 正方形中国风工笔重彩插画与金石朱砂印章**。

### 3. 🎙️ 智能语音拼字与防抖选字
- 内置 0.3 秒防抖控制（`DispatchWorkItem`），支持自然口述语音识别。
- 支持真机麦克风输入与模拟器 Mock 双重兼容，语音吐字平滑流畅。

### 4. 📜 功名学阶与全域词汇同步
- 独立统计从**童生、秀才、贡生、举人**到**宰辅、帝师**的科举学阶递进。
- 跨主题同词全域自动同步与“全新开发”重玩模式。

---

## 🛠️ 技术架构与栈说明

- **UI 框架**：SwiftUI + Modern Combine
- **音频与语音**：AVFoundation (`AVAudioEngine`) + Speech (`SFSpeechRecognizer`)
- **工程构建**：XcodeGen (`project.yml`)
- **质量保证**：XCTest 自动化单元测试框架，全量 76+ 测试 100% 绿色成功通过。

---

## 🚀 编译与运行指南

### 1. 刷新工程
```bash
xcodegen generate
```

### 2. 运行单元测试
```bash
swift test
```

### 3. App Store IPA 打包与导出
```bash
# 1. 归档 Archive
xcodebuild archive -project luDuan.xcodeproj -scheme luDuan -configuration Release -destination 'generic/platform=iOS' -archivePath build/luDuan.xcarchive

# 2. 导出 IPA 包 (可直接拖入 Transporter 交付)
xcodebuild -exportArchive -archivePath build/luDuan.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath build/ipa -allowProvisioningUpdates
```

---

## 📸 App Store 官方宣发功能图 (1242×2688 & 2064×2752)

工程中已生成用于 App Store Connect 上传的高清功能宣传大图：
- **iPhone 宣发海报**：[`docs/appstore_screenshot_iphone.png`](file:///Users/minghualiu/personal/EastlakeStudio/luDuan/docs/appstore_screenshot_iphone.png) (`1242 × 2688`)
- **iPad 宣发海报**：[`docs/appstore_screenshot_ipad.png`](file:///Users/minghualiu/personal/EastlakeStudio/luDuan/docs/appstore_screenshot_ipad.png) (`2064 × 2752`)
