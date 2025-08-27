// 챗봇 목록

import 'dart:convert'; // 추가: book.json 파싱용
import 'package:flutter/services.dart' show rootBundle; // 추가: 에셋 로드용

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

  // 추가: book.json에서 불러온 "제목 → imagePath(URL 또는 에셋 경로)" 매핑
  final Map<String, String> _coverByTitle = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId = Provider.of<UserProvider>(context, listen: false).user?.userId ?? '';
      chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // 추가: book.json 로드해서 제목→커버 매핑 준비 (imagePath 사용)
      await _loadCoversFromBookJson();

      await fetchLastMessages();
    });
  }
  
  // 추가: book.json에서 "title"과 "imagePath" 매핑 생성
  Future<void> _loadCoversFromBookJson() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/book.json');
      final List<dynamic> list = json.decode(jsonStr);

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final title = (item['title'] ?? '').toString().trim();
          if (title.isEmpty) continue;

          // 🔑 표지 키는 imagePath로 고정
          final cover = item['imagePath']?.toString();

          if (cover != null && cover.isNotEmpty) {
            _coverByTitle[title] = cover;
          }
        }
      }
      setState(() {}); // 매핑 갱신
    } catch (e) {
      debugPrint('book.json 로드 실패: $e');
    }
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

  // 추가: 문자열이 http면 NetworkImage, 그 외엔 에셋 경로로 간주 (없으면 기본 커버)
  ImageProvider _coverProvider(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      return const AssetImage('assets/images/default_cover.png');
    }
    if (pathOrUrl.startsWith('http')) {
      return NetworkImage(pathOrUrl);
    }
    return AssetImage(pathOrUrl);
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
                    // 추가: 제목(title)로 imagePath 찾기
                    final cover = _coverByTitle[bookTitle];
                    return chatRecord(bookTitle, message.text, message.timestamp, cover);
                  },
                ),
        ),
      ),
    );
  }

  // 책 당 채팅 목록
  Widget chatRecord(String bookTitle, String chat, DateTime time, String? cover) {
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
                  image: _coverProvider(cover), // 추가: title 매칭된 imagePath 적용
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
