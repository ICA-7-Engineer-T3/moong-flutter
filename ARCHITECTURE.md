# Moong App Architecture

## 📐 시스템 아키텍처 개요

Moong는 Flutter 기반의 크로스플랫폼 가상 펫 육성 앱으로, Clean Architecture 원칙과 Provider 패턴을 활용한 확장 가능한 구조를 갖추고 있습니다.

---

## 🏗️ 레이어 아키텍처

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│    (Screens, Widgets, Providers)        │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│          Business Logic Layer           │
│         (Providers, Services)           │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│           Data Access Layer             │
│            (DAO, Models)                │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│          Persistence Layer              │
│     (SQLite, SharedPreferences)         │
└─────────────────────────────────────────┘
```

---

## 📦 레이어별 상세 설명

### 1. Presentation Layer (UI)

**위치**: `lib/screens/`, `lib/widgets/`

**역할**: 사용자 인터페이스 및 사용자 상호작용 처리

**주요 컴포넌트**:
- **Screens**: 40+ 화면 (로그인, Moong 선택, 정원, 상점, 채팅 등)
- **Widgets**: 재사용 가능한 UI 컴포넌트
- **Theme**: Material 3 디자인 시스템

**기술 스택**:
- Flutter SDK 3.7.2+
- Material Design 3
- flutter_svg (SVG 렌더링)
- cached_network_image (이미지 캐싱)

**핵심 화면**:
```dart
// 메인 플로우
SplashScreen → LoginScreen → MoongSelectScreen → GardenScreen

