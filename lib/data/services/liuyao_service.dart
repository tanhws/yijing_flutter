import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/liu_shisigua_data.dart';
import '../models/liuyao_model.dart';

/// 六爻起卦服务
class LiuYaoService {
  static const String _storageKey = 'liuyao_result';
  
  final Random _random = Random();
  
  /// 摇硬币一次（3枚）
  /// 返回: 0=三正面(老阳变阴), 1=两正一背(少阴), 2=两背一正(少阳), 3=三背面(老阴变阳)
  CoinThrowResult tossCoins() {
    final results = List.generate(3, (_) => _random.nextInt(2));
    final total = results.reduce((a, b) => a + b);
    
    if (total == 3) return CoinThrowResult.laoYang;  // 三正面
    if (total == 0) return CoinThrowResult.laoYin;   // 三背面
    if (total == 2) return CoinThrowResult.shaoYang; // 两背一正
    return CoinThrowResult.shaoYin;                   // 两正一背
  }

  /// 执行完整的六爻起卦
  LiuYaoResult divine() {
    String zhugua = '';   // 主卦二进制
    String biangua = '';  // 变卦二进制
    String dongyao = '';   // 动爻标记

    for (int i = 0; i < 6; i++) {
      final result = tossCoins();
      
      // 根据铜钱结果设置爻值
      int zhuValue; // 主卦爻值
      int bianValue; // 变卦爻值
      
      switch (result) {
        case CoinThrowResult.laoYang: // 老阳→阴（动）
          zhuValue = 1;
          bianValue = 0;
          dongyao += '2'; // 标记为老阳
          break;
        case CoinThrowResult.laoYin: // 老阴→阳（动）
          zhuValue = 0;
          bianValue = 1;
          dongyao += '3'; // 标记为老阴
          break;
        case CoinThrowResult.shaoYang: // 少阳（不动）
          zhuValue = 1;
          bianValue = 1;
          dongyao += '4';
          break;
        case CoinThrowResult.shaoYin: // 少阴（不动）
          zhuValue = 0;
          bianValue = 0;
          dongyao += '4';
          break;
      }
      
      zhugua += zhuValue.toString();
      biangua += bianValue.toString();
    }

    return LiuYaoResult(
      zhugua: zhugua,
      biangua: biangua,
      dongyao: dongyao,
      flag: 6,
      dataTime: _getCurrentTime(),
      dayInGanZhi: _getDayInGanZhi(),
    );
  }

  /// 获取卦象信息
  Map<String, String>? getHexagramInfo(String binary) {
    return LiuShiSiGuaData.getHexagramByBinary(binary);
  }

  /// 获取主卦和变卦信息
  Map<String, Map<String, String>?> getBothHexagrams(LiuYaoResult result) {
    return {
      'zhugua': getHexagramInfo(result.zhugua),
      'biangua': getHexagramInfo(result.biangua),
    };
  }

  /// 获取变爻位置列表
  List<int> getChangingYaoPositions(String dongyao) {
    final positions = <int>[];
    for (int i = 0; i < dongyao.length; i++) {
      if (dongyao[i] == '2' || dongyao[i] == '3') {
        positions.add(i); // 0-based index
      }
    }
    return positions;
  }

  /// 计算变卦
  String calculateBianGua(String zhugua, String dongyao) {
    final buffer = StringBuffer();
    for (int i = 0; i < 6; i++) {
      if (dongyao[i] == '2') {
        // 老阳变阴
        buffer.write('0');
      } else if (dongyao[i] == '3') {
        // 老阴变阳
        buffer.write('1');
      } else {
        buffer.write(zhugua[i]);
      }
    }
    return buffer.toString();
  }

