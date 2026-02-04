# Moong App Use Cases

## 📱 사용자 시나리오

이 문서는 Moong 앱의 모든 주요 유즈케이스를 상세히 설명합니다. 각 유즈케이스는 사용자 관점에서 작성되었으며, 기술적 구현 세부사항도 포함합니다.

---

## 🎯 핵심 유즈케이스

### UC-001: 사용자 등록 및 로그인

#### 사용자 스토리
> "**As a** 신규 사용자, **I want to** 닉네임으로 간단히 가입하고 로그인하여, **So that** 즉시 Moong을 생성하고 키울 수 있다."

#### 사전 조건
- 앱이 설치되어 있음
- 인터넷 연결 불필요 (로컬 앱)

#### 기본 플로우
1. 사용자가 앱을 실행
2. 스플래시 화면 표시 (2초)
3. 로그인 화면 표시
4. 사용자가 닉네임 입력 (2-10자)
5. "시작하기" 버튼 클릭
6. 시스템이 닉네임 중복 확인
   - 신규: User 생성 (credits=250, sprouts=250)
   - 기존: 기존 User 로드
7. AuthProvider 상태 업데이트
8. MoongProvider 초기화
9. Moong 선택 화면으로 이동

#### 대체 플로우
- **닉네임 중복**: 기존 사용자로 로그인
- **닉네임 유효성 실패**: 에러 메시지 표시 (2-10자, 특수문자 제한)
- **데이터베이스 오류**: 에러 다이얼로그 표시

#### 기술적 구현
```dart
// AuthProvider
Future<void> login(String nickname) async {
  final userDao = UserDao();
  User? existingUser = await userDao.getUser(nickname);
  
  if (existingUser == null) {
    // 신규 사용자 생성
    final newUser = User(
      id: Uuid().v4(),
      nickname: nickname,
      level: 1,
      credits: 250,
      sprouts: 250,
      createdAt: DateTime.now(),
    );
    await userDao.insertUser(newUser);
    _currentUser = newUser;
  } else {
    _currentUser = existingUser;
  }
  
  notifyListeners();
}
```

#### 관련 화면
- `SplashScreen`: 앱 초기 로딩
- `LoginScreen`: 로그인/회원가입
- `SignupScreen`: 추가 정보 입력 (선택)

#### 데이터베이스 영향
- **테이블**: `users`
- **작업**: INSERT or SELECT

---

### UC-002: Moong 생성

#### 사용자 스토리
> "**As a** 로그인한 사용자, **I want to** Moong의 이름과 타입을 선택하여, **So that** 나만의 가상 펫을 키울 수 있다."

#### 사전 조건
- 사용자가 로그인되어 있음
- 활성 Moong이 없음 (졸업 또는 첫 생성)

#### 기본 플로우
1. Moong 선택 화면 표시
2. 사용자가 Moong 타입 선택 (Pet/Friend/Guide)
3. 사용자가 Moong 이름 입력 (1-10자)
4. "생성하기" 버튼 클릭
5. 시스템이 Moong 생성
   - UUID 생성
   - 초기 레벨=1, 친밀도=0
   - isActive=true
6. MoongProvider 상태 업데이트
7. 정원 화면으로 이동
8. 환영 애니메이션 표시

#### 대체 플로우
- **이름 유효성 실패**: 에러 메시지 (1-10자)
- **이미 활성 Moong 존재**: 기존 Moong으로 이동
- **데이터베이스 오류**: 재시도 옵션 제공

#### 기술적 구현
```dart
// MoongProvider
Future<void> createMoong(String name, MoongType type) async {
  final moongDao = MoongDao();
  final newMoong = Moong(
    id: Uuid().v4(),
    userId: _userId!,
    name: name,
    type: type,
    level: 1,
    intimacy: 0,
    createdAt: DateTime.now(),
    isActive: true,
  );
  
  await moongDao.insertMoong(newMoong);
  _currentMoong = newMoong;
  notifyListeners();
}
```

