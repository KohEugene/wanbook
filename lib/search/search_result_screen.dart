
// 검색 결과 화면
// 아직 예시용으로 '데미안', '채식주의자', '싯다르타'만 넣어둔 상태
// 검색화면 보고 싶으면 위 3개 제목을 쳐서 확인할 것것

import 'package:flutter/material.dart';

//import 'package:wanbook/search/addlibrary_menu.dart';

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

  // 검색 예시용 책
    final Map<String, Map<String, String>> books = {
      '데미안': {
        'author': '헤르만 헤세',
        'imageUrl': 'https://covers.openlibrary.org/b/id/14633424-L.jpg',
      },
      '채식주의자': {
        'author': '한강',
        'imageUrl': 'https://covers.openlibrary.org/b/id/10226571-L.jpg',
      },
      '싯다르타': {
        'author': '헤르만 헤세',
        'imageUrl': 'https://covers.openlibrary.org/b/id/6456720-L.jpg',
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
      bookImageUrl = bookData['imageUrl'] ?? '';
    } else {
      bookTitle = '검색 결과 없음';
      bookAuthor = '';
      bookImageUrl = '';
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
        icon: Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
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
                  decoration: InputDecoration(
                    hintText: '검색어를 입력해 주세요',
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
              image: NetworkImage(bookImageUrl),
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (bookAuthor.isNotEmpty)
              Text(
                '$bookAuthor 저자(글)',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            SizedBox(height: 4),
            Text(
              '출판사 · 출판일',
              style: TextStyle(fontSize: 14, color: Color(0xff777777)),
            ),
            SizedBox(height: 8),
            Text(
              '어쩌구저쩌구 책 설명이 여기에 들어갑니다.어쩌구저쩌구 책 설명이 여기에 들어갑니다. 어쩌구저쩌구 책 설명이 여기에 들어갑니다.어쩌구저쩌구 책 설명이 여기에 들어갑니다.책의 요약이나 소개문구 웃땨땨땨땨땨땨. 최대한 스포 안하는 선에서 간단히 적을 것것',
              style: TextStyle(fontSize: 14, color: Color(0xff777777)),
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
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xffCCE4FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '내 서재에 추가',
          style: TextStyle(color: Color(0xff0077FF), fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}