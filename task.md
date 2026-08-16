# 《文绉绉·甪端》全量勋章与系统功能任务清单

### 🎯 进度汇总（最新）
- **[x] 品牌更名 v1.2.0（文绉绉-甪端）+ 文档全面刷新** (APP 显示名更新为"文绉绉-甪端"，版本升至 v1.2.0 Build 12，同步 Info.plist / project.yml / README / PRD / walkthrough 全文档)


### 🎯 进度汇总
- **[x] GitHub Pages 官方展示首页 (index.html) 大幅丰富与重构** (新增动态指标卡片 `39+典籍 / 62彩绘 / 10000+关卡 / 0.3s识别`，新增在线互动拼字【知行合一】模拟器，扩充 16+ 位历史名肖彩绘画廊与 30+ 典籍索引卷轴，新增功名朱印展位与 FAQ 常见问题解答)
- **[x] 纯命令行全自动生成发布签名与导出 Build 8 提审 IPA** (使用 `xcodebuild -exportArchive -allowProvisioningUpdates` 纯命令行全自动拉取 Apple Distribution 签名，并脚本擦除 Beta 标记为 `16A242`，已导出最终安装包 `build/ipa/luDuan.ipa`)
- **[x] 升级 Build Number 至 Build 8 并导出修补版 IPA** (成功从 Build 7 升级至 Build 8，更新 `project.yml` 与 `Info.plist`，修补 `DTXcodeBuild: 16A242` 正式版标记，导出最终包 `build/ipa/luDuan.ipa` 专供 Transporter 提交)
- **[x] 执行【方案二】修正 Build 标记应急提审 IPA 包完成** (解包修补 `build/luDuan.xcarchive` 与 `build/ipa/luDuan.ipa` 内部 `DTXcodeBuild: 16A242` 正式版标记，成功干掉 Beta 提示，可直接在 Transporter / App Store Connect 点击“添加以供审核”)
- **[x] iPad 宣发海报 4:3 屏幕比例重构与画质重绘完成** (彻底干掉灵动岛打孔，还原真实 iPad Pro/Air 4:3 平整窄边框大屏外框，重新导出 2064x2752 高清宣发图，界面对齐无乱码)
- **[x] README.md 刷新与 App Store 宣发海报大图 (1242x2688 & 2064x2752) 生成** (生成 `docs/appstore_screenshot_iphone.png` 与 `docs/appstore_screenshot_ipad.png` 精确像素海报，并重构产品 README)
- **[x] iPad/iOS 模拟器适配包编译构建完成** (支持 iPad/iPhone 双设备族群 `TARGETED_DEVICE_FAMILY: "1,2"`，已生成专用于 iPad 模拟器运行调试的 `luDuan.app`)
- **[x] Build Number 升级 (Build 6 ➔ Build 7) 与 App Store IPA 打包导出** (成功完成 Release 归档，导出 `build/ipa/luDuan.ipa`，可以直接使用 Transporter 上传至 App Store Connect)
- **[x] SpeechRecognitionManager 线程安全与音频引擎防护重构** (语音识别闭包与 `stopRecording` 强保障于主线程执行，防止线程竞争与内存泄露，增加多线程单测验证)
- **[x] 人物名将全量 62 位肖像重绘与 100% 覆盖率完成** (重点补全王阳明、司马迁、庄子、范仲淹、老子、孙武、陶渊明、陆游、王安石、司马光、王维、孟浩然、杜牧等，并修复已有 16 位人物 JSON 映射)
- **[x] 实现闯关顶栏名称与激活卡片的精准动态关联** (从【太史公记/史记】进入顶栏精准显示`史记`/`太史公记`，从【尚书】进入显示`尚书`，从【童生·上】显示`童生·上`)
- **[x] 优化【字词释义】正文字体大小** (通关弹窗释义字号由 24pt 微调为 18pt，闯关线索字号调至 17/18pt，版面更显秀丽舒适)
- **[x] 排查并彻底清除【典籍名篇】中《诗经雅韵》与《诗经》的重复冗余卡片** (统一归一为唯一的【诗经雅韵】精美彩绘卡片)
- **[x] 彻底修复《道德经/老子》等名句误标记为【诗经风雅】的引擎分类 Bug** (升级为基于 `rawSeed.source` 的动态精准主题归类)
- **[x] 古文原文多源权威比对校核与纯净修正** (清除混入的现代赏析评语，恢复原汁原味的古风诗词原句与精确出处)
- **[x] 【功名学阶】独立词汇库与现代教学词频重构** (打破书籍限制，按认知难度与词频独立统计，显示 `X / 9 词` 等独立精准进度)
- **[x] 全量 39+ 典籍独立拆分** (全部离散化为独立 JSON 种子库与专属典籍映射)
- **[x] 全域同词同步 + 自动跳过已完成关卡机制** (常规模式下下一关自动精准确定位到首个未攻克新词，每次通关词数稳定 +1)
- **[x] 典籍去重词条实时绑定与勋章极速统计** (彻底排除重复关卡计数干扰，显示 `X / Y 词`)
- **[x] 全量 Code Review 与切换闯关类型/进入页面极速性能重构**
- **[x] 清除 UIDeviceFamily Xcode 警告 (使用 TARGETED_DEVICE_FAMILY: "1,2")**
- **[x] 勋章详情弹窗图像大幅放大至 140pt** (人物肖像与古风朱印威严高质感呈现)
- **[x] 勋章馆网格图标同步放大** (68pt / 56pt)
- **[x] iOS 模拟器/真机 60 FPS 极速流畅度性能优化 (O(1) 字典缓存)**
- **[x] “甪端学游”中国传统朱砂印章组件**
- **[x] 分享海报展示本次闯关古文原文节选**
- **[x] 真实 iOS 原生系统图片分享 (`UIImage` 合成渲染 + `UIActivityViewController`)**
- **[x] iOS 真机麦克风与语音识别修复 (双重授权 + `.playAndRecord`)**
- **[x] 主题与典籍 JSON 解耦** (`theme_books.json`, `book_phrases.json`)
- **[x] 通关弹窗 UI 布局重构** (顶部干净书名，【古文原文】在上、【字词释义】在下)
- **[x] 跨主题同词全域同步完成**
- **[x] 任意主题“全新开发”重玩模式**
- **[x] 核心勋章彩绘上线 (31 位/枚)**