// 주요 기능 화면
- MainMoongScreen: Moong 상호작용
- ChatScreen/ChatDetailScreen: AI 대화
- ShopScreen/ShopCategoryScreen: 아이템 구매
- QuestScreen: 일일 미션
- ArchiveScreen: Moong 아카이브
- SettingsScreen: 설정 관리
```

---

### 2. Business Logic Layer

**위치**: `lib/providers/`, `lib/services/`

**역할**: 비즈니스 로직, 상태 관리, 외부 서비스 연동

#### 2.1 Providers (상태 관리)

**패턴**: Provider (ChangeNotifier)

**주요 Provider**:

##### AuthProvider
```dart
// 역할: 사용자 인증 및 세션 관리
- 사용자 로그인/로그아웃
- 회원가입
- 세션 복원
- 사용자 정보 업데이트
```

##### MoongProvider
```dart
// 역할: Moong 상태 관리
- Moong 생성/조회
- 레벨업 및 친밀도 관리
- Active Moong 관리
- Moong 졸업 처리
```

**Provider 특징**:
- ChangeNotifier 기반 Reactive 상태 관리
- DAO 레이어를 통한 데이터 접근
- 앱 전역 상태 공유
- 자동 UI 업데이트 (notifyListeners)

#### 2.2 Services

##### DatabaseHelper
```dart
// 역할: SQLite 데이터베이스 초기화 및 관리
- 싱글톤 패턴
- 데이터베이스 생성 (6개 테이블)
- 스키마 버전 관리
- Foreign Key 제약 활성화
- 인덱스 관리 (12개)
```

##### MigrationService
```dart
// 역할: 데이터 마이그레이션
- SharedPreferences → SQLite 마이그레이션
- 사용자 데이터 이전
- Moong 데이터 이전
- 중복 마이그레이션 방지
```

##### SeedDataService
```dart
// 역할: 초기 데이터 시딩
- ShopItem 16개 생성
- 카테고리별 아이템 (의류, 잡화, 가구, 배경, 시즌)
- 중복 시딩 방지
- 앱 첫 실행 시 자동 실행
```

---

### 3. Data Access Layer (DAO)

**위치**: `lib/dao/`

**역할**: 데이터베이스 CRUD 작업 추상화

**패턴**: Data Access Object (DAO)

**주요 DAO 클래스**:

#### UserDao (115줄)
```dart
// 사용자 데이터 관리
Methods:
- insertUser(User) → 사용자 생성
- getUser(userId) → 사용자 조회
- getAllUsers() → 전체 사용자 조회
- updateUser(User) → 사용자 정보 업데이트
- deleteUser(userId) → 사용자 삭제 (CASCADE)
- updateCredits(userId, amount) → 크레딧 업데이트
- updateSprouts(userId, amount) → 새싹 업데이트
```

#### MoongDao (187줄)
```dart
// Moong 데이터 관리
Methods:
- insertMoong(Moong) → Moong 생성
- getMoong(moongId) → Moong 조회
- getMoongsByUser(userId) → 사용자별 Moong 조회
- getActiveMoong(userId) → 활성 Moong 조회
- updateMoong(Moong) → Moong 업데이트
- deleteMoong(moongId) → Moong 삭제
- graduateMoong(moongId) → Moong 졸업
- updateLevel(moongId, level) → 레벨 업데이트
- updateIntimacy(moongId, intimacy) → 친밀도 업데이트
- getActiveMoongsCount(userId) → 활성 Moong 수
- getTotalMoongsCount(userId) → 전체 Moong 수
```

#### QuestDao (261줄)
```dart
// Quest 데이터 관리
Methods:
- insertQuest(Quest) → Quest 생성
- getQuest(questId) → Quest 조회
- getQuestsByMoong(moongId) → Moong별 Quest 조회
- getTodayQuests(moongId) → 오늘의 Quest 조회
- updateQuestProgress(questId, progress) → 진행도 업데이트
- completeQuest(questId) → Quest 완료
- deleteQuest(questId) → Quest 삭제
- getCompletedQuestsCount(moongId) → 완료된 Quest 수
- getCompletionRate(moongId) → Quest 완료율
- getPendingQuests(moongId) → 미완료 Quest 조회
- getQuestsByDateRange(moongId, start, end) → 기간별 Quest 조회
- getQuestsByType(moongId, type) → 타입별 Quest 조회
- hasActiveQuests(moongId) → 활성 Quest 존재 여부
```

#### ShopItemDao (267줄)
```dart
// 상점 아이템 관리
Methods:
- insertShopItem(ShopItem) → 아이템 생성
- insertBatch(List<ShopItem>) → 배치 생성
- getShopItem(itemId) → 아이템 조회
- getAllShopItems() → 전체 아이템 조회
- getAvailableShopItems() → 사용 가능 아이템 조회
- getShopItemsByCategory(category) → 카테고리별 조회
- getShopItemsByCurrency(currency) → 통화별 조회
- getShopItemsByPriceRange(min, max, currency) → 가격대별 조회
- updateShopItem(ShopItem) → 아이템 업데이트
- deleteShopItem(itemId) → 아이템 삭제
- unlockItem(itemId) → 아이템 잠금 해제
- searchShopItems(keyword) → 아이템 검색
- getLockedItems() → 잠긴 아이템 조회
- getFeaturedItems() → 추천 아이템 조회
- getItemCount() → 아이템 총 개수
```

#### UserInventoryDao (282줄)
```dart
// 사용자 인벤토리 관리
Methods:
- addItem(userId, itemId, quantity) → 아이템 추가
- removeItem(userId, itemId, quantity) → 아이템 제거
- getUserInventory(userId) → 사용자 인벤토리 조회
- getInventoryItem(userId, itemId) → 특정 아이템 조회
- hasItem(userId, itemId) → 아이템 보유 여부
- getItemQuantity(userId, itemId) → 아이템 수량 조회
- updateItemQuantity(userId, itemId, quantity) → 수량 업데이트
- deleteInventoryItem(userId, itemId) → 아이템 삭제
- getInventoryByCategory(userId, category) → 카테고리별 인벤토리
- getInventoryWithDetails(userId) → 상세 정보 포함 조회 (JOIN)
- getTotalItems(userId) → 총 아이템 수
- getUniqueItemsCount(userId) → 고유 아이템 수
- getInventoryValue(userId) → 인벤토리 총 가치
- clearInventory(userId) → 인벤토리 비우기
```

#### ChatMessageDao (348줄)
```dart
// 채팅 메시지 관리
Methods:
- insertMessage(ChatMessage) → 메시지 생성
- getMessage(messageId) → 메시지 조회
- getMessagesByMoong(moongId, limit, offset) → Moong별 메시지 조회
- getRecentMessages(moongId, limit) → 최근 메시지 조회
- updateMessage(ChatMessage) → 메시지 업데이트
- deleteMessage(messageId) → 메시지 삭제
- deleteMessagesByMoong(moongId) → Moong별 메시지 삭제
- getMessageCount(moongId) → 메시지 수
- searchMessages(moongId, keyword) → 메시지 검색
- getMessagesByDateRange(moongId, start, end) → 기간별 메시지 조회
- getMessagesBySender(moongId, isUser) → 발신자별 메시지 조회
- getFirstMessage(moongId) → 첫 메시지 조회
- getLastMessage(moongId) → 마지막 메시지 조회
- hasMessages(moongId) → 메시지 존재 여부
- getConversationStats(moongId) → 대화 통계
- getMessagesByEmotion(moongId, emotion) → 감정별 메시지 조회
- getDailyMessageCount(moongId, date) → 일별 메시지 수
- getAverageMessagesPerDay(moongId) → 일평균 메시지 수
- getLongestConversation(moongId) → 최장 대화 조회
- getTotalConversationDuration(moongId) → 총 대화 시간
```

**DAO 특징**:
- 모든 메서드는 async/await 패턴
- 에러 핸들링: try-catch + debugPrint + rethrow
- 트랜잭션 지원
- 복잡한 쿼리: JOIN, GROUP BY, ORDER BY 활용
- 배치 작업 지원 (insertBatch)

---

### 4. Data Model Layer

**위치**: `lib/models/`

**역할**: 데이터 구조 정의 및 직렬화/역직렬화

**주요 모델**:

#### User Model
```dart
class User {
  final String id;
  final String nickname;
  int level;
  int credits;
  int sprouts;
  final DateTime createdAt;
  
