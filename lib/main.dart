import 'package:flutter/material.dart';
import 'package:wanbook/home/splash_screen.dart';
import 'package:wanbook/shared/size_config.dart';

void main() {
  runApp(const MyApp());
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
                fontFamily: 'Pretendard'
            ),
            home: SplashScreen(),
          );
        }
    );
  }
}
