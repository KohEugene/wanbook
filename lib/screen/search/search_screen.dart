// 검색 메인 화면
import 'package:flutter/material.dart';
import 'package:wanbook/model/book_model.dart';
import 'package:wanbook/shared/book_basic.dart';
import 'package:wanbook/shared/menu_bottom.dart';
import 'package:wanbook/screen/search/search_result_screen.dart';

import '../../shared/size_config.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final recentSearches = ['데미안', '아몬드', '노인과 바다', '이방인', '인간실격'];
  final recommendedSearches = ['오만과 편견', '소년이 온다', '변신', '눈먼 자들의 도시'];

  List<BookModel> books = [
    BookModel(title: '데미안', author: '헤르만 헤세', imagePath: 'assets/images/b_damian.png'),
    BookModel(title: '소년이 온다', author: '한강', imagePath: 'assets/images/b_boycome.png'),
    BookModel(title: '아몬드', author: '손원평', imagePath: 'assets/images/b_amond.png'),
    BookModel(title: '인간실격', author: '다자이 오사무', imagePath: 'assets/images/b_human.png'),
    BookModel(title: '노인과 바다', author: '어니스트 헤밍웨이', imagePath: 'assets/images/b_sea.png'),
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    buildSearchBar(context),
                    SizedBox(height: 24),
                    buildRecentSearchSection(),
                    SizedBox(height: 24),
                    buildRecommendedSearchSection(),
                    SizedBox(height: 24),
                    buildBookSection('추천 도서'),
                    SizedBox(height: 24),
                    buildBookSection('인기 도서'),
                    SizedBox(height: 24),
                  ],
                ),
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
        // 뒤로가기 아이콘
        IconButton(
          icon: Icon(Icons.chevron_left_rounded),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return MenuBottom(initialIndex: 0,);
            },));
          },
          color: Colors.black,
        ),
        SizedBox(width: 8,),
        // 검색창
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
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: '검색어를 입력해 주세요',
                      hintStyle: TextStyle(
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16), // 텍스트 위치 조정
                    ),
                  ),
                ),
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

  // 최근 검색어
  Widget buildRecentSearchSection() {
    return buildSearchSection(
      '최근 검색어',
      recentSearches,
      showClear: true,
      onClear: () {
        setState(() {
          recentSearches.clear();
        });
      },
      onWordTap: (word) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultScreen(searchKeyword: word),
          ),
        );
      },
    );
  }

  // 추천 검색어
  Widget buildRecommendedSearchSection() {
    return buildSearchSection(
      '추천 검색어',
      recommendedSearches,
      onWordTap: (word) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultScreen(searchKeyword: word),
          ),
        );
      },
    );
  }

  // 최근, 추천 검색어 UI
  Widget buildSearchSection(
    String title,
    List<String> words, {
    bool showClear = false,
    VoidCallback? onClear, // 지우기 콜백
    Function(String)? onWordTap, // 단어 클릭 콜백
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            if (showClear)
              TextButton(
                onPressed: onClear,
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) => Colors.transparent,
                  ),
                  foregroundColor: WidgetStateProperty.all(Color(0xff777777)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('지우기', style: TextStyle(
                    color: Color(0xff777777),
                    fontWeight: FontWeight.w400,
                    fontSize: 14),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: words.map((word) {
              return GestureDetector(
                onTap: () {
                  if (onWordTap != null) {
                    onWordTap(word);
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(right: 8), // Chip 사이 간격
                  child: Chip(
                    label: Text(word),
                    labelStyle: TextStyle(
                      color: Color(0xff777777),
                      fontWeight: FontWeight.w400,
                      fontSize: 14
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(2),
                      ),
                      side: BorderSide(color: Color(0xff777777)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 추천 도서, 인기 도서
  Widget buildBookSection(String sectionTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sectionTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return BookBasic(book: books[index], onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => SearchResultScreen(searchKeyword: books[index].title),)
                );
              },);
            },
          ),
        )
      ],
    );
  }
}