  // SQLite serialization
  Map<String, dynamic> toMap();
  static User fromMap(Map<String, dynamic> map);
}
```

#### Moong Model
```dart
enum MoongType { pet, friend, guide }

class Moong {
  final String id;
  final String userId;
  final String name;
  final MoongType type;
  int level;
  int intimacy;
  final DateTime createdAt;
  DateTime? graduatedAt;
  bool isActive;
  
  // SQLite serialization
  Map<String, dynamic> toMap();
  static Moong fromMap(Map<String, dynamic> map);
}
```

#### Quest Model
```dart
enum QuestType { steps, exercise, study, sleep, water }

class Quest {
  final String id;
  final String moongId;
  final QuestType type;
  final String title;
  final String description;
  final int targetValue;
  int currentProgress;
  bool isCompleted;
  final DateTime createdAt;
  DateTime? completedAt;
  
  // SQLite serialization
  Map<String, dynamic> toMap();
  static Quest fromMap(Map<String, dynamic> map);
}
```

#### ShopItem Model
```dart
enum ShopCategory { clothes, accessories, furniture, background, season }
enum Currency { credits, sprouts }

class ShopItem {
  final String id;
  final String name;
  final String description;
  final ShopCategory category;
  final int price;
  final Currency currency;
  final String imageUrl;
  bool isLocked;
  DateTime? unlockDate;
  
  // SQLite serialization
  Map<String, dynamic> toMap();
  static ShopItem fromMap(Map<String, dynamic> map);
}
```

#### ChatMessage Model
```dart
class ChatMessage {
  final String id;
  final String moongId;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  String? emotion;
  
