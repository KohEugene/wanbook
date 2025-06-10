// 챗봇 목록

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/model/chatmessage_model.dart';
import 'package:wanbook/provider/chat_provider.dart';
import 'package:wanbook/provider/user_provider.dart';
import 'package:wanbook/screen/aichat/chat_screen.dart';
import '../../shared/size_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatlistScreen extends StatefulWidget {
  const ChatlistScreen({super.key});

  @override
  State<ChatlistScreen> createState() => _ChatlistScreenState();
}

class _ChatlistScreenState extends State<ChatlistScreen> {
  late String userId;
  late ChatProvider chatProvider;

  Map<String, ChatMessageModel> lastMessages = {};

  final Map<String, String> bookImageMap = {
    '데미안': 'assets/images/b_damian.png',
    '이기적 유전자': 'assets/images/b_gene.png',
    '이방인': 'assets/images/b_stranger.png',
    '노인과 바다': 'assets/images/b_sea.png',
    '아몬드': 'assets/images/b_almond.png',
    '인간실격': 'assets/images/b_human.png',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId = Provider.of<UserProvider>(context, listen: false).user?.userId ?? '';
      chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await fetchLastMessages();
    });
  }
  
  Future<void> fetchLastMessages() async {
    final firestore = FirebaseFirestore.instance;
    userId = Provider.of<UserProvider>(context, listen: false).user?.userId ?? '';
    final chatCollectionRef = firestore
        .collection('users')
        .doc(userId)
        .collection('chats');

    final chatDocsSnapshot = await chatCollectionRef.get();
    final Map<String, ChatMessageModel> tempMap = {};

    for (final doc in chatDocsSnapshot.docs) {
      final bookTitle = doc.id;
      final messageSnapshot = await chatCollectionRef
          .doc(bookTitle)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messageSnapshot.docs.isNotEmpty) {
        final message = ChatMessageModel.fromMap(messageSnapshot.docs.first.data());
        tempMap[bookTitle] = message;
      } else {
        print('메시지 없음: $bookTitle');
      }
    }

    setState(() {
      lastMessages = tempMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅 목록'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.screenWidth * 0.05, vertical: 16),
          child: lastMessages.isEmpty
              ? const Center(child: Text("채팅 기록이 없습니다."))
              : ListView.builder(
                  itemCount: lastMessages.length,
                  itemBuilder: (context, index) {
                    final bookTitle = lastMessages.keys.elementAt(index);
                    final message = lastMessages[bookTitle]!;
                    return chatRecord(bookTitle, message.text, message.timestamp);
                  },
                ),
        ),
      ),
    );
  }

  // 책 당 채팅 목록
  Widget chatRecord(String bookTitle, String chat, DateTime time) {
    final imagePath = bookImageMap[bookTitle] ?? 'assets/images/default_cover.png';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(message: chat, title: bookTitle, isFromHistory: true,),
          ),
        );
      },
      child: SizedBox(
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookTitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    chat,
                    style: const TextStyle(
                      color: Color(0xffADADAD),
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Color(0xffADADAD),
                fontWeight: FontWeight.w400,
                fontSize: 10,
              ),
            )
          ],
        ),
      ),
    );
  }
}
