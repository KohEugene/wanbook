// 검색 메인 화면

import 'package:flutter/material.dart';
import 'package:wanbook/shared/menu_bottom.dart';

import '../shared/size_config.dart';

import 'package:cached_network_image/cached_network_image.dart';
// 이거 사용하려면 pubspec.yaml에 dependencies: cached_network_image: ^3.3.0 추가
// 그리고 난 후 터미널에 flutter pub get 입력


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final recentSearches = ['데미안', '종의 기원', '소년이 온다', '책제목'];
  final recommendedSearches = ['데미안', '종의 기원', '소년이 온다', '싯다르타', '눈먼 자들의 도시'];

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
                  highlightTitle: '싯다르타',
                  highlightAuthor: '헤르만 헤세',
                ),
                SizedBox(height: 24),
                buildBookSection(
                  '인기 도서',
                  highlightTitle: '소년이 온다',
                  highlightAuthor: '한강',
                ),
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
        // 뒤로가기 아이콘
        IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

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
                    decoration: InputDecoration(
                      hintText: '검색어를 입력해 주세요',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16), // 텍스트 위치 조정정
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Color(0xff777777)),
                onPressed: () {}
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (showClear)
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xff777777),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('지우기'),
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
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              if (index == 0) {
                return buildBookItem(
                  '싯다르타', 
                  '헤르만 헤세', 
                  imageUrl: 'https://covers.openlibrary.org/b/id/6456720-L.jpg'
                  , 
                );
              } 
              if (index == 1) {
                return buildBookItem(
                  '데미안', 
                  '헤르만 헤세', 
                  imageUrl: 'https://covers.openlibrary.org/b/id/14633424-L.jpg'
                  , 
                );
              } 
              else {
                return buildBookItem(
                  '책 제목', 
                  '저자 명',
                  imageUrl: 'https://via.placeholder.com/110x150.png',
                );
              }
            },
          ),
        )
      ],
    );
  }

  // 개별 책 항목
  Widget buildBookItem(String title, String author, {String? imageUrl}) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300], ),
                    fit: BoxFit.cover,
                  )
                : Container(color: Colors.grey[300]),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(author, style: TextStyle(color: Color(0xff777777), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