  // SQLite serialization
  Map<String, dynamic> toMap();
  static ChatMessage fromMap(Map<String, dynamic> map);
}
```

**직렬화 규칙**:
- DateTime → `millisecondsSinceEpoch` (int)
- Enum → `toString().split('.').last` (string)
- bool → 0/1 (int)
- null → SQLite NULL

---

## 🗄️ 데이터베이스 스키마

### 테이블 구조

#### 1. users 테이블
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  nickname TEXT NOT NULL,
  level INTEGER NOT NULL DEFAULT 1,
  credits INTEGER NOT NULL DEFAULT 250,
  sprouts INTEGER NOT NULL DEFAULT 250,
  created_at INTEGER NOT NULL
);

CREATE INDEX idx_users_nickname ON users(nickname);
```

#### 2. moongs 테이블
```sql
CREATE TABLE moongs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  level INTEGER NOT NULL DEFAULT 1,
  intimacy INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  graduated_at INTEGER,
  is_active INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_moongs_user_id ON moongs(user_id);
CREATE INDEX idx_moongs_is_active ON moongs(is_active);
```

#### 3. quests 테이블
```sql
CREATE TABLE quests (
  id TEXT PRIMARY KEY,
  moong_id TEXT NOT NULL,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  target_value INTEGER NOT NULL,
  current_progress INTEGER NOT NULL DEFAULT 0,
  is_completed INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  completed_at INTEGER,
  FOREIGN KEY (moong_id) REFERENCES moongs(id) ON DELETE CASCADE
);

CREATE INDEX idx_quests_moong_id ON quests(moong_id);
CREATE INDEX idx_quests_is_completed ON quests(is_completed);
CREATE INDEX idx_quests_created_at ON quests(created_at);
```

#### 4. shop_items 테이블
```sql
CREATE TABLE shop_items (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  price INTEGER NOT NULL,
  currency TEXT NOT NULL,
  image_url TEXT NOT NULL,
  is_locked INTEGER NOT NULL DEFAULT 0,
  unlock_date INTEGER
);

CREATE INDEX idx_shop_items_category ON shop_items(category);
CREATE INDEX idx_shop_items_is_locked ON shop_items(is_locked);
```

#### 5. user_inventory 테이블
```sql
CREATE TABLE user_inventory (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  item_id TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  acquired_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES shop_items(id) ON DELETE CASCADE
);

CREATE INDEX idx_user_inventory_user_id ON user_inventory(user_id);
CREATE INDEX idx_user_inventory_item_id ON user_inventory(item_id);
```

#### 6. chat_messages 테이블
```sql
CREATE TABLE chat_messages (
  id TEXT PRIMARY KEY,
  moong_id TEXT NOT NULL,
  content TEXT NOT NULL,
  is_user INTEGER NOT NULL,
  timestamp INTEGER NOT NULL,
  emotion TEXT,
  FOREIGN KEY (moong_id) REFERENCES moongs(id) ON DELETE CASCADE
);

CREATE INDEX idx_chat_messages_moong_id ON chat_messages(moong_id);
CREATE INDEX idx_chat_messages_timestamp ON chat_messages(timestamp);
```

### Foreign Key 제약 조건

**CASCADE 삭제 정책**:
```
users 삭제 → moongs 자동 삭제
moongs 삭제 → quests, chat_messages 자동 삭제
users 삭제 → user_inventory 자동 삭제
```

**데이터 무결성**:
- Foreign Key 제약 활성화 (`PRAGMA foreign_keys = ON`)
- 참조 무결성 보장
- Orphan 레코드 방지

---

## 🔄 데이터 플로우

### 1. 사용자 로그인 플로우
```
LoginScreen (UI)
     ↓
AuthProvider.login(nickname)
     ↓
UserDao.getUser() or insertUser()
     ↓
AuthProvider.notifyListeners()
     ↓
UI Auto Update (Provider listening)
     ↓
MoongProvider.initialize(userId)
     ↓
MoongDao.getActiveMoong()
     ↓
Navigation → GardenScreen
```

