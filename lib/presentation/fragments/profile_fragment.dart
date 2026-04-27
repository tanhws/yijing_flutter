import 'package:flutter/material.dart';

class ProfileFragment extends StatelessWidget {
  const ProfileFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: Colors.amber[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 头像区域
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.amber[100],
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.amber[700],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '易经学者',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '探索古老智慧的奥秘',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // 功能列表
              _buildMenuSection('历史记录', [
                _MenuItem(Icons.history, '起卦记录', () {}),
                _MenuItem(Icons.bookmark, '收藏卦象', () {}),
              ]),
              
              _buildMenuSection('工具', [
                _MenuItem(Icons.calculate, '四柱计算', () {}),
                _MenuItem(Icons.auto_stories, '卦象速查', () {}),
              ]),
              
              _buildMenuSection('关于', [
                _MenuItem(Icons.info, '关于我们', () => _showAboutDialog(context)),
                _MenuItem(Icons.help, '使用帮助', () {}),
                _MenuItem(Icons.settings, '设置', () {}),
              ]),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: Colors.amber[700]),
                    title: Text(item.title),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('关于'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('易经起卦 App'),
            SizedBox(height: 8),
            Text('版本：1.0.0'),
            SizedBox(height: 8),
            Text('一款基于易经六爻的起卦应用，'
                '包含六爻起卦、四柱八字、卦象搜索等功能。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem(this.icon, this.title, this.onTap);
}