#### Moong 타입별 특성
- **Pet**: 친근하고 애교 많음, 놀이 중심
- **Friend**: 친구처럼 대화, 공감 중심
- **Guide**: 조언과 격려, 목표 달성 중심

#### 관련 화면
- `MoongSelectScreen`: Moong 생성
- `MoongChoiceScreen`: 타입 선택 상세
- `GardenScreen`: Moong 홈

#### 데이터베이스 영향
- **테이블**: `moongs`
- **작업**: INSERT
- **제약**: `user_id` Foreign Key

---

### UC-003: Quest 생성 및 완료

#### 사용자 스토리
> "**As a** Moong 소유자, **I want to** 일일 미션을 설정하고 완료하여, **So that** Moong과 함께 성장하고 보상을 받을 수 있다."

#### 사전 조건
- 활성 Moong이 있음
- 오늘의 Quest가 아직 생성되지 않음

#### 기본 플로우

##### 3.1 Quest 생성
1. Quest 화면 진입
2. Quest 타입 선택 (걷기/운동/공부/수면/물마시기)
3. 목표값 설정 (예: 7000보)
4. "생성하기" 버튼 클릭
5. 시스템이 Quest 생성
   - currentProgress=0
   - isCompleted=false
6. Quest 리스트에 표시

##### 3.2 Quest 진행
1. 사용자가 실제 활동 수행 (예: 걷기)
2. Quest 상세 화면에서 진행도 입력 또는 자동 연동 (향후)
3. 시스템이 진행도 업데이트
4. 프로그레스 바 시각적 업데이트

##### 3.3 Quest 완료
1. 진행도가 목표값 도달 (100%)
2. "완료하기" 버튼 활성화
3. 사용자가 완료 버튼 클릭
4. 시스템이 Quest 완료 처리
   - isCompleted=true
   - completedAt 기록
5. 보상 지급
   - Moong 친밀도 +10
   - Credits +50
   - Sprouts +50
6. 완료 축하 화면 표시
7. Moong 레벨업 확인 (친밀도 100 단위)

#### 대체 플로우
- **중복 Quest**: 오늘 이미 생성된 경우 에러
- **미달성 완료 시도**: 완료 불가 메시지
- **Quest 삭제**: 사용자가 Quest 취소 가능

#### 기술적 구현
```dart
// QuestDao
Future<void> completeQuest(String questId) async {
  final db = await DatabaseHelper().database;
  await db.update(
    'quests',
    {
      'is_completed': 1,
      'completed_at': DateTime.now().millisecondsSinceEpoch,
    },
    where: 'id = ?',
    whereArgs: [questId],
  );
}

// Quest 완료 후 보상
Future<void> onQuestCompleted(Quest quest) async {
  final moongDao = MoongDao();
  final userDao = UserDao();
  
  // Moong 친밀도 증가
  final moong = await moongDao.getMoong(quest.moongId);
  final newIntimacy = moong!.intimacy + 10;
  await moongDao.updateIntimacy(quest.moongId, newIntimacy);
  
  // 레벨업 확인
  if (newIntimacy % 100 == 0) {
    await moongDao.updateLevel(quest.moongId, moong.level + 1);
  }
  
  // 사용자 보상
  await userDao.updateCredits(moong.userId, 50);
  await userDao.updateSprouts(moong.userId, 50);
}
```

#### Quest 타입별 목표값
- **Steps (걷기)**: 3000 ~ 10000보
- **Exercise (운동)**: 20 ~ 60분
- **Study (공부)**: 30 ~ 180분
- **Sleep (수면)**: 6 ~ 9시간
- **Water (물)**: 4 ~ 12잔

#### 관련 화면
- `QuestScreen`: Quest 리스트 및 생성
- `QuestCompletedScreen`: 완료 축하

#### 데이터베이스 영향
- **테이블**: `quests`, `moongs`, `users`
- **작업**: INSERT, UPDATE
- **제약**: `moong_id` Foreign Key

