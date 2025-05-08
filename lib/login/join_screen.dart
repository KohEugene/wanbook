
// 회원가입 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanbook/login/login_screen.dart';
import 'package:wanbook/shared/menu_bottom.dart';

import '../shared/size_config.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {

  final _idController = TextEditingController();
  final _pwdController = TextEditingController();
  final _rePwdController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nicknameController = TextEditingController();

  // 포커스 여부
  final _idFocus = FocusNode();
  final _pwdFocus = FocusNode();
  final _rePwdFocus = FocusNode();
  final _nicknameFocus = FocusNode();

  // 에러 여부
  bool _idHasError = false;
  bool _pwdHasError = false;
  bool _rePwdHasError = false;
  bool _nicknameHasError = false;

  // 에러 메시지
  String _idError = '';
  String _pwdError = '';
  String _rePwdError = '';
  String _nicknameError = '';

  // 폼 유효성 검사
  bool isFormvalid = false;

  @override
  void initState() {
    super.initState();

    _idFocus.addListener(() {
      if (!_idFocus.hasFocus) validateId();
    });
    _pwdFocus.addListener(() {
      if (!_pwdFocus.hasFocus) validatePassword();
    });
    _rePwdFocus.addListener(() {
      if (!_rePwdFocus.hasFocus) validateRePassword();
    });
    _nicknameFocus.addListener(() {
      if (!_nicknameFocus.hasFocus) validateNickname();
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwdController.dispose();
    _rePwdController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _nicknameController.dispose();

    _idFocus.dispose();
    _pwdFocus.dispose();
    _rePwdFocus.dispose();
    _nicknameFocus.dispose();

    super.dispose();
  }

  // 아이디 유효성 검사 함수 (중복 확인 절차 추가 필요)
  void validateId() {
    setState(() {
      if (_idController.text.length < 6 || _idController.text.length > 20) {
        _idHasError = true;
        _idError = '사용할 수 없는 아이디입니다';
      } else {
        _idHasError = false;
      }
      validateInputs();
    });
  }

  // 비밀번호 유효성 검사 함수
  void validatePassword() {
    setState(() {
      String pwd = _pwdController.text;
      bool hasLetter = pwd.contains(RegExp(r'[A-Za-z]'));
      bool hasNumber = pwd.contains(RegExp(r'[0-9]'));
      bool hasSpecial = pwd.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
      if (pwd.length < 8 || pwd.length > 20 || !(hasLetter && hasNumber && hasSpecial)) {
        _pwdHasError = true;
        _pwdError = '사용할 수 없는 비밀번호입니다';
      } else {
        _pwdHasError = false;
      }
      validateInputs();
    });
  }

  // 비밀번호 재입력 유효성 검사 함수
  void validateRePassword() {
    setState(() {
      if (_rePwdController.text != _pwdController.text) {
        _rePwdHasError = true;
        _rePwdError = '비밀번호가 일치하지 않습니다';
      } else {
        _rePwdHasError = false;
      }
      validateInputs();
    });
  }

  // 별명 유효성 검사 함수
  void validateNickname() {
    setState(() {
      if (_nicknameController.text.isEmpty) {
        _nicknameHasError = true;
        _nicknameError = '사용할 수 없는 별명입니다';
      } else {
        _nicknameHasError = false;
      }
      validateInputs();
    });
  }

  // 모든 조건 충족 여부 검사 함수
  void validateInputs() {
    setState(() {
      isFormvalid = !_idHasError && !_pwdHasError && !_rePwdHasError && !_nicknameHasError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth*0.05, vertical: SizeConfig.screenHeight*0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildFieldWithError(
                            controller: _idController, focusNode: _idFocus,
                            label: '아이디', hintText: '아이디 입력 (6~20자)',
                            hasError: _idHasError, errorMessage: _idError,
                            hasCheckButton: true
                        ),
                        buildFieldWithError(
                            controller: _pwdController, focusNode: _pwdFocus,
                            label: '비밀번호', hintText: '비밀번호 입력 (문자, 숫자, 특수문자 포함 8~20자)',
                            hasError: _pwdHasError, errorMessage: _pwdError
                        ),
                        buildFieldWithError(
                            controller: _rePwdController, focusNode: _rePwdFocus,
                            label: '비밀번호 확인', hintText: '비밀번호 재입력',
                            hasError: _rePwdHasError, errorMessage: _rePwdError
                        ),
                        buildSimpleField(
                            controller: _nameController,
                            label: '이름', hintText: '이름을 입력해 주세요'
                        ),
                        buildSimpleField(
                            controller: _phoneController,
                            label: '전화번호', hintText: "휴대폰 번호 입력 ('-' 제외 11자리 입력)"
                        ),
                        buildFieldWithError(
                            controller: _nicknameController, focusNode: _nicknameFocus,
                            label: '별명', hintText: '별명을 입력해 주세요',
                            hasError: _nicknameHasError, errorMessage: _nicknameError,
                            hasCheckButton: true
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                signUpButton()
              ],
            ),
          ),
        ),
      )
    );
  }

  // 에러 메시지 있는 TextFormField
  Widget buildFieldWithError({
    required TextEditingController controller,
    required String label,
    required String hintText,
    FocusNode? focusNode,
    bool hasError = false,
    String errorMessage = '',
    bool obscure = false,
    bool hasCheckButton = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            SizedBox(width: 8,),
            if (hasError)
              Text(errorMessage, style: TextStyle(
                  color: Color(0xffFF4F4F), fontWeight: FontWeight.w400, fontSize: 12)
              ),
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
                      color: hasError ? Color(0xffFF4F4F) : Color(0xffE4E4E4)
                  ),
                  borderRadius: BorderRadius.circular(16)
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                cursorColor: Color(0xff777777),
                obscureText: obscure,
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
                    width: 94,
                    height: 36,
                    child: OutlinedButton(onPressed: (){},
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xff777777),
                            backgroundColor: Color(0xffF8F8F8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)
                            ),
                            side: BorderSide(color: Colors.transparent),
                            shadowColor: Colors.transparent,
                            elevation: 0,
                        ),
                        child: Text('중복 확인', style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
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

  // 단순 입력 TextFormField
  Widget buildSimpleField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
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
            controller: controller,
            cursorColor: Color(0xff777777),
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

  Widget signUpButton() {
    return SizedBox(
        width: SizeConfig.screenWidth * 0.9,
        height: 57,
        child: OutlinedButton(
            onPressed: isFormvalid ? () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MenuBottom()));
            } : null,
            style: OutlinedButton.styleFrom(
                foregroundColor: isFormvalid ? Color(0xff0077FF) : Color(0xff777777),
                backgroundColor: isFormvalid ? Color(0xffCCE4FF) : Color(0xffE4E4E4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                ),
                side: BorderSide(color: Colors.transparent),
                shadowColor: Colors.transparent,
                elevation: 0
            ),
            child: Text('가입하기', style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18),
            )
        )
    );
  }
}