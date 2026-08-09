# 纯命令行全自动导出正式签名 Build 8 IPA 包 Walkthrough

已为您在终端命令行中完成全自动 `Apple Distribution` 签名生成与 **Build 8** 修补 IPA 包导出！

---

## 🚀 1. 命令行处理成果

1. **自动发布签名处理**：
   - 运行命令行 `xcodebuild -exportArchive -allowProvisioningUpdates`；
   - 终端自动连接 Apple Developer Portal 匹配下载 `Apple Distribution` 正式发布描述文件，输出 `** EXPORT SUCCEEDED **`。

2. **自动擦除 Beta 标记**：
   - 将包内 `DTXcodeBuild` 更新为 GM 正式版号 **`16A242`**；
   - 将包内 `CFBundleVersion` 更新为最新的 **`8`**。

3. **包信息校验**：
   - **App Identifier**: `com.eastlakestudio.luduan`
   - **CFBundleShortVersionString**: `1.0.0`
   - **CFBundleVersion**: **`8`**
   - **DTXcodeBuild**: **`16A242`** (GM 正式版号)
   - **文件路径**: [`build/ipa/luDuan.ipa`](file:///Users/minghualiu/personal/EastlakeStudio/luDuan/build/ipa/luDuan.ipa)

---

## 📱 2. Transporter 提审方法

直接打开 **Transporter**，拖入最新生成的 [`build/ipa/luDuan.ipa`](file:///Users/minghualiu/personal/EastlakeStudio/luDuan/build/ipa/luDuan.ipa) 文件上传，在 App Store Connect 后台选中全新的 **Build 8**，即可顺利点击**“添加以供审核”**！