---

### UC-004: 상점 아이템 구매

#### 사용자 스토리
> "**As a** Moong 소유자, **I want to** 상점에서 아이템을 구매하여, **So that** Moong을 꾸미고 정원을 꾸밀 수 있다."

#### 사전 조건
- 사용자가 로그인되어 있음
- 충분한 Credits 또는 Sprouts 보유

#### 기본 플로우
1. 상점 화면 진입
2. 카테고리 선택 (의류/잡화/가구/배경/시즌)
3. 아이템 리스트 표시
   - 이름, 설명, 가격, 통화
   - 잠금 상태 (locked/unlocked)
4. 사용자가 아이템 선택
5. 아이템 상세 정보 표시
6. "구매하기" 버튼 클릭
7. 구매 확인 다이얼로그 표시
8. 사용자가 확인
9. 시스템이 잔액 확인
   - 부족: 에러 메시지
   - 충분: 구매 진행
10. 트랜잭션 실행 (향후 개선)
    - Credits/Sprouts 차감
    - Inventory에 아이템 추가
11. 구매 완료 메시지
12. 인벤토리로 이동 (선택)

#### 대체 플로우
- **잔액 부족**: "Credits 부족" 에러, 크레딧 충전 화면으로 이동
- **잠긴 아이템**: "잠금 해제 날짜" 표시, 구매 불가
- **이미 보유**: "이미 보유한 아이템" 메시지 (수량 증가 또는 중복 불가)
- **구매 취소**: 다이얼로그에서 취소 선택

#### 기술적 구현
```dart
// Shop Purchase Flow (현재)
Future<bool> purchaseItem(String userId, String itemId) async {
  final userDao = UserDao();
  final shopItemDao = ShopItemDao();
  final inventoryDao = UserInventoryDao();
  
  // 1. 아이템 조회
  final item = await shopItemDao.getShopItem(itemId);
  if (item == null || item.isLocked) {
    return false;
  }
  
  // 2. 사용자 조회 및 잔액 확인
  final user = await userDao.getUser(userId);
  if (user == null) return false;
  
  final hasBalance = item.currency == Currency.credits
      ? user.credits >= item.price
      : user.sprouts >= item.price;
  
  if (!hasBalance) {
    return false;
  }
  
  // 3. 구매 처리 (트랜잭션 미구현)
  try {
    // 잔액 차감
    if (item.currency == Currency.credits) {
      await userDao.updateCredits(userId, -item.price);
    } else {
      await userDao.updateSprouts(userId, -item.price);
    }
    
    // 인벤토리 추가
    await inventoryDao.addItem(userId, itemId, 1);
    
    return true;
  } catch (e) {
    // 에러 발생 시 롤백 필요 (향후 개선)
    debugPrint('Purchase failed: $e');
    return false;
  }
}

// 향후 개선: Transaction 사용
Future<bool> purchaseItemWithTransaction(String userId, String itemId) async {
  final db = await DatabaseHelper().database;
  
  return await db.transaction((txn) async {
    // 모든 작업을 트랜잭션 내에서 수행
    // 실패 시 자동 롤백
  });
}
```

#### 아이템 카테고리
- **Clothes (의류)**: 모자, 옷, 신발
- **Accessories (잡화)**: 목걸이, 안경, 가방
- **Furniture (가구)**: 의자, 테이블, 침대
- **Background (배경)**: 숲, 해변, 우주, 벚꽃
- **Season (시즌)**: 한정 아이템, 잠금 상태

#### 통화 시스템
- **Credits (크레딧)**: 주 화폐, Quest 보상
- **Sprouts (새싹)**: 보조 화폐, 특별 아이템

#### 관련 화면
- `ShopScreen`: 상점 메인
- `ShopCategoryScreen`: 카테고리별 리스트
- `CreditBalanceScreen`: 크레딧 잔액 확인
- `CreditInfo1Screen`, `CreditInfo2Screen`: 크레딧 정보
- `CreditRefundScreen`: 환불 정책

