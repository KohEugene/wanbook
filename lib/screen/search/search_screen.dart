// 검색 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/model/book_model.dart';
import 'package:wanbook/provider/recentsearch_provider.dart';
import 'package:wanbook/provider/recommend_provider.dart';
import 'package:wanbook/provider/user_provider.dart';
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
  List<String> recentSearches = [];

  final TextEditingController _searchController = TextEditingController();

 @override
  void initState() {
    super.initState();

    // userId 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.userId ?? '';
      final recentSearchProvider = Provider.of<RecentSearchProvider>(context, listen: false);
      recentSearchProvider.setUserId(userId);
      loadRecentSearches();

      final recommendProvider = Provider.of<RecommendProvider>(context, listen: false);
      recommendProvider.loadBooksFromJson().then((_) {
        recommendProvider.fetchTagBasedBooks(userId);
        recommendProvider.fetchPopularBooks();
      });
    });
  }

  Future<void> loadRecentSearches() async {
    final provider = Provider.of<RecentSearchProvider>(context, listen: false);
    final results = await provider.fetchRecentSearches();
    setState(() {
      recentSearches = results.map((e) => e.keyword).toList();
    });
  }

  Future<void> performSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;

    final provider = Provider.of<RecentSearchProvider>(context, listen: false);
    await provider.saveRecentSearch(keyword);
    await loadRecentSearches();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(searchKeyword: keyword),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendProvider = Provider.of<RecommendProvider>(context);
    final recommendBooks = recommendProvider.tagBasedBooks;
    final popularBooks = recommendProvider.popularBooks;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  buildSearchBar(context),
                  const SizedBox(height: 24),
                  buildRecentSearchSection(),
                  const SizedBox(height: 24),
                  buildBookSection('추천 도서', recommendBooks),
                  const SizedBox(height: 24),
                  buildBookSection('인기 도서', popularBooks),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 검색바
  Widget buildSearchBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MenuBottom(initialIndex: 0)),
          ),
          color: Colors.black,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    cursorColor: const Color(0xff0077FF),
                    textInputAction: TextInputAction.search,
                    onSubmitted: performSearch,
                    decoration: const InputDecoration(
                      hintText: '검색어를 입력해 주세요',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Color(0xff777777)),
                  onPressed: () => performSearch(_searchController.text),
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
      onClear: () async {
        final provider = RecentSearchProvider();
        await provider.clearRecentSearches();
        await loadRecentSearches();
      },
      onWordTap: performSearch,
    );
  }

  // 검색어 chip
  Widget buildSearchSection(
    String title,
    List<String> words, {
    bool showClear = false,
    VoidCallback? onClear,
    Function(String)? onWordTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            if (showClear)
              TextButton(
                onPressed: onClear,
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  foregroundColor: WidgetStateProperty.all(const Color(0xff777777)),
                ),
                child: const Text('지우기', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
              ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: words.map((word) => GestureDetector(
                onTap: () => onWordTap?.call(word),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(word),
                    labelStyle: const TextStyle(color: Color(0xff777777), fontSize: 14),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(2),
                      ),
                      side: const BorderSide(color: Color(0xff777777)),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // 도서 구성 UI
  Widget buildBookSection(String sectionTitle, List<BookModel> books) {
    if (books.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sectionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              return BookBasic(
                book: books[index],
                onTap: () => performSearch(books[index].title),
              );
            },
          ),
        ),
      ],
    );
  }
}