/// 八卦模型
class BaGua {
  final String name;
  final String chinese;
  final String emoji;
  final String nature;

  const BaGua({
    required this.name,
    required this.chinese,
    required this.emoji,
    required this.nature,
  });

  // 乾、坤、震、巽、坎、离、艮、兑
  static const List<BaGua> all = [
    BaGua(name: '乾', chinese: '乾', emoji: '☰', nature: '天'),
    BaGua(name: '坤', chinese: '坤', emoji: '☷', nature: '地'),
    BaGua(name: '震', chinese: '震', emoji: '☳', nature: '雷'),
    BaGua(name: '巽', chinese: '巽', emoji: '☴', nature: '风'),
    BaGua(name: '坎', chinese: '坎', emoji: '☵', nature: '水'),
    BaGua(name: '离', chinese: '离', emoji: '☲', nature: '火'),
    BaGua(name: '艮', chinese: '艮', emoji: '☶', nature: '山'),
    BaGua(name: '兑', chinese: '兑', emoji: '☱', nature: '泽'),
  ];

  static BaGua? getByName(String name) {
    try {
      return all.firstWhere((b) => b.name == name);
    } catch (_) {
      return null;
    }
  }
}

/// 卦象模型
class Hexagram {
  final String name;           // 卦名（如"乾为天"）
  final String palace;          // 宫位
  final String fiveElements;   // 五行
  final String upperBaGua;     // 上卦
  final String lowerBaGua;     // 下卦
  final List<int> lines;       // 六爻 [1,0,1,1,1,1] 从初一到上六
  final List<int> changingLines; // 动爻位置

  const Hexagram({
    required this.name,
    required this.palace,
    required this.fiveElements,
    required this.upperBaGua,
    required this.lowerBaGua,
    required this.lines,
    this.changingLines = const [],
  });

  /// 二进制表示
  String get binaryValue => lines.join();

  /// 从二进制创建卦象
  static Hexagram? fromBinary(String binary, {List<int>? changing}) {
    if (binary.length != 6) return null;

    final lines = binary.split('').map((c) => int.parse(c)).toList();
    final upper = _getBaGua(lines.sublist(0, 3));
    final lower = _getBaGua(lines.sublist(3, 6));
    final name = '$upper$lower';

    return Hexagram(
      name: name,
      palace: _getPalace(lines),
      fiveElements: _getFiveElements(lines),
      upperBaGua: upper,
      lowerBaGua: lower,
      lines: lines,
      changingLines: changing ?? const [],
    );
  }

  static String _getBaGua(List<int> trigrams) {
    final value = trigrams.reduce((a, b) => a * 2 + b);
    const names = ['坤', '艮', '坎', '巽', '震', '离', '乾', '兑'];
    return names[value];
  }

  static String _getPalace(List<int> lines) {
    // 简化逻辑，实际需要查表
    return '乾';
  }

  static String _getFiveElements(List<int> lines) {
    // 简化逻辑，实际需要查表
    return '金';
  }

  /// 获取卦象符号（Unicode）
  String get symbol {
    return '$upperBaGua$lowerBaGua';
  }

  /// 动卦（变卦）
  Hexagram? get changingHexagram {
    if (changingLines.isEmpty) return null;
    final newLines = List<int>.from(lines);
    for (final i in changingLines) {
      newLines[i] = newLines[i] == 1 ? 0 : 1;
    }
    return Hexagram.fromBinary(
      newLines.join(),
      changing: [],
    );
  }
}

/// 六爻信息
class LiuYao {
  final int position;      // 位置 1-6
  final int value;         // 阴阳 0/1
  final String name;       // 爻名
  final bool isChanging;   // 是否为动爻

  const LiuYao({
    required this.position,
    required this.value,
    required this.name,
    this.isChanging = false,
  });

  String get yaoName {
    const names = ['初九', '九二', '九三', '九四', '九五', '上九'];
    const yinNames = ['初六', '六二', '六三', '六四', '六五', '上六'];
    return value == 1 ? names[position - 1] : yinNames[position - 1];
  }
}

/// 起卦结果
class DivinationResult {
  final Hexagram mainHexagram;    // 主卦
  final Hexagram? changingHexagram; // 变卦
  final List<LiuYao> yaoList;      // 六爻列表
  final DateTime timestamp;         // 起卦时间

  const DivinationResult({
    required this.mainHexagram,
    this.changingHexagram,
    required this.yaoList,
    required this.timestamp,
  });
}