#### 데이터베이스 영향
- **테이블**: `users`, `shop_items`, `user_inventory`
- **작업**: UPDATE (users), INSERT (user_inventory)
- **제약**: `user_id`, `item_id` Foreign Keys

---

### UC-005: Moong과 채팅

#### 사용자 스토리
> "**As a** Moong 소유자, **I want to** Moong과 대화하여, **So that** 친밀도를 높이고 위로/조언을 받을 수 있다."

#### 사전 조건
- 활성 Moong이 있음
- 채팅 화면 진입

#### 기본 플로우
1. 채팅 화면 진입
2. 기존 대화 내역 로드 (최근 50개)
3. 사용자가 메시지 입력
4. "전송" 버튼 클릭
5. 시스템이 사용자 메시지 저장
   - ChatMessage (isUser=true)
6. UI에 사용자 메시지 표시
7. AI 응답 생성 (현재: 더미, 향후: LLM)
8. 시스템이 Moong 응답 저장
   - ChatMessage (isUser=false, emotion='happy')
9. UI에 Moong 응답 표시
10. 스크롤을 최신 메시지로 이동
11. 친밀도 +1 (메시지당)

#### 대체 플로우
- **빈 메시지**: 전송 버튼 비활성화
- **긴 메시지**: 500자 제한, 초과 시 알림
- **네트워크 오류** (향후 LLM 연동 시): 재시도 옵션
- **메시지 삭제**: 길게 눌러 삭제 (선택)

#### 기술적 구현
```dart
// ChatMessageDao
Future<void> sendMessage(String moongId, String content, bool isUser) async {
  final chatMessageDao = ChatMessageDao();
  
  final message = ChatMessage(
    id: Uuid().v4(),
    moongId: moongId,
    content: content,
    isUser: isUser,
    timestamp: DateTime.now(),
    emotion: isUser ? null : _detectEmotion(content),
  );
  
  await chatMessageDao.insertMessage(message);
}

// 현재: 더미 AI 응답
String _generateDummyResponse(String userMessage) {
  final responses = [
    "그렇구나! 재밌겠다~",
    "응원할게! 화이팅!",
    "오늘 하루도 수고했어!",
    "우와, 정말 멋진데?",
    "함께 있어서 행복해!",
  ];
  return responses[Random().nextInt(responses.length)];
}

// 향후: LLM API 연동
Future<String> _generateAIResponse(String userMessage, String moongType) async {
  // OpenAI/Claude API 호출
  // Moong 타입별 페르소나 적용
  // - Pet: 애교 많고 친근한 말투
  // - Friend: 공감하고 대화하는 말투
  // - Guide: 조언과 격려하는 말투
}
```

#### 감정 분석 (향후)
- **Happy**: 긍정적 내용 감지
- **Sad**: 부정적 내용 감지
- **Excited**: 흥분된 내용 감지
- **Calm**: 평온한 내용 감지

#### 채팅 통계
- 총 메시지 수
- 사용자 vs Moong 메시지 비율
- 일평균 메시지 수
- 최장 대화 시간
- 감정별 메시지 분포

#### 관련 화면
- `ChatScreen`: 채팅 리스트 (Moong 선택)
- `ChatDetailScreen`: 1:1 대화
- `ChatInputScreen`: 메시지 입력 (전체 화면)
- `EmotionAnalysisScreen`: 감정 분석 결과

#### 데이터베이스 영향
- **테이블**: `chat_messages`
- **작업**: INSERT, SELECT
- **제약**: `moong_id` Foreign Key

---

### UC-006: Moong 레벨업 및 졸업

#### 사용자 스토리
> "**As a** Moong 소유자, **I want to** Moong의 레벨을 올리고 최종적으로 졸업시켜, **So that** 새로운 Moong을 키울 수 있다."

#### 사전 조건
- 활성 Moong이 있음
- 충분한 친밀도 획득

#### 기본 플로우

