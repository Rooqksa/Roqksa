// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  static const Color _background = Color(0xFF15111F);
  static const Color _surface = Color(0xFF211C31);
  static const Color _purple = Color(0xFF493568);
  static const Color _gold = Color(0xFFE9BD68);

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final List<Map<String, dynamic>> conversations = [
    {
      'name': 'صديق Roqksa',
      'message': 'أهلاً، كيف حالك؟',
      'time': 'الآن',
      'unread': 2,
      'online': true,
      'avatar': 'ص',
    },
    {
      'name': 'مجتمع الأصدقاء',
      'message': 'نلتقي في الغرفة مساءً ❤️',
      'time': 'أمس',
      'unread': 0,
      'online': false,
      'avatar': 'م',
    },
    {
      'name': 'عضو جديد',
      'message': 'تشرفت بمعرفتك',
      'time': 'الأحد',
      'unread': 0,
      'online': true,
      'avatar': 'ع',
    },
  ];

  List<Map<String, dynamic>> get filteredConversations {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return conversations;
    return conversations.where((item) {
      return item['name'].toString().toLowerCase().contains(query) ||
          item['message'].toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: _background,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الرسائل',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'تواصل مع أصدقائك',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: _purple.withValues(alpha: .35),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: _gold.withValues(alpha: .25)),
                      ),
                      child: IconButton(
                        tooltip: 'محادثة جديدة',
                        onPressed: () => _showNotice(context),
                        icon: const Icon(Icons.edit_square_rounded, color: _gold),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => searchQuery = value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'ابحث في المحادثات',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: _gold),
                    suffixIcon: searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'مسح البحث',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => searchQuery = '');
                            },
                            icon: const Icon(Icons.close, color: Colors.white54),
                          ),
                    filled: true,
                    fillColor: _surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: .05),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: const BorderSide(color: _gold, width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: filteredConversations.isEmpty
                    ? _buildEmptySearch()
                    : ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        itemCount: filteredConversations.length,
                        separatorBuilder: (_, __) => Divider(
                          indent: 78,
                          height: 1,
                          color: Colors.white.withValues(alpha: .07),
                        ),
                        itemBuilder: (context, index) {
                          final item = filteredConversations[index];
                          return _buildConversationTile(item);
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 5, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: .35),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'محادثات تجريبية على هذا الجهاز — لم يتم ربط الخادم بعد.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .4),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> item) {
    final int unread = item['unread'] as int;
    final bool online = item['online'] as bool;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => item['unread'] = 0);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _LocalChatScreen(
                contactName: item['name'].toString(),
                isOnline: online,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: _purple,
                    child: Text(
                      item['avatar'].toString(),
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (online)
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFF42D392),
                          shape: BoxShape.circle,
                          border: Border.all(color: _background, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['message'].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unread > 0 ? Colors.white70 : Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item['time'].toString(),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 7),
                  if (unread > 0)
                    Container(
                      constraints:
                          const BoxConstraints(minWidth: 19, minHeight: 19),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: const BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unread.toString(),
                        style: const TextStyle(
                          color: Color(0xFF211C31),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 19),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 48, color: Colors.white.withValues(alpha: .3)),
            const SizedBox(height: 12),
            const Text(
              'لا توجد محادثات مطابقة',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'جرّب البحث باسم آخر',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'إنشاء محادثة مع مستخدمين حقيقيين يتطلب ربط الحسابات والخادم.',
        ),
      ),
    );
  }
}

class _LocalChatScreen extends StatefulWidget {
  const _LocalChatScreen({
    required this.contactName,
    required this.isOnline,
  });

  final String contactName;
  final bool isOnline;

  @override
  State<_LocalChatScreen> createState() => _LocalChatScreenState();
}

class _LocalChatScreenState extends State<_LocalChatScreen> {
  static const Color _background = Color(0xFF15111F);
  static const Color _surface = Color(0xFF211C31);
  static const Color _purple = Color(0xFF493568);
  static const Color _gold = Color(0xFFE9BD68);

  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> messages = [
    {
      'text': 'مرحباً بك في Roqksa 👋',
      'time': 'الآن',
      'sender': 'other',
    },
  ];

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final value = controller.text.trim();
    if (value.isEmpty) return;

    setState(() {
      messages.add({
        'text': value,
        'time': TimeOfDay.now().format(context),
        'sender': 'me',
      });
    });
    controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _background,
          foregroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: _purple,
                child: Text(
                  widget.contactName.isEmpty
                      ? '?'
                      : widget.contactName.characters.first,
                  style: const TextStyle(
                    color: _gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contactName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isOnline ? 'متصل الآن' : 'غير متصل',
                      style: TextStyle(
                        color: widget.isOnline
                            ? const Color(0xFF42D392)
                            : Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: _purple.withValues(alpha: .55),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: const Text(
                'هذه محادثة محلية تجريبية وليست رسالة مرسلة إلى مستخدم آخر.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final bool isMe = message['sender'] == 'me';

                  return Align(
                    alignment:
                        isMe ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .76,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.fromLTRB(14, 9, 14, 7),
                      decoration: BoxDecoration(
                        color: isMe ? _purple : _surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(17),
                          topRight: const Radius.circular(17),
                          bottomLeft: Radius.circular(isMe ? 5 : 17),
                          bottomRight: Radius.circular(isMe ? 17 : 5),
                        ),
                        border: Border.all(
                          color: isMe
                              ? _gold.withValues(alpha: .12)
                              : Colors.white.withValues(alpha: .05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['text'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              message['time'] ?? '',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .45),
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 7, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالة...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: _surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide:
                                const BorderSide(color: _gold, width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        tooltip: 'إرسال',
                        onPressed: _send,
                        color: _background,
                        icon: const Icon(Icons.send_rounded),
                      ),
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