  /// 保存结果
  Future<void> saveResult(LiuYaoResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(result.toJson()));
  }

  /// 加载结果
  Future<LiuYaoResult?> loadResult() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null) return null;
    return LiuYaoResult.fromJson(jsonDecode(jsonStr));
  }

  /// 清除结果
  Future<void> clearResult() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// 获取当前时间字符串
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// 获取日干支（简化版）
  String _getDayInGanZhi() {
    // 这里需要配合日历库获取准确的干支
    // 简化实现
    const tianGan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const diZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    
    final now = DateTime.now();
    // 简化计算（实际需要根据农历计算）
    final dayIndex = now.day % 10;
    final monthIndex = now.month % 12;
    
    return '${tianGan[dayIndex]}${diZhi[monthIndex]}日';
  }

  /// 纳地支（根据卦的五行和爻位）
  static String naDiZhi(String binary, String fiveElements) {
    // 乾宫卦
    if (fiveElements == '金') {
      const patterns = ['子', '寅', '辰', '午', '申', '戌'];
      return _matchPattern(binary, patterns);
    }
    // 坤宫卦
    if (fiveElements == '土') {
      const patterns = ['未', '酉', '亥', '丑', '卯', '巳'];
      return _matchPattern(binary, patterns);
    }
    // 震宫卦
    if (fiveElements == '木') {
      const patterns = ['子', '寅', '卯', '巳', '午', '申'];
      return _matchPattern(binary, patterns);
    }
    // 巽宫卦
    if (fiveElements == '木') {
      const patterns = ['丑', '亥', '酉', '未', '卯', '巳'];
      return _matchPattern(binary, patterns);
    }
    // 坎宫卦
    if (fiveElements == '水') {
      const patterns = ['寅', '辰', '午', '申', '戌', '子'];
      return _matchPattern(binary, patterns);
    }
    // 离宫卦
    if (fiveElements == '火') {
      const patterns = ['卯', '丑', '亥', '未', '酉', '亥'];
      return _matchPattern(binary, patterns);
    }
    // 艮宫卦
    if (fiveElements == '土') {
      const patterns = ['辰', '午', '申', '戌', '子', '寅'];
      return _matchPattern(binary, patterns);
    }
    // 兑宫卦
    if (fiveElements == '金') {
      const patterns = ['未', '巳', '卯', '丑', '亥', '酉'];
      return _matchPattern(binary, patterns);
    }
    return '子丑寅卯辰巳';
  }

  static String _matchPattern(String binary, List<String> patterns) {
    final buffer = StringBuffer();
    for (int i = 0; i < 6; i++) {
      buffer.write(patterns[i]);
    }
    return buffer.toString();
  }

  /// 六亲（根据卦宫五行和爻五行）
  static List<String> getLiuQin(String palace, String naDiZhiResult, String fiveElements) {
    // 六亲：父母、兄弟、子孙、妻财、官鬼
    final wuxing = ['金', '木', '水', '火', '土'];
    final guaIndex = wuxing.indexOf(palace);
    
    // 五行相生相克
    // 金生水、水生木、木生火、火生土、土生金
    // 金克木、木克土、土克水、水克火、火克金
    
    final result = <String>[];
    for (int i = 0; i < 6; i++) {
      final dz = naDiZhiResult[i];
      final dzElement = _getDiZhiElement(dz);
      final dzIndex = wuxing.indexOf(dzElement);
      
      // 计算关系
      if ((dzIndex - guaIndex + 5) % 5 == 1) {
        // 我生者
        result.add('子孙');
      } else if ((dzIndex - guaIndex + 5) % 5 == 2) {
        // 我克者
        result.add('妻财');
      } else if ((dzIndex - guaIndex + 5) % 5 == 3) {
        // 克我者
        result.add('官鬼');
      } else if ((dzIndex - guaIndex + 5) % 5 == 4) {
        // 生我者
        result.add('父母');
      } else {
        // 比和
        result.add('兄弟');
      }
    }
    return result;
  }

  static String _getDiZhiElement(String dz) {
    // 地支五行
    const map = {
      '子': '水', '丑': '土', '寅': '木', '卯': '木',
      '辰': '土', '巳': '火', '午': '火', '未': '土',
      '申': '金', '酉': '金', '戌': '土', '亥': '水',
    };
    return map[dz] ?? '土';
  }
}
