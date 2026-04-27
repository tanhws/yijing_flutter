import 'package:flutter/material.dart';
import '../../data/models/liu_shisigua_data.dart';

class SearchFragment extends StatefulWidget {
  const SearchFragment({super.key});

  @override
  State<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // 初始显示所有卦象
    _searchResults = LiuShiSiGuaData.getAllHexagrams();
  }

  void _search(String query) {
    setState(() {
      _isSearching = true;
      if (query.isEmpty) {
        _searchResults = LiuShiSiGuaData.getAllHexagrams();
      } else {
        _searchResults = LiuShiSiGuaData.searchHexagrams(query);
      }
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('卦象搜索'),
        backgroundColor: Colors.amber[700],
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索卦象名称...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _search,
            ),
          ),
          
          // 搜索结果
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(
                    child: Text('未找到相关卦象'),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final hexagram = _searchResults[index];
                      return _buildHexagramCard(hexagram);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHexagramCard(Map<String, String> hexagram) {
    final name = hexagram['guaxiang'] ?? '';
    final palace = hexagram['gong'] ?? '';
    final wuxin = hexagram['wuxin'] ?? '';
    final shiYao = hexagram['shiyao'] ?? '';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showHexagramDetail(hexagram),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 卦象符号
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _getBaGuaEmoji(name),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 卦象信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTag(palace, Colors.blue),
                        const SizedBox(width: 8),
                        _buildTag(wuxin, Colors.orange),
                        const SizedBox(width: 8),
                        _buildTag('世$shiYao', Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }

  String _getBaGuaEmoji(String name) {
    // 根据卦名返回简单的符号表示
    if (name.contains('乾')) return '☰';
    if (name.contains('坤')) return '☷';
    if (name.contains('震')) return '☳';
    if (name.contains('巽')) return '☴';
    if (name.contains('坎')) return '☵';
    if (name.contains('离')) return '☲';
    if (name.contains('艮')) return '☶';
    if (name.contains('兑')) return '☱';
    return '☯';
  }

  void _showHexagramDetail(Map<String, String> hexagram) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  hexagram['guaxiang'] ?? '',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 卦象符号
                Center(
                  child: Text(
                    _getBaGuaEmoji(hexagram['guaxiang'] ?? ''),
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 信息卡片
                _buildInfoCard('宫位', hexagram['gong'] ?? ''),
                _buildInfoCard('五行', hexagram['wuxin'] ?? ''),
                _buildInfoCard('世爻', hexagram['shiyao'] ?? ''),
                _buildInfoCard('应爻', hexagram['yingyao'] ?? ''),
                
                const SizedBox(height: 24),
                const Text(
                  '卦象解释',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getHexagramText(hexagram['guaxiang'] ?? ''),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getHexagramText(String name) {
    // 简化版卦辞
    final texts = {
      '乾为天': '元亨利贞。初九：潜龙勿用。九二：见龙在田，利见大人。九三：君子终日乾乾，夕惕若厉，无咎。九四：或跃在渊，无咎。九五：飞龙在天，利见大人。上九：亢龙有悔。用九：见群龙无首，吉。',
      '坤为地': '元亨利牝马之贞。君子有攸往，先迷后得主。利西南得朋，东北丧朋。安贞，吉。',
      '天水讼': '有孚，窒。惕中吉。终凶。利见大人，不利涉大川。',
      '火水未济': '小狐汔济，濡其尾，无攸利。',
    };
    return texts[name] ?? '卦辞详细内容请参考《易经》原文。';
  }
}
