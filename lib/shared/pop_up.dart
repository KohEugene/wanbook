// 팝업 메뉴
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';

class PopUp extends StatefulWidget {
  const PopUp({super.key});

  @override
  State<PopUp> createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> {
  final _nicknameController = TextEditingController();

  bool _saving = false;  
  bool _picking = false;        
  Uint8List? _previewBytes;    
  String? _pendingBase64;      

  @override
  void initState() {
    super.initState();
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final user = userProv.user;

    _nicknameController.text = user?.nickname ?? '';

    final b64 = user?.profileImageBase64;
    if (b64 != null && b64.isNotEmpty) {
      try {
        final sanitized = b64.contains(',') ? b64.split(',').last : b64;
        _previewBytes = base64Decode(sanitized);
      } catch (_) {
        _previewBytes = null;
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  // 권한
  Future<bool> _ensurePermissionFor(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (status.isGranted) return true;
      _showSnack('카메라 권한이 필요해요.', const Color(0xffFF4F4F));
      if (status.isPermanentlyDenied) openAppSettings();
      return false;
    } else {
      if (Platform.isIOS) {
        final status = await Permission.photos.request();
        if (status.isGranted || status.isLimited) return true;
        _showSnack('사진 접근 권한이 필요해요.', const Color(0xffFF4F4F));
        if (status.isPermanentlyDenied) openAppSettings();
        return false;
      } else {
        final results = await [
          Permission.photos,   // Android 13+
          Permission.storage,  // Android 12 이하
        ].request();
        final ok = results.values.any((s) => s.isGranted);
        if (ok) return true;
        _showSnack('사진 접근 권한이 필요해요.', const Color(0xffFF4F4F));
        if (results.values.any((s) => s.isPermanentlyDenied)) openAppSettings();
        return false;
      }
    }
  }

  // 카메라 or 앨범
  Future<void> _showPickSheet() async {
    if (_picking) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('앨범에서 선택'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndPreview(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('카메라로 찍기'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndPreview(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 이미지 보정 (Base64로 압축+JPG로 변환 등)
  Future<void> _pickAndPreview(ImageSource source) async {
    if (_picking) return;

    final granted = await _ensurePermissionFor(source);
    if (!granted) return;

    try {
      setState(() => _picking = true);

      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: source,
        imageQuality: 100,
      );
      if (picked == null) {
        setState(() => _picking = false);
        return;
      }

      final raw = await picked.readAsBytes();
      final decoded = img.decodeImage(raw);
      if (decoded == null) {
        throw Exception('이미지 디코딩 실패');
      }

      final oriented = img.bakeOrientation(decoded);         
      final resized = img.copyResize(oriented, width: 256);
      final jpgBytes = Uint8List.fromList(img.encodeJpg(resized, quality: 80));

      setState(() {
        _previewBytes = jpgBytes;              
        _pendingBase64 = base64Encode(jpgBytes);  
        _picking = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _picking = false);
      _showSnack('이미지 처리 중 오류가 발생했어요: $e', const Color(0xffFF4F4F));
    }
  }

  // 닉네임 및 사진 변경 시 저장
  Future<void> _applyChanges() async {
    if (_saving) return;

    final newNickname = _nicknameController.text.trim();
    if (newNickname.isEmpty) {
      _showSnack('닉네임을 입력해 주세요.', const Color(0xffFF4F4F));
      return;
    }

    try {
      setState(() => _saving = true);

      final userProv = Provider.of<UserProvider>(context, listen: false);
      await userProv.updateNicknameInDb(newNickname);

      if (_pendingBase64 != null && _pendingBase64!.isNotEmpty) {
        await userProv.updateProfileImageBase64InDb(_pendingBase64!);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      _showSnack('프로필이 변경되었어요.', const Color(0xff0077FF));
    } catch (e) {
      if (!mounted) return;
      _showSnack('변경 중 오류가 발생했어요: $e', const Color(0xffFF4F4F));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
    }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: 300,
          height: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '변경할 내용을 선택해 주세요',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xffD9D9D9),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (_previewBytes != null)
                    ClipOval(
                      child: Image.memory(
                        _previewBytes!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                  IconButton(
                    onPressed: _picking ? null : _showPickSheet,
                    icon: _picking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xff0077FF),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.photo_camera_rounded,
                            color: Color(0xff777777),
                            size: 20,
                          ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Container(
                width: 266,
                height: 54,
                decoration: ShapeDecoration(
                  color: const Color(0xffF8F8F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: TextFormField(
                  controller: _nicknameController,
                  cursorColor: const Color(0xff0077FF),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: '사용자 명',
                    hintStyle: TextStyle(
                      color: Color(0xff777777),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    suffixIcon:
                        Icon(Icons.edit, color: Color(0xff777777), size: 20),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: _saving ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff777777),
                          backgroundColor: const Color(0xffE4E4E4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          side: BorderSide.none,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: _saving ? null : _applyChanges,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff0077FF),
                          backgroundColor: const Color(0xffCCE4FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          side: BorderSide.none,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xff0077FF),
                                  ),
                                ),
                              )
                            : const Text(
                                '변경',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
