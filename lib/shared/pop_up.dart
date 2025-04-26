
// 팝업 메뉴

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanbook/shared/size_config.dart';

class PopUp extends StatefulWidget {
  const PopUp({super.key});

  @override
  State<PopUp> createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)
      ),
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
                SizedBox(
                    width: 118,
                    height: 46,
                    child: TextButton(onPressed: (){
                    },
                        style: TextButton.styleFrom(
                            backgroundColor: Color(0xffE4E4E4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)
                            )
                        ),
                        child: Text('취소', style: TextStyle(
                            color: Color(0xff777777),
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                        )
                    )
                ),
                SizedBox(width: 16,),
                SizedBox(
                    width: 118,
                    height: 46,
                    child: TextButton(onPressed: (){
                    },
                        style: TextButton.styleFrom(
                            backgroundColor: Color(0xffCCE4FF),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)
                            )
                        ),
                        child: Text('변경', style: TextStyle(
                            color: Color(0xff0077FF),
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                        )
                    )
                ),
              ],
            )
          ]
        ),
      ),
    );
  }
}
