import Foundation

public struct PresetData {
    
    public static let characterBadges: [BadgeModel] = [
        BadgeModel(
            id: "badge_char_kongzi",
            name: "孔子",
            sealText: "至圣\n先师",
            category: .character,
            description: "万世师表，儒家学派至圣先师。",
            requirementDescription: "掌握《论语》相关成语名句解锁",
            imageName: "badge_kongzi",
            dynasty: .zhou
        ),
        BadgeModel(
            id: "badge_char_laozi",
            name: "老子",
            sealText: "道德\n真经",
            category: .character,
            description: "紫气东来，道家学派始祖。",
            requirementDescription: "掌握《道德经》相关成语名句解锁",
            imageName: "badge_laozi",
            dynasty: .zhou
        ),
        BadgeModel(
            id: "badge_char_zhuangzi",
            name: "庄子",
            sealText: "逍遥\n齐物",
            category: .character,
            description: "心游万仞，梦蝶逍遥傲王侯。",
            requirementDescription: "掌握《庄子》相关成语名句解锁",
            imageName: "badge_zhuangzi",
            dynasty: .zhou
        ),
        BadgeModel(
            id: "badge_char_xunzi",
            name: "荀子",
            sealText: "劝学\n修身",
            category: .character,
            description: "儒家后劲，劝学积跬步至千里。",
            requirementDescription: "掌握《荀子》相关成语名句解锁",
            imageName: "badge_xunzi",
            dynasty: .zhou
        ),
        BadgeModel(
            id: "badge_char_mozi",
            name: "墨子",
            sealText: "兼爱\n非攻",
            category: .character,
            description: "兼爱非攻，摩顶放踵利天下。",
            requirementDescription: "掌握《墨子》相关成语名句解锁",
            imageName: "badge_mozi",
            dynasty: .zhou
        ),
        BadgeModel(
            id: "badge_char_hanfeizi",
            name: "韩非子",
            sealText: "法术\n势备",
            category: .character,
            description: "法家集大成者，深谋富国强兵。",
            requirementDescription: "掌握《韩非子》相关成语名句解锁",
            imageName: "badge_hanfeizi",
            dynasty: .qin
        ),
        BadgeModel(
            id: "badge_char_sunwu",
            name: "孙武",
            sealText: "兵家\n至圣",
            category: .character,
            description: "兵学圣典，百世用兵之始祖。",
            requirementDescription: "掌握《孙子兵法》相关成语名句解锁",
            imageName: "badge_sunwu",
            dynasty: .zhou
        ),
        BadgeModel(
            id: "badge_char_quyuan",
            name: "屈原",
            sealText: "楚辞\n九歌",
            category: .character,
            description: "行廉志洁，九死不悔怀沙赋。",
            requirementDescription: "掌握《楚辞》相关成语名句解锁",
            imageName: "badge_quyuan",
            dynasty: .zhou
        ),
        BadgeModel(
            id: "badge_char_simaqian",
            name: "司马迁",
            sealText: "史家\n绝唱",
            category: .character,
            description: "通古今之变，成一家之言。",
            requirementDescription: "掌握《史记》相关成语名句解锁",
            imageName: "badge_simaqian",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_bangu",
            name: "班固",
            sealText: "汉书\n良史",
            category: .character,
            description: "编纂汉书，文辞渊懿开断代。",
            requirementDescription: "掌握《汉书》相关成语名句解锁",
            imageName: "badge_bangu",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_jiayi",
            name: "贾谊",
            sealText: "洛阳\n才子",
            category: .character,
            description: "雄文过秦，少年名动宣室策。",
            requirementDescription: "掌握贾谊名篇相关成语名句解锁",
            imageName: "badge_jiayi",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_liuxiang",
            name: "刘向",
            sealText: "说苑\n策府",
            category: .character,
            description: "典校群书，辨章学术辑名篇。",
            requirementDescription: "掌握《战国策》《说苑》相关成语名句解锁",
            imageName: "badge_liuxiang",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_fanye",
            name: "范晔",
            sealText: "后汉\n良史",
            category: .character,
            description: "后汉书成，笔意雄健叙英豪。",
            requirementDescription: "掌握《后汉书》相关成语名句解锁",
            imageName: "badge_fanye",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_chenshou",
            name: "陈寿",
            sealText: "三国\n良史",
            category: .character,
            description: "魏蜀吴分，千秋青史著三国。",
            requirementDescription: "掌握《三国志》相关成语名句解锁",
            imageName: "badge_chenshou",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_simaguang",
            name: "司马光",
            sealText: "资治\n通鉴",
            category: .character,
            description: "鉴往知来，历代治乱编年表。",
            requirementDescription: "掌握《资治通鉴》相关成语名句解锁",
            imageName: "badge_simaguang",
            dynasty: .song
        ),
        BadgeModel(
            id: "badge_char_fangxuanling",
            name: "房玄龄",
            sealText: "贞观\n房谋",
            category: .character,
            description: "房谋杜断，贞观盛世宰相勋。",
            requirementDescription: "掌握《晋书》与唐初名篇解锁",
            imageName: "badge_fangxuanling",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_duruhui",
            name: "杜如晦",
            sealText: "贞观\n杜断",
            category: .character,
            description: "经纶济世，辅弼太宗定太平。",
            requirementDescription: "掌握贞观策论相关成语解锁",
            imageName: "badge_duruhui",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_weizheng",
            name: "魏征",
            sealText: "人镜\n名臣",
            category: .character,
            description: "兼听则明，以人为镜正得失。",
            requirementDescription: "掌握魏征奏议相关成语解锁",
            imageName: "badge_weizheng",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_taoyuanming",
            name: "陶渊明",
            sealText: "靖节\n五柳",
            category: .character,
            description: "采菊东篱，不为五斗米折腰。",
            requirementDescription: "掌握陶渊明诗文相关成语名句解锁",
            imageName: "badge_taoyuanming",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_libai",
            name: "李白",
            sealText: "诗仙\n太白",
            category: .character,
            description: "长风破浪，仰天大笑出门去。",
            requirementDescription: "掌握李白诗篇相关成语名句解锁",
            imageName: "badge_libai",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_dufu",
            name: "杜甫",
            sealText: "诗圣\n子美",
            category: .character,
            description: "安得广厦，心系苍生笔底波。",
            requirementDescription: "掌握杜甫诗篇相关成语名句解锁",
            imageName: "badge_dufu",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_baijuyi",
            name: "白居易",
            sealText: "香山\n居士",
            category: .character,
            description: "同是天涯，琵琶长恨写人寰。",
            requirementDescription: "掌握白居易诗篇相关成语名句解锁",
            imageName: "badge_baijuyi",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_wangwei",
            name: "王维",
            sealText: "诗佛\n摩诘",
            category: .character,
            description: "空山新雨，诗中有画画中诗。",
            requirementDescription: "掌握王维诗篇相关成语名句解锁",
            imageName: "badge_wangwei",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_menghaoran",
            name: "孟浩然",
            sealText: "鹿门\n高士",
            category: .character,
            description: "春眠不觉，隐居鹿门伴清风。",
            requirementDescription: "掌握孟浩然诗篇相关成语名句解锁",
            imageName: "badge_menghaoran",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_dumu",
            name: "杜牧",
            sealText: "樊川\n绝唱",
            category: .character,
            description: "借问酒家，一骑红尘妃子笑。",
            requirementDescription: "掌握杜牧诗篇相关成语名句解锁",
            imageName: "badge_dumu",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_lishangyin",
            name: "李商隐",
            sealText: "玉溪\n锦瑟",
            category: .character,
            description: "沧海月明，身无彩凤双飞翼。",
            requirementDescription: "掌握李商隐诗篇相关成语名句解锁",
            imageName: "badge_lishangyin",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_hanyu",
            name: "韩愈",
            sealText: "文起\n八代",
            category: .character,
            description: "师者传道，文起八代之衰颓。",
            requirementDescription: "掌握韩愈古文相关成语名句解锁",
            imageName: "badge_hanyu",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_liuzongyuan",
            name: "柳宗元",
            sealText: "河东\n先生",
            category: .character,
            description: "千山鸟绝，永州山水寄幽怀。",
            requirementDescription: "掌握柳宗元诗文相关成语名句解锁",
            imageName: "badge_liuzongyuan",
            dynasty: .tang
        ),
        BadgeModel(
            id: "badge_char_sushi",
            name: "苏轼",
            sealText: "东坡\n居士",
            category: .character,
            description: "大江东去，一蓑烟雨任平生。",
            requirementDescription: "掌握苏轼词篇相关成语名句解锁",
            imageName: "badge_sushi",
            dynasty: .song
        ),
        BadgeModel(
            id: "badge_char_ouyangxiu",
            name: "欧阳修",
            sealText: "六一\n居士",
            category: .character,
            description: "醉翁之意，山水之间与民乐。",
            requirementDescription: "掌握欧阳修散文相关成语名句解锁",
            imageName: "badge_ouyangxiu",
            dynasty: .song
        ),
        BadgeModel(
            id: "badge_char_wanganshi",
            name: "王安石",
            sealText: "临川\n变法",
            category: .character,
            description: "天变不足畏，风正一帆悬。",
            requirementDescription: "掌握王安石诗文相关成语名句解锁",
            imageName: "badge_wanganshi",
            dynasty: .song
        ),
        BadgeModel(
            id: "badge_char_fanzhongyan",
            name: "范仲淹",
            sealText: "文正\n忧乐",
            category: .character,
            description: "先忧后乐，岳阳楼上万古名。",
            requirementDescription: "掌握范仲淹名作相关成语名句解锁",
            imageName: "badge_fanzhongyan",
            dynasty: .song
        ),
        BadgeModel(
            id: "badge_char_luyou",
            name: "陆游",
            sealText: "放翁\n剑南",
            category: .character,
            description: "王师北定，铁马冰河入梦来。",
            requirementDescription: "掌握陆游诗词相关成语名句解锁",
            imageName: "badge_luyou",
            dynasty: .song
        ),
        BadgeModel(
            id: "badge_char_xinqiji",
            name: "辛弃疾",
            sealText: "稼轩\n豪迈",
            category: .character,
            description: "醉里挑灯，气吞万里如虎。",
            requirementDescription: "掌握辛弃疾词篇相关成语名句解锁",
            imageName: "badge_xinqiji",
            dynasty: .song
        ),
        BadgeModel(
            id: "badge_char_liqingzhao",
            name: "李清照",
            sealText: "易安\n词宗",
            category: .character,
            description: "寻寻觅觅，生当作人杰。",
            requirementDescription: "掌握李清照词篇相关成语名句解锁",
            imageName: "badge_liqingzhao",
            dynasty: .song
        ),
        BadgeModel(
            id: "badge_char_wangyangming",
            name: "王阳明",
            sealText: "心学\n知行",
            category: .character,
            description: "知行合一，此心光明复何求。",
            requirementDescription: "掌握《传习录》相关成语名句解锁",
            imageName: "badge_wangyangming",
            dynasty: .ming
        ),
        BadgeModel(
            id: "badge_char_zengguofan",
            name: "曾国藩",
            sealText: "立德\n立言",
            category: .character,
            description: "结硬寨打呆仗，俭以养廉家书长。",
            requirementDescription: "掌握曾国藩名作相关成语名句解锁",
            imageName: "badge_zengguofan",
            dynasty: .qing
        ),
        BadgeModel(
            id: "badge_char_linzexu",
            name: "林则徐",
            sealText: "文忠\n虎门",
            category: .character,
            description: "苟利国家，海纳百川有容乃大。",
            requirementDescription: "掌握林则徐名篇相关成语名句解锁",
            imageName: "badge_linzexu",
            dynasty: .qing
        ),
        BadgeModel(
            id: "badge_char_jixiaolan",
            name: "纪晓岚",
            sealText: "四库\n总纂",
            category: .character,
            description: "阅微草堂，总纂四库博群书。",
            requirementDescription: "掌握《阅微草堂笔记》相关成语解锁",
            imageName: "badge_jixiaolan",
            dynasty: .qing
        ),
        BadgeModel(
            id: "badge_char_caoxueqin",
            name: "曹雪芹",
            sealText: "红楼\n梦笔",
            category: .character,
            description: "字字看来皆是血，红楼万古情。",
            requirementDescription: "掌握《红楼梦》相关成语名句解锁",
            imageName: "badge_caoxueqin",
            dynasty: .qing
        ),
        BadgeModel(
            id: "badge_char_luxun",
            name: "鲁迅",
            sealText: "朝花\n夕拾",
            category: .character,
            description: "横眉冷对，俯首甘为孺子牛。",
            requirementDescription: "掌握鲁迅名作相关成语名句解锁",
            imageName: "badge_luxun",
            dynasty: .qing
        ),
        BadgeModel(
            id: "badge_char_caocao",
            name: "曹操",
            sealText: "魏武\n雄才",
            category: .character,
            description: "对酒当歌，慨当以慷忧思难忘。",
            requirementDescription: "掌握曹操诗文相关成语名句解锁",
            imageName: "badge_caocao",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_zhugeliang",
            name: "诸葛亮",
            sealText: "武侯\n忠臣",
            category: .character,
            description: "鞠躬尽瘁，两朝开济老臣心。",
            requirementDescription: "掌握《出师表》相关成语名句解锁",
            imageName: "badge_zhugeliang",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_guanyu",
            name: "关羽",
            sealText: "义薄\n云天",
            category: .character,
            description: "千里单骑，忠义千秋美髯公。",
            requirementDescription: "掌握三国义气典故成语解锁",
            imageName: "badge_guanyu",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_zhangfei",
            name: "张飞",
            sealText: "勇冠\n三军",
            category: .character,
            description: "长坂坡头，据水断桥万夫莫敌。",
            requirementDescription: "掌握三国名将典故成语解锁",
            imageName: "badge_zhangfei",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_zhouyu",
            name: "周瑜",
            sealText: "赤壁\n公瑾",
            category: .character,
            description: "谈笑之间，羽扇纶巾樯橹灭。",
            requirementDescription: "掌握赤壁名篇相关成语名句解锁",
            imageName: "badge_zhouyu",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_lusu",
            name: "鲁肃",
            sealText: "东吴\n都督",
            category: .character,
            description: "榻上策定，大智若愚辅江东。",
            requirementDescription: "掌握江东名臣典故成语解锁",
            imageName: "badge_lusu",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_lubu",
            name: "吕布",
            sealText: "无双\n温侯",
            category: .character,
            description: "辕门射戟，人中吕布冠群雄。",
            requirementDescription: "掌握三国风云典故成语解锁",
            imageName: "badge_lubu",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_guojia",
            name: "郭嘉",
            sealText: "鬼谋\n奇佐",
            category: .character,
            description: "才策谋略，见微知著算无遗策。",
            requirementDescription: "掌握三国谋略典故成语解锁",
            imageName: "badge_guojia",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_xunyu",
            name: "荀彧",
            sealText: "王佐\n之才",
            category: .character,
            description: "运筹帷幄，深谋远虑辅魏武。",
            requirementDescription: "掌握汉魏谋臣典故成语解锁",
            imageName: "badge_xunyu",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_jiangwei",
            name: "姜维",
            sealText: "继志\n幼常",
            category: .character,
            description: "九伐中原，一片赤心继武侯。",
            requirementDescription: "掌握蜀汉名将典故成语解锁",
            imageName: "badge_jiangwei",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_hanxin",
            name: "韩信",
            sealText: "兵仙\n国士",
            category: .character,
            description: "背水一战，多多益善立汉基。",
            requirementDescription: "掌握韩信典故成语名句解锁",
            imageName: "badge_hanxin",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_huoqubing",
            name: "霍去病",
            sealText: "冠军\n封狼",
            category: .character,
            description: "匈奴未灭，封狼居胥饮马瀚海。",
            requirementDescription: "掌握大汉名将典故成语解锁",
            imageName: "badge_huoqubing",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_weiqing",
            name: "卫青",
            sealText: "大将军\n印",
            category: .character,
            description: "深入漠北，龙城飞将扫胡尘。",
            requirementDescription: "掌握大汉铁骑典故成语解锁",
            imageName: "badge_weiqing",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_yuefei",
            name: "岳飞",
            sealText: "精忠\n报国",
            category: .character,
            description: "三十功名，还我河山满江红。",
            requirementDescription: "掌握岳飞名篇相关成语名句解锁",
            imageName: "badge_yuefei",
            dynasty: .song
        ),
        BadgeModel(
            id: "badge_char_wentianxiang",
            name: "文天祥",
            sealText: "丹心\n正气",
            category: .character,
            description: "人生自古，留取丹心照汗青。",
            requirementDescription: "掌握《过零丁洋》相关成语名句解锁",
            imageName: "badge_wentianxiang",
            dynasty: .song
        ),
        BadgeModel(
            id: "badge_char_zhengchenggong",
            name: "郑成功",
            sealText: "延平\n郡王",
            category: .character,
            description: "开台辟土，驱逐荷夷复神州。",
            requirementDescription: "掌握明末名将典故成语解锁",
            imageName: "badge_zhengchenggong",
            dynasty: .ming
        ),
        BadgeModel(
            id: "badge_char_baozheng",
            name: "包拯",
            sealText: "龙图\n青天",
            category: .character,
            description: "铁面无私，青天照镜断曲直。",
            requirementDescription: "掌握廉明典故相关成语解锁",
            imageName: "badge_baozheng",
            dynasty: .song
        ),
        BadgeModel(
            id: "badge_char_zhangliang",
            name: "张良",
            sealText: "谋圣\n子房",
            category: .character,
            description: "决胜千里，运筹帷幄辟强汉。",
            requirementDescription: "掌握张良典故相关成语解锁",
            imageName: "badge_zhangliang",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_xiaohe",
            name: "萧何",
            sealText: "汉初\n相国",
            category: .character,
            description: "镇守关中，萧规曹随奠汉邦。",
            requirementDescription: "掌握汉初三杰典故成语解锁",
            imageName: "badge_xiaohe",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_liubang",
            name: "刘邦",
            sealText: "大风\n高帝",
            category: .character,
            description: "大风起兮，威加海内归故乡。",
            requirementDescription: "掌握大风歌相关成语名句解锁",
            imageName: "badge_liubang",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_xiangyu",
            name: "项羽",
            sealText: "西楚\n霸王",
            category: .character,
            description: "力拔山兮，破釜沉舟盖世勇。",
            requirementDescription: "掌握垓下歌与楚霸王典故解锁",
            imageName: "badge_xiangyu",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_zhangheng",
            name: "张衡",
            sealText: "科圣\n候风",
            category: .character,
            description: "地动仪成，仰观天文俯察地理。",
            requirementDescription: "掌握汉代科技名篇相关成语解锁",
            imageName: "badge_zhangheng",
            dynasty: .han
        ),
        BadgeModel(
            id: "badge_char_zuchongzhi",
            name: "祖冲之",
            sealText: "算圣\n大明",
            category: .character,
            description: "缀术精深，圆周密率传千载。",
            requirementDescription: "掌握古代数学典籍相关成语解锁",
            imageName: "badge_zuchongzhi",
            dynasty: .tang
        )
    ]
    
    public static var defaultBadges: [BadgeModel] {
        var list: [BadgeModel] = []
        if let data = GameDataRepository.loadJSONData(named: "badges"),
           let decoded = try? JSONDecoder().decode([BadgeModel].self, from: data) {
            list = decoded
        }
        let existingIds = Set(list.map { $0.id })
        for charBadge in characterBadges {
            if !existingIds.contains(charBadge.id) {
                list.append(charBadge)
            }
        }
        return list
    }
}
