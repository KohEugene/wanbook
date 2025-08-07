import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../shared/size_config.dart';
import '../../provider/badge_provider.dart';
import '../../provider/user_provider.dart';

class BadgeScreen extends StatefulWidget {
  const BadgeScreen({super.key});

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  late Future<List<BadgeItem>> _badgesFuture;
  late Future<List<MonthlyRecordItem>> _monthlyFuture;

  // 월간, 업적 배지 기본 UI 세팅
  static const _monthlyCross      = 3;
  static const _monthlyMainSpace  = 16.0;
  static const _monthlyCrossSpace = 14.0;
  static const _monthlyAspect     = 0.8;

  static const _achieveCross      = 3;
  static const _achieveMainSpace  = 16.0;
  static const _achieveCrossSpace = 14.0;
  static const _achieveAspect     = 0.53;

  @override
  void initState() {
    super.initState();
    final userId = context.read<UserProvider>().userId ?? '';

    if (userId.isEmpty) {
      _badgesFuture = Future.value(const <BadgeItem>[]);
      _monthlyFuture = Future.value(const <MonthlyRecordItem>[]);
    } else {
      final provider = context.read<BadgeProvider>();
      _badgesFuture  = provider.getUserAchievements(userId);
      _monthlyFuture = provider.getMonthlyRecords(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('독서 배지'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.screenWidth * 0.05,
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _monthlyRecordSection(),
                const SizedBox(height: 16),
                FutureBuilder<List<BadgeItem>>(
                  future: _badgesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _loadingBox();
                    }
                    if (snapshot.hasError) {
                      return _errorBox(snapshot.error.toString());
                    }
                    final badges = snapshot.data ?? const <BadgeItem>[];
                    return _achievementSection(badges);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 공통 UI
  Widget _loadingBox() => Container(
        width: SizeConfig.screenWidth * 0.9,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: const CircularProgressIndicator(),
      );

  Widget _errorBox(String message) => Container(
        width: SizeConfig.screenWidth * 0.9,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffFCEBEA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text("배지를 불러오는 중 오류가 발생했습니다.\n$message"),
      );

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
                        ? const ColorFilter.mode(Color(0xFF777777), BlendMode.srcIn)
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
          child: _iconOnlyTile(!item.unlocked, svgAsset: item.asset, scale: 0.9),
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

  // 업적 배지 부분
  Widget _achievementTile(BadgeItem b) {
    final (primary, secondary) = _splitStageTitle(b.title);
    final isLocked = !b.unlocked;

    return Column(
      children: [
        Expanded(
          flex: 8,
          child: _iconOnlyTile(isLocked, svgAsset: b.asset, scale: 0.94),
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

  // 월간 기록 섹션
  Widget _monthlyRecordSection() {
    return FutureBuilder<List<MonthlyRecordItem>>(
      future: _monthlyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingBox();
        }
        if (snapshot.hasError) {
          return _errorBox(snapshot.error.toString());
        }
        final items = snapshot.data ?? const <MonthlyRecordItem>[];

        return Container(
          width: SizeConfig.screenWidth * 0.9,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '월간 기록',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.count(
                  crossAxisCount: _monthlyCross,              // 3열
                  mainAxisSpacing: _monthlyMainSpace,
                  crossAxisSpacing: _monthlyCrossSpace,
                  childAspectRatio: _monthlyAspect,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(12, (i) => _monthlyTile(items[i])),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 업적 배지 섹션
  Widget _achievementSection(List<BadgeItem> badges) {
    return Container(
      width: SizeConfig.screenWidth * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '업적 배지',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              itemCount: badges.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _achieveCross,         // 3열
                mainAxisSpacing: _achieveMainSpace,
                crossAxisSpacing: _achieveCrossSpace,
                childAspectRatio: _achieveAspect,
              ),
              itemBuilder: (context, index) => _achievementTile(badges[index]),
            ),
          ),
        ],
      ),
    );
  }
}
