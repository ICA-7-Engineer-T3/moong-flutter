# 🔌 API Specification - Moong App

향후 백엔드 연동을 위한 API 명세서

## 📋 목차

1. [개요](#개요)
2. [인증](#인증)
3. [사용자 API](#사용자-api)
4. [뭉 API](#뭉-api)
5. [퀘스트 API](#퀘스트-api)
6. [상점 API](#상점-api)
7. [채팅 API](#채팅-api)
8. [AI API](#ai-api)

## 개요

### Base URL

```
Production: https://api.moong.app/v1
Staging: https://api-staging.moong.app/v1
Development: http://localhost:3000/v1
```

### 공통 응답 형식

#### 성공

```json
{
  "success": true,
  "data": { ... },
  "message": "Success message"
}
```

#### 에러

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Error message",
    "details": { ... }
  }
}
```

### HTTP Status Codes

| Code | 의미 |
|------|------|
| 200 | OK - 성공 |
| 201 | Created - 리소스 생성 성공 |
| 400 | Bad Request - 잘못된 요청 |
| 401 | Unauthorized - 인증 실패 |
| 403 | Forbidden - 권한 없음 |
| 404 | Not Found - 리소스 없음 |
| 500 | Internal Server Error - 서버 에러 |

## 인증

### 1. 회원가입

```http
POST /auth/signup
```

**Request Body**

```json
{
  "username": "user123",
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "u_123",
      "username": "user123",
      "email": "user@example.com",
      "level": 1,
      "sprouts": 100,
      "credits": 0,
      "createdAt": "2026-02-03T00:00:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 2. 로그인

```http
POST /auth/login
```

**Request Body**

```json
{
  "username": "user123",
  "password": "securepassword123"
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "user": { ... },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 3. 로그아웃

```http
POST /auth/logout
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

### 4. 토큰 갱신

```http
POST /auth/refresh
```

**Request Body**

```json
{
  "refreshToken": "refresh_token_here"
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "token": "new_access_token",
    "refreshToken": "new_refresh_token"
  }
}
```

## 사용자 API

### 1. 내 프로필 조회

```http
GET /users/me
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "id": "u_123",
    "username": "user123",
    "email": "user@example.com",
    "level": 5,
    "sprouts": 1250,
    "credits": 500,
    "activeMoong": {
      "id": "m_456",
      "name": "뭉이",
      "type": "pet",
      "level": 3,
      "intimacy": 75
    },
    "createdAt": "2026-01-01T00:00:00Z",
    "updatedAt": "2026-02-03T00:00:00Z"
  }
}
```

### 2. 프로필 수정

```http
PATCH /users/me
Authorization: Bearer {token}
```

**Request Body**

```json
{
  "username": "newusername",
  "email": "newemail@example.com"
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "user": { ... }
  }
}
```

### 3. 크레딧 충전

```http
POST /users/me/credits/charge
Authorization: Bearer {token}
```

**Request Body**

```json
{
  "amount": 1000,
  "paymentMethod": "card",
  "paymentDetails": { ... }
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "transaction": {
      "id": "tx_789",
      "amount": 1000,
      "bonus": 100,
      "total": 1100,
      "status": "completed",
      "createdAt": "2026-02-03T00:00:00Z"
    },
    "newBalance": 1600
  }
}
```

### 4. 크레딧 사용 내역

```http
GET /users/me/credits/history?page=1&limit=20
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "transactions": [
      {
        "id": "tx_789",
        "type": "charge",
        "amount": 1100,
        "description": "크레딧 충전",
        "createdAt": "2026-02-03T00:00:00Z"
      },
      {
        "id": "tx_788",
        "type": "spend",
        "amount": -50,
        "description": "특별한 음식 구매",
        "createdAt": "2026-02-02T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "totalPages": 3
    }
  }
}
```

## 뭉 API

### 1. 내 뭉 목록

```http
GET /moongs?includeGraduated=false
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "moongs": [
      {
        "id": "m_456",
        "userId": "u_123",
        "name": "뭉이",
        "type": "pet",
        "level": 3,
        "intimacy": 75,
        "isActive": true,
        "createdAt": "2026-01-15T00:00:00Z",
        "graduatedAt": null
      }
    ]
  }
}
```

### 2. 뭉 생성

```http
POST /moongs
Authorization: Bearer {token}
```

**Request Body**

```json
{
  "name": "새뭉이",
  "type": "mate"
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "moong": {
      "id": "m_789",
      "userId": "u_123",
      "name": "새뭉이",
      "type": "mate",
      "level": 1,
      "intimacy": 0,
      "isActive": false,
      "createdAt": "2026-02-03T00:00:00Z"
    }
  }
}
```

### 3. 뭉 상세 조회

```http
GET /moongs/{moongId}
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "moong": {
      "id": "m_456",
      "name": "뭉이",
      "type": "pet",
      "level": 3,
      "intimacy": 75,
      "stats": {
        "totalChats": 125,
        "questsCompleted": 45,
        "daysWithUser": 19,
        "itemsOwned": 12
      }
    }
  }
}
```

### 4. 활성 뭉 변경

```http
PUT /moongs/{moongId}/activate
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "activeMoong": { ... }
  }
}
```

### 5. 뭉 졸업

```http
POST /moongs/{moongId}/graduate
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "moong": {
      "id": "m_456",
      "isActive": false,
      "graduatedAt": "2026-02-03T00:00:00Z"
    },
    "rewards": {
      "sprouts": 500,
      "credits": 100
    }
  }
}
```

### 6. 친밀도 업데이트

```http
PATCH /moongs/{moongId}/intimacy
Authorization: Bearer {token}
```

**Request Body**

```json
{
  "change": 5
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "moong": {
      "id": "m_456",
      "intimacy": 80,
      "level": 3
    },
    "leveledUp": false
  }
}
```

## 퀘스트 API

### 1. 오늘의 퀘스트 목록

```http
GET /quests/today
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "quests": [
      {
        "id": "q_123",
        "type": "walk",
        "target": 3000,
        "progress": 1200,
        "completed": false,
        "rewards": {
          "sprouts": 10,
          "intimacy": 5
        },
        "createdAt": "2026-02-03T00:00:00Z"
      }
    ]
  }
}
```

### 2. 퀘스트 진행도 업데이트

```http
PATCH /quests/{questId}/progress
Authorization: Bearer {token}
```

**Request Body**

```json
{
  "progress": 1500
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "quest": {
      "id": "q_123",
      "progress": 1500,
      "completed": false
    }
  }
}
```

### 3. 퀘스트 완료

```http
POST /quests/{questId}/complete
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "quest": {
      "id": "q_123",
      "completed": true,
      "completedAt": "2026-02-03T12:30:00Z"
    },
    "rewards": {
      "sprouts": 10,
      "intimacy": 5
    },
    "newBalance": {
      "sprouts": 1260,
      "moongIntimacy": 80
    }
  }
}
```

### 4. 퀘스트 히스토리

```http
GET /quests/history?page=1&limit=20
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "quests": [
      {
        "id": "q_122",
        "type": "walk",
        "target": 3000,
        "progress": 3000,
        "completed": true,
        "completedAt": "2026-02-02T18:00:00Z"
      }
    ],
    "pagination": { ... }
  }
}
```

## 상점 API

### 1. 카테고리별 아이템 목록

```http
GET /shop/items?category=clothes&page=1&limit=20
Authorization: Bearer {token}
```

**Query Parameters**
- `category`: clothes, accessories, furniture, background, season
- `page`: 페이지 번호 (default: 1)
- `limit`: 페이지당 아이템 수 (default: 20)

**Response**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "item_456",
        "name": "귀여운 모자",
        "category": "clothes",
        "price": 100,
        "currency": "sprout",
        "imageUrl": "https://cdn.moong.app/items/item_456.png",
        "unlockDays": null,
        "isOwned": false
      }
    ],
    "pagination": { ... }
  }
}
```

### 2. 아이템 구매

```http
POST /shop/items/{itemId}/purchase
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "purchase": {
      "id": "purchase_789",
      "itemId": "item_456",
      "price": 100,
      "currency": "sprout",
      "purchasedAt": "2026-02-03T00:00:00Z"
    },
    "newBalance": {
      "sprouts": 1160,
      "credits": 500
    }
  }
}
```

### 3. 내 아이템 목록

```http
GET /shop/my-items?category=clothes
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "item_456",
        "name": "귀여운 모자",
        "category": "clothes",
        "purchasedAt": "2026-02-03T00:00:00Z",
        "equipped": true
      }
    ]
  }
}
```

### 4. 아이템 장착/해제

```http
PUT /shop/items/{itemId}/equip
Authorization: Bearer {token}
```

**Request Body**

```json
{
  "equipped": true
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "item": {
      "id": "item_456",
      "equipped": true
    }
  }
}
```

## 채팅 API

### 1. 채팅 목록

```http
GET /chats?page=1&limit=20
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "chats": [
      {
        "id": "chat_123",
        "moongId": "m_456",
        "moongName": "뭉이",
        "lastMessage": "안녕! 오늘 어땠어?",
        "lastMessageAt": "2026-02-03T15:30:00Z",
        "unreadCount": 2
      }
    ],
    "pagination": { ... }
  }
}
```

### 2. 채팅 메시지 목록

```http
GET /chats/{chatId}/messages?page=1&limit=50
Authorization: Bearer {token}
```

**Response**

```json
{
  "success": true,
  "data": {
    "messages": [
      {
        "id": "msg_789",
        "chatId": "chat_123",
        "senderId": "m_456",
        "senderType": "moong",
        "content": "안녕! 오늘 어땠어?",
        "createdAt": "2026-02-03T15:30:00Z"
      },
      {
        "id": "msg_788",
        "chatId": "chat_123",
        "senderId": "u_123",
        "senderType": "user",
        "content": "좋았어!",
        "createdAt": "2026-02-03T15:25:00Z"
      }
    ],
    "pagination": { ... }
  }
}
```

### 3. 메시지 전송

```http
POST /chats/{chatId}/messages
Authorization: Bearer {token}
```

**Request Body**

```json
{
  "content": "뭉이야 놀자!"
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "message": {
      "id": "msg_790",
      "chatId": "chat_123",
      "senderId": "u_123",
      "senderType": "user",
      "content": "뭉이야 놀자!",
      "createdAt": "2026-02-03T15:35:00Z"
    }
  }
}
```

### 4. WebSocket 연결 (실시간 채팅)

```
ws://api.moong.app/v1/chats/{chatId}/ws
Authorization: Bearer {token}
```

**Server → Client 메시지**

```json
{
  "type": "new_message",
  "data": {
    "message": {
      "id": "msg_791",
      "senderId": "m_456",
      "content": "좋아! 뭐 하고 놀까?",
      "createdAt": "2026-02-03T15:36:00Z"
    }
  }
}
```

## AI API

### 1. 감정 분석

```http
POST /ai/emotion/analyze
Authorization: Bearer {token}
```

**Request Body**

```json
{
  "text": "오늘 너무 힘든 하루였어...",
  "context": "daily_chat"
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "emotions": {
      "joy": 10,
      "sadness": 70,
      "anxiety": 50,
      "happiness": 20
    },
    "dominantEmotion": "sadness",
    "keywords": ["힘든", "하루"],
    "sentiment": "negative"
  }
}
```

### 2. 음악 생성

```http
POST /ai/music/generate
Authorization: Bearer {token}
```

**Request Body**

```json
{
  "environment": {
    "nature": 0.8,
    "urban": 0.2,
    "sea": 0.5,
    "space": 0.0
  },
  "emotion": {
    "happy": 0.7,
    "calm": 0.9,
    "energetic": 0.3,
    "melancholy": 0.1
  }
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "music": {
      "id": "music_123",
      "url": "https://cdn.moong.app/music/music_123.mp3",
      "duration": 180,
      "title": "평화로운 자연의 소리",
      "createdAt": "2026-02-03T00:00:00Z"
    }
  }
}
```

### 3. 운동 제안

```http
POST /ai/suggestions/exercise
Authorization: Bearer {token}
```

**Request Body**

```json
{
  "userLevel": 3,
  "recentActivity": "low",
  "preferences": ["walking", "yoga"]
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "suggestion": {
      "type": "walking",
      "duration": 30,
      "intensity": "moderate",
      "description": "공원에서 30분 걷기를 추천해요! 자연을 느끼며 스트레스를 풀어보세요.",
      "tips": [
        "편한 신발을 신으세요",
        "물을 충분히 마시세요"
      ]
    }
  }
}
```

### 4. 음식 제안

```http
POST /ai/suggestions/food
Authorization: Bearer {token}
```

**Request Body**

```json
{
  "timeOfDay": "lunch",
  "mood": "tired",
  "dietaryRestrictions": []
}
```

**Response**

```json
{
  "success": true,
  "data": {
    "suggestion": {
      "name": "연어 샐러드",
      "category": "healthy",
      "description": "오메가-3가 풍부한 연어로 에너지를 보충하세요!",
      "benefits": [
        "단백질 풍부",
        "두뇌 건강",
        "항산화 효과"
      ],
      "recipe": "..."
    }
  }
}
```

## 에러 코드

| 코드 | 메시지 | HTTP Status |
|------|--------|-------------|
| AUTH_001 | Invalid credentials | 401 |
| AUTH_002 | Token expired | 401 |
| AUTH_003 | Invalid token | 401 |
| USER_001 | User not found | 404 |
| USER_002 | Username already exists | 400 |
| MOONG_001 | Moong not found | 404 |
| MOONG_002 | Cannot graduate active moong | 400 |
| QUEST_001 | Quest not found | 404 |
| QUEST_002 | Quest already completed | 400 |
| SHOP_001 | Item not found | 404 |
| SHOP_002 | Insufficient balance | 400 |
| SHOP_003 | Item locked | 400 |
| CHAT_001 | Chat not found | 404 |
| AI_001 | AI service unavailable | 503 |

---

**API Version: 1.0.0**  
**Last Updated: 2026-02-03**