##### 6.1 레벨업
1. Quest 완료 또는 채팅으로 친밀도 축적
2. 친밀도 100 단위마다 레벨업
   - 예: 친밀도 0→100: Lv 1→2
   - 예: 친밀도 100→200: Lv 2→3
3. 레벨업 애니메이션 표시
4. 축하 메시지 및 보상
   - Credits +100
   - 새로운 상호작용 잠금 해제

##### 6.2 졸업
1. Moong이 레벨 10 도달
2. 졸업 가능 알림 표시
3. 사용자가 졸업 선택
4. 졸업 확인 다이얼로그
   - "정말 졸업시키겠습니까?"
   - "졸업 후 다시 돌아올 수 없습니다"
5. 사용자가 확인
6. 시스템이 Moong 졸업 처리
   - isActive=false
   - graduatedAt 기록
7. 졸업 축하 화면
8. Moong 아카이브로 이동
9. 새 Moong 생성 옵션 제공

#### 대체 플로우
- **졸업 취소**: 계속 키우기 선택
- **레벨 10 미만 졸업**: 불가, 최소 레벨 10 필요
- **졸업 후 복구**: 불가 (향후 개선 시 고려)

#### 기술적 구현
```dart
// MoongDao
Future<void> graduateMoong(String moongId) async {
  final db = await DatabaseHelper().database;
  await db.update(
    'moongs',
    {
      'is_active': 0,
      'graduated_at': DateTime.now().millisecondsSinceEpoch,
    },
    where: 'id = ?',
    whereArgs: [moongId],
  );
}

// 레벨업 로직
void checkLevelUp(Moong moong) {
  final currentLevel = moong.level;
  final expectedLevel = (moong.intimacy ~/ 100) + 1;
  
  if (expectedLevel > currentLevel) {
    // 레벨업!
    moongDao.updateLevel(moong.id, expectedLevel);
    
    // 보상 지급
    userDao.updateCredits(moong.userId, 100);
    
    // 레벨업 알림
    showLevelUpDialog(expectedLevel);
  }
}
```

#### 레벨별 마일스톤
- **Lv 1-3**: 유아기, 기본 상호작용
- **Lv 4-6**: 성장기, 다양한 활동
- **Lv 7-9**: 청소년기, 깊은 대화
- **Lv 10**: 성인기, 졸업 가능

#### 관련 화면
- `IntimacyUpScreen`: 친밀도 증가 알림
- `ArchiveScreen`: 졸업한 Moong 보관함
- `ArchiveMainScreen`: 아카이브 메인
- `StatisticsScreen`: Moong 통계

#### 데이터베이스 영향
- **테이블**: `moongs`, `users`
- **작업**: UPDATE
- **제약**: CASCADE (졸업 시 Quest/Chat 유지)

---

### UC-007: 정원 꾸미기

#### 사용자 스토리
> "**As a** Moong 소유자, **I want to** 정원의 배경과 가구를 배치하여, **So that** 나만의 공간을 만들 수 있다."

#### 사전 조건
- 활성 Moong이 있음
- 인벤토리에 배경/가구 아이템 보유

#### 기본 플로우
1. 정원 화면 진입
2. "꾸미기" 버튼 클릭
3. 편집 모드 진입
4. 인벤토리에서 아이템 선택
   - 배경: 숲/해변/우주/벚꽃
   - 가구: 의자/테이블/침대 등
5. 아이템을 화면에 배치
6. 드래그로 위치 조정
7. "저장" 버튼 클릭
8. 정원 레이아웃 저장 (향후 구현)
9. 편집 모드 종료
10. 꾸며진 정원 확인

#### 대체 플로우
- **미보유 아이템**: 상점으로 이동 옵션
- **저장 취소**: 변경사항 무시
- **아이템 제거**: 아이템 클릭 → 제거