### 2. Moong 생성 플로우
```
MoongSelectScreen (UI)
     ↓
MoongProvider.createMoong(name, type)
     ↓
Moong 객체 생성 (UUID, DateTime)
     ↓
MoongDao.insertMoong()
     ↓
SQLite INSERT
     ↓
MoongProvider.notifyListeners()
     ↓
Navigation → GardenScreen
```

### 3. Quest 생성 및 완료 플로우
```
QuestScreen (UI)
     ↓
Quest 생성 (targetValue 설정)
     ↓
QuestDao.insertQuest()
     ↓
SQLite INSERT
     ↓
Quest 진행 (사용자 활동)
     ↓
QuestDao.updateQuestProgress()
     ↓
SQLite UPDATE
     ↓
진행도 100% 도달
     ↓
QuestDao.completeQuest()
     ↓
SQLite UPDATE (is_completed=1, completed_at)
     ↓
UI 업데이트 (완료 화면)
```

### 4. Shop 구매 플로우
```
ShopScreen (UI)
     ↓
사용자 아이템 선택
     ↓
AuthProvider.currentUser.credits 확인
     ↓
충분한 잔액 확인
     ↓
[Transaction 시작 - 미구현, 향후 개선]
  ↓
  UserDao.updateCredits(-price)
  ↓
  UserInventoryDao.addItem()
[Transaction 종료]
     ↓
UI 업데이트 (구매 완료)
```

### 5. Chat 메시지 플로우
```
ChatScreen (UI)
     ↓
사용자 메시지 입력
     ↓
ChatMessage 객체 생성 (isUser=true)
     ↓
ChatMessageDao.insertMessage()
     ↓
AI 응답 생성 (향후 LLM 연동)
     ↓
ChatMessage 객체 생성 (isUser=false)
     ↓
ChatMessageDao.insertMessage()
     ↓
ChatMessageDao.getRecentMessages()
     ↓
UI 업데이트 (메시지 리스트)
```

---

## 🛠️ 기술 스택

### Core Framework
- **Flutter SDK**: 3.7.2+
- **Dart**: ^3.7.2
- **Material Design 3**: UI/UX 프레임워크

### State Management
- **Provider**: ^6.1.2 (ChangeNotifier 패턴)

### Data Persistence
- **sqflite**: ^2.3.0 (SQLite for Mobile)
- **sqflite_common_ffi**: ^2.3.0 (SQLite for Desktop/Web)
- **path**: ^1.9.0 (파일 경로 관리)
- **shared_preferences**: ^2.3.3 (간단한 키-값 저장)

### UI Components
- **flutter_svg**: ^2.0.10+1 (SVG 렌더링)
- **cached_network_image**: ^3.4.1 (이미지 캐싱)
- **cupertino_icons**: ^1.0.8 (iOS 스타일 아이콘)

### Testing
- **flutter_test**: SDK (단위 테스트)
- **integration_test**: SDK (통합 테스트)

### Development Tools
- **flutter_lints**: ^5.0.0 (코드 품질 검사)

---

## 🔐 보안 및 데이터 관리

### 데이터 보안
- **로컬 데이터 저장**: SQLite (암호화 미적용, 향후 개선)
- **사용자 인증**: 로컬 세션 (서버 인증 미구현)
- **데이터 격리**: userId 기반 완전 격리

### 데이터 백업
- **자동 백업**: 미구현 (향후 개선)
- **수동 백업**: 미구현
- **클라우드 동기화**: 미구현

### 개인정보 처리
- **수집 정보**: 닉네임, Moong 데이터, Quest 기록, 채팅 메시지
- **저장 위치**: 로컬 SQLite 데이터베이스
- **제3자 공유**: 없음 (완전 로컬 앱)

---

## 📱 플랫폼 지원

