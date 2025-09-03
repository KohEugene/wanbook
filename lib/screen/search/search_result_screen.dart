// 검색 결과 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/provider/user_book_provider.dart';
import 'package:wanbook/provider/recentsearch_provider.dart';
import 'package:wanbook/provider/user_provider.dart';
import 'package:wanbook/shared/achievement_screen.dart';
import '../../provider/badge_provider.dart';
import '../../provider/search_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../shared/menu_bottom.dart';
import '../../shared/size_config.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchKeyword;

  const SearchResultScreen({super.key, required this.searchKeyword});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late TextEditingController _searchController;

  late Future<void> _searchFuture;


  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchKeyword);
    _runSearch(widget.searchKeyword);
  }

  void _runSearch(String keyword) {
    final viewModel = context.read<SearchProvider>();
    viewModel.clearResults();

    setState(() {
      _searchFuture = viewModel
          .searchBooks(keyword)
          .timeout(const Duration(seconds: 8))
          .catchError((_) {});
    });

    Future.microtask(() async {
      final userId = context.read<UserProvider>().user?.userId ?? '';
      final recent = context.read<RecentSearchProvider>();
      recent.setUserId(userId);
      await recent.saveRecentSearch(keyword);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: FutureBuilder<void>(
            future: _searchFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xff0077FF)),
                );
              }

              final book = searchProvider.searchResult;

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      _buildSearchBar(),
                      if (book == null) ...[
                        const SizedBox(height: 140),
                        _noResultBox(),
                      ] else ...[
                        const SizedBox(height: 24),
                        _buildBookCover(book.imagePath),
                        const SizedBox(height: 24),
                        _buildBookInfo(book.title, book.author, book.description),
                        const SizedBox(height: 24),
                        _buildAddButton(context, book.title),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _noResultBox() => Container(
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            SvgPicture.asset('assets/images/no_result.svg', height: 170),
            const SizedBox(height: 16),
            const Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xff777777),
              ),
            ),
          ],
        ),
      );

  // 검색창
  Widget _buildSearchBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
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
                    decoration: const InputDecoration(
                      hintText: '검색어를 입력해 주세요',
                      hintStyle: TextStyle(
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _runSearch(value.trim());
                      }
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(_searchController.clear),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xffD9D9D9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 16, color: Color(0xff777777)),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search, color: Color(0xff777777)),
                  onPressed: () {
                    final keyword = _searchController.text.trim();
                    if (keyword.isNotEmpty) {
                      FocusScope.of(context).unfocus();
                      _runSearch(keyword); 
                    }
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
  Widget _buildBookCover(String? imagePath) {
    return Center(
      child: Container(
        width: 220,
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xffD9D9D9),
          borderRadius: BorderRadius.circular(8),
          image: imagePath != null
              ? DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),
    );
  }

  // 책 정보
  Widget _buildBookInfo(String? title, String? author, String? description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title.isNotEmpty)
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (author != null && author.isNotEmpty)
              Text(
                '$author 저자(글)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
              ),
            const SizedBox(height: 16),
            Text(
              (description != null && description.isNotEmpty)
                  ? description
                  : '해당 도서에 대한 설명이 없습니다.',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff777777)),
            ),
          ],
        ),
      ),
    );
  }

  // 내 서재 추가 버튼
  Widget _buildAddButton(BuildContext context, String bookId) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () async {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          final success = await context.read<UserBookProvider>().addBook(context, bookId: bookId);
          if (success) {
            final badgeProvider = Provider.of<BadgeProvider>(context, listen: false);
            await badgeProvider.checkAndShowAchievements(userProvider.userId!, context);
          }
          Future.delayed(const Duration(seconds: 3), () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                final title = success ? '추가 완료' : '이미 추가됨';
                final content = success
                    ? '해당 도서가 내 서재에 추가되었어요.'
                    : '이미 서재에 도서가 있어요.';

                return AlertDialog(
                  backgroundColor: const Color(0xffF8F8F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff0077FF),
                    ),
                  ),
                  content: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff777777),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xff777777)),
                      child: const Text('머무르기'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MenuBottom(initialIndex: 2)),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: const Color(0xff0077FF)),
                      child: const Text('서재로 이동'),
                    ),
                  ],
                );
              },
            );
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xff0077FF),
          backgroundColor: const Color(0xffCCE4FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          shadowColor: Colors.transparent,
          side: const BorderSide(color: Colors.transparent),
        ),
        child: const Text(
          '내 서재에 추가',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