#### 기술적 구현
```dart
// 현재: 배경 화면별 라우팅
Navigator.pushNamed(context, '/background-forest');
Navigator.pushNamed(context, '/background-beach');
Navigator.pushNamed(context, '/background-space');
Navigator.pushNamed(context, '/background-sakura');

// 향후: 동적 레이아웃 저장
class GardenLayout {
  String userId;
  String backgroundId;
  List<PlacedItem> items; // 위치, 회전, 크기
  
  Future<void> save() async {
    // JSON으로 직렬화 후 저장
  }
}
```

#### 관련 화면
- `GardenScreen`: 정원 메인
- `GardenViewScreen`: 정원 둘러보기
- `BackgroundScreen`: 배경 선택
- `ForestBackgroundScreen`: 숲 배경
- `BeachBackgroundScreen`: 해변 배경
- `SpaceBackgroundScreen`: 우주 배경
- `SakuraBackgroundScreen`: 벚꽃 배경

#### 데이터베이스 영향
- **테이블**: `user_inventory` (현재)
- **향후**: `garden_layouts` 테이블 추가

---

### UC-008: 프로필 관리

#### 사용자 스토리
> "**As a** 사용자, **I want to** 내 프로필을 확인하고 수정하여, **So that** 개인화된 경험을 할 수 있다."

#### 사전 조건
- 사용자가 로그인되어 있음

#### 기본 플로우
1. 설정 화면 진입
2. "프로필 편집" 선택
3. 현재 정보 표시
   - 닉네임
   - 레벨
   - Credits, Sprouts
   - 가입일
4. 닉네임 수정 (선택)
5. "저장" 버튼 클릭
6. 시스템이 변경사항 저장
7. 성공 메시지 표시
8. 설정 화면으로 복귀

#### 대체 플로우
- **닉네임 중복**: 에러 메시지
- **저장 취소**: 변경사항 무시

#### 관련 화면
- `SettingsScreen`: 설정 메인
- `ProfileEditScreen`: 프로필 편집
- `StatisticsScreen`: 사용자 통계

#### 데이터베이스 영향
- **테이블**: `users`
- **작업**: UPDATE

---

## 📊 API 명세 (DAO Methods)

### UserDao API

#### `insertUser(User user) → Future<void>`
**설명**: 새 사용자 생성  
**파라미터**: User 객체  
**반환**: void  
**에러**: 중복 ID, DB 오류

#### `getUser(String userId) → Future<User?>`
**설명**: 사용자 조회  
**파라미터**: userId (String)  
**반환**: User 또는 null  

#### `updateCredits(String userId, int amount) → Future<void>`
**설명**: 크레딧 증감 (양수/음수)  
**파라미터**: userId, amount  
**반환**: void

---

### MoongDao API

#### `insertMoong(Moong moong) → Future<void>`
**설명**: 새 Moong 생성  
**파라미터**: Moong 객체  
**반환**: void

#### `getActiveMoong(String userId) → Future<Moong?>`
**설명**: 활성 Moong 조회  
**파라미터**: userId  
**반환**: Moong 또는 null

#### `updateIntimacy(String moongId, int intimacy) → Future<void>`
**설명**: 친밀도 업데이트  
**파라미터**: moongId, 새로운 친밀도  
**반환**: void

---

### QuestDao API

#### `insertQuest(Quest quest) → Future<void>`
**설명**: 새 Quest 생성  
**파라미터**: Quest 객체  
**반환**: void

#### `getTodayQuests(String moongId) → Future<List<Quest>>`
**설명**: 오늘의 Quest 조회  
**파라미터**: moongId  
**반환**: Quest 리스트

#### `completeQuest(String questId) → Future<void>`
**설명**: Quest 완료 처리  
**파라미터**: questId  
**반환**: void

---

### ShopItemDao API

#### `getAvailableShopItems() → Future<List<ShopItem>>`
**설명**: 구매 가능한 아이템 조회  
**파라미터**: 없음  
**반환**: ShopItem 리스트 (isLocked=false)

