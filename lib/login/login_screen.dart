
// 로그인 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanbook/login/join_screen.dart';
import 'package:wanbook/shared/size_config.dart';

import '../shared/menu_bottom.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // 아이디 저장 여부
  bool saveId = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('로그인'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              SizeConfig.screenWidth*0.05, SizeConfig.screenHeight*0.1,
              SizeConfig.screenWidth*0.05, SizeConfig.screenHeight*0.05
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('완북', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22, color: Colors.black)),
              SizedBox(height: 24),
              Container(
                width: SizeConfig.screenWidth * 0.9,
                height: 54,
                decoration: ShapeDecoration(
                    color: Color(0xffF8F8F8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintText: '아이디를 입력해 주세요',
                      hintStyle: TextStyle(
                          color: Color(0xff777777),
                          fontWeight: FontWeight.w400,
                          fontSize: 16
                      )
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: SizeConfig.screenWidth * 0.9,
                height: 54,
                decoration: ShapeDecoration(
                    color: Color(0xffF8F8F8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))
                ),
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintText: '비밀번호를 입력해 주세요',
                      hintStyle: TextStyle(
                          color: Color(0xff777777),
                          fontWeight: FontWeight.w400,
                          fontSize: 16
                      )
                  ),
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: SizeConfig.screenWidth * 0.9,
                height: 57,
                child: TextButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MenuBottom();
                  },));
                },
                    style: TextButton.styleFrom(
                        backgroundColor: Color(0xffCCE4FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)
                        )
                    ),
                    child: Text('로그인', style: TextStyle(
                        color: Color(0xff0077FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 18
                    ),
                    )
                )
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    activeColor: Colors.transparent,
                    checkColor: Color(0xff777777),
                    value: saveId,
                    onChanged: (value) {
                      setState(() {
                        saveId = value!;
                      });
                      },
                  ),
                  Text('아이디 저장', style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xff777777)
                  )
                  )
                ],
              ),
              Spacer(),
              Divider(thickness: 1, color: Color(0xffC9C9C9)),
              SizedBox(height: 20),
              SizedBox(
                  width: SizeConfig.screenWidth * 0.9,
                  height: 57,
                  child: TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return JoinScreen();
                    },));
                  },
                      style: TextButton.styleFrom(
                          backgroundColor: Color(0xffE4E4E4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)
                          )
                      ),
                      child: Text('회원가입', style: TextStyle(
                          color: Color(0xff777777),
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                      )
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
