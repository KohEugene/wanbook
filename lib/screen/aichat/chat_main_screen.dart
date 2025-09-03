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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatClickAndFetchQuestions();
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
                    const SizedBox(height: 72),
                    SvgPicture.asset('assets/images/main_Chaekmeong_1.svg', width: 180, height: 180),
                    const SizedBox(height: 16),
                    const Text('도움이 필요하신가요?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text(
                      '아래는 많은 독서가들이 궁금해하는 것들이에요!',
                      style: TextStyle(fontSize: 14, color: Color(0xff777777)),
                    ),
                    const SizedBox(height: 16),
                    buildHintChips(),
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

  Widget buildMessageInputArea() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
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
