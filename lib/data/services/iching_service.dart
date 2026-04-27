import 'dart:math';
import '../models/hexagram.dart';

/// 易经起卦服务
class IChingService {
  final Random _random = Random();

  /// 蓍草占卦法（简化版：使用随机数模拟）
  DivinationResult divine() {
    // 生成6爻
    final lines = List.generate(6, (_) => _getYao());
    
    // 找出动爻（随机1-2个）
    final changingIndices = <int>[];
    final numChanging = _random.nextInt(3); // 0-2个动爻
    while (changingIndices.length < numChanging) {
      final idx = _random.nextInt(6);
      if (!changingIndices.contains(idx)) {
        changingIndices.add(idx);
      }
    }
    changingIndices.sort();

    // 构建爻列表
    final yaoList = List.generate(6, (i) {
      return LiuYao(
        position: i + 1,
        value: lines[i],
        name: _getYaoName(i, lines[i]),
        isChanging: changingIndices.contains(i),
      );
    });

    // 创建卦象
    final mainHexagram = Hexagram.fromBinary(
      lines.join(),
      changing: changingIndices,
    )!;

    return DivinationResult(
      mainHexagram: mainHexagram,
      changingHexagram: mainHexagram.changingHexagram,
      yaoList: yaoList,
      timestamp: DateTime.now(),
    );
  }

  /// 获取单爻（0=阴，1=阳）
  int _getYao() => _random.nextInt(2);

  /// 获取爻名
  String _getYaoName(int position, int value) {
    const yangNames = ['初九', '九二', '九三', '九四', '九五', '上九'];
    const yinNames = ['初六', '六二', '六三', '六四', '六五', '上六'];
    return value == 1 ? yangNames[position] : yinNames[position];
  }

  /// 数字起卦（铜钱摇卦）
  DivinationResult divineByCoins() {
    // 铜钱法：3枚硬币抛6次
    final lines = List.generate(6, (_) => _tossCoin());
    
    // 确定动爻（少阳不动，老阳老阴动）
    final changingIndices = <int>[];
    for (int i = 0; i < 6; i++) {
      if (lines[i] == 2 || lines[i] == 3) { // 老阳或老阴
        changingIndices.add(i);
      }
    }

    // 转换爻值（2→1阳，3→0阴，老阳老阴变）
    final realLines = lines.map((l) => l == 2 || l == 0 ? 1 : 0).toList();
    
    final yaoList = List.generate(6, (i) {
      final val = lines[i];
      String name;
      bool isChanging = false;
      
      if (val == 2) {
        name = '九${_getPositionName(i)}';
        isChanging = true;
      } else if (val == 3) {
        name = '六${_getPositionName(i)}';
        isChanging = true;
      } else if (val == 0) {
        name = '九${_getPositionName(i)}';
      } else {
        name = '六${_getPositionName(i)}';
      }
      
      return LiuYao(
        position: i + 1,
        value: realLines[i],
        name: name,
        isChanging: isChanging,
      );
    });

    final mainHexagram = Hexagram.fromBinary(
      realLines.join(),
      changing: changingIndices,
    )!;

    return DivinationResult(
      mainHexagram: mainHexagram,
      changingHexagram: mainHexagram.changingHexagram,
      yaoList: yaoList,
      timestamp: DateTime.now(),
    );
  }

  int _tossCoin() {
    // 0=两背一正面→少阳（不动）
    // 1=两正面一背→少阴（不动）
    // 2=三正面→老阳（变阴）
    // 3=三背面→老阴（变阳）
    final heads = _random.nextInt(2) + _random.nextInt(2) + _random.nextInt(2);
    return heads;
  }

  String _getPositionName(int pos) {
    const names = ['初', '二', '三', '四', '五', '上'];
    return names[pos];
  }

  /// 获取卦象解释
  String getHexagramText(Hexagram hexagram) {
    // 简化版，实际需要完整的卦辞
    final texts = {
      '乾为天': '乾：元，亨，利，贞。初九：潜龙，勿用。九二：见龙在田，利见大人。九三：君子终日乾乾，夕惕若厉，无咎。九四：或跃在渊，无咎。九五：飞龙在天，利见大人。上九：亢龙，有悔。用九：见群龙无首，吉。',
      '坤为地': '坤：元，亨，利牝马之贞。君子有攸往，先迷后得主。利西南得朋，东北丧朋。安贞，吉。初六：履霜，坚冰至。六二：直，方，大，不习无不利。六三：含章，可贞。或从王事，无成有终。六四：括囊，无咎无誉。六五：黄裳，元吉。上六：龙战于野，其血玄黄。用六：利永贞。',
    };
    return texts[hexagram.name] ?? '${hexagram.name}：象曰...';
  }

  /// 获取卦象五行属性
  String getFiveElements(Hexagram hexagram) {
    const fiveElementsMap = {
      '乾': '金', '兑': '金',
      '坤': '土', '艮': '土',
      '坎': '水',
      '离': '火',
      '震': '木', '巽': '木',
    };
    return fiveElementsMap[hexagram.upperBaGua] ?? '金';
  }

  /// 获取卦象宫位
  String getPalace(Hexagram hexagram) {
    // 简化：按上卦确定宫
    const palaceMap = {
      '乾': '乾宫', '坤': '坤宫', '震': '震宫', '巽': '巽宫',
      '坎': '坎宫', '离': '离宫', '艮': '艮宫', '兑': '兑宫',
    };
    return palaceMap[hexagram.upperBaGua] ?? '乾宫';
  }
}