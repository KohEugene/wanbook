
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final Map<String, Map<String, String>> notificationMessages = {
    '지식 습득': {
      'title': '새로운 지식을 채울 시간이에요!',
      'body': '어제 읽은 책에서 새로운 사실을 발견하셨나요? 오늘 한 페이지 더 읽고 지식을 쌓아봐요.',
    },
    '공감 능력 향상': {
      'title': '타인의 마음에 귀 기울여보세요.',
      'body': '이야기 속 주인공의 감정에 공감하다 보면 어느새 당신의 마음도 더 넓어질 거예요.',
    },
    '재미와 힐링': {
      'title': '책과 함께하는 힐링 타임!',
      'body': '하루의 고단함을 잊게 해줄 흥미로운 이야기 속으로 떠나볼 시간이에요. 책멍이가 응원할게요.',
    },
    '치매 예방': {
      'title': '뇌를 위한 최고의 운동, 독서!',
      'body': '꾸준한 독서는 뇌를 활성화시켜줘요. 오늘 10분만 투자해서 건강한 뇌를 만들어봐요.',
    },
    '어려운 책 정복': {
      'title': '포기하지 않고 한 걸음씩!',
      'body': '조금 어려워도 괜찮아요. 한 페이지씩 꾸준히 읽다 보면 어느새 책 한 권을 다 읽게 될 거예요.',
    },
    '독서 습관 형성': {
      'title': '독서 습관의 시작, 바로 오늘!',
      'body': '매일 조금씩 읽는 습관이 모여 위대한 변화를 만들어요. 책과 함께하는 하루를 시작해 보세요.',
    },
    '자아 성장': {
      'title': '더 나은 내가 되는 길, 독서!',
      'body': '책은 당신의 생각을 넓히고, 새로운 시각을 선물해 줄 거예요. 책멍이가 당신의 성장을 응원합니다.',
    },
    '어휘력 향상': {
      'title': '마법 같은 단어들을 만나보세요.',
      'body': '다양한 단어들을 만나고 사용하다 보면 어느새 표현력이 풍부해질 거예요.',
    },
    'default': {
      'title': '한 페이지씩 완성하는 독서 습관!',
      'body': '책멍이와 함께 오늘 하루도 책 한 쪽 읽어볼까요?',
    }
  };

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // 사용자의 독서 목적을 Firebase에서 가져오기
  static Future<List<String>> fetchUserPurposes(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('reading_books')
          .get();

      final purposes = <String>{}; // 중복 제거를 위해 Set 사용
      for (var doc in querySnapshot.docs) {
        final purpose = doc.data()['purpose'] as String?;
        if (purpose != null) {
          purposes.add(purpose);
        }
      }
      return purposes.toList(); // List로 변환하여 반환
    } catch (e) {
      print('Error fetching user purposes: $e');
      return [];
    }
  }

  // 랜덤 메시지 고르기
  static Future<void> sendRandomNotification(String userId) async {
    final userPurposes = await fetchUserPurposes(userId);

    if (userPurposes.isNotEmpty) {
      final randomPurpose = userPurposes[Random().nextInt(userPurposes.length)];

      final message = notificationMessages[randomPurpose] ?? notificationMessages['default']!;

      await showNotification(
        title: message['title']!,
        body: message['body']!,
      );
    }
  }

  static Future<void> showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidNotificationDetails = 
      AndroidNotificationDetails('channel id', 'channel name',
                  channelDescription: 'channel description',
                  importance: Importance.max,
                  priority: Priority.max,
                  showWhen: false
      );

    const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, 
                  iOS: DarwinNotificationDetails(badgeNumber: 1));

      await flutterLocalNotificationsPlugin.show(
          0, title, body, notificationDetails);
  }
}
