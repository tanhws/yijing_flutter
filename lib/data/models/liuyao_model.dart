import 'package:flutter/material.dart';

/// 六爻起卦结果模型
class LiuYaoResult {
  final String zhugua;      // 主卦二进制
  final String biangua;      // 变卦二进制
  final String dongyao;      // 动爻标识 (2=老阳变阴, 3=老阴变阳, 4=少阳/少阴不动)
  final int flag;            // 当前摇到第几爻
  final String dataTime;     // 时间
  final String dayInGanZhi;  // 日干支

  LiuYaoResult({
    required this.zhugua,
    required this.biangua,
    required this.dongyao,
    required this.flag,
    required this.dataTime,
    required this.dayInGanZhi,
  });

  Map<String, dynamic> toJson() => {
    'zhugua': zhugua,
    'biangua': biangua,
    'dongyao': dongyao,
    'flag': flag,
    'dataTime': dataTime,
    'DayInGanZhi': dayInGanZhi,
  };

  factory LiuYaoResult.fromJson(Map<String, dynamic> json) => LiuYaoResult(
    zhugua: json['zhugua'] ?? '',
    biangua: json['biangua'] ?? '',
    dongyao: json['dongyao'] ?? '',
    flag: json['flag'] ?? 0,
    dataTime: json['dataTime'] ?? '',
    dayInGanZhi: json['DayInGanZhi'] ?? '',
  );
}

/// 硬币投掷结果
enum CoinThrowResult {
  laoYang,   // 三正面 → 老阳，变阴
  shaoYin,   // 两正一背 → 少阴，不动
  shaoYang,  // 两背一正 → 少阳，不动
  laoYin,    // 三背面 → 老阴，变阳
}

/// 爻位类型
enum YaoType {
  yang,    // 阳爻
  yin,     // 阴爻
  laoYang, // 老阳（动，变阴）
  laoYin,  // 老阴（动，变阳）
}

/// 单个爻
class Yao {
  final int position;  // 位置 1-6
  final YaoType type;
  final int binaryValue; // 0或1

  Yao({required this.position, required this.type, required this.binaryValue});
}

/// 六爻完整对象
class Hexagram6 {
  final String name;           // 卦名
  final String binary;          // 二进制值
  final String palace;          // 宫
  final String fiveElements;    // 五行
  final String shiYao;          // 世爻位置
  final String yingYao;         // 应爻位置
  final List<Yao> yaoList;      // 六爻列表

  Hexagram6({
    required this.name,
    required this.binary,
    required this.palace,
    required this.fiveElements,
    required this.shiYao,
    required this.yingYao,
    required this.yaoList,
  });
}
