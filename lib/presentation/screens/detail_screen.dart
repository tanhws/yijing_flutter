import 'package:flutter/material.dart';
import '../../data/models/liu_shisigua_data.dart';
import '../../data/services/liuyao_service.dart';

class DetailScreen extends StatelessWidget {
  final String zhugua;
  final String biangua;
  final String dongyao;
  final String timeText;
  final String dayInGanZhi;

  const DetailScreen({
    super.key,
    required this.zhugua,
    required this.biangua,
    required this.dongyao,
    required this.timeText,
    required this.dayInGanZhi,
  });

  @override
  Widget build(BuildContext context) {
    final service = LiuYaoService();
    final zhuInfo = service.getHexagramInfo(zhugua);
    final bianInfo = service.getHexagramInfo(biangua);
    final naDiZhi = zhuInfo != null ? LiuYaoService.naDiZhi(zhugua, zhuInfo['wuxin']!.substring(0, 1)) : '';
    final liuQin = zhuInfo != null ? LiuYaoService.getLiuQin(zhuInfo['wuxin']!.substring(0, 1), naDiZhi, zhuInfo['wuxin']!) : <String>[];
    final changingPositions = service.getChangingYaoPositions(dongyao);
    final liuShen = ['青龙', '朱雀', '勾陈', '螣蛇', '白虎', '玄武'];
    
    // 地支五行
    final dizhiWuxing = naDiZhi.split('').map((dz) => _getDiZhiWuXing(dz)).join();

    return Scaffold(
      appBar: AppBar(
        title: const Text('卦象详情'),
        backgroundColor: const Color(0xFF8B4513),
      ),
      body: Container(
        color: const Color(0xFFFFF8DC),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 顶部时间
                Container(
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFFDEB887),
                  child: Column(
                    children: [
                      Text(dayInGanZhi, style: const TextStyle(fontSize: 16)),
                      Text(timeText, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                
                // 主卦卦盘
                _buildHexagramBoard(
                  title: '主卦',
                  binary: zhugua,
                  info: zhuInfo,
                  liuShen: liuShen,
                  naDiZhi: naDiZhi,
                  dizhiWuxing: dizhiWuxing,
                  liuQin: liuQin,
                  changingPositions: changingPositions,
                ),
                
                const Divider(height: 1, color: Color(0xFF8B4513)),
                
                // 变卦卦盘
                _buildHexagramBoard(
                  title: '变卦',
                  binary: biangua,
                  info: bianInfo,
                  liuShen: liuShen,
                  naDiZhi: naDiZhi,
                  dizhiWuxing: dizhiWuxing,
                  liuQin: liuQin,
                  changingPositions: const [],
                ),
                
                const Divider(height: 1, color: Color(0xFF8B4513)),
                
                // 详细信息
                _buildDetailInfo(zhuInfo, naDiZhi, dizhiWuxing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHexagramBoard({
    required String title,
    required String binary,
    required Map<String, String>? info,
    required List<String> liuShen,
    required String naDiZhi,
    required String dizhiWuxing,
    required List<String> liuQin,
    required List<int> changingPositions,
  }) {
    return Column(
      children: [
        // 标题行
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: const Color(0xFFDEB887).withOpacity(0.3),
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 12),
              if (info != null) ...[
                Text(info['guaxiang'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B4513).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${info['gong']} ${info['wuxin']}', style: const TextStyle(fontSize: 12)),
                ),
              ],
            ],
          ),
        ),
        
        // 表头
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          color: Colors.brown.withOpacity(0.1),
          child: const Row(
            children: [
              Expanded(flex: 1, child: Center(child: Text('六神', style: TextStyle(fontSize: 11)))),
              Expanded(flex: 1, child: Center(child: Text('地支', style: TextStyle(fontSize: 11)))),
              Expanded(flex: 2, child: Center(child: Text('爻', style: TextStyle(fontSize: 11)))),
              Expanded(flex: 1, child: Center(child: Text('地支五行', style: TextStyle(fontSize: 11)))),
              Expanded(flex: 1, child: Center(child: Text('六亲', style: TextStyle(fontSize: 11)))),
            ],
          ),
        ),
        
        // 六爻行
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: List.generate(6, (index) {
              final reversedIndex = 5 - index;
              final isYang = binary[reversedIndex] == '1';
              final isChanging = changingPositions.contains(reversedIndex);
              final liushenColor = _getLiuShenColor(reversedIndex);
              
              return Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isChanging ? Colors.red.withOpacity(0.1) : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(color: Colors.brown.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    // 六神
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          liuShen[reversedIndex],
                          style: TextStyle(fontSize: 12, color: liushenColor),
                        ),
                      ),
                    ),
                    // 地支
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          naDiZhi.isNotEmpty ? naDiZhi[reversedIndex] : '',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    // 爻
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 左爻
                            Container(
                              width: 35,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isYang ? Colors.black : Colors.white,
                                border: Border.all(color: Colors.black, width: 1.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // 间隙
                            const SizedBox(width: 4),
                            // 右爻
                            Container(
                              width: 35,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isYang ? Colors.black : Colors.white,
                                border: Border.all(color: Colors.black, width: 1.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 地支五行
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          dizhiWuxing.isNotEmpty ? dizhiWuxing[reversedIndex] : '',
                          style: TextStyle(fontSize: 12, color: _getWuXingColor(dizhiWuxing.isNotEmpty ? dizhiWuxing[reversedIndex] : '')),
                        ),
                      ),
                    ),
                    // 六亲
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          liuQin.isNotEmpty ? liuQin[reversedIndex] : '',
                          style: const TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInfo(Map<String, String>? info, String naDiZhi, String dizhiWuxing) {
    if (info == null) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('详细信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildInfoRow('卦名', info['guaxiang'] ?? ''),
          _buildInfoRow('卦宫', info['gong'] ?? ''),
          _buildInfoRow('卦五行', info['wuxin'] ?? ''),
          _buildInfoRow('世爻', info['shiyao'] ?? ''),
          _buildInfoRow('应爻', info['yingyao'] ?? ''),
          _buildInfoRow('纳地支', naDiZhi),
          _buildInfoRow('地支五行', dizhiWuxing),
          const SizedBox(height: 8),
          const Text('卦象解释', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            _getHexagramText(info['guaxiang'] ?? ''),
            style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label：',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLiuShenColor(int index) {
    const colors = [Colors.green, Colors.red, Colors.brown, Colors.purple, Colors.grey, Colors.blue];
    return colors[index % colors.length];
  }

  String _getDiZhiWuXing(String dz) {
    const map = {
      '子': '水', '丑': '土', '寅': '木', '卯': '木',
      '辰': '土', '巳': '火', '午': '火', '未': '土',
      '申': '金', '酉': '金', '戌': '土', '亥': '水',
    };
    return map[dz] ?? '土';
  }

  Color _getWuXingColor(String wx) {
    switch (wx) {
      case '金': return Colors.grey;
      case '木': return Colors.green;
      case '水': return Colors.blue;
      case '火': return Colors.red;
      case '土': return Colors.brown;
      default: return Colors.black;
    }
  }

  String _getHexagramText(String name) {
    final texts = {
      '乾为天': '元亨利贞。初九：潜龙勿用。九二：见龙在田，利见大人。九三：君子终日乾乾，夕惕若厉，无咎。九四：或跃在渊，无咎。九五：飞龙在天，利见大人。上九：亢龙有悔。用九：见群龙无首，吉。',
      '坤为地': '坤：元，亨，利牝马之贞。君子有攸往，先迷后得主。利西南得朋，东北丧朋。安贞，吉。',
    };
    return texts[name] ?? '卦辞详细内容请参考《易经》原文。';
  }
}
