# Firebase 보안 규칙

**작성일**: 2026-02-06
**프로젝트**: Moong Flutter
**보안 정책**: 사용자 데이터 격리 + 읽기 전용 카탈로그

---

## 목차

1. [보안 원칙](#보안-원칙)
2. [Firestore Security Rules](#firestore-security-rules)
3. [Firebase Authentication 설정](#firebase-authentication-설정)
4. [보안 체크리스트](#보안-체크리스트)
5. [일반적인 보안 이슈](#일반적인-보안-이슈)

---

## 보안 원칙

### 핵심 보안 정책

1. **사용자 데이터 격리**
   - 각 사용자는 자신의 데이터만 읽기/쓰기 가능
   - UID 기반 접근 제어

2. **공유 카탈로그**
   - ShopItems는 모든 사용자 읽기 가능
   - 관리자만 쓰기 가능

3. **인증 필수**
   - 모든 데이터 접근은 Firebase Auth 필수
   - 익명 접근 불가

4. **서버 사이드 검증**
   - 중요한 비즈니스 로직은 서버에서 처리
   - 클라이언트는 UI 로직만

---

## Firestore Security Rules

### 전체 규칙 (firestore.rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ==========================================
    // 헬퍼 함수
    // ==========================================

    // 인증된 사용자인지 확인
    function isSignedIn() {
      return request.auth != null;
    }

    // 자신의 데이터인지 확인
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // 관리자 권한 확인 (향후 확장)
    function isAdmin() {
      return isSignedIn() &&
             get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin';
    }

    // ==========================================
    // Users 컬렉션
    // ==========================================

    match /users/{userId} {
      // 읽기: 본인만 가능
      allow read: if isOwner(userId);

      // 쓰기: 본인만 가능 + 데이터 검증
      allow create: if isOwner(userId) &&
                       request.resource.data.keys().hasAll(['nickname', 'level', 'credits', 'sprouts']) &&
                       request.resource.data.level >= 1 &&
                       request.resource.data.credits >= 0 &&
                       request.resource.data.sprouts >= 0;

      allow update: if isOwner(userId) &&
                       request.resource.data.credits >= 0 &&
                       request.resource.data.sprouts >= 0 &&
                       request.resource.data.level >= 1;

      allow delete: if isOwner(userId);

      // ==========================================
      // Moongs 서브컬렉션
      // ==========================================

      match /moongs/{moongId} {
        allow read: if isOwner(userId);

        allow create: if isOwner(userId) &&
                         request.resource.data.userId == userId &&
                         request.resource.data.intimacy >= 0 &&
                         request.resource.data.intimacy <= 100 &&
                         request.resource.data.level >= 1 &&
                         request.resource.data.type in ['pet', 'mate', 'guide'];

        allow update: if isOwner(userId) &&
                         request.resource.data.intimacy >= 0 &&
                         request.resource.data.intimacy <= 100 &&
                         request.resource.data.level >= 1;

        allow delete: if isOwner(userId);
      }

      // ==========================================
      // Quests 서브컬렉션
      // ==========================================

      match /quests/{questId} {
        allow read: if isOwner(userId);

        allow create: if isOwner(userId) &&
                         request.resource.data.userId == userId &&
                         request.resource.data.progress >= 0 &&
                         request.resource.data.type in ['daily', 'special'];

        allow update: if isOwner(userId) &&
                         request.resource.data.progress >= 0;

        allow delete: if isOwner(userId);
      }

      // ==========================================
      // Inventory 서브컬렉션
      // ==========================================

      match /inventory/{inventoryId} {
        allow read: if isOwner(userId);

        allow create: if isOwner(userId) &&
                         request.resource.data.keys().hasAll(['shopItemId', 'purchasedAt']);

        allow update: if false; // 인벤토리는 수정 불가, 삭제만 가능

        allow delete: if isOwner(userId);
      }

      // ==========================================
      // ChatMessages 서브컬렉션
      // ==========================================

      match /chatMessages/{messageId} {
        allow read: if isOwner(userId);

        allow create: if isOwner(userId) &&
                         request.resource.data.keys().hasAll(['moongId', 'message', 'isUser', 'createdAt']) &&
                         request.resource.data.message.size() > 0 &&
                         request.resource.data.message.size() <= 1000; // 메시지 길이 제한

        allow update: if false; // 메시지 수정 불가

        allow delete: if isOwner(userId);
      }
    }

    // ==========================================
    // ShopItems 컬렉션 (공유 카탈로그)
    // ==========================================

    match /shopItems/{itemId} {
      // 읽기: 모든 인증된 사용자 가능
      allow read: if isSignedIn();

      // 쓰기: 관리자만 가능 (또는 테스트 중에는 막아둠)
      allow write: if false; // 프로덕션에서는 관리자만
      // allow write: if isAdmin(); // 향후 관리자 시스템 구축 시
    }

    // ==========================================
    // Admins 컬렉션 (향후 확장)
    // ==========================================

    match /admins/{adminId} {
      allow read: if isSignedIn() && request.auth.uid == adminId;
      allow write: if false; // Firebase Console에서만 수정
    }
  }
}
```

---

## Firebase Authentication 설정

### 인증 방법 활성화

**Firebase Console → Authentication → Sign-in method**

| 방법 | 상태 | 설명 |
|------|------|------|
| 이메일/비밀번호 | ✅ 활성화 | 기본 인증 방법 |
| Google | ❌ 비활성화 | 향후 추가 예정 |
| 익명 | ❌ 비활성화 | 보안상 사용 안 함 |

### 비밀번호 정책

**설정 권장사항:**
- 최소 길이: 8자
- 복잡도: 대소문자 + 숫자 조합
- 재사용 방지: 이전 3개 비밀번호 차단

### 이메일 인증

**옵션:**
- 이메일 인증 필수: ❌ (선택사항)
- 비밀번호 재설정: ✅ 활성화
- 이메일 링크 로그인: ❌ 비활성화

---

## 보안 체크리스트

### 배포 전 필수 확인

- [ ] **Firestore Rules 배포 완료**
  ```bash
  firebase deploy --only firestore:rules
  ```

- [ ] **테스트 계정 제거**
  - Firebase Console에서 테스트 계정 확인
  - 프로덕션 배포 전 삭제

- [ ] **API 키 보안**
  - Service Account 키는 절대 Git 커밋 금지
  - `.gitignore`에 `*.json` 포함 확인

- [ ] **Rate Limiting 설정**
  - Firebase App Check 활성화 권장
  - DDoS 방어 설정

- [ ] **보안 규칙 테스트**
  ```bash
  firebase emulators:start --only firestore
  # 테스트 실행
  ```

### 운영 중 모니터링

- [ ] **이상 접근 패턴 감지**
  - Firebase Console → Firestore → Usage 탭
  - 비정상적인 읽기/쓰기 급증 확인

- [ ] **오류 로그 모니터링**
  - Firebase Console → Firestore → Rules 탭
  - 거부된 요청 로그 확인

- [ ] **인증 로그 검토**
  - Firebase Console → Authentication → Users
  - 계정 생성 패턴 확인

---

## 일반적인 보안 이슈

### 1. 데이터 누출

**문제:**
```javascript
// ❌ 잘못된 예: 모든 사용자가 다른 사용자 데이터 읽기 가능
match /users/{userId} {
  allow read: if true; // 위험!
}
```

**해결:**
```javascript
// ✅ 올바른 예: 본인 데이터만 읽기 가능
match /users/{userId} {
  allow read: if request.auth.uid == userId;
}
```

### 2. 무제한 쓰기

**문제:**
```javascript
// ❌ 잘못된 예: 데이터 검증 없음
match /users/{userId} {
  allow write: if request.auth != null; // 위험!
}
```

**해결:**
```javascript
// ✅ 올바른 예: 데이터 검증 포함
match /users/{userId} {
  allow create: if request.auth.uid == userId &&
                   request.resource.data.credits >= 0 &&
                   request.resource.data.sprouts >= 0;
}
```

### 3. 서브컬렉션 접근 제어 누락

**문제:**
```javascript
// ❌ 잘못된 예: 서브컬렉션 규칙 없음
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
  // moongs, quests 서브컬렉션 규칙 없음!
}
```

**해결:**
```javascript
// ✅ 올바른 예: 서브컬렉션 규칙 명시
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;

  match /moongs/{moongId} {
    allow read, write: if request.auth.uid == userId;
  }
}
```

### 4. 관리자 권한 오용

**문제:**
```javascript
// ❌ 잘못된 예: 하드코딩된 UID
function isAdmin() {
  return request.auth.uid == 'hardcoded_uid_123'; // 위험!
}
```

**해결:**
```javascript
// ✅ 올바른 예: 별도 컬렉션 관리
function isAdmin() {
  return exists(/databases/$(database)/documents/admins/$(request.auth.uid));
}
```

---

## 보안 규칙 테스트

### 로컬 에뮬레이터 사용

**1. 에뮬레이터 시작**
```bash
firebase emulators:start --only firestore,auth
```

**2. 테스트 실행**
```dart
// test/firestore_rules_test.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('사용자는 자신의 데이터만 읽을 수 있다', () async {
    // 사용자 A로 로그인
    final userA = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: 'a@test.com', password: 'test123');

    // 사용자 A 데이터 읽기: 성공
    final docA = await FirebaseFirestore.instance
        .collection('users')
        .doc(userA.user!.uid)
        .get();
    expect(docA.exists, true);

    // 사용자 B 데이터 읽기 시도: 실패
    expect(
      () => FirebaseFirestore.instance
          .collection('users')
          .doc('user_b_uid')
          .get(),
      throwsA(isA<FirebaseException>()),
    );
  });
}
```

### Firebase Console에서 테스트

**Firebase Console → Firestore → Rules 탭**

1. **Rules Playground** 클릭
2. 인증 상태 설정 (Authenticated / Unauthenticated)
3. 테스트할 경로 입력 (예: `/users/test_uid`)
4. 작업 선택 (get, list, create, update, delete)
5. **Run** 클릭하여 결과 확인

---

## 규칙 배포

### 개발 환경

```bash
# 규칙 파일 확인
cat firestore.rules

# 규칙 문법 검증
firebase firestore:rules:validate

# 배포
firebase deploy --only firestore:rules
```

### 프로덕션 배포

```bash
# 1. 규칙 백업
firebase firestore:rules get > firestore.rules.backup

# 2. 새 규칙 배포
firebase deploy --only firestore:rules --project moong-736e9

# 3. Firebase Console에서 확인
# Firestore → Rules → 최신 배포 시간 확인
```

### 롤백

```bash
# 이전 버전으로 복원
cat firestore.rules.backup > firestore.rules
firebase deploy --only firestore:rules
```

---

## 다음 문서

- 👥 [Firebase 협업 가이드](./FIREBASE_COLLABORATION.md)
- 📊 [Firestore ERD](./FIRESTORE_ERD.md)
- ⚙️ [Firebase 설정 가이드](./FIREBASE_SETUP.md)

---

## 참고 자료

- [Firestore Security Rules 공식 문서](https://firebase.google.com/docs/firestore/security/get-started)
- [보안 규칙 테스트](https://firebase.google.com/docs/rules/unit-tests)
- [Firebase App Check](https://firebase.google.com/docs/app-check)
