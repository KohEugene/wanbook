
// 접속 화면

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../model/user_model.dart';
import '../../provider/user_provider.dart';
import '../../shared/menu_bottom.dart';
import '../login/login_screen.dart';
import '../../shared/size_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLoginStatus();
  }

  Future<void> loadUserData(BuildContext context, String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data()!;
      final userModel = UserModel.fromMap(userData, userId);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(userModel);
    }
  }

  Future<void> checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 2));

    final userId = await storage.read(key: 'keepLogin');
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && userId != null) {
      await loadUserData(context, userId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MenuBottom(initialIndex: 0,)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
