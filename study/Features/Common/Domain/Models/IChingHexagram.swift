import Foundation

struct IChingHexagram: Identifiable, Hashable {
    let index: Int
    let name: String
    let pinyin: String
    let binary: String
    let upperTrigram: String
    let lowerTrigram: String
    let meaning: String

    var id: Int { index }

    var displayName: String {
        let upperNature = IChingHexagramCatalog.trigramNature(for: upperTrigram)
        let lowerNature = IChingHexagramCatalog.trigramNature(for: lowerTrigram)
        if upperTrigram == lowerTrigram {
            return "\(name)为\(upperNature)"
        }
        return "\(upperNature)\(lowerNature)\(name)"
    }
}

struct OracleSession: Hashable {
    let originalLines: [Bool]
    let changedLines: [Bool]
    let movingLineIndex: Int
    let originalHexagram: IChingHexagram
    let changedHexagram: IChingHexagram

    static let preview: OracleSession = {
        let lines = [false, true, false, true, false, false]
        return IChingHexagramCatalog.makeSession(originalLines: lines, movingLineIndex: 1)
            ?? OracleSession(
                originalLines: lines,
                changedLines: lines,
                movingLineIndex: 0,
                originalHexagram: IChingHexagramCatalog.hexagram(for: lines) ?? IChingHexagramCatalog.fallbackHexagram(lines: lines),
                changedHexagram: IChingHexagramCatalog.hexagram(for: lines) ?? IChingHexagramCatalog.fallbackHexagram(lines: lines)
            )
    }()
}

enum IChingHexagramCatalog {
    private struct TrigramDef {
        let name: String
        let binary: String
        let nature: String
    }

    private static let trigramOrder: [TrigramDef] = [
        .init(name: "乾", binary: "111", nature: "天"),
        .init(name: "兑", binary: "110", nature: "泽"),
        .init(name: "离", binary: "101", nature: "火"),
        .init(name: "震", binary: "100", nature: "雷"),
        .init(name: "巽", binary: "011", nature: "风"),
        .init(name: "坎", binary: "010", nature: "水"),
        .init(name: "艮", binary: "001", nature: "山"),
        .init(name: "坤", binary: "000", nature: "地")
    ]

    // Rows are lower trigram; columns are upper trigram.
    private static let kingWenMatrix: [[Int]] = [
        [1, 43, 14, 34, 9, 5, 26, 11],
        [10, 58, 38, 54, 61, 60, 41, 19],
        [13, 49, 30, 55, 37, 63, 22, 36],
        [25, 17, 21, 51, 42, 3, 27, 24],
        [44, 28, 50, 32, 57, 48, 18, 46],
        [6, 47, 64, 40, 59, 29, 4, 7],
        [33, 31, 56, 62, 53, 39, 52, 15],
        [12, 45, 35, 16, 20, 8, 23, 2]
    ]

