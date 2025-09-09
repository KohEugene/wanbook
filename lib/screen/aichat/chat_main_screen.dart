import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanbook/provider/user_provider.dart';
import 'package:wanbook/provider/question_provider.dart';
import 'package:wanbook/screen/aichat/chat_screen.dart';

class ChatMainScreen extends StatefulWidget {
  final String title;

  const ChatMainScreen({super.key, required this.title});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> hintQuestions = [];

  int chatClick = 0;

  String? communityHint;
  bool _loadingCommunity = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatClickAndFetchQuestions();
      _loadCommunityRandomQuestion(); 
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadChatClickAndFetchQuestions() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.userId)
        .collection('reading_books')
        .doc(widget.title);

    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      chatClick = (data['chat_click'] ?? 0) as int;
      await docRef.update({'chat_click': chatClick + 1});
      chatClick += 1;
    } else {
      chatClick = 1;
      await docRef.set({
        'book_id': widget.title,
        'chat_click': chatClick
      }, SetOptions(merge: true));
    }

    final level = chatClick < 3 ? 1 : (chatClick < 6 ? 2 : 3);

    final questions = await Provider.of<QuestionProvider>(context, listen: false)
        .fetchQuestionsByLevel(widget.title, level);

    setState(() {
      hintQuestions = questions.take(4).toList();
    });
  }

  Future<void> _loadCommunityRandomQuestion() async {
    setState(() => _loadingCommunity = true);
    try {
      final qs = await FirebaseFirestore.instance
          .collectionGroup('messages')
          .where('bookTitle', isEqualTo: widget.title) 
          .limit(120)                                 
          .get();

      // 허용/제외 라벨
      const allowed = {'on_topic', 'meta', 'compare', 'recommendation'};
      const excluded = {'praise', 'guard_block', 'off_topic'};

      final candidates = <String>[];

      for (final doc in qs.docs) {
        final m = doc.data();

        // 유저 메시지
        final isUser = (m['senderId'] ?? '') != 'bot';
        if (!isUser) continue;
        // 텍스트 존재
        final text = (m['text'] as String?)?.trim() ?? '';
        if (text.isEmpty) continue;
        // 가드 차단 아님
        final isBlocked = (m['isBlocked'] as bool?) ?? false;
        if (isBlocked) continue;
        // 책 연관
        final related = (m['relatedToBook'] as bool?) ?? true;
        if (!related) continue;
        // 라벨
        final cat = ((m['category'] as String?) ?? 'on_topic').toString();
        if (excluded.contains(cat)) continue;
        if (!allowed.contains(cat) && m['category'] != null) continue;
        // 화면에 이미 있는 힌트와 중복 제거
        if (hintQuestions.contains(text)) continue;

        candidates.add(text);
      }

      // 중복 제거
      final unique = candidates.toSet().toList();

      if (unique.isNotEmpty) {
        final pick = unique[Random().nextInt(unique.length)];
        if (mounted) setState(() => communityHint = pick);
      } else {
        if (mounted) setState(() => communityHint = null);
      }
    } catch (e) {
      if (mounted) setState(() => communityHint = null);
    } finally {
      if (mounted) setState(() => _loadingCommunity = false);
    }
  }
  
  Future<void> _incrementChatClickAndNavigate(String message) async {
    if (message.trim().isEmpty) return;

    final user = Provider.of<UserProvider>(context, listen: false).user;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.userId)
        .collection('reading_books')
        .doc(widget.title); 

    final snap = await docRef.get();
    if (snap.exists) {
      final current = (snap.data()?['chat_click'] ?? 0) as int;
      await docRef.update({'chat_click': current + 1});
    } else {
      await docRef.set({
        'book_id': widget.title, 
        'chat_click': 1
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          message: message.trim(),
          title: widget.title,
        ),
      ),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 56),
                    SvgPicture.asset('assets/images/main_Chaekmeong_1.svg', width: 180, height: 180),
                    const SizedBox(height: 16),
                    const Text('도움이 필요하신가요?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('아래는 많은 독서가들이 궁금해하는 것들이에요!', style: TextStyle(fontSize: 14, color: Color(0xff777777)),),
                    const SizedBox(height: 16),
                    buildHintChips(),
                    const SizedBox(height: 12),
                    const Text('다른 독자들이 책멍이에게 한 질문', style: TextStyle(fontSize: 12, color: Color(0xff777777))),
                    const SizedBox(height: 2),
                    if (communityHint != null) buildCommunityChip(),
                    if (_loadingCommunity && communityHint == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: SizedBox(height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: buildMessageInputArea(),
            ),
          ],
        ),
      ),
    );
  }

  // 질문 힌트 메세지
  Widget buildHintChips() {
    return Wrap(
      spacing: 14,
      children: hintQuestions.map((hint) {
        return GestureDetector(
          onTap: () => _incrementChatClickAndNavigate(hint),
          child: Chip(
            label: Text(hint),
            backgroundColor: const Color(0xffE4E4E4),
            labelStyle: const TextStyle(color: Color(0xff777777), fontWeight: FontWeight.w400, fontSize: 12),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(2),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            side: BorderSide.none,
          ),
        );
      }).toList(),
    );
  }

  // 다른 사용자 질문
  Widget buildCommunityChip() {
    return Wrap(
      spacing: 14,
      children: [
        GestureDetector(
          onTap: () {
            if (communityHint != null) _incrementChatClickAndNavigate(communityHint!);
          },
          child: Chip(
            label: Text(communityHint!),
            backgroundColor: const Color(0xffCCE4FF),
            labelStyle: const TextStyle(color: Color(0xff0077FF), fontWeight: FontWeight.w400, fontSize: 12),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(2),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            side: BorderSide.none,
          ),
        ),
      ],
    );
  }

  // 텍스트 입력
  Widget buildMessageInputArea() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            cursorColor: const Color(0xff0077FF),
            decoration: InputDecoration(
              hintText: '책에 대해 궁금한 점을 물어보세요',
              hintStyle: const TextStyle(color: Color(0xff777777), fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xffE4E4E4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xff0077FF), width: 2),
              ),
            ),
            onSubmitted: _incrementChatClickAndNavigate,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _incrementChatClickAndNavigate(_controller.text),
          child: const CircleAvatar(
            backgroundColor: Color(0xff0077FF),
            child: Icon(Icons.arrow_upward_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
