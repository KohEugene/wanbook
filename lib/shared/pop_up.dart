
// 팝업 메뉴

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';

class PopUp extends StatefulWidget {
  const PopUp({super.key});

  @override
  State<PopUp> createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> {

  final _nicknameController = TextEditingController();

  // 사용자 정보 수정 다이얼로그
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: 300,
          height: 280,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('변경할 내용을 선택해 주세요', style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
                ),
              ),
              SizedBox(height: 16,),
              Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: Color(0xffD9D9D9),
                          shape: BoxShape.circle),
                    ),
                    Positioned(
                        child: Icon(
                            Icons.photo_camera_rounded,
                            color: Color(0xff777777),
                            size: 20
                        )
                    )
                  ]
              ),
              SizedBox(height: 16,),
              Container(
                width: 266,
                height: 54,
                decoration: ShapeDecoration(
                    color: Color(0xffF8F8F8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))
                ),
                child: TextFormField(
                  controller: _nicknameController,
                  cursorColor: Color(0xff0077FF),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintText: '사용자 명',
                      hintStyle: TextStyle(
                          color: Color(0xff777777),
                          fontWeight: FontWeight.w600,
                          fontSize: 16
                      ),
                    suffixIcon: Icon(Icons.edit, color: Color(0xff777777), size: 20),
                  ),
                ),
              ),
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                        height: 46,
                        child: OutlinedButton(onPressed: (){
                          Navigator.of(context).pop();
                        },
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Color(0xff777777),
                                backgroundColor: Color(0xffE4E4E4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32)
                                ),
                                side: BorderSide(color: Colors.transparent),
                                shadowColor: Colors.transparent,
                                elevation: 0,
                            ),
                            child: Text('취소', style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16),
                            )
                        )
                    ),
                  ),
                  SizedBox(width: 16,),
                  Expanded(
                    child: SizedBox(
                        height: 46,
                        child: OutlinedButton(onPressed: () async {
                          String newNickname = _nicknameController.text.trim();
                          if (newNickname.isEmpty) return;

                          try {
                            final user = Provider.of<UserProvider>(context, listen: false).user;

                            if (user != null) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.userId)
                                  .update({'nickname': newNickname});

                              Provider.of<UserProvider>(context, listen: false)
                                  .updateUserNickname(newNickname);

                              // 팝업 닫기
                              Navigator.of(context).pop();

                              // 사용자에게 알림 등 추가 가능
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('별명이 성공적으로 변경되었어요.'),
                                    backgroundColor: Color(0xff0077FF),
                                  )
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('별명 변경 중 오류가 발생했어요.'),
                                    backgroundColor: Color(0xff0077FF)
                                )
                            );
                          }
                        },
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Color(0xff0077FF),
                                backgroundColor: Color(0xffCCE4FF),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32)
                                ),
                                side: BorderSide(color: Colors.transparent),
                                shadowColor: Colors.transparent,
                                elevation: 0,
                            ),
                            child: Text('변경', style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                            )
                        )
                    ),
                  ),
                ],
              )
            ]
          ),
        ),
      ),
    );
  }
}