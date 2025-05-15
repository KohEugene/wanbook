
// 로그인 화면

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanbook/screen/login/join_screen.dart';
import 'package:wanbook/shared/size_config.dart';

import '../../shared/menu_bottom.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _pwdController = TextEditingController();
  
  // 비밀번호 obscure 여부
  bool obscurePwd = true;

  // 아이디 저장 여부
  bool saveId = false;

  // 에러 메시지
  String? _idError;
  String? _pwdError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('로그인'),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
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
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          loginField(),
                          SizedBox(height: 8),
                          passwordField()
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    loginButton(),
                    SizedBox(height: 8),
                    checkSaveId(),
                    SizedBox(height: 20),
                    Divider(thickness: 1, color: Color(0xffC9C9C9)),
                    SizedBox(height: 20),
                    joinButton(),
                  ]
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 아이디 입력 칸
  Widget loginField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: SizeConfig.screenWidth * 0.9,
          height: 54,
          decoration: ShapeDecoration(
              color: Color(0xffF8F8F8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))
          ),
          child: TextFormField(
            controller: _idController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            cursorColor: Color(0xff0077FF),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                hintText: '아이디를 입력해 주세요',
                hintStyle: TextStyle(
                    color: Color(0xff777777),
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                ),
            ),
          ),
        ),
        if (_idError != null)
          Padding(
              padding: EdgeInsets.only(left: 8, top: 4),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, size: 12, color: Color(0xffFF4F4F),),
                  SizedBox(width: 2,),
                  Text(_idError!, style: TextStyle(
                    color: Color(0xffFF4F4F),
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
                  ),
                ],
              ),
          )
      ],
    );
  }

  // 비밀번호 입력 칸
  Widget passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: SizeConfig.screenWidth * 0.9,
          height: 54,
          padding: EdgeInsets.only(right: 12),
          decoration: ShapeDecoration(
            color: Color(0xffF8F8F8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16))
          ),
          child: TextFormField(
            obscureText: obscurePwd,
            controller: _pwdController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            cursorColor: Color(0xff0077FF),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText: '비밀번호를 입력해 주세요',
              hintStyle: TextStyle(
                color: Color(0xff777777),
                fontWeight: FontWeight.w400,
                fontSize: 16
              ),
              suffixIcon: IconButton(
                icon: Icon(obscurePwd ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () {
                  setState(() {
                    obscurePwd = !obscurePwd;
                  });},
                iconSize: 24,
                color: Color(0xff777777),
              )
            ),
          ),
        ),
        if (_pwdError != null)
          Padding(
            padding: EdgeInsets.only(left: 8, top: 4),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, size: 12, color: Color(0xffFF4F4F),),
                SizedBox(width: 2,),
                Text(_pwdError!, style: TextStyle(
                    color: Color(0xffFF4F4F),
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
                ),
              ],
            ),
          )
      ],
    );
  }

  // 로그인 버튼
  Widget loginButton() {
    return SizedBox(
        width: SizeConfig.screenWidth * 0.9,
        height: 57,
        child: OutlinedButton(onPressed: () async {
          setState(() {
            _idError = _idController.text.isEmpty ? '아이디를 입력해 주세요!' : null;
            _pwdError = _pwdController.text.isEmpty ? '비밀번호를 입력해 주세요!' : null;
          });
          if (_idError == null && _pwdError == null) {
            final userId = _idController.text.trim();
            final password = _pwdController.text.trim();
            final email = '$userId@wanbook.com';  // 인증을 위한 가짜 이메일 생성

            try {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password
              );

              final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

              if (!userDoc.exists) {
                setState(() {
                  _idError = '아이디가 존재하지 않아요';
                });
                return;
              }

              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return MenuBottom();
                },
              ));
            } on FirebaseAuthException catch (e) {
              if (e.code == 'user-not-found') {
                setState(() {
                  _idError = '아이디가 존재하지 않아요';
                });
              } else if (e.code == 'wrong-password') {
                setState(() {
                  _pwdError = '비밀번호를 잘못 입력했어요';
                });
              } else {
                setState(() {
                  _pwdError = '로그인 중 오류가 발생했어요';
                });
              }
            }
          }
        },
            style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xff0077FF),
                backgroundColor: Color(0xffCCE4FF),
                padding: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                ),
                side: BorderSide(color: Colors.transparent),
                shadowColor: Colors.transparent,
                elevation: 0
            ),
            child: Text('로그인', style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18
              ),
            )
        )
    );
  }

  // 아이디 저장 체크박스
  Widget checkSaveId() {
    return Row(
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
    );
  }

  // 회원가입 버튼
  Widget joinButton() {
    return SizedBox(
        width: SizeConfig.screenWidth * 0.9,
        height: 57,
        child: OutlinedButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return JoinScreen();
          },));
        },
            style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xff777777),
                backgroundColor: Color(0xffE4E4E4),
                padding: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                ),
                side: BorderSide(color: Colors.transparent),
                shadowColor: Colors.transparent,
                elevation: 0
            ),
            child: Text('회원가입', style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18),
            )
        )
    );
  }
}
