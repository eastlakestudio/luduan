# 《甪端字游》全量 39+ 典籍独立拆分与种子库挂载 Walkthrough

根据您的指示，已将 APP 中【典籍名篇】与各大经典书目**全量拆分为独立离散的 39+ 典籍种子库与数据契约**！

---

## 📚 1. 典籍独立拆分清单

在 `Sources/core/Resources/Seeds/` 目录下为每本典籍建立了专属 JSON 种子文件，并在 `Classic10000LevelsEngine.swift` 与 `theme_books.json` 中完成直连映射：

1. 《史记》 (`shiji.json`)
2. 《尚书》 (`shangshu.json`)
3. 《周易》 (`zhouyi.json`)
4. 《礼记》 (`liji.json`)
5. 《春秋左传》 (`chunqiu.json`)
6. 《论语》 (`lunyu.json`)
7. 《孟子》 (`mengzi.json`)
8. 《大学》 (`daxue.json`)
9. 《中庸》 (`zhongyong.json`)
10. 《汉书》 (`hanshu.json`)
11. 《后汉书》 (`houhanshu.json`)
12. 《三国志》 (`sanguozhi.json`)
13. 《资治通鉴》 (`zizhitongjian.json`)
14. 《战国策》 (`zhanguoce.json`)
15. 《道德经/老子》 (`daodejing.json`)
16. 《庄子》 (`zhuangzi.json`)
17. 《荀子》 (`xunzi.json`)
18. 《韩非子》 (`hanfeizi.json`)
19. 《孙子兵法》 (`sunzibingfa.json`)
20. 《淮南子》 (`huainanzi.json`)
21. 《吕氏春秋》 (`lvshichunqiu.json`)
22. 《楚辞》 (`chuci.json`)
23. 《昭明文选》 (`zhaomingwenxuan.json`)
24. 《文心雕龙》 (`wenxindiaolong.json`)
25. 《唐诗三百首》 (`tangshi.json`)
26. 《宋词三百首》 (`songci.json`)
27. 《花间乐府》 (`huajianyuefu.json`)
28. 《颜氏家训》 (`yanshijiaxun.json`)
29. 《传习录》 (`chuanxilu.json`)
30. 《菜根谭》 (`caigentan.json`)
31. 《小窗幽记/围炉》 (`xiaochuangyouji.json`)
32. 《曾国藩家书》 (`zengguofanjiashu.json`)
33. 《朱子家训》 (`zhuzijiaxun.json`)
34. 《西游记》 (`xiyouji.json`)
35. 《三国演义》 (`sanguoyanyi.json`)
36. 《水浒传》 (`shuihuzhuan.json`)
37. 《红楼梦》 (`hongloumeng.json`)
38. 《聊斋志异》 (`liaozhaizhiyi.json`)
39. 《国语》 (`guoyu.json`)

---

## 🧪 2. 验证与单元测试
- 全量 **73/73** 单元测试 **100% 绿色成功通过**！
- Xcode 项目工程编译 `** BUILD SUCCEEDED **` 100% 验证成功！
