
// 검색 결과 화면

import 'package:flutter/material.dart';

import '../shared/menu_bottom.dart';
import '../shared/size_config.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchKeyword;

  const SearchResultScreen({super.key, required this.searchKeyword});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {

  late TextEditingController _searchController;

  late String bookTitle;
  late String bookAuthor;
  late String bookImageUrl;
  late String bookDescription;

  // 검색 예시용 책
  final Map<String, Map<String, String>> books = {
    '데미안': {
      'author': '헤르만 헤세',
      'imageAsset': 'assets/images/b_damian.png',
      'description': '자아의 탄생과 성장을 주제로, 내면의 갈등과 깨달음을 통해 한 소년이 자신만의 세계를 인식하게 되는 과정을 그려냅니다. 모든 인간이 겪는 어둠과 빛의 경계를 마주하게 되는 여정 속에서, 삶에 대한 새로운 시각을 제시합니다.',
    },
    '소년이 온다': {
      'author': '한강',
      'imageAsset': 'assets/images/b_boycome.png',
      'description': '어느 도시의 아픔을 배경으로, 고통과 기억이 교차하는 목소리들이 등장하며 인간의 존엄과 슬픔을 마주하게 합니다. 담담한 서술 속에서도 깊은 울림을 전하며, 역사 속 개인의 흔적을 조용히 되새기게 합니다.',
    },
    '종의 기원': {
      'author': '정유정',
      'imageAsset': 'assets/images/b_jong.png',
      'description': '인간 본성의 이면을 파고드는 한 인물의 이야기를 통해, 냉정한 사고와 충동 사이에서 발생하는 복잡한 심리를 사실적으로 그려냅니다. 강렬한 분위기 속에서도 침착한 서사가 이어지며, 인간 존재에 대한 철학적 고찰을 던집니다.',
    },
    '침묵의 봄': {
      'author': '레이첼 카슨',
      'imageAsset': 'assets/images/b_spring.png',
      'description': '자연이 점차 침묵에 잠기게 되는 배경 아래, 우리가 인식하지 못했던 일상의 위험성과 환경의 연관성을 통찰력 있게 풀어냅니다. 과학적 사실을 바탕으로 하되 그 표현은 매우 문학적이며, 경고와 성찰이 교차하는 목소리가 인상 깊습니다.',
    },
    '이기적 유전자': {
      'author': '리처드 도킨스',
      'imageAsset': 'assets/images/b_gene.png',
      'description': '진화의 핵심을 개체가 아닌 유전자로 바라보는 새로운 관점이 제시되며, 생명 현상을 설명하는 방식에 일대 전환을 불러옵니다. 어려운 개념이지만 명쾌한 비유와 설명을 통해 독자의 이해를 돕고, 존재의 의미에 대해 다시 생각하게 만듭니다.',
    },
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchKeyword);

    final bookData = books[widget.searchKeyword];

    if (bookData != null) {
      bookTitle = widget.searchKeyword;
      bookAuthor = bookData['author'] ?? '작가 미상';
      bookImageUrl = bookData['imageAsset'] ?? '';
      bookDescription = bookData['description'] ?? '';
    } else {
      bookTitle = '검색 결과 없음';
      bookAuthor = '';
      bookImageUrl = '';
      bookDescription = '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                buildSearchBar(context),

                SizedBox(height: 24),
                buildBookCover(),

                SizedBox(height: 24),
                buildBookInfo(),

                SizedBox(height: 24),
                buildAddButton(),

                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 검색창
  Widget buildSearchBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left_rounded),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        SizedBox(width: 8,),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            height: 56,
            decoration: BoxDecoration(
              color: Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    cursorColor: Color(0xff0077FF),
                    decoration: InputDecoration(
                      hintText: '검색어를 입력해 주세요',
                      hintStyle: TextStyle(
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xff777777),
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.search, color: Color(0xff777777)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(
                          searchKeyword: _searchController.text,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 책 이미지
  Widget buildBookCover() {
    return Center(
      child: Container(
        width: 220,
        height: 300,
        decoration: BoxDecoration(
          color: Color(0xffD9D9D9),
          borderRadius: BorderRadius.circular(8),
          image: bookImageUrl.isNotEmpty
              ? DecorationImage(
                  image: AssetImage(bookImageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),
    );
  }

  // 책정보
  Widget buildBookInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bookTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            if (bookAuthor.isNotEmpty)
              Text(
                '$bookAuthor 저자(글)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
              ),
            SizedBox(height: 16),
            Text(
              bookDescription.isNotEmpty
                  ? bookDescription
                  : '해당 도서에 대한 설명이 없습니다.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff777777)),
            ),
          ],
        ),
      ),
    );
  }

  // 내 서재 추가 버튼
  Widget buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Color(0xffF8F8F8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  '추가 완료',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff0077FF),
                  ),
                ),
                content: Text(
                  '해당 도서가 내 서재에 추가되었어요.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff777777),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // 단순 닫기
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xff777777),
                    ),
                    child: Text('머무르기'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                        return MenuBottom(initialIndex: 2,);
                      },));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xff0077FF),
                    ),
                    child: Text('서재로 이동'),
                  ),
                ],
              );
            },
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xff0077FF),
          backgroundColor: Color(0xffCCE4FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          side: BorderSide(color: Colors.transparent)
        ),
        child: Text(
          '내 서재에 추가',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

}