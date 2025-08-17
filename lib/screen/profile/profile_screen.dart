// 내 프로필 메인 화면
import 'dart:math' as math;
import 'dart:convert'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/screen/aichat/chatlist_screen.dart';
import 'package:wanbook/screen/login/login_screen.dart';
import 'package:wanbook/screen/profile/badge_screen.dart';
import 'package:wanbook/shared/pop_up.dart';
import '../../model/book_model.dart';
import '../../provider/badge_provider.dart';
import '../../provider/user_book_provider.dart';
import '../../provider/user_provider.dart';
import '../../shared/size_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = FlutterSecureStorage();

  String nickname = '사용자 명';
  String userId = '사용자 아이디';
  DateTime? joinDate;
  int howManyBook = 0;

  BookModel? longestReadBook;
  BookModel? shortestReadBook;
  Duration? longestReadDuration;
  Duration? shortestReadDuration;

  // 뱃지에서 보여줄 아이템들
  Future<List<BadgeItem>> _recentBadgesFuture =
      Future.value(const <BadgeItem>[]);
  Future<List<MonthlyRecordItem>> _monthly3Future =
      Future.value(const <MonthlyRecordItem>[]);

  // 월간, 업적 배지 기본 UI 세팅
  static const _monthlyCross = 3;
  static const _monthlyMainSpace = 16.0;
  static const _monthlyCrossSpace = 14.0;
  static const _monthlyAspect = 0.8;

  static const _achieveCross = 3;
  static const _achieveMainSpace = 16.0;
  static const _achieveCrossSpace = 14.0;
  static const _achieveAspect = 0.53;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final viewModel = Provider.of<UserBookProvider>(context, listen: false);
      final readingCard = await viewModel.calculateBookStats(context);
      setState(() {
        shortestReadBook = readingCard?.shortestReadBook;
        longestReadBook = readingCard?.longestReadBook;
        shortestReadDuration = readingCard?.shortestReadDuration;
        longestReadDuration = readingCard?.longestReadDuration;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final viewModel = Provider.of<UserBookProvider>(context, listen: false);
      final booksData = await viewModel.fetchReadingBooks(context);
      setState(() {
        nickname = userProvider.user?.nickname ?? '사용자';
        userId =
            userProvider.user?.userId ?? userProvider.userId ?? '사용자 아이디';
        joinDate = userProvider.user?.joinedAt;
        howManyBook = booksData.length;
      });

      // 최근 획득 배지 3개
      final uid = userProvider.user?.userId ?? userProvider.userId ?? '';
      if (uid.isNotEmpty) {
        final badgeProvider =
        Provider.of<BadgeProvider>(context, listen: false);

        // 연속 3개월
        Future<List<MonthlyRecordItem>> buildMonthly3() async {
          final now = DateTime.now();
          final curY = now.year;
          final curM = now.month;

          int prevM = curM - 1, nextM = curM + 1;
          int prevY = curY, nextY = curY;
          if (prevM == 0) {
            prevM = 12;
            prevY = curY - 1;
          }
          if (nextM == 13) {
            nextM = 1;
            nextY = curY + 1;
          }

          final thisYear =
          await badgeProvider.getMonthlyRecords(uid, year: curY);
          List<MonthlyRecordItem> prevYearList = thisYear;
          List<MonthlyRecordItem> nextYearList = thisYear;

          if (prevY != curY) {
            prevYearList =
            await badgeProvider.getMonthlyRecords(uid, year: prevY);
          }
          if (nextY != curY) {
            nextYearList =
            await badgeProvider.getMonthlyRecords(uid, year: nextY);
          }

          MonthlyRecordItem pick(List<MonthlyRecordItem> list, int month) {
            return list.firstWhere(
                  (e) => e.month == month,
              orElse: () => MonthlyRecordItem(
                  month: month,
                  count: 0,
                  achieved: 0,
                  unlocked: false,
                  asset: null),
            );
          }

          final a = pick(prevY == curY ? thisYear : prevYearList, prevM);
          final b = pick(thisYear, curM);
          final c = pick(nextY == curY ? thisYear : nextYearList, nextM);

          return [a, b, c];
        }

        final badgesF =
        badgeProvider.getRecentUnlockedBadgesSafe(uid, limit: 3);
        final monthlyF = buildMonthly3();

        setState(() {
          _recentBadgesFuture = badgesF;
          _monthly3Future = monthlyF;
        });
      } else {
        setState(() {
          _recentBadgesFuture = Future.value(const <BadgeItem>[]);
          _monthly3Future = Future.value(const <MonthlyRecordItem>[]);
        });
      }
    });
  }

  String formatElapsedTime(DateTime joinedAt) {
    final now = DateTime.now();
    final difference = now.difference(joinedAt);
    final elapsedDays = difference.inDays + 1;
    return '$elapsedDays일째';
  }

  String formatDuration(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays}일';
    if (duration.inHours > 0) return '${duration.inHours}시간';
    return '${duration.inMinutes}분';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('내 프로필'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
                // 양쪽 여백 넣기 (좌우, 상하 기준)
                padding:
                    EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    userInfoSection(),
                    const SizedBox(height: 16),
                    readingStatus(),
                    const SizedBox(height: 16),
                    chatWithChackmeong(),
                    const SizedBox(height: 16),
                    readingCard(),
                    const SizedBox(height: 16),
                    monthlyRecord(),
                    const SizedBox(height: 16),
                    achieveBadge(),
                    const SizedBox(height: 16),
                  ],
              ),
            )
          ),
        )
    );
  }

  // 사용자 정보 섹션
  Widget userInfoSection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;

        ImageProvider? avatarImage;
        final b64 = user?.profileImageBase64 ?? '';
        if (b64.isNotEmpty) {
          try {
            avatarImage = MemoryImage(base64Decode(b64));
          } catch (_) {
            avatarImage = null;
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xffD9D9D9),
                      backgroundImage: avatarImage,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xffBABABA),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const PopUp(),
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xff777777),
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.nickname ?? '사용자 명',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user?.userId ?? '사용자 아이디'}',
                      style: const TextStyle(
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: 90,
              height: 36,
              child: OutlinedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  await storage.delete(key: 'keepLogin');
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff777777),
                  backgroundColor: const Color(0xffF8F8F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  side: const BorderSide(color: Colors.transparent),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget readingStatus() {
    String elapsedDaysStr = formatElapsedTime(joinDate ?? DateTime.now());

    return Container(
      width: SizeConfig.screenWidth * 0.9,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: Color(0xff777777)),
          const SizedBox(width: 16),
          Text(
            elapsedDaysStr,
            style: const TextStyle(
                color: Color(0xff0077FF),
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
          Text(
            ' $howManyBook권',
            style: const TextStyle(
                color: Color(0xff0077FF),
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
          const Text(
            ' 독서 중이에요!',
            style: TextStyle(
                color: Color(0xff777777),
                fontWeight: FontWeight.w400,
                fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget chatWithChackmeong() {
    return Container(
      width: SizeConfig.screenWidth * 0.9,
      height: 166,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/list_Chaekmeong.svg',
              width: 150,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text(
              '책멍이와의 대화',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return const ChatlistScreen();
                }));
              },
              style: ButtonStyle(
                overlayColor: WidgetStateColor.resolveWith(
                    (states) => Colors.transparent),
              ),
              child: const Row(
                children: [
                  Text(
                    '목록 보기',
                    style: TextStyle(
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w400,
                        fontSize: 14),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xff777777),
                    size: 14,
                  )
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget readingCard() {
    if (longestReadBook == null || shortestReadBook == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: SizeConfig.screenWidth * 0.435,
          height: 270,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('가장 빨리 읽었어요',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                height: 140,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: shortestReadBook?.imagePath != null
                      ? Image.network(
                    shortestReadBook!.imagePath!,
                    fit: BoxFit.cover,
                  )
                      : Container(color: Color(0xffD9D9D9)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                shortestReadBook!.title,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                shortestReadBook!.author,
                style: const TextStyle(
                    color: Color(0xff777777),
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(formatDuration(shortestReadDuration!),
                  style: const TextStyle(
                      color: Color(0xff777777),
                      fontWeight: FontWeight.w400,
                      fontSize: 11))
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: SizeConfig.screenWidth * 0.435,
          height: 270,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('가장 오래 읽었어요',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                height: 140,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: longestReadBook?.imagePath != null
                      ? Image.network(
                    longestReadBook!.imagePath!,
                    fit: BoxFit.cover,
                  )
                      : Container(color: Color(0xffD9D9D9)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                longestReadBook!.title,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                longestReadBook!.author,
                style: const TextStyle(
                    color: Color(0xff777777),
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(formatDuration(longestReadDuration!),
                  style: const TextStyle(
                      color: Color(0xff777777),
                      fontWeight: FontWeight.w400,
                      fontSize: 11))
            ],
          ),
        ),
      ],
    );
  }

  // 태그명 두줄 분리
  (String, String?) _splitStageTitle(String title) {
    final m = RegExp(r'\s+(입문자|베테랑|정복자)$').firstMatch(title);
    if (m != null) {
      final primary = title.substring(0, m.start).trim();
      final secondary = m.group(1)!;
      return (primary, secondary);
    }
    return (title, null);
  }

  // 공통 UI (SVG, 글씨)
  Widget _iconOnlyTile(bool isLocked, {String? svgAsset, double scale = 1.0}) {
    return LayoutBuilder(
      builder: (context, c) {
        final side = math.min(c.maxWidth, c.maxHeight);
        final icon = side * scale;
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (svgAsset != null)
                  SvgPicture.asset(
                    svgAsset,
                    width: icon,
                    height: icon,
                    fit: BoxFit.contain,
                    colorFilter: isLocked
                        ? const ColorFilter.mode(
                            Color(0xFF777777), BlendMode.srcIn)
                        : null,
                  ),
                if (isLocked)
                  const Icon(Icons.lock, size: 18, color: Color(0xFF555555)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 월간 기록 부분
  Widget _monthlyTile(MonthlyRecordItem item) {
    return Column(
      children: [
        Expanded(
          flex: 8,
          child:
              _iconOnlyTile(!item.unlocked, svgAsset: item.asset, scale: 0.9),
        ),
        const SizedBox(height: 4),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff777777),
                fontWeight: FontWeight.w400,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 뱃지 제목
  Widget _achievementTile(BadgeItem b) {
    final (primary, secondary) = _splitStageTitle(b.title);
    final isLocked = !b.unlocked;

    return Column(
      children: [
        Expanded(
          flex: 8,
          child: _iconOnlyTile(isLocked, svgAsset: b.asset, scale: 0.88),
        ),
        const SizedBox(height: 2),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                primary,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff777777),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
              if (secondary != null)
                Text(
                  secondary,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff9A9A9A),
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget recordBadge(String title, bool isLocked) {
    return SizedBox(
      width: 65,
      height: 93,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(alignment: Alignment.center, children: [
            Container(
              width: 55,
              height: 55,
              decoration: const BoxDecoration(
                  color: Color(0xffD9D9D9), shape: BoxShape.circle),
            ),
            if (isLocked) ...[
              const Positioned(
                  child: Icon(Icons.lock,
                      color: Color(0xff777777), size: 24))
            ],
          ]),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  color: Color(0xff777777),
                  fontWeight: FontWeight.w400,
                  fontSize: 12))
        ],
      ),
    );
  }

  // 월간 기록 뱃지
  Widget monthlyRecord() {
    return Container(
      width: SizeConfig.screenWidth * 0.9,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('월간 기록',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return const BadgeScreen();
                }));
              },
              style: ButtonStyle(
                overlayColor: WidgetStateColor.resolveWith(
                    (states) => Colors.transparent),
              ),
              child: const Row(
                children: [
                  Text('더보기',
                      style: TextStyle(
                          color: Color(0xff777777),
                          fontWeight: FontWeight.w400,
                          fontSize: 14)),
                  Icon(Icons.chevron_right_rounded,
                      color: Color(0xff777777), size: 14)
                ],
              ),
            ),
          ]),
          const SizedBox(height: 8),
          FutureBuilder<List<MonthlyRecordItem>>(
            future: _monthly3Future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return GridView.count(
                  crossAxisCount: _monthlyCross,
                  mainAxisSpacing: _monthlyMainSpace,
                  crossAxisSpacing: _monthlyCrossSpace,
                  childAspectRatio: _monthlyAspect,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    SizedBox.shrink(),
                    SizedBox.shrink(),
                    SizedBox.shrink()
                  ],
                );
              }
              if (snapshot.hasError) {
                return Text(
                  '월간 기록을 불러오는 중 오류가 발생했습니다.\n${snapshot.error}',
                  style:
                      const TextStyle(color: Color(0xff777777), fontSize: 12),
                );
              }

              final items = snapshot.data ?? const <MonthlyRecordItem>[];
              if (items.isEmpty) {
                return const Text(
                  '아직 월간 기록이 없어요.',
                  style:
                      TextStyle(color: Color(0xff777777), fontSize: 12),
                );
              }

              return GridView.builder(
                itemCount: items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _monthlyCross,
                  mainAxisSpacing: _monthlyMainSpace,
                  crossAxisSpacing: _monthlyCrossSpace,
                  childAspectRatio: _monthlyAspect,
                ),
                itemBuilder: (_, i) => _monthlyTile(items[i]),
              );
            },
          ),
        ],
      ),
    );
  }

  // 업적 배지
  Widget achieveBadge() {
    return Container(
      width: SizeConfig.screenWidth * 0.9,
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text(
              '업적 배지',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BadgeScreen()),
                );
              },
              style: ButtonStyle(
                overlayColor: WidgetStateColor.resolveWith(
                    (_) => Colors.transparent),
              ),
              child: const Row(
                children: [
                  Text('더보기',
                      style: TextStyle(
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      )),
                  Icon(Icons.chevron_right_rounded,
                      color: Color(0xff777777), size: 14),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 8),
          FutureBuilder<List<BadgeItem>>(
            future: _recentBadgesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 14.0,
                  childAspectRatio: 0.50,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    SizedBox.shrink(),
                    SizedBox.shrink(),
                    SizedBox.shrink(),
                  ],
                );
              }
              if (snapshot.hasError) {
                return Text(
                  '배지를 불러오는 중 오류가 발생했습니다.\n${snapshot.error}',
                  style:
                      const TextStyle(color: Color(0xff777777), fontSize: 12),
                );
              }

              final badges = (snapshot.data ?? const <BadgeItem>[]);
              if (badges.isEmpty) {
                return const Text(
                  '아직 획득한 배지가 없어요.',
                  style:
                      TextStyle(color: Color(0xff777777), fontSize: 12),
                );
              }

              final view = badges.take(3).toList();

              return GridView.builder(
                itemCount: view.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _achieveCross,
                  mainAxisSpacing: _achieveMainSpace,
                  crossAxisSpacing: _achieveCrossSpace,
                  childAspectRatio: _achieveAspect,
                ),
                itemBuilder: (_, i) => _achievementTile(view[i]),
              );
            },
          ),
        ],
      ),
    );
  }
}
