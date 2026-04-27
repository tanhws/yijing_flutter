import 'package:flutter/material.dart';
import '../../data/models/liu_shisigua_data.dart';
import '../../data/services/liuyao_service.dart';

class SearchFragment extends StatefulWidget {
  const SearchFragment({super.key});

  @override
  State<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  final LiuYaoService _service = LiuYaoService();
  
  String _inputText = '';
  Map<String, String>? _hexagramInfo;
  Map<int, String>? _yaoCiInfo;
  
  // 爻辞显示
  String _yiYao = '';
  String _erYao = '';
  String _sanYao = '';
  String _siYao = '';
  String _wuYao = '';
  String _liuYao = '';

  void _addYao(String value) {
    if (_inputText.length >= 6) return;
    
    setState(() {
      _inputText += value;
    });
  }

  void _deleteLast() {
    if (_inputText.isEmpty) return;
    
    setState(() {
      _inputText = _inputText.substring(0, _inputText.length - 1);
      _hexagramInfo = null;
      _yaoCiInfo = null;
      _yiYao = _erYao = _sanYao = _siYao = _wuYao = _liuYao = '';
    });
  }

  void _confirm() {
    if (_inputText.length != 6) return;
    
    final info = _service.getHexagramInfo(_inputText);
    if (info != null) {
      setState(() {
        _hexagramInfo = info;
        // 这里需要获取爻辞，实际应该从liuYaoYaoCi获取
        _yiYao = '初六';
        _erYao = '六二';
        _sanYao = '六三';
        _siYao = '六四';
        _wuYao = '六五';
        _liuYao = '上六';
      });
    }
  }

  void _reset() {
    setState(() {
      _inputText = '';
      _hexagramInfo = null;
      _yaoCiInfo = null;
      _yiYao = _erYao = _sanYao = _siYao = _wuYao = _liuYao = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('查卦'),
        backgroundColor: const Color(0xFF8B4513),
      ),
      body: Container(
        color: const Color(0xFFFFF8DC),
        child: SafeArea(
          child: Column(
            children: [
              // 输入区域
              _buildInputArea(),
              
              // 爻辞显示
              Expanded(
                child: _buildYaoCiArea(),
              ),
              
              // 按钮
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: const Color(0xFFDEB887),
      child: Column(
        children: [
          // 卦名显示
          Text(
            _hexagramInfo?['guaxiang'] ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 8),
          
          // 二进制输入显示 + 按钮
          Row(
            children: [
              // 输入显示
              Container(
                width: 200,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF8B4513)),
                ),
                child: Center(
                  child: Text(
                    _inputText.isEmpty ? '请点击右侧按钮输入' : _inputText,
                    style: TextStyle(
                      fontSize: 18,
                      color: _inputText.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // 阴按钮
              ElevatedButton(
                onPressed: () => _addYao('0'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF8B4513),
                ),
                child: const Text('阴'),
              ),
              const SizedBox(width: 4),
              
              // 阳按钮
              ElevatedButton(
                onPressed: () => _addYao('1'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF8B4513),
                ),
                child: const Text('阳'),
              ),
              const SizedBox(width: 4),
              
              // 删除按钮
              ElevatedButton(
                onPressed: _deleteLast,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  foregroundColor: Colors.red,
                ),
                child: const Text('删除'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYaoCiArea() {
    return Card(
      margin: const EdgeInsets.all(8),
      color: const Color(0xFFFFF8DC),
      elevation: 0,
      child: Column(
        children: [
          // 卦象显示
          Expanded(
            child: Row(
              children: [
                // 右侧爻象
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final reversedIndex = 5 - index;
                      final yaoValue = reversedIndex < _inputText.length 
                          ? _inputText[reversedIndex] 
                          : '';
                      return _buildYaoImage(yaoValue == '1');
                    }),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: Color(0xFF8B4513)),
          
          // 爻辞显示
          if (_hexagramInfo != null) ...[
            _buildYaoCiRow('上六', _liuYao),
            _buildYaoCiRow('六五', _wuYao),
            _buildYaoCiRow('六四', _siYao),
            _buildYaoCiRow('六三', _sanYao),
            _buildYaoCiRow('六二', _erYao),
            _buildYaoCiRow('初六', _yiYao),
          ],
        ],
      ),
    );
  }

  Widget _buildYaoImage(bool isYang) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: 80,
        height: 8,
        decoration: BoxDecoration(
          color: isYang ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildYaoCiRow(String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _reset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('重置'),
          ),
          const SizedBox(width: 32),
          ElevatedButton(
            onPressed: _inputText.length == 6 ? _confirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
