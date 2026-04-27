import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/liu_shisigua_data.dart';
import '../../data/models/liuyao_model.dart';
import '../../data/services/liuyao_service.dart';
import '../screens/detail_screen.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> with SingleTickerProviderStateMixin {
  final LiuYaoService _service = LiuYaoService();
  
  late AnimationController _coinAnimController;
  late Animation<double> _coinAnimation;
  
  List<int> _coinResults = [0, 0, 0];
  bool _isAnimating = false;
  int _throwCount = 0;
  
  LiuYaoResult? _result;
  Map<String, Map<String, String>?>? _hexagrams;
  List<int> _changingPositions = [];
  List<String> _leftLiuQin = [];
  List<String> _leftLiuShen = [];
  List<String> _naDiZhi = [];
  
  final List<String> _liuShen = ['青龙', '朱雀', '勾陈', '螣蛇', '白虎', '玄武'];
  
  @override
  void initState() {
    super.initState();
    _coinAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _coinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _coinAnimController, curve: Curves.easeInOut),
    );
    _coinAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isAnimating = false);
      }
    });
    
    _loadSavedResult();
  }

  Future<void> _loadSavedResult() async {
    final saved = await _service.loadResult();
    if (saved != null && saved.flag >= 6) {
      _applyResult(saved);
    }
  }

  void _applyResult(LiuYaoResult result) {
    final hexagrams = _service.getBothHexagrams(result);
    final changing = _service.getChangingYaoPositions(result.dongyao);
    
    if (hexagrams['zhugua'] != null) {
      final wuxin = hexagrams['zhugua']!['wuxin']!.substring(0, 1);
      final naDi = LiuYaoService.naDiZhi(result.zhugua, wuxin);
      _naDiZhi = naDi.split('');
      _leftLiuQin = LiuYaoService.getLiuQin(wuxin, naDi, wuxin);
      _leftLiuShen = _liuShen;
    }
    
    setState(() {
      _result = result;
      _hexagrams = hexagrams;
      _changingPositions = changing;
      _throwCount = 6;
      _coinResults = [1, 1, 1];
    });
  }

  @override
  void dispose() {
    _coinAnimController.dispose();
    super.dispose();
  }

  void _throwCoins() async {
    if (_isAnimating || _throwCount >= 6) return;
    
    setState(() => _isAnimating = true);
    
    final random = Random();
    setState(() {
      _coinResults = List.generate(3, (_) => random.nextInt(2));
    });
    
    await _coinAnimController.forward(from: 0);
    
    final result = _service.divine();
    _applyResult(result);
    await _service.saveResult(result);
  }

  void _reset() async {
    await _service.clearResult();
    setState(() {
      _throwCount = 0;
      _result = null;
      _hexagrams = null;
      _changingPositions = [];
      _leftLiuQin = [];
      _leftLiuShen = [];
      _naDiZhi = [];
      _coinResults = [0, 0, 0];
    });
  }

  void _viewDetail() {
    if (_result == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => DetailScreen(
          zhugua: _result!.zhugua,
          biangua: _result!.biangua,
          dongyao: _result!.dongyao,
          timeText: _result!.dataTime,
          dayInGanZhi: _result!.dayInGanZhi,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('六爻起卦'),
        backgroundColor: const Color(0xFF8B4513),
        actions: [
          if (_throwCount > 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
            ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFF8DC),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部时间
              _buildTimeHeader(),
              
              // 卦盘区域
              Expanded(
                child: _buildHexagramBoard(),
              ),
              
              // 硬币区域
              _buildCoinArea(),
              
              // 按钮
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeHeader() {
    return GestureDetector(
      onTap: _throwCount >= 6 ? _viewDetail : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4),
        color: const Color(0xFFDEB887),
        child: Column(
          children: [
            Text(
              _result != null ? _result!.dayInGanZhi : '',
              style: const TextStyle(fontSize: 14, color: Color(0xFF8B4513)),
            ),
            Text(
              _result != null ? _result!.dataTime : '请摇卦',
              style: const TextStyle(fontSize: 18, color: Color(0xFF8B4513), fontWeight: FontWeight.bold),
            ),
            if (_throwCount >= 6)
              const Text(
                '点击查看卦象详情 >',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHexagramBoard() {
    return Card(
      margin: const EdgeInsets.all(4),
      color: const Color(0xFFFFF8DC),
      elevation: 0,
      child: _result == null
          ? const Center(child: Text('请点击下方"摇一爻"开始起卦'))
          : Column(
              children: [
                // 主卦区域
                Expanded(child: _buildSingleHexagramSection('主卦', true)),
                const Divider(height: 1, color: Color(0xFF8B4513)),
                // 变卦区域
                Expanded(child: _buildSingleHexagramSection('变卦', false)),
              ],
            ),
    );
  }

  Widget _buildSingleHexagramSection(String title, bool isMain) {
    return Column(
      children: [
        // 标题行
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          color: const Color(0xFFDEB887).withOpacity(0.3),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              if (isMain && _hexagrams?['zhugua'] != null) ...[
                Text(_hexagrams!['zhugua']!['guaxiang'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(_hexagrams!['zhugua']!['gong'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 4),
                Text(_hexagrams!['zhugua']!['wuxin'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.orange)),
              ] else if (!isMain && _hexagrams?['biangua'] != null) ...[
                Text(_hexagrams!['biangua']!['guaxiang'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(_hexagrams!['biangua']!['gong'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 4),
                Text(_hexagrams!['biangua']!['wuxin'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.orange)),
              ],
              const SizedBox(width: 8),
            ],
          ),
        ),
        // 表头
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          color: Colors.brown.withOpacity(0.1),
          child: const Row(
            children: [
              SizedBox(width: 8),
              SizedBox(width: 45, child: Center(child: Text('六神', style: TextStyle(fontSize: 10)))),
              SizedBox(width: 35, child: Center(child: Text('地支', style: TextStyle(fontSize: 10)))),
              Expanded(child: Center(child: Text('主卦', style: TextStyle(fontSize: 10)))),
              SizedBox(width: 35, child: Center(child: Text('动爻', style: TextStyle(fontSize: 10)))),
              SizedBox(width: 45, child: Center(child: Text('六亲', style: TextStyle(fontSize: 10)))),
              SizedBox(width: 8),
            ],
          ),
        ),
        // 六爻行
        Expanded(
          child: _buildSixYaoRows(isMain),
        ),
      ],
    );
  }

  Widget _buildSixYaoRows(bool isMain) {
    final binary = isMain ? _result!.zhugua : _result!.biangua;
    final liuShen = _leftLiuShen;
    final liuQin = _leftLiuQin;
    
    return Row(
      children: [
        const SizedBox(width: 8),
        // 六神列
        SizedBox(
          width: 45,
          child: Column(
            children: List.generate(6, (i) => Expanded(
              child: Center(
                child: Text(
                  liuShen.isNotEmpty ? liuShen[5-i] : '',
                  style: TextStyle(fontSize: 11, color: _getLiuShenColor(5-i)),
                ),
              ),
            )),
          ),
        ),
        // 地支列
        SizedBox(
          width: 35,
          child: Column(
            children: List.generate(6, (i) => Expanded(
              child: Center(
                child: Text(
                  _naDiZhi.isNotEmpty ? _naDiZhi[5-i] : '',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            )),
          ),
        ),
        // 爻列
        Expanded(
          child: Column(
            children: List.generate(6, (index) {
              final reversedIndex = 5 - index;
              final isYang = binary[reversedIndex] == '1';
              return Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 35,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isYang ? Colors.black : Colors.white,
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
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
              );
            }),
          ),
        ),
        // 动爻列（空心圆圈）
        SizedBox(
          width: 35,
          child: Column(
            children: List.generate(6, (index) {
              final reversedIndex = 5 - index;
              final isChanging = _changingPositions.contains(reversedIndex);
              return Expanded(
                child: Center(
                  child: isChanging
                      ? Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                        )
                      : Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                        ),
                ),
              );
            }),
          ),
        ),
        // 六亲列
        SizedBox(
          width: 45,
          child: Column(
            children: List.generate(6, (i) => Expanded(
              child: Center(
                child: Text(
                  liuQin.isNotEmpty ? liuQin[5-i] : '',
                  style: const TextStyle(fontSize: 11, color: Colors.orange),
                ),
              ),
            )),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Color _getLiuShenColor(int index) {
    const colors = [Colors.green, Colors.red, Colors.brown, Colors.purple, Colors.grey, Colors.blue];
    return colors[index % colors.length];
  }

  Widget _buildCoinArea() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _coinAnimation,
            builder: (context, child) {
              final angle = _isAnimating ? _coinAnimation.value * 2 * pi : 0.0;
              return Transform.rotate(
                angle: angle,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber[100],
                    border: Border.all(color: const Color(0xFF8B4513), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _coinResults[index] == 1 ? '正' : '背',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: ElevatedButton(
        onPressed: _throwCount < 6 && !_isAnimating ? _throwCoins : _reset,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B4513),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
        ),
        child: Text(
          _throwCount < 6 ? '摇一爻 (${_throwCount + 1}/6)' : '重新起卦',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
