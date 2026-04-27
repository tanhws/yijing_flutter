import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/liu_shisigua_data.dart';
import '../../data/models/liuyao_model.dart';
import '../../data/services/liuyao_service.dart';

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
  List<String> _rightLiuQin = [];
  List<String> _leftLiuShen = [];
  List<String> _rightLiuShen = [];
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
      _rightLiuQin = LiuYaoService.getLiuQin(wuxin, naDi, wuxin);
      _leftLiuShen = _liuShen;
      _rightLiuShen = _liuShen;
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
      _rightLiuQin = [];
      _leftLiuShen = [];
      _rightLiuShen = [];
      _naDiZhi = [];
      _coinResults = [0, 0, 0];
    });
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
    return Container(
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
        ],
      ),
    );
  }

  Widget _buildHexagramBoard() {
    return Card(
      margin: const EdgeInsets.all(4),
      color: const Color(0xFFFFF8DC),
      elevation: 0,
      child: Column(
        children: [
          // 卦名行
          _buildHexagramNameRow(),
          const Divider(height: 1, color: Color(0xFF8B4513)),
          
          // 左卦盘（主卦）
          Expanded(
            child: _result == null
                ? const Center(child: Text('请点击下方"摇一爻"开始起卦'))
                : _buildLeftBoard(),
          ),
          
          const Divider(height: 1, color: Color(0xFF8B4513)),
          
          // 右卦盘（变卦）
          Expanded(
            child: _buildRightBoard(),
          ),
        ],
      ),
    );
  }

  Widget _buildHexagramNameRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: const Color(0xFFDEB887).withOpacity(0.3),
      child: Row(
        children: [
          const SizedBox(width: 60),
          Expanded(
            child: Text(
              _hexagrams?['zhugua']?['guaxiang'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Text(
              _hexagrams?['biangua']?['guaxiang'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildLeftBoard() {
    return Row(
      children: [
        // 六神列
        SizedBox(
          width: 50,
          child: Column(
            children: List.generate(6, (i) => Expanded(
              child: Center(
                child: Text(
                  _leftLiuShen.isNotEmpty ? _leftLiuShen[5-i] : '',
                  style: TextStyle(fontSize: 12, color: _getLiuShenColor(5-i)),
                ),
              ),
            )),
          ),
        ),
        // 地支行
        SizedBox(
          width: 50,
          child: Column(
            children: List.generate(6, (i) => Expanded(
              child: Center(
                child: Text(
                  _naDiZhi.isNotEmpty ? _naDiZhi[5-i] : '',
                  style: const TextStyle(fontSize: 12),
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
              final isYang = _result!.zhugua[reversedIndex] == '1';
              return Expanded(
                child: Center(
                  child: Container(
                    width: 80,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isYang ? Colors.black : Colors.white,
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        // 动爻列
        SizedBox(
          width: 30,
          child: Column(
            children: List.generate(6, (index) {
              final reversedIndex = 5 - index;
              final isChanging = _changingPositions.contains(reversedIndex);
              return Expanded(
                child: Center(
                  child: Text(
                    isChanging ? '〇' : '',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              );
            }),
          ),
        ),
        // 六亲列
        SizedBox(
          width: 50,
          child: Column(
            children: List.generate(6, (i) => Expanded(
              child: Center(
                child: Text(
                  _leftLiuQin.isNotEmpty ? _leftLiuQin[5-i] : '',
                  style: const TextStyle(fontSize: 11, color: Colors.orange),
                ),
              ),
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildRightBoard() {
    return Row(
      children: [
        // 六神列
        SizedBox(
          width: 50,
          child: Column(
            children: List.generate(6, (i) => Expanded(
              child: Center(
                child: Text(
                  _rightLiuShen.isNotEmpty ? _rightLiuShen[5-i] : '',
                  style: TextStyle(fontSize: 12, color: _getLiuShenColor(5-i)),
                ),
              ),
            )),
          ),
        ),
        // 地支行
        SizedBox(
          width: 50,
          child: Column(
            children: List.generate(6, (i) => Expanded(
              child: Center(
                child: Text(
                  _naDiZhi.isNotEmpty ? _naDiZhi[5-i] : '',
                  style: const TextStyle(fontSize: 12),
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
              final isYang = _result!.biangua[reversedIndex] == '1';
              return Expanded(
                child: Center(
                  child: Container(
                    width: 80,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isYang ? Colors.black : Colors.white,
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        // 动爻列（空白）
        const SizedBox(width: 30),
        // 六亲列
        SizedBox(
          width: 50,
          child: Column(
            children: List.generate(6, (i) => Expanded(
              child: Center(
                child: Text(
                  _rightLiuQin.isNotEmpty ? _rightLiuQin[5-i] : '',
                  style: const TextStyle(fontSize: 11, color: Colors.orange),
                ),
              ),
            )),
          ),
        ),
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
