
// 검색 결과 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/provider/user_book_provider.dart';

import '../../provider/search_provider.dart';
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

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(text: widget.searchKeyword);

    // 검색 실행
    Future.microtask(() {
      final viewModel = Provider.of<SearchProvider>(context, listen: false);
      viewModel.clearResults();
      viewModel.searchBooks(widget.searchKeyword);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    final isloading = searchProvider.isLoading;
    final book = searchProvider.searchResult;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: isloading
            ? Center(
                child: CircularProgressIndicator(
                  color: Color(0xff0077FF),
                ),
              )
            :
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    buildSearchBar(context),
                    SizedBox(height: 24),
                    buildBookCover(book?.imagePath),
                    SizedBox(height: 24),
                    buildBookInfo(book?.title, book?.author, book?.description),
                    SizedBox(height: 24),
                    buildAddButton(context, book!.title),
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
  Widget buildBookCover(String? imagePath) {
    return Center(
      child: Container(
        width: 220,
        height: 300,
        decoration: BoxDecoration(
          color: Color(0xffD9D9D9),
          borderRadius: BorderRadius.circular(8),
          image: imagePath != null
              ? DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),
    );
  }

  // 책 정보
  Widget buildBookInfo(String? title, String? author, String? description) {
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
            if (title != null && title.isNotEmpty)
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            SizedBox(height: 8),
            if (author != null && author.isNotEmpty)
              Text(
                '$author 저자(글)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
              ),
            SizedBox(height: 16),
            Text(
              (description != null && description.isNotEmpty)
                  ? description
                  : '해당 도서에 대한 설명이 없습니다.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff777777)),
            ),
          ],
        ),
      ),
    );
  }

  // 내 서재 추가 버튼
  Widget buildAddButton(BuildContext context, String bookId) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () async {
          await Provider.of<UserBookProvider>(context, listen: false)
            .addBook(context, bookId: bookId);

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