    private static let metadataByIndex: [Int: (name: String, pinyin: String, meaning: String)] = [
        1: ("乾", "Qian", "天行健，自强不息"),
        2: ("坤", "Kun", "地势坤，厚德载物"),
        3: ("屯", "Zhun", "初难将生，宜守正待机"),
        4: ("蒙", "Meng", "启蒙求学，先难后易"),
        5: ("需", "Xu", "待时而动，诚信可成"),
        6: ("讼", "Song", "有争宜止，以和为贵"),
        7: ("师", "Shi", "师旅有律，统众而行"),
        8: ("比", "Bi", "亲比协作，择善而从"),
        9: ("小畜", "Xiao Chu", "小蓄待发，柔以制刚"),
        10: ("履", "Lu", "履道慎行，和而不争"),
        11: ("泰", "Tai", "天地交泰，万事亨通"),
        12: ("否", "Pi", "阴阳不交，闭塞待变"),
        13: ("同人", "Tong Ren", "同心同德，共济其志"),
        14: ("大有", "Da You", "大有丰盛，守正不骄"),
        15: ("谦", "Qian", "谦冲自牧，损己益人"),
        16: ("豫", "Yu", "顺势而豫，戒逸守度"),
        17: ("随", "Sui", "随时应变，随善而行"),
        18: ("蛊", "Gu", "振弊除腐，先治其本"),
        19: ("临", "Lin", "临下有德，渐进有成"),
        20: ("观", "Guan", "观其大略，省身明辨"),
        21: ("噬嗑", "Shi He", "明法断事，去障通达"),
        22: ("贲", "Bi", "文饰有度，质胜于华"),
        23: ("剥", "Bo", "剥落将尽，守正待复"),
        24: ("复", "Fu", "复归本真，阳气初生"),
        25: ("无妄", "Wu Wang", "无妄而行，诚则有吉"),
        26: ("大畜", "Da Chu", "厚积而发，蓄德待时"),
        27: ("颐", "Yi", "颐养正道，慎言节食"),
        28: ("大过", "Da Guo", "栋梁负重，非常之举"),
        29: ("坎", "Kan", "险中求通，守信不失"),
        30: ("离", "Li", "明而附丽，光明中正"),
        31: ("咸", "Xian", "感应相求，诚意相合"),
        32: ("恒", "Heng", "恒久有常，持之以恒"),
        33: ("遁", "Dun", "退而有守，避害全身"),
        34: ("大壮", "Da Zhuang", "大壮有为，刚健守礼"),
        35: ("晋", "Jin", "日进于明，进德修业"),
        36: ("明夷", "Ming Yi", "明夷韬晦，晦而不昧"),
        37: ("家人", "Jia Ren", "家人有序，内正外和"),
        38: ("睽", "Kui", "睽异求同，和而不同"),
        39: ("蹇", "Jian", "蹇难在前，反求诸己"),
        40: ("解", "Jie", "解困释结，动而得解"),
        41: ("损", "Sun", "损有余而补不足"),
        42: ("益", "Yi", "利他益己，顺势增益"),
        43: ("夬", "Guai", "决而能断，先难后通"),
        44: ("姤", "Gou", "猝遇强势，慎始防微"),
        45: ("萃", "Cui", "聚众成事，同心可成"),
        46: ("升", "Sheng", "循序上升，柔进有功"),
        47: ("困", "Kun", "困而不失其志"),
        48: ("井", "Jing", "改邑不改井，养民之源"),
        49: ("革", "Ge", "革故鼎新，顺时而变"),
        50: ("鼎", "Ding", "鼎新化成，德业并举"),
        51: ("震", "Zhen", "震惊百里，动而知惧"),
        52: ("艮", "Gen", "止于其所，静定明心"),
        53: ("渐", "Jian", "循序渐进，积小成大"),
        54: ("归妹", "Gui Mei", "归妹有时，位不当慎"),
        55: ("丰", "Feng", "丰盛而中，盛极戒盈"),
        56: ("旅", "Lu", "旅途寄居，谨慎自守"),
        57: ("巽", "Xun", "入而不争，柔顺以行"),
        58: ("兑", "Dui", "悦而能和，言行相孚"),
        59: ("涣", "Huan", "涣散可聚，先解后合"),
        60: ("节", "Jie", "节制有度，守中得安"),
        61: ("中孚", "Zhong Fu", "中心诚信，感而遂通"),
        62: ("小过", "Xiao Guo", "小事可行，大事宜慎"),
        63: ("既济", "Ji Ji", "事已成而戒其终"),
        64: ("未济", "Wei Ji", "未济将济，慎终如始")
    ]

    static let all: [IChingHexagram] = {
        var entries: [IChingHexagram] = []
        entries.reserveCapacity(64)

        for (lowerIndex, lower) in trigramOrder.enumerated() {
            for (upperIndex, upper) in trigramOrder.enumerated() {
                let hexIndex = kingWenMatrix[lowerIndex][upperIndex]
                guard let meta = metadataByIndex[hexIndex] else { continue }

                entries.append(
                    IChingHexagram(
                        index: hexIndex,
                        name: meta.name,
                        pinyin: meta.pinyin,
                        binary: lower.binary + upper.binary,
                        upperTrigram: upper.name,
                        lowerTrigram: lower.name,
                        meaning: meta.meaning
                    )
                )
            }
        }

        return entries.sorted { $0.index < $1.index }
    }()

    private static let byBinary: [String: IChingHexagram] = {
        Dictionary(uniqueKeysWithValues: all.map { ($0.binary, $0) })
    }()

    static func trigramNature(for trigramName: String) -> String {
        trigramOrder.first(where: { $0.name == trigramName })?.nature ?? ""
    }

    static func binaryString(for lines: [Bool]) -> String {
        guard lines.count == 6 else { return "" }
        return lines.map { $0 ? "1" : "0" }.joined()
    }

    static func hexagram(for lines: [Bool]) -> IChingHexagram? {
        hexagram(binary: binaryString(for: lines))
    }

    static func hexagram(binary: String) -> IChingHexagram? {
        byBinary[binary]
    }

    static func fallbackHexagram(lines: [Bool]) -> IChingHexagram {
        IChingHexagram(
            index: -1,
            name: "未定",
            pinyin: "Unknown",
            binary: binaryString(for: lines),
            upperTrigram: "",
            lowerTrigram: "",
            meaning: "卦象未能匹配，请重新起卦"
        )
    }

    static func makeSession(originalLines: [Bool], movingLineIndex: Int) -> OracleSession? {
        guard originalLines.count == 6, originalLines.indices.contains(movingLineIndex) else { return nil }

        var changedLines = originalLines
        changedLines[movingLineIndex].toggle()

        let originalHexagram = hexagram(for: originalLines) ?? fallbackHexagram(lines: originalLines)
        let changedHexagram = hexagram(for: changedLines) ?? fallbackHexagram(lines: changedLines)

        return OracleSession(
            originalLines: originalLines,
            changedLines: changedLines,
            movingLineIndex: movingLineIndex,
            originalHexagram: originalHexagram,
            changedHexagram: changedHexagram
        )
    }
}
