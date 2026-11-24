// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String searchQuery = '';

  final List<Map<String, String>> conversations = [
    {'name': 'صديق Roqksa', 'message': 'أهلاً، كيف حالك؟', 'time': 'الآن'},
    {'name': 'مجتمع الأصدقاء', 'message': 'نلتقي في الغرفة مساءً ❤️', 'time': 'أمس'},
    {'name': 'عضو جديد', 'message': 'تشرفت بمعرفتك', 'time': 'الأحد'},
  ];

  List<Map<String, String>> get filteredConversations {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return conversations;
    return conversations.where((item) {
      return item.values.any((value) => value.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text('الرسائل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                ),
                IconButton(
                  tooltip: 'محادثة جديدة',
                  onPressed: () => _showNotice(context),
                  icon: const Icon(Icons.edit_square),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'ابحث في المحادثات',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF211C31),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: filteredConversations.length,
              separatorBuilder: (_, __) => const Divider(indent: 76, height: 1, color: Colors.white10),
              itemBuilder: (context, index) {
                final item = filteredConversations[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF493568),
                    child: Text(item['name']!.substring(0, 1), style: const TextStyle(color: Color(0xFFE9BD68), fontWeight: FontWeight.bold)),
                  ),
                  title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['message']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60)),
                  trailing: Text(item['time']!, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => _LocalChatScreen(contactName: item['name']!)),
                  ),
                );
              },
            ),
          ),
          if (filteredConversations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text('لا توجد محادثات مطابقة', style: TextStyle(color: Colors.white54)),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'محادثات تجريبية على هذا الجهاز — لم يتم ربط الرسائل بالخادم بعد.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: .4), fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('إنشاء محادثة مع مستخدمين حقيقيين يتطلب ربط الحسابات والخادم.')),
    );
  }
}

class _LocalChatScreen extends StatefulWidget {
  const _LocalChatScreen({required this.contactName});

  final String contactName;

  @override
  State<_LocalChatScreen> createState() => _LocalChatScreenState();
}

class _LocalChatScreenState extends State<_LocalChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<String> messages = ['مرحباً بك في Roqksa 👋'];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _send() {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() => messages.add(value));
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.contactName)),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF3B2B58),
              padding: const EdgeInsets.all(9),
              child: const Text(
                'هذه محادثة محلية تجريبية وليست رسالة مرسلة إلى مستخدم آخر.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) => Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF493568),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(messages[index]),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالة...',
                          filled: true,
                          fillColor: const Color(0xFF211C31),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _send,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
