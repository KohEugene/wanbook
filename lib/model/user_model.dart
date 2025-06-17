// 사용자 모델 정의
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String userId;
  final String userPwd;
  final String name;
  final String phonenumber;
  final String nickname;
  final String profileImageUrl;
  final DateTime joinedAt;

  UserModel({required this.email,
    required this.userId,
    required this.userPwd,
    required this.name,
    required this.phonenumber,
    required this.nickname,
    this.profileImageUrl = '',
    required this.joinedAt
  });

  UserModel copyWith({
    String? email,
    String? userId,
    String? userPwd,
    String? name,
    String? phonenumber,
    String? nickname,
    String? profileImageUrl,
    DateTime? joinedAt,
  }) {
    return UserModel(
      email: email ?? this.email,
      userId: userId ?? this.userId,
      userPwd: userPwd ?? this.userPwd,
      name: name ?? this.name,
      phonenumber: phonenumber ?? this.phonenumber,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      email: map['email'] ?? '',
      userId: map['user_id'] ?? '',
      userPwd: '',
      name: map['name'] ?? '',
      phonenumber: map['phone_number'] ?? '',
      nickname: map['nickname'] ?? '',
      profileImageUrl: map['profile_image_url'] ?? '',
      joinedAt: (map['join_date'] as Timestamp).toDate()
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'user_id': userId,
      'name': name,
      'nickname': nickname,
      'phone_number': phonenumber,
      'profile_image_url': profileImageUrl,
      'join_date': joinedAt
    };
  }

  bool isEmpty() {
    return email.isEmpty || userId.isEmpty || userPwd.isEmpty;
  }
}
