# Firestore ERD 및 데이터 구조

**작성일**: 2026-02-06
**데이터베이스**: Cloud Firestore (Native Mode)
**리전**: asia-northeast3 (서울)

---

## 목차

1. [ERD 다이어그램](#erd-다이어그램)
2. [컬렉션 구조](#컬렉션-구조)
3. [데이터 모델 상세](#데이터-모델-상세)
4. [관계 및 제약조건](#관계-및-제약조건)
5. [인덱스 전략](#인덱스-전략)

---

## ERD 다이어그램

### 전체 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    Firestore 데이터 구조                      │
└─────────────────────────────────────────────────────────────┘

ROOT COLLECTIONS (루트 컬렉션)
├── /users/{uid}                    [User 문서]
│   │
│   ├── SUBCOLLECTIONS (서브컬렉션)
│   │   ├── /moongs/{moongId}       [Moong 문서]
│   │   ├── /quests/{questId}       [Quest 문서]
│   │   ├── /inventory/{invId}      [Inventory 문서]
│   │   └── /chatMessages/{msgId}   [ChatMessage 문서]
│
└── /shopItems/{itemId}             [ShopItem 문서] ★ 공유 카탈로그


관계:
- User (1) ──< (N) Moong           [1:N - 한 사용자는 여러 펫 소유]
- User (1) ──< (N) Quest           [1:N - 한 사용자는 여러 퀘스트]
- User (1) ──< (N) Inventory       [1:N - 한 사용자는 여러 아이템]
- User (1) ──< (N) ChatMessage     [1:N - 한 사용자는 여러 메시지]
- Moong (1) ──< (N) Quest          [1:N - 한 펫은 여러 퀘스트]
- Moong (1) ──< (N) ChatMessage    [1:N - 한 펫은 여러 대화]
- ShopItem (1) ──< (N) Inventory   [1:N - 한 상품은 여러 사용자가 구매]
```

---

## 컬렉션 구조

### 1. /users/{uid} (루트 컬렉션)

**용도:** 사용자 계정 정보
**문서 ID:** Firebase Auth UID
**접근 권한:** 본인만 읽기/쓰기

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| email | string | ❌ | null | 이메일 주소 |
| nickname | string | ✅ | - | 닉네임 |
| level | number | ✅ | 1 | 사용자 레벨 |
| credits | number | ✅ | 250 | 프리미엄 화폐 |
| sprouts | number | ✅ | 250 | 무료 화폐 |
| createdAt | timestamp | ✅ | now | 계정 생성일 |

**예시:**
```json
{
  "email": "user@example.com",
  "nickname": "무무",
  "level": 5,
  "credits": 1000,
  "sprouts": 500,
  "createdAt": "2026-02-06T00:00:00Z"
}
```

---

### 2. /users/{uid}/moongs/{moongId} (서브컬렉션)

**용도:** 사용자의 펫(Moong) 정보
**문서 ID:** 자동 생성 (Firestore ID)
**접근 권한:** 소유자만 읽기/쓰기

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| userId | string | ✅ | - | 소유자 UID |
| name | string | ✅ | - | 펫 이름 |
| type | string | ✅ | - | 펫 유형 (pet/mate/guide) |
| level | number | ✅ | 1 | 펫 레벨 |
| intimacy | number | ✅ | 0 | 친밀도 (0-100) |
| isActive | boolean | ✅ | false | 활성 펫 여부 |
| createdAt | timestamp | ✅ | now | 생성일 |
| graduatedAt | timestamp | ❌ | null | 졸업일 (친밀도 100 도달 시) |

**비즈니스 규칙:**
- 사용자당 활성 펫은 **1개만** 허용 (isActive: true)
- 친밀도 범위: 0 ~ 100
- 친밀도 100 도달 시 졸업 처리 (graduatedAt 설정)

**펫 유형:**
- `pet` - 장난기 많은 동반자
- `mate` - 친근한 친구
- `guide` - 현명한 멘토

**예시:**
```json
{
  "userId": "firebase_uid_123",
  "name": "뭉이",
  "type": "pet",
  "level": 3,
  "intimacy": 75,
  "isActive": true,
  "createdAt": "2026-02-06T00:00:00Z",
  "graduatedAt": null
}
```

---

### 3. /users/{uid}/quests/{questId} (서브컬렉션)

**용도:** 사용자의 퀘스트(미션) 정보
**문서 ID:** 자동 생성 (Firestore ID)
**접근 권한:** 소유자만 읽기/쓰기

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| userId | string | ✅ | - | 소유자 UID |
| moongId | string | ❌ | null | 연관 펫 ID (nullable) |
| type | string | ✅ | - | 퀘스트 유형 (daily/special) |
| target | string | ✅ | - | 목표 설명 |
| progress | number | ✅ | 0 | 진행도 |
| completed | boolean | ✅ | false | 완료 여부 |
| createdAt | timestamp | ✅ | now | 생성일 |
| completedAt | timestamp | ❌ | null | 완료일 |

**비즈니스 규칙:**
- 일일 퀘스트(daily)는 24시간마다 리셋
- 완료 시 새싹(sprouts) + 친밀도(intimacy) 보상
- 보상은 퀘스트 유형과 목표에 따라 계산

**퀘스트 유형:**
- `daily` - 일일 퀘스트 (매일 리셋)
- `special` - 특별 퀘스트 (일회성 또는 이벤트)

**예시:**
```json
{
  "userId": "firebase_uid_123",
  "moongId": "moong_abc",
  "type": "daily",
  "target": "3번 대화하기",
  "progress": 2,
  "completed": false,
  "createdAt": "2026-02-06T00:00:00Z",
  "completedAt": null
}
```

---

### 4. /users/{uid}/inventory/{inventoryId} (서브컬렉션)

**용도:** 사용자가 구매한 아이템 목록
**문서 ID:** 자동 생성 (Firestore ID)
**접근 권한:** 소유자만 읽기/쓰기

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| shopItemId | string | ✅ | - | 상점 아이템 ID 참조 |
| purchasedAt | timestamp | ✅ | now | 구매일 |

**비즈니스 규칙:**
- 중복 구매 가능 (동일 아이템 여러 개 소유)
- ShopItem과 1:N 관계 (외래 키: shopItemId)
- 실제 아이템 정보는 /shopItems 컬렉션 조회

**예시:**
```json
{
  "shopItemId": "clothes_1",
  "purchasedAt": "2026-02-06T12:30:00Z"
}
```

---

### 5. /users/{uid}/chatMessages/{messageId} (서브컬렉션)

**용도:** 사용자와 펫의 대화 기록
**문서 ID:** 자동 생성 (Firestore ID)
**접근 권한:** 소유자만 읽기/쓰기

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| moongId | string | ✅ | - | 대화 대상 펫 ID |
| message | string | ✅ | - | 메시지 내용 |
| isUser | boolean | ✅ | - | true: 사용자 발신, false: AI 응답 |
| createdAt | timestamp | ✅ | now | 메시지 전송 시각 |

**비즈니스 규칙:**
- 페이지네이션 지원 (ChatProvider에서 limit 설정)
- 최신 메시지 우선 정렬 (createdAt desc)
- AI 응답은 서버에서 생성 (향후 구현 예정)

**예시:**
```json
{
  "moongId": "moong_abc",
  "message": "안녕, 뭉이!",
  "isUser": true,
  "createdAt": "2026-02-06T12:30:00Z"
}
```

---

### 6. /shopItems/{itemId} (루트 컬렉션 - 공유)

**용도:** 상점 카탈로그 (모든 사용자 공유)
**문서 ID:** 수동 설정 (예: clothes_1, acc_1)
**접근 권한:** 모든 사용자 읽기, 관리자만 쓰기

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| category | string | ✅ | - | 카테고리 (clothes/accessories/furniture/background/season) |
| name | string | ✅ | - | 아이템 이름 |
| price | number | ✅ | - | 가격 |
| currency | string | ✅ | - | 통화 (credit/sprout) |
| imageUrl | string | ❌ | null | 이미지 URL |
| unlockDays | number | ✅ | 0 | 잠금 해제 일수 (0: 즉시) |

**비즈니스 규칙:**
- 총 18개 아이템 (FirestoreSeedService로 초기 생성)
- 시즌 아이템은 unlockDays 설정 (가입 후 N일 필요)
- 단일 진실 공급원(Single Source of Truth)

**카테고리:**
- `clothes` - 의류 (3개, 100-200 새싹)
- `accessories` - 액세서리 (3개, 80-300 혼합)
- `furniture` - 가구 (3개, 400-600 혼합)
- `background` - 배경 테마 (4개, 250-400 혼합)
- `season` - 시즌 한정 (3개, 400-600 크레딧, 잠금)

**통화:**
- `credit` - 크레딧 (프리미엄 화폐)
- `sprout` - 새싹 (무료 화폐)

**예시:**
```json
{
  "category": "clothes",
  "name": "빨간 모자",
  "price": 100,
  "currency": "sprout",
  "imageUrl": null,
  "unlockDays": 0
}
```

---

## 관계 및 제약조건

### 데이터 관계

```
User ──< Moong
  │      └── Quest (moongId 참조)
  │      └── ChatMessage (moongId 참조)
  │
  ├──< Quest
  ├──< Inventory ──> ShopItem (shopItemId 참조)
  └──< ChatMessage
```

### 외래 키 (참조 관계)

| 자식 컬렉션 | 부모 참조 | 필드명 | 설명 |
|-------------|-----------|--------|------|
| moongs | users | userId | 펫 소유자 |
| quests | users | userId | 퀘스트 소유자 |
| quests | moongs | moongId | 연관 펫 (nullable) |
| inventory | users | - | 서브컬렉션으로 암시적 관계 |
| inventory | shopItems | shopItemId | 구매한 상품 |
| chatMessages | users | - | 서브컬렉션으로 암시적 관계 |
| chatMessages | moongs | moongId | 대화 대상 펫 |

### 제약조건

**User:**
- credits, sprouts >= 0 (음수 불가)
- level >= 1

**Moong:**
- intimacy: 0 ~ 100 범위
- isActive: true는 사용자당 1개만 (앱 레벨 제약)
- type: 'pet' | 'mate' | 'guide' 중 하나

**Quest:**
- progress >= 0
- completed: true면 completedAt 필수

**ShopItem:**
- price > 0
- unlockDays >= 0

---

## 인덱스 전략

### 복합 인덱스 (Composite Indexes)

Firestore는 복합 쿼리 시 인덱스 생성이 필요합니다.

**1. 활성 퀘스트 조회**
```
컬렉션: quests
필드:
  - completed (ASC)
  - createdAt (DESC)

사용 쿼리:
.where('completed', '==', false)
.orderBy('createdAt', 'desc')
```

**2. 펫별 퀘스트 조회**
```
컬렉션: quests
필드:
  - moongId (ASC)
  - createdAt (DESC)

사용 쿼리:
.where('moongId', '==', moongId)
.orderBy('createdAt', 'desc')
```

**3. 카테고리별 상점 아이템**
```
컬렉션: shopItems
필드:
  - category (ASC)
  - price (ASC)

사용 쿼리:
.where('category', '==', 'clothes')
.orderBy('price', 'asc')
```

**4. 채팅 메시지 (펫별 + 시간순)**
```
컬렉션: chatMessages
필드:
  - moongId (ASC)
  - createdAt (DESC)

사용 쿼리:
.where('moongId', '==', moongId)
.orderBy('createdAt', 'desc')
.limit(20)
```

### 단일 필드 인덱스

Firestore는 자동으로 각 필드에 단일 인덱스를 생성합니다.
- `userId`, `moongId`, `questId` 등 참조 필드
- `createdAt`, `completedAt` 등 타임스탬프 필드
- `isActive`, `completed` 등 boolean 필드

---

## 데이터 크기 추정

### 사용자당 예상 데이터 크기

| 컬렉션 | 문서 수 | 문서당 크기 | 총 크기 |
|--------|---------|-------------|---------|
| users | 1 | ~200 bytes | 200 B |
| moongs | 3-10 | ~300 bytes | 0.9-3 KB |
| quests | 10-50 | ~250 bytes | 2.5-12.5 KB |
| inventory | 5-30 | ~100 bytes | 0.5-3 KB |
| chatMessages | 100-500 | ~200 bytes | 20-100 KB |

**총 예상:** 사용자당 약 **24-120 KB**

### 전체 프로젝트 규모 (1만 명 기준)

| 항목 | 추정치 |
|------|--------|
| 총 사용자 문서 | 10,000 |
| 총 데이터 크기 | 240 MB - 1.2 GB |
| 월간 읽기 | ~300만 읽기 (사용자당 300회) |
| 월간 쓰기 | ~100만 쓰기 (사용자당 100회) |

**Spark 플랜 제한:**
- 문서 읽기: 50,000 / day (월 150만)
- 문서 쓰기: 20,000 / day (월 60만)
- 저장소: 1 GB

→ 사용자 100-200명 수준에서 유료 플랜 전환 필요

---

## 다음 문서

- 🔒 [Firebase 보안 규칙](./FIREBASE_SECURITY.md)
- 👥 [Firebase 협업 가이드](./FIREBASE_COLLABORATION.md)
- ⚙️ [Firebase 설정 가이드](./FIREBASE_SETUP.md)