#### `getShopItemsByCategory(ShopCategory category) → Future<List<ShopItem>>`
**설명**: 카테고리별 아이템 조회  
**파라미터**: category  
**반환**: ShopItem 리스트

---

### UserInventoryDao API

#### `addItem(String userId, String itemId, int quantity) → Future<void>`
**설명**: 인벤토리에 아이템 추가  
**파라미터**: userId, itemId, quantity  
**반환**: void

#### `hasItem(String userId, String itemId) → Future<bool>`
**설명**: 아이템 보유 여부  
**파라미터**: userId, itemId  
**반환**: bool

#### `getUserInventory(String userId) → Future<List<Map<String, dynamic>>>`
**설명**: 사용자 인벤토리 조회  
**파라미터**: userId  
**반환**: 인벤토리 아이템 리스트

---

### ChatMessageDao API

#### `insertMessage(ChatMessage message) → Future<void>`
**설명**: 채팅 메시지 저장  
**파라미터**: ChatMessage 객체  
**반환**: void

#### `getRecentMessages(String moongId, int limit) → Future<List<ChatMessage>>`
**설명**: 최근 메시지 조회  
**파라미터**: moongId, limit  
**반환**: ChatMessage 리스트

#### `getConversationStats(String moongId) → Future<Map<String, dynamic>>`
**설명**: 대화 통계  
**파라미터**: moongId  
**반환**: {totalMessages, userMessages, moongMessages}

---

## 🔄 시나리오별 플로우

### 일반적인 하루 사용 시나리오

```
아침 (08:00)
  ↓
앱 실행 → 정원 화면
  ↓
Moong 인사 애니메이션
  ↓
오늘의 Quest 확인
  ↓
걷기 Quest 생성 (7000보)
  ↓
[외출]

점심 (12:00)
  ↓
Quest 진행도 확인 (3500/7000)
  ↓
Moong과 채팅 ("오늘 점심은 뭐 먹었어?")
  ↓
친밀도 +1

저녁 (18:00)
  ↓
Quest 완료 (7000/7000)
  ↓
보상 획득 (Credits +50, Intimacy +10)
  ↓
레벨업! (Lv 3 → Lv 4)
  ↓
상점 방문
  ↓
모자 구매 (Credits -120)
  ↓
정원 꾸미기
  ↓
Moong에게 모자 착용
  ↓
스크린샷 저장
  ↓
앱 종료
```

---

## 🎯 성공 지표 (KPI)

### 사용자 참여도
- **일일 활성 사용자** (DAU): 목표 70%
- **주간 활성 사용자** (WAU): 목표 90%
- **월간 활성 사용자** (MAU): 목표 95%

### 기능 사용률
- **Quest 생성률**: 목표 80% (일일)
- **Quest 완료율**: 목표 60%
- **채팅 메시지**: 목표 평균 10개/일
- **상점 방문율**: 목표 50% (주간)

### 리텐션
- **D1 리텐션**: 목표 70%
- **D7 리텐션**: 목표 40%
- **D30 리텐션**: 목표 20%

### Moong 성장
- **평균 Moong 레벨**: 목표 Lv 5
- **졸업률**: 목표 10% (30일 내)
- **평균 친밀도**: 목표 300

---

## 📚 참고 사항

### 향후 추가 유즈케이스
- UC-009: 친구 초대 및 랭킹
- UC-010: 알림 및 푸시 설정
- UC-011: 데이터 백업 및 복원
- UC-012: 멀티 Moong 관리
- UC-013: 이벤트 및 시즌 컨텐츠
- UC-014: 음악 생성 (Music Generation)
- UC-015: 운동 추천 (Exercise Suggestion)
- UC-016: 음식 추천 (Food Suggestion)

### 제한사항
- **AI 대화**: 현재 더미 응답, LLM 연동 필요
- **트랜잭션**: 구매 시 원자성 미보장
- **푸시 알림**: 미구현
- **소셜 기능**: 미구현

---

**작성일**: 2026-02-03  
**버전**: 1.0  
**작성자**: Warp AI Agent
