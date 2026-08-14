#!/bin/sh
set -e

# Xcode Cloud post-clone: 从 project.yml 生成/更新 Xcode 工程
# 如果 xcodegen 不可用则跳过（使用仓库中已提交的 .xcodeproj）

if ! command -v xcodegen >/dev/null 2>&1; then
    brew install xcodegen 2>/dev/null || true
fi

if command -v xcodegen >/dev/null 2>&1; then
    if [ -d "$CI_PRIMARY_REPOSITORY_PATH/ios" ]; then
        cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
    elif [ -d "$CI_WORKSPACE_PATH/ios" ]; then
        cd "$CI_WORKSPACE_PATH/ios"
    fi
    xcodegen generate
fi
