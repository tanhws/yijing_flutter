import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/liu_shisigua_data.dart';
import '../../data/models/liuyao_model.dart';
import '../../data/services/liuyao_service.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> with TickerProviderStateMixin {
  final LiuYaoService _service = LiuYaoService();
  
  // 动画控制器
  late AnimationController _coinAnimController;
  late Animation<double> _coinAnimation;
  
  // 硬币状态
  List<int> _coinResults = [0, 0, 0];
  bool _isAnimating = false;
  int _throwCount = 0;
  
  // 结果
  LiuYaoResult? _result;
  Map<String, Map<String, String>?>? _hexagrams;
  List<int> _changingPositions = [];
  List<String> _leftLiuQin = [];
  List<String> _rightLiuQin = [];
  List<String> _leftLiuShen = [];
  
  // 六神
  final List<String> _liuShen = ['青龙', '朱雀', '勾陈', '螣蛇', '白虎', '玄武'];
  
  @override
  void initState() {
    super.initState();
    _coinAnimController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    
    // 计算六亲和六神
    if (hexagrams['zhugua'] != null) {
      final naDiZhi = LiuYaoService.naDiZhi(result.zhugua, hexagrams['zhugua']!['wuxin']!);
      _leftLiuQin = LiuYaoService.getLiuQin(
        hexagrams['zhugua']!['wuxin']!.substring(0, 1),
        naDiZhi,
        hexagrams['zhugua']!['wuxin']!,
      );
      _rightLiuQin = LiuYaoService.getLiuQin(
        hexagrams['zhugua']!['wuxin']!.substring(0, 1),
        naDiZhi,
        hexagrams['zhugua']!['wuxin']!,
      );
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
    
    // 随机生成硬币结果
    final random = Random();
    setState(() {
      _coinResults = List.generate(3, (_) => random.nextInt(2));
    });
    
    // 播放动画
    await _coinAnimController.forward(from: 0);
    
    // 执行起卦（每次都重新起完整的卦，模拟用户摇6次）
    final result = _service.divine();
    _applyResult(result);
    
    // 保存结果
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
      _rightLiuQin = [];
      _leftLiuShen = [];
      _coinResults = [0, 0, 0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('六爻起卦'),
        backgroundColor: const Color(0xFF8B4513), // 棕色主题
        actions: [
          if (_throwCount > 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
            ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFF8DC), // 米色背景
        child: SafeArea(
          child: Column(
            children: [
              // 顶部时间显示
              _buildHeader(),
              
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFFDEB887),
      child: Center(
        child: Text(
          _result != null ? '${_result!.dataTime}  ${_result!.dayInGanZhi}' : '请摇卦',
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF8B4513),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHexagramBoard() {
    return Card(
      margin: const EdgeInsets.all(8),
      color: const Color(0xFFFFF8DC),
      elevation: 0,
      child: Column(
        children: [
          // 表头
          _buildBoardHeader(),
          const Divider(height: 1, color: Color(0xFF8B4513)),
          // 六爻行
          Expanded(
            child: _result == null
                ? const Center(child: Text('点击下方"摇一爻"开始起卦'))
                : _buildSixYaoRows(),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardHeader() {
    return Container(
      color: const Color(0xFFDEB887).withOpacity(0.3),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: const Row(
        children: [
          Expanded(flex: 1, child: Center(child: Text('六神', style: TextStyle(fontSize: 12)))),
          Expanded(flex: 2, child: Center(child: Text('主卦', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))),
          Expanded(flex: 1, child: Center(child: Text('动爻', style: TextStyle(fontSize: 12)))),
          Expanded(flex: 2, child: Center(child: Text('六亲', style: TextStyle(fontSize: 12)))),
        ],
      ),
    );
  }

  Widget _buildSixYaoRows() {
    return Column(
      children: List.generate(6, (index) {
        final reversedIndex = 5 - index; // 从上爻开始
        return _buildYaoRow(reversedIndex);
      }),
    );
  }

  Widget _buildYaoRow(int index) {
    final zhuguaYao = _result!.zhugua[index];
    final bianguaYao = _result!.biangua[index];
    final dongyaoMark = _result!.dongyao[index];
    final isChanging = dongyaoMark == '2' || dongyaoMark == '3';
    
    return Container(
      height: 44,
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
                _leftLiuShen.isNotEmpty ? _leftLiuShen[index] : '',
                style: TextStyle(
                  fontSize: 12,
                  color: _getLiuShenColor(index),
                ),
              ),
            ),
          ),
          // 主卦爻
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 左卦
                _buildYaoImage(zhuguaYao == '1', isChangable: false),
                const SizedBox(width: 8),
                // 右卦
                _buildYaoImage(bianguaYao == '1', isChangable: false),
              ],
            ),
          ),
          // 动爻标记
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                isChanging ? '⚡' : '',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          // 六亲
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                _leftLiuQin.isNotEmpty ? _leftLiuQin[index] : '',
                style: const TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYaoImage(bool isYang, {bool isChangable = false}) {
    return Container(
      width: 30,
      height: 6,
      decoration: BoxDecoration(
        color: isYang ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(2),
      ),
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
      padding: const EdgeInsets.all(16),
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
