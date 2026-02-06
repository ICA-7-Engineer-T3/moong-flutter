# Firebase 협업 가이드

**작성일**: 2026-02-06
**프로젝트**: Moong Flutter
**대상**: 개발팀 전체

---

## 목차

1. [협업 환경 설정](#협업-환경-설정)
2. [Git 워크플로우](#git-워크플로우)
3. [Firebase 프로젝트 공유](#firebase-프로젝트-공유)
4. [개발 가이드라인](#개발-가이드라인)
5. [문제 해결 (FAQ)](#문제-해결-faq)

---

## 협업 환경 설정

### 신규 개발자 온보딩

**1단계: 프로젝트 클론**
```bash
git clone https://github.com/ICA-7-Engineer-T3/moong-flutter.git
cd moong-flutter
```

**2단계: 의존성 설치**
```bash
# Flutter 의존성
flutter pub get

# Firebase CLI 설치 (전역)
npm install -g firebase-tools

# FlutterFire CLI 설치
dart pub global activate flutterfire_cli
```

**3단계: Firebase 로그인**
```bash
# Firebase 계정 로그인
firebase login

# 프로젝트 설정 확인
firebase projects:list

# Moong 프로젝트 확인 (moong-736e9)
```

**4단계: Firebase 설정 재생성**
```bash
# FlutterFire 설정 (기존 firebase_options.dart 덮어쓰기)
flutterfire configure --project=moong-736e9

# 플랫폼 선택
# ✅ iOS
# ✅ Android
# ✅ Web
```

**5단계: 앱 실행 테스트**
```bash
# Web에서 실행
flutter run -d chrome

# 로그인 테스트
# 이메일: hong@talkcrm24.com
# 비밀번호: (팀 공유 문서 참고)
```

### 필수 도구 설치

| 도구 | 버전 | 설치 명령 | 용도 |
|------|------|-----------|------|
| Flutter | ^3.7.2 | `flutter --version` | 앱 개발 |
| Dart | ^3.7.2 | (Flutter 포함) | 언어 |
| Firebase CLI | latest | `npm i -g firebase-tools` | Firebase 관리 |
| FlutterFire CLI | latest | `dart pub global activate flutterfire_cli` | Firebase 설정 |
| Git | latest | `git --version` | 버전 관리 |

---

## Git 워크플로우

### 브랜치 전략

**메인 브랜치:**
- `main` - 프로덕션 배포 브랜치 (보호됨)
- `feat/production-readiness` - 현재 개발 브랜치 (Firebase 마이그레이션)

**기능 브랜치 네이밍:**
```
feat/기능명         # 새 기능 (예: feat/chat-pagination)
fix/버그명          # 버그 수정 (예: fix/auth-logout)
refactor/작업명     # 리팩토링 (예: refactor/provider-immutability)
test/테스트명       # 테스트 추가 (예: test/moong-provider)
docs/문서명         # 문서 작업 (예: docs/firebase-setup)
```

### 커밋 메시지 규칙

**형식:**
```
<type>: <subject>

<body (optional)>
```

**타입:**
- `feat` - 새 기능
- `fix` - 버그 수정
- `refactor` - 코드 리팩토링
- `test` - 테스트 추가/수정
- `docs` - 문서 업데이트
- `chore` - 빌드/설정 변경

**예시:**
```bash
# 좋은 예
git commit -m "feat: add chat message pagination

- Implemented ChatProvider.loadMoreMessages()
- Added hasMore flag for infinite scroll
- Updated chat_screen.dart with ListView builder"

# 나쁜 예
git commit -m "Update files"
```

### Pull Request 가이드

**PR 생성 전 체크리스트:**
- [ ] `flutter analyze` 통과 (0 errors)
- [ ] 관련 테스트 작성 및 통과
- [ ] 코드 리뷰어 1명 이상 지정
- [ ] PR 설명에 변경 사항 상세 기술

**PR 템플릿:**
```markdown
## 변경 사항
- 구현한 기능 또는 수정한 버그

## 테스트 계획
- [ ] 단위 테스트 추가
- [ ] 통합 테스트 확인
- [ ] 수동 테스트 완료

## 스크린샷 (해당 시)
(UI 변경 시 스크린샷 첨부)

## 리뷰 요청 사항
- 특별히 확인이 필요한 부분
```

---

## Firebase 프로젝트 공유

### IAM 권한 설정

**Firebase Console → Project Settings → Users and permissions**

| 역할 | 권한 | 설명 |
|------|------|------|
| Owner | 모든 권한 | 프로젝트 삭제 가능 (팀 리더) |
| Editor | 읽기/쓰기 | Firestore 데이터 수정 가능 |
| Viewer | 읽기 전용 | 데이터 조회만 가능 |

**권장 역할:**
- **백엔드 개발자**: Editor
- **프론트엔드 개발자**: Editor (Firestore Rules 배포 필요)
- **디자이너**: Viewer
- **QA 엔지니어**: Viewer

### 협업 시 주의사항

**1. Firestore Rules 수정 시**
```bash
# 1. 수정 전 백업
firebase firestore:rules get > firestore.rules.backup

# 2. 로컬에서 테스트
firebase emulators:start --only firestore

# 3. 팀에 공지 후 배포
firebase deploy --only firestore:rules

# 4. Firebase Console에서 확인
```

**2. 데이터 직접 수정 시**
- ⚠️ Firebase Console에서 프로덕션 데이터 직접 수정 금지
- ✅ 테스트 환경 사용 또는 로컬 에뮬레이터 권장

**3. Service Account 키 공유**
- ❌ Slack/Email로 키 파일 전송 금지
- ✅ 팀 내부 보안 저장소 사용 (예: 1Password)
- ✅ 각 개발자가 Firebase Console에서 직접 다운로드

---

## 개발 가이드라인

### Repository 패턴 사용

**DO: Repository를 통한 데이터 접근**
```dart
// ✅ 올바른 예
class MyProvider with ChangeNotifier {
  final MoongRepository _moongRepository;

  Future<void> loadMoongs(String userId) async {
    final moongs = await _moongRepository.getAllMoongs(userId);
    // ...
  }
}
```

**DON'T: Firestore 직접 호출**
```dart
// ❌ 잘못된 예
class MyProvider with ChangeNotifier {
  Future<void> loadMoongs(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('moongs')
        .get();
    // ...
  }
}
```

### 불변성 유지

**DO: copyWith 사용**
```dart
// ✅ 올바른 예
Future<void> updateCredits(int credits) async {
  _currentUser = _currentUser!.copyWith(credits: credits);
  await _userRepository.updateUser(_currentUser!);
  notifyListeners();
}
```

**DON'T: 직접 수정**
```dart
// ❌ 잘못된 예
Future<void> updateCredits(int credits) async {
  _currentUser!.credits = credits; // 돌연변이!
  await _userRepository.updateUser(_currentUser!);
  notifyListeners();
}
```

### 에러 처리

**DO: 포괄적인 에러 처리**
```dart
// ✅ 올바른 예
try {
  await _repository.createMoong(userId, moong);
} on FirebaseException catch (e) {
  debugPrint('Firestore error: ${e.code} - ${e.message}');
  // 사용자에게 친화적인 메시지 표시
  throw Exception('펫 생성에 실패했습니다. 다시 시도해주세요.');
} catch (e) {
  debugPrint('Unexpected error: $e');
  rethrow;
}
```

**DON'T: 에러 무시**
```dart
// ❌ 잘못된 예
try {
  await _repository.createMoong(userId, moong);
} catch (e) {
  // 아무것도 안 함
}
```

### 테스트 작성

**필수 테스트:**
- ✅ 단위 테스트 (Provider, Repository)
- ✅ 통합 테스트 (데이터 흐름)
- ⏳ E2E 테스트 (Playwright)

**테스트 모킹:**
```dart
// Firebase 모킹 예시
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth(signedIn: false);
    fakeFirestore = FakeFirebaseFirestore();
  });

  test('사용자 생성 테스트', () async {
    final repository = UserRepositoryFirestore(firestore: fakeFirestore);
    // ...
  });
}
```

---

## 문제 해결 (FAQ)

### Q1: firebase_options.dart가 없어요!

**답변:**
```bash
# FlutterFire CLI로 재생성
flutterfire configure --project=moong-736e9

# 플랫폼 선택 후 파일 자동 생성됨
# lib/firebase_options.dart
```

### Q2: Firestore 권한 오류가 발생해요!

**증상:**
```
[cloud_firestore/permission-denied] Missing or insufficient permissions
```

**해결:**
1. Firebase Console → Firestore → Rules 확인
2. 로그인 상태 확인 (`FirebaseAuth.instance.currentUser`)
3. UID가 올바른지 확인
4. Security Rules 테스트

### Q3: 웹에서 Firebase가 로딩되지 않아요!

**해결:**
```bash
# 1. 캐시 클리어
flutter clean

# 2. 의존성 재설치
flutter pub get

# 3. 재실행
flutter run -d chrome

# 4. 브라우저 캐시 삭제 (Ctrl+Shift+R)
```

### Q4: 다른 개발자가 작업한 Firestore Rules가 덮어써졌어요!

**예방:**
```bash
# 1. 작업 전 최신 코드 pull
git pull origin feat/production-readiness

# 2. Rules 파일 확인
cat firestore.rules

# 3. 수정 후 커밋
git add firestore.rules
git commit -m "feat: update Firestore security rules"

# 4. 배포
firebase deploy --only firestore:rules
```

### Q5: 테스트 데이터가 프로덕션에 들어갔어요!

**대응:**
```bash
# 1. 즉시 Firebase Console에서 삭제

# 2. 향후 예방: 환경 분리
# - 개발: moong-dev
# - 프로덕션: moong-736e9
```

### Q6: Service Account 키를 잃어버렸어요!

**해결:**
1. Firebase Console → Project Settings → Service Accounts
2. **Generate New Private Key** 클릭
3. JSON 파일 다운로드
4. `.claude/` 폴더에 저장 (`.gitignore` 포함 확인)

### Q7: Flutter 업데이트 후 Firebase 오류가 발생해요!

**해결:**
```bash
# 1. Flutter 버전 확인
flutter --version

# 2. Firebase 의존성 업데이트
flutter pub upgrade

# 3. Firebase 설정 재생성
flutterfire configure

# 4. 클린 빌드
flutter clean && flutter pub get
flutter run
```

---

## 코드 리뷰 가이드

### 리뷰어 체크리스트

**기능:**
- [ ] 요구사항을 충족하는가?
- [ ] 엣지 케이스를 고려했는가?
- [ ] 에러 처리가 적절한가?

**코드 품질:**
- [ ] Repository 패턴을 따르는가?
- [ ] 불변성을 유지하는가?
- [ ] 네이밍이 명확한가?

**테스트:**
- [ ] 단위 테스트가 작성되었는가?
- [ ] 테스트 커버리지가 적절한가? (목표: 80%+)

**보안:**
- [ ] API 키나 비밀번호가 하드코딩되지 않았는가?
- [ ] 사용자 입력 검증이 있는가?

### 리뷰 코멘트 예시

**건설적인 피드백:**
```
✅ "이 부분은 copyWith를 사용해서 불변성을 유지하는 게 좋을 것 같아요."

✅ "에러 처리가 잘 되어 있네요! 다만 사용자에게 보여줄 메시지도 추가하면 더 좋을 것 같습니다."

❌ "이 코드 이상해요." (구체적이지 않음)
```

---

## 배포 프로세스

### 개발 환경 → 프로덕션

**1단계: 테스트**
```bash
# 모든 테스트 실행
flutter test

# 분석 도구 실행
flutter analyze
```

**2단계: 빌드**
```bash
# Web 빌드
flutter build web --release

# iOS 빌드 (macOS)
flutter build ios --release

# Android 빌드
flutter build apk --release
flutter build appbundle --release
```

**3단계: Firebase 배포 (Web)**
```bash
# Hosting 배포
firebase deploy --only hosting

# 배포 확인
firebase hosting:channel:list
```

**4단계: 모니터링**
- Firebase Console → Analytics 확인
- 에러 로그 모니터링
- 사용자 피드백 수집

---

## 추가 리소스

### 내부 문서
- 📘 [Firestore ERD](./FIRESTORE_ERD.md)
- 🔒 [Firebase 보안 규칙](./FIREBASE_SECURITY.md)
- ⚙️ [Firebase 설정 가이드](./FIREBASE_SETUP.md)

### 외부 리소스
- [Flutter 공식 문서](https://docs.flutter.dev)
- [Firebase 공식 문서](https://firebase.google.com/docs)
- [FlutterFire 문서](https://firebase.flutter.dev)
- [Provider 패턴 가이드](https://pub.dev/packages/provider)

### 팀 커뮤니케이션
- Slack 채널: `#moong-dev`
- 주간 스탠드업: 매주 월요일 10:00
- 코드 리뷰: PR 생성 후 24시간 내

---

## 문의 및 지원

**기술 문의:**
- 슬랙 `#moong-dev` 채널에 질문 작성
- 긴급한 경우 팀 리더에게 직접 연락

**버그 리포트:**
- GitHub Issues 사용
- 재현 단계 명확히 기술
- 스크린샷 또는 에러 로그 첨부

**기능 제안:**
- GitHub Discussions 사용
- 사용 사례와 기대 효과 설명
