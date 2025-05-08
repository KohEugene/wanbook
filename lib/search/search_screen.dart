// 검색 메인 화면
import 'package:flutter/material.dart';
import 'package:wanbook/shared/menu_bottom.dart';
import 'package:wanbook/search/search_result_screen.dart'; 

import '../shared/size_config.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final recentSearches = ['데미안', '종의 기원', '소년이 온다', '책제목'];
  final recommendedSearches = ['데미안', '종의 기원', '소년이 온다', '싯다르타', '눈먼 자들의 도시'];
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
                    buildSearchSection(
                      '최근 검색어',
                      recentSearches,
                      showClear: true,
                      onClear: () {
                          setState(() {
                            recentSearches.clear();
                          });
                        },
                      onWordTap: (word) {
                        print('클릭된 검색어: $word');
                          //검색 실행 로직 추가필요
                      },),
                    SizedBox(height: 24),
                    buildSearchSection('추천 검색어', recommendedSearches,
                      onWordTap: (word) {
                        print('클릭된 검색어: $word');
                          //검색 실행 로직 추가필요
                      },),
                    SizedBox(height: 24),
                    buildBookSection(
                      '추천 도서',
                      highlightTitle: '',
                      highlightAuthor: '',
                    ),
                    SizedBox(height: 24),
                    buildBookSection(
                      '인기 도서',
                      highlightTitle: '',
                      highlightAuthor: '',
                    ),
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

  // 최근, 추천 검색어
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
  Widget buildBookSection(String title, {
    required String highlightTitle,
    required String highlightAuthor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              if (index == 0) {
                return buildBookItem(
                  '데미안',
                  '헤르만 헤세',
                  imageAsset: 'assets/images/b_damian.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(searchKeyword: '데미안'),
                      ),
                    );
                  },
                );
              } else if (index == 1) {
                return buildBookItem(
                  '소년이 온다',
                  '한강',
                  imageAsset: 'assets/images/b_boycome.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(searchKeyword: '소년이 온다'),
                      ),
                    );
                  },
                );
              } else if (index == 2) {
                return buildBookItem(
                  '종의 기원',
                  '정유정',
                  imageAsset: 'assets/images/b_jong.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(searchKeyword: '종의 기원'),
                      ),
                    );
                  },
                );
              } else if (index == 3) {
                return buildBookItem(
                  '침묵의 봄',
                  '레이첼 카슨',
                  imageAsset: 'assets/images/b_spring.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(searchKeyword: '침묵의 봄'),
                      ),
                    );
                  },
                );
              } else if (index == 4) {
                return buildBookItem(
                  '이기적 유전자',
                  '리처드 도킨스',
                  imageAsset: 'assets/images/b_gene.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(searchKeyword: '이기적 유전자'),
                      ),
                    );
                  },
                );
              } else {
                return buildBookItem(
                  '책 제목',
                  '저자 명',
                  imageAsset: null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(searchKeyword: '책 제목'),
                      ),
                    );
                  },
                );
              }
            },
          ),
        )
      ],
    );
  }

  // 개별 책 항목
  Widget buildBookItem(String title, String author, {String? imageAsset, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageAsset != null
                    ? Image.asset(
                        imageAsset,
                        fit: BoxFit.cover,
                      )
                    : Container(color: Color(0xffD9D9D9)),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                  Text(author, style: const TextStyle(color: Color(0xff777777), fontSize: 12, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
