
// 접속 화면

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../login/login_screen.dart';
import '../../shared/size_config.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });

    return Scaffold(
      body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Padding(
                  padding: EdgeInsets.only(top: SizeConfig.screenHeight*0.1, left: SizeConfig.screenWidth*0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('책멍이와', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 28, color: Color(0xff777777))),
                      Text('함께 완독하자!', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 28, color: Color(0xff777777))),
                      Text('완북', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28, color: Colors.black))
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 130,
                bottom: 60,
                child: SvgPicture.asset('assets/images/main_Chaekmeong_2.svg', width: 300, height: 300,),
              )
            ],
          )
      ),
    );
  }
}


