#!/bin/sh
set -e

echo '=== Xcode Cloud: 安装 XcodeGen ==='
brew install xcodegen

echo '=== Xcode Cloud: 生成 xcodeproj ==='
xcodegen generate

echo '=== xcodeproj 生成完毕 ==='
ls -la luDuan.xcodeproj
