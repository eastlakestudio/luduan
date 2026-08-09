# 《甪端字游》全量勋章与系统功能任务清单

### 🎯 进度汇总
- **[x] 全量 Code Review 与切换闯关类型/进入页面极速性能重构**
  - [x] 增加 `completedCount(for:key:)` 进度缓存
  - [x] 增加 `ChineseSealView.imageCache` 静态内存缓存 (消除磁盘 I/O)
  - [x] 增加 `headerBannerView` 静态内存缓存
  - [x] 修正全工程 `mport` 语法拼写
- **[x] 清除 UIDeviceFamily Xcode 构建警告 (使用 TARGETED_DEVICE_FAMILY: "1,2")**
- **[x] 勋章详情弹窗图像大幅放大至 140pt** (人物肖像与古风朱印威严高质感呈现)
- **[x] 勋章馆网格图标同步放大** (68pt / 56pt)
- **[x] “甪端学游”中国传统朱砂印章组件**
- **[x] 分享海报展示本次闯关古文原文节选**
- **[x] 真实 iOS 原生系统图片分享 (`UIImage` 合成渲染 + `UIActivityViewController`)**
- **[x] iOS 真机麦克风与语音识别修复 (双重授权 + `.playAndRecord`)**
- **[x] 主题与典籍 JSON 解耦** (`theme_books.json`, `book_phrases.json`)
- **[x] 通关弹窗 UI 布局重构** (顶部干净书名，【古文原文】在上、【字词释义】在下)
- **[x] 跨主题同词全域同步完成**
- **[x] 任意主题“全新开发”重玩模式**
- **[x] 核心勋章彩绘上线 (31 位/枚)**
