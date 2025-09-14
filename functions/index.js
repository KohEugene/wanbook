const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

const notificationMessages = {
    '지식 습득': {
        'low': {
            'title': '새로운 지식을 채울 시간이에요!',
        },
        'mid': {
            'title': '지식 습득의 절반을 넘었어요!',
            'body': '벌써 절반이나 읽으셨네요! 이제 곧 지식의 산을 정복할 시간이에요.',
        },
        'high': {
            'title': '이제 지식 정복이 코앞이에요!',
            'body': '거의 다 읽으셨네요! 마지막까지 힘내서 지식을 완전히 내 것으로 만들어봐요.',
        },
    },
    '공감 능력 향상': {
        'low': {
            'title': '타인의 마음에 귀 기울여보세요.',
            'body': '이야기 속 주인공의 감정에 공감하다 보면 어느새 당신의 마음도 더 넓어질 거예요.',
        },
        'mid': {
            'title': '공감 능력이 한 단계 성장했어요!',
            'body': '책 속 인물의 삶을 통해 세상에 대한 이해가 깊어지고 있어요.',
        },
        'high': {
            'title': '이제 당신의 마음도 이야기의 주인공처럼!',
            'body': '마지막 장을 넘기며 책이 선물하는 따뜻한 공감을 온전히 느껴보세요.',
        },
    },
    '재미와 힐링': {
        'low': {
            'title': '책과 함께하는 힐링 타임!',
            'body': '하루의 고단함을 잊게 해줄 흥미로운 이야기 속으로 떠나볼 시간이에요.',
        },
        'mid': {
            'title': '책 속 세상이 점점 더 재밌어지고 있어요.',
            'body': '이야기의 절정을 향해 달려가고 있네요! 남은 이야기도 책멍이가 응원할게요.',
        },
        'high': {
            'title': '마지막까지 즐겁게 완독해 보세요!',
            'body': '최고의 힐링을 선사할 책의 마지막 장이 당신을 기다리고 있어요.',
        },
    },
    '치매 예방': {
        'low': {
            'title': '뇌를 위한 최고의 운동, 독서!',
            'body': '꾸준한 독서는 뇌를 활성화시켜줘요. 오늘 10분만 투자해서 건강한 뇌를 만들어봐요.',
        },
        'mid': {
            'title': '기억력 향상 효과가 나타나고 있어요!',
            'body': '벌써 절반이나 읽으셨네요! 독서를 통해 뇌를 활발하게 움직여보세요.',
        },
        'high': {
            'title': '똑똑한 뇌를 위한 독서 정복이 코앞!',
            'body': '거의 다 읽으셨네요! 마지막까지 힘내서 뇌 건강을 챙겨보세요.',
        },
    },
    '어려운 책 정복': {
        'low': {
            'title': '포기하지 않고 한 걸음씩!',
            'body': '조금 어려워도 괜찮아요. 한 페이지씩 꾸준히 읽다 보면 어느새 책 한 권을 다 읽게 될 거예요.',
        },
        'mid': {
            'title': '어려운 책도 당신에겐 문제없어요!',
            'body': '벌써 절반이나 읽으셨네요! 난이도 높은 책을 정복하는 기쁨을 느껴보세요.',
        },
        'high': {
            'title': '드디어 어려운 책을 끝낼 시간!',
            'body': '거의 다 읽으셨네요! 당신의 노력으로 곧 어려운 책을 완독하게 될 거예요.',
        },
    },
    '독서 습관 형성': {
        'low': {
            'title': '독서 습관의 시작, 바로 오늘!',
            'body': '매일 조금씩 읽는 습관이 모여 위대한 변화를 만들어요.',
        },
        'mid': {
            'title': '독서 습관의 절반을 넘었어요!',
            'body': '벌써 절반이나 읽으셨네요! 꾸준함으로 독서 습관을 완성해 봐요.',
        },
        'high': {
            'title': '독서 습관을 굳힐 마지막 단계!',
            'body': '거의 다 읽으셨네요! 꾸준한 독서로 습관을 완전히 내 것으로 만들어봐요.',
        },
    },
    '자아 성장': {
        'low': {
            'title': '더 나은 내가 되는 길, 독서!',
            'body': '책은 당신의 생각을 넓히고, 새로운 시각을 선물해 줄 거예요.',
        },
        'mid': {
            'title': '자아 성장의 절반을 넘었어요!',
            'body': '벌써 절반이나 읽으셨네요! 자신을 더 깊이 이해하는 시간이 될 거예요.',
        },
        'high': {
            'title': '자아 성장 완성이 코앞이에요!',
            'body': '거의 다 읽으셨네요! 책이 주는 인사이트로 더 나은 나를 만나보세요.',
        },
    },
    '어휘력 향상': {
        'low': {
            'title': '마법 같은 단어들을 만나보세요.',
            'body': '다양한 단어들을 만나고 사용하다 보면 어느새 표현력이 풍부해질 거예요.',
        },
        'mid': {
            'title': '어휘력 향상의 절반을 넘었어요!',
            'body': '벌써 절반이나 읽으셨네요! 새로운 단어들이 당신의 언어를 더 풍요롭게 할 거예요.',
        },
        'high': {
            'title': '어휘력 정복이 코앞이에요!',
            'body': '거의 다 읽으셨네요! 책 속의 보물 같은 단어들을 모두 내 것으로 만들어봐요.',
        },
    },
    'default': {
        'general': {
            'title': '한 페이지씩 완성하는 독서 습관!',
            'body': '책멍이와 함께 오늘 하루도 책 한 쪽 읽어볼까요?',
        }
    },
};

exports.scheduledNotifications = functions.pubsub
  .schedule("every 1 minutes")
  .timeZone("Asia/Seoul")
  .onRun(async (context) => {
    const usersSnapshot = await admin.firestore().collection("users").get();
    const now = new Date();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const token = userDoc.data().fcmToken;
      if (!token) continue;

      const booksSnapshot = await admin.firestore()
        .collection("users").doc(userId)
        .collection("reading_books").get();

      const candidates = [];
      for (const bookDoc of booksSnapshot.docs) {
        const book = bookDoc.data();
        const lastReadDate = book.update_date?.toDate?.();
        const lastNotifiedDate = book.notify_date?.toDate?.();

        const baseDate = lastNotifiedDate || lastReadDate;
        if (!baseDate) continue;

        const minutesSinceBase = (now - baseDate) / (1000 * 60);
        if (minutesSinceBase >= 1) candidates.push({ id: bookDoc.id, data: book });
      }

      if (candidates.length > 0) {
        const randomIndex = Math.floor(Math.random() * candidates.length);
        const chosenBook = candidates[randomIndex];
        const book = chosenBook.data;

        let progressKey = "general";
        if (book.progress < 0.3) progressKey = "low";
        else if (book.progress < 0.7) progressKey = "mid";
        else progressKey = "high";

        const message = notificationMessages[book.purpose]?.[progressKey]
          ?? notificationMessages["default"]["general"];

        await admin.messaging().send({
          token,
          notification: { title: message.title, body: message.body },
        });

        await admin.firestore()
          .collection("users").doc(userId)
          .collection("books").doc(chosenBook.id)
          .update({ notify_date: now });
      }
    }

    return null;
  });
