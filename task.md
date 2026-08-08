# 《甪端字游》启动页“甪端字游”字距拉大与拼音对齐开发任务清单

- [ ] **Task 65: 重构 LaunchScreenView 标题字距与拼音垂直对齐 (`LaunchScreenView.swift`)**
  - [ ] 调整“甪 端 字 游”字距 `tracking(14)`
  - [ ] 调整“lù    duān    zì    yóu”拼音间距，实现上下垂直精准对齐

- [ ] **Task 66: 单元测试与验证 (`LaunchPinyinTests.swift`)**
  - [ ] 运行 `swift test --scratch-path .build` 确保全量测试通过
  - [ ] 部署至 iPhone 17 模拟器，截屏验证启动页版式，更新 `walkthrough.md`
