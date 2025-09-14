import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/firebase_options.dart';
import 'package:wanbook/provider/badge_provider.dart';
import 'package:wanbook/provider/recommend_provider.dart';
import 'package:wanbook/provider/search_provider.dart';
import 'package:wanbook/provider/user_book_provider.dart';
import 'package:wanbook/provider/user_provider.dart';
import 'package:wanbook/provider/attendance_provider.dart';
import 'package:wanbook/provider/recentsearch_provider.dart';
import 'package:wanbook/provider/chat_provider.dart';
import 'package:wanbook/provider/question_provider.dart';
import 'package:wanbook/screen/home/splash_screen.dart';
import 'package:wanbook/shared/alarm.dart';
import 'package:wanbook/shared/size_config.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserProvider(),),
          ChangeNotifierProvider(create: (context) => SearchProvider()),
          ChangeNotifierProvider(create: (context) => UserBookProvider(),),
          ChangeNotifierProvider(create: (_) => AttendanceProvider(),),
          ChangeNotifierProvider(create: (_) => RecentSearchProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => RecommendProvider()),
          ChangeNotifierProvider(create: (_) => QuestionProvider()),
          ChangeNotifierProvider(create: (_) => BadgeProvider()),
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          SizeConfig.init(context);
          return MaterialApp(
            title: '완북',
            debugShowCheckedModeBanner: false,
            // 테마 설정
            theme: ThemeData(
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: AppBarTheme(
                  scrolledUnderElevation: 0,
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                  )
                ),
                fontFamily: 'Pretendard',
                textSelectionTheme: TextSelectionThemeData(
                  selectionColor: Color(0xffCCE4FF),
                  selectionHandleColor: Color(0xff0077FF)
                )
            ),
            home: SplashScreen(),
          );
        }
    );
  }
}