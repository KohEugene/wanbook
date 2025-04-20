
// 회원가입 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanbook/home/home_screen.dart';
import 'package:wanbook/login/login_screen.dart';
import 'package:wanbook/shared/menu_bottom.dart';

import '../shared/size_config.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('회원가입'),
        leading: IconButton(onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return LoginScreen();
          },));
        },
          icon: Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth*0.05, vertical: SizeConfig.screenHeight*0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildFieldWithError('아이디', '사용할 수 없는 아이디입니다', '아이디 입력 (6~20자)'),
                        buildFieldWithError('비밀번호', '사용할 수 없는 비밀번호입니다', '비밀번호 입력 (문자, 숫자, 특수문자 포함 8~20자)'),
                        buildFieldWithError('비밀번호 확인', '비밀번호가 일치하지 않습니다', '비밀번호 재입력'),
                        buildSimpleField('이름', '이름을 입력해 주세요'),
                        buildSimpleField('전화번호', "휴대폰 번호 입력 ('-' 제외 11자리 입력)"),
                        buildFieldWithError('별명', '사용할 수 없는 별명입니다', '별명을 입력해 주세요', hasCheckButton: true),
                      ],
                    ),
                  )
              ),
              SizedBox(height: 20),
              SizedBox(
                  width: SizeConfig.screenWidth * 0.9,
                  height: 57,
                  child: ElevatedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return MenuBottom();
                    },));
                  },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffE4E4E4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)
                          )
                      ),
                      child: Text('가입하기', style: TextStyle(
                          color: Color(0xff777777),
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                      )
                  )
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget buildFieldWithError(String label, String errorText, String hintText,
      {bool obscure = false, bool hasCheckButton = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            SizedBox(width: 8,),
            Text(errorText, style: TextStyle(color: Color(0xffFF4F4F), fontWeight: FontWeight.w400, fontSize: 12)),
          ],
        ),
        SizedBox(height: 4),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Container(
              width: SizeConfig.screenWidth * 0.9,
              height: 54,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: Color(0xffE4E4E4)
                  ),
                  borderRadius: BorderRadius.circular(16)
              ),
              child: TextFormField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: hintText,
                    hintStyle: TextStyle(
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w400,
                        fontSize: 14
                    )
                ),
              ),
            ),
            if (hasCheckButton) ...[
              Positioned(
                right: 16,
                child: SizedBox(
                    width: 90,
                    height: 36,
                    child: ElevatedButton(onPressed: (){},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffF8F8F8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)
                            )
                        ),
                        child: Text('중복 확인', style: TextStyle(
                            color: Color(0xff777777),
                            fontWeight: FontWeight.w400,
                            fontSize: 10),
                        )
                    )
                ),
              ),
            ]
          ],
        ),
        SizedBox(height: 8,)
      ],
    );
  }

  Widget buildSimpleField(String label, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        SizedBox(height: 4),
        Container(
          width: SizeConfig.screenWidth * 0.9,
          height: 54,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: Color(0xffE4E4E4)
              ),
              borderRadius: BorderRadius.circular(16)
          ),
          child: TextFormField(
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                hintText: hintText,
                hintStyle: TextStyle(
                    color: Color(0xff777777),
                    fontWeight: FontWeight.w400,
                    fontSize: 14
                )
            ),
          ),
        ),
        SizedBox(height: 8,)
      ],
    );
  }
}