### 지원 플랫폼
- ✅ **Android**: 완전 지원 (sqflite)
- ✅ **iOS**: 완전 지원 (sqflite)
- ✅ **macOS**: 지원 (sqflite_common_ffi)
- ✅ **Windows**: 지원 (sqflite_common_ffi)
- ✅ **Linux**: 지원 (sqflite_common_ffi)
- ✅ **Web**: 부분 지원 (IndexedDB, 제한적)

### 플랫폼별 차이점
- **모바일**: Native SQLite 사용
- **데스크톱**: sqflite_common_ffi 사용
- **웹**: IndexedDB 사용 (일부 기능 제한)

---

## 🚀 성능 최적화

### 데이터베이스 최적화
- **인덱스**: 12개 인덱스 (빈번한 쿼리 최적화)
- **Foreign Key**: CASCADE 삭제로 수동 삭제 방지
- **배치 작업**: `insertBatch()` 메서드 제공
- **쿼리 최적화**: JOIN 쿼리 활용

### UI 최적화
- **Lazy Loading**: 리스트 페이지네이션
- **이미지 캐싱**: cached_network_image
- **상태 관리**: Provider로 불필요한 리빌드 방지

### 메모리 관리
- **DatabaseHelper 싱글톤**: DB 인스턴스 재사용
- **Provider 라이프사이클**: 자동 dispose

---

## 🔄 확장성 및 유지보수성

### 확장 가능한 구조
- **레이어 분리**: 각 레이어 독립적 수정 가능
- **DAO 패턴**: 데이터 접근 로직 캡슐화
- **Provider 패턴**: 비즈니스 로직 재사용

### 코드 품질
- **Dart Analyze**: 14개 info 경고 (프로덕션 영향 없음)
- **테스트 커버리지**: 13/13 테스트 통과
- **문서화**: 코드 주석 및 외부 문서

### 마이그레이션 전략
- **데이터베이스 버전 관리**: `onUpgrade()` 콜백
- **스키마 마이그레이션**: SQL ALTER TABLE 지원
- **데이터 마이그레이션**: MigrationService

---

## 📊 시스템 메트릭

### 코드 규모
- **총 파일 수**: 100+ 파일
- **총 코드 라인**: 10,000+ 줄
- **DAO 레이어**: 1,462 줄 (6개 파일)
- **Model 레이어**: 500+ 줄 (5개 파일)
- **Provider 레이어**: 300+ 줄 (2개 파일)
- **Screen 레이어**: 40+ 화면

### 데이터베이스
- **테이블**: 6개
- **인덱스**: 12개
- **Foreign Keys**: 5개
- **DAO 메서드**: 80개

---

## 🎯 향후 개선 사항

### 우선순위 P1 (중요)
1. **트랜잭션 처리**: 구매 시 credits 차감 + inventory 추가를 원자적으로 처리
2. **에러 처리 고도화**: 사용자 친화적 에러 메시지
3. **데이터 백업/복원**: 로컬 파일 백업 기능

### 우선순위 P2 (중간)
4. **AI LLM 연동**: ChatGPT/Claude API 연동
5. **서버 동기화**: Firebase/Supabase 연동
6. **푸시 알림**: Quest 완료 알림
7. **소셜 기능**: 친구 초대, 랭킹

### 우선순위 P3 (낮음)
8. **애니메이션 개선**: Moong 인터랙션 애니메이션
9. **다국어 지원**: i18n 구현
10. **접근성 개선**: 스크린 리더 지원

---

## 📚 참고 자료

### 공식 문서
- [Flutter Official Docs](https://docs.flutter.dev)
- [Provider Package](https://pub.dev/packages/provider)
- [sqflite Package](https://pub.dev/packages/sqflite)

### 아키텍처 패턴
- Clean Architecture (Robert C. Martin)
- Repository Pattern
- Provider Pattern (Flutter)

---

**작성일**: 2026-02-03  
**버전**: 1.0  
**작성자**: Warp AI Agent
