// 사용자 모델 정의
class UserModel {
  final String userId;     // 사용자 아이디 (문서 ID)
  final String nickname;

  UserModel({required this.userId, required this.nickname});

  factory UserModel.fromMap(Map<String, dynamic> data, String docId) {
    return UserModel(
      userId: docId,
      nickname: data['nickname'] ?? '',
    );
  }
}

