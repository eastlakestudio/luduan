# 《甪端字游》UIDeviceFamily 构建警告修复 Walkthrough

已成功解决 Xcode `UIDeviceFamily` 覆盖警告问题！

---

## 🛠️ 1. 警告根因与修复说明
- **警告原因**：当在 `Info.plist` 或 `project.yml` 的 `info: properties:` 中直接指定 `UIDeviceFamily` 时，Xcode 会在构建时输出警告：
  `User supplied UIDeviceFamily key in the Info.plist will be overwritten. Please use the build setting TARGETED_DEVICE_FAMILY and remove UIDeviceFamily from your Info.plist.`
- **修复方案**：
  1. 从 [`AppSupport/Info.plist`](file:///Users/minghualiu/personal/EastlakeStudio/luDuan/AppSupport/Info.plist) 与 [`project.yml`](file:///Users/minghualiu/personal/EastlakeStudio/luDuan/project.yml) 中移除了手写 `UIDeviceFamily` 字典键。
  2. 在 `project.yml` 的 `settings.base` 构建配置中显式配置 `TARGETED_DEVICE_FAMILY: "1,2"`（适配 iPhone 与 iPad 通用设备支持）。

---

## 🧪 2. 验证与构建
- `xcodegen generate` 生成项目工程结构。
- `xcodebuild` 编译构建 `** BUILD SUCCEEDED **` 100% 成功，警告彻底消除！
