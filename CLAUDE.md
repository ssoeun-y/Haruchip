# CLAUDE.md — 하루칩 (HaruChip)

이 문서 하나로 프로젝트 규칙, 담당자(서브에이전트) 정의, 기능 명세를 모두 담는다.
Claude Code / Antigravity(리더 세션)는 작업 전 이 문서를 항상 먼저 읽는다.
서브에이전트를 부를 때도 이 문서가 공통 배경이 된다 — 여기 안 적힌 것은 담당자가 모른다.

---

## 다섯 칸 (핵심 규칙 — 한 장 요약)

① **이 폴더는 무엇을 하는 곳인가**
하루칩(HaruChip) Flutter+Firebase 앱의 실제 개발 저장소. D-day 카운팅, 캘린더, 친구 약속 조율/정산 기능을 구현한다.

② **자주 쓰는 자료는 어디에 있나**
데이터 모델(§4) · 핵심 도메인 로직(§7) · 화면별 명세(§8) · 담당자 정의(§1) · 폴더 구조(§2)

③ **결과는 어디에 어떤 형식으로 남기나**
코드는 각자 담당 폴더(§1 팀 구성표)에만 작성. 규칙/도메인 로직이 바뀌면 이 CLAUDE.md를 직접 갱신하고, PR 설명에 "무엇을 왜 바꿨는지" 한 줄로 남긴다.

④ **절대 하지 말 것**
시크릿(API키·토큰) 평문 커밋 / 담당 폴더 밖 파일 쓰기 / 정산 확정을 "계산 완료 시점"으로 처리 / OWASP 체크리스트(§9) 없이 인증·결제·타인데이터 코드 머지 / 재회·이별 데이터 30일 유예 없이 즉시 영구삭제

⑤ **언제 멈추고 사람에게 물을 것인가**
데이터 영구삭제 로직을 실제로 실행하기 전 / 결제·송금 관련 실제 API·제휴 연동을 붙이기 전 / 기획서에 없는 새 정책(색상 수, 자유도 범위 등)을 임의로 정해야 할 때 / 담당 폴더를 벗어난 파일을 고쳐야 할 때

> 칸마다 3줄을 넘기지 않는다. 지켰는지 눈으로 바로 확인 가능해야 한다.

---

## 판단 기준 세 줄

1. 기획서/본 문서에 확정되지 않은 새 로직이 필요하면 → 임의로 구현하지 말고 사람에게 먼저 확인한다
2. 결제·정산·인증 등 사용자 데이터를 다루는 함수는 → 테스트 케이스가 2개 미만이면 머지하지 않는다
3. 삭제류 액션(재회 영구삭제, 방 삭제, 계정 탈퇴 등)은 → 실행 전 반드시 확인 다이얼로그를 거치게 한다

---

## 1. 담당자(서브에이전트) 정의 · 팀 구성표

| 담당자 | 무엇을 맡나 | 손의 크기(읽기/쓰기) | 담당 폴더 |
|---|---|---|---|
| 소은 (도메인 담당) | 카테고리 화면, 재회/기념일 로직, 꾸미기 시스템, AI 스케줄링, 캘린더 UI, 방 조율/정산 로직, **로그인 전체(카카오/애플/구글)** | 읽기 + 쓰기 | `lib/features/*`, `lib/design_system/`, `functions/src/aiScheduling`, `functions/src/settlement`, `lib/services/auth/` |
| 보안 담당 | 인앱결제/구독, Firestore 보안 규칙, 카카오페이/토스 딥링크 구현, 시크릿 관리 | 읽기 + 쓰기 | `lib/services/payment`, `firestore.rules`, `functions/.env` 관리 |

- **쓰기는 각자 담당 폴더 안에서만.** 서브에이전트를 만들 때도 `tools`로 손 크기를 이 표대로 제한한다 (읽기 전용 담당자에게 파일 쓰기 도구를 주지 않는다)
- 겹치는 파일(`pubspec.yaml`, 라우팅, `design_system/`, `firestore.rules`)을 고칠 땐 반드시 상대에게 알리고 진행
- 서브에이전트를 팀으로 묶어 부를 때: 배경(이 문서 요약)을 프롬프트에 충분히 적어준다 — 서브에이전트는 리더의 대화 기록을 물려받지 않는다

---

## 2. 폴더 구조 (레포 전체)

```
haruchip/                         # Flutter 앱(프론트엔드) 겸 레포 루트
├── lib/
│   ├── core/                 # 공통 유틸, 상수, 테마, 라우팅
│   ├── design_system/        # 색상/타이포/컴포넌트 토큰
│   ├── features/
│   │   ├── onboarding/
│   │   ├── home/
│   │   ├── couple/
│   │   ├── solo/
│   │   ├── plan/             # 계획/업무/학업/시험/군대 공통
│   │   ├── ai_scheduling/
│   │   ├── calendar/         # 하루칩 캘린더 (개인/커플/방/외부연동)
│   │   ├── settlement/       # 정산
│   │   ├── friends/
│   │   └── profile_settings/
│   └── services/             # Firebase, 결제, 딥링크 등 외부 서비스 래퍼 (auth/, payment/ 포함)
├── env/
│   ├── dev.json.example      # ✅ 커밋 — 형식(키 이름)만 존재
│   └── dev.json               # 🚫 .gitignore — 실제 값
├── pubspec.yaml
├── functions/                    # Firebase Cloud Functions (백엔드 로직)
│   ├── src/{aiScheduling, settlement, calendarSync}/
│   ├── .env.example               # ✅ 커밋 — 형식만
│   └── .env                       # 🚫 .gitignore — 실제 값
├── firestore.rules
├── firestore.indexes.json
├── CLAUDE.md                     # 본 문서
└── .gitignore
```

### 네이밍 규칙
- 화면 파일명: `snake_case.dart` / 클래스명: `PascalCase`
- 상태관리: Riverpod, Provider는 기능 폴더 내 `providers/`에 위치

---

## 3. 시크릿(개인정보/토큰) 관리 원칙

**절대 평문 커밋 금지**: 카카오/애플/구글 클라이언트 시크릿, Claude API 키, RevenueCat API 키, Firebase 서비스 계정 JSON, 카카오페이·토스 관련 값.

```
# .gitignore 필수 항목
env/dev.json
env/prod.json
functions/.env
**/*serviceAccountKey.json
**/*service-account*.json
```

- 클라이언트(Flutter): `flutter run --dart-define-from-file=env/dev.json`로 빌드 시점 주입, `String.fromEnvironment(...)`로만 참조
- Cloud Functions: `.env` + Functions v2 dotenv, 민감한 값은 Google Cloud Secret Manager 권장
- 새 시크릿은 `*.example`에 키 이름만 먼저 추가 → 실제 값은 별도 비공개 채널로 공유, 채팅/커밋에 값 자체를 남기지 않는다

---

## 4. 데이터 모델 (Firestore)

```
users/{uid}
  - name, email, avatarEmoji, selectedCategories: []

users/{uid}/categoryItems/{itemId}
  - categoryKey: "exam" | "birthday" | "pet" | "plan" | "solo" | "military" | "couple" | "baby"
  - title, date, repeat(bool), colorHex, visibility("public"|"private")

users/{uid}/categories/{categoryId}  (카테고리 인스턴스 — 동일 categoryKey 다중 허용, §5)
  - categoryKey, name, emoji, colorHex(무료 프리셋 7개 중 하나, §6), createdAt
  - backgroundImageUrl(선택, 감성형만) — 사진 업로드 흐름은 §6 참고
  > 클라이언트 쪽 구현은 `lib/features/categories/`(Category 모델·provider) +
  > `lib/features/plan/models/plan_item.dart`(displayMode/repeatConfig/
  > calendarSync/photoUrl/roomLink/isPredicted로 확장된 항목 모델) +
  > `lib/features/military/models/military_service.dart`(군대 카테고리
  > 전용, branch 포함) 참고 — 아직 Firestore 미연동, 로컬 Riverpod 상태로만
  > 존재. 사진 업로드(`lib/features/categories/services/
  > image_upload_service.dart`)는 Firebase Storage에 실제로 쓰는 유일한
  > 예외 — 업로드 경로 권한은 `storage.rules`(신규, repo 루트)가 통제한다.

coupleRooms/{roomId}
  - members: [uid1, uid2]
  - startDate, reunions: [{breakupDate, reuniteDate}]
  - themeColor, photos: [{url, date, caption}]

scheduleRooms/{roomId}
  - name, inviteCode(1회용), members: [{uid, name, icon}]
  - dates: { "YYYY-MM-DD": [uid, ...] }
  - settlement: { payments: {uid: amount}, confirmedAt: timestamp|null }
```

---

## 5. 카테고리 & 꾸미기 규칙

| 유형 | 카테고리 | 자유도 |
|---|---|---|
| 감성형 | 커플, 솔로, 생일, 반려동물 | 배경/스티커/애니메이션/폰트/프레임 자유 |
| 실용형 | 업무/시험/계획/학업/군대 | 컬러+폰트만 제한, 레이아웃 고정 |

- 카테고리는 태그 개념 — 동일 카테고리 다중 인스턴스 항상 허용
- 실용형 UI에 감성형 전용 컴포넌트(스티커·애니메이션) 재사용 금지
- 대시보드에 "+ 새 카테고리 추가하기" 진입점 항상 유지 (온보딩 이후에도 추가 가능해야 함)
- 모든 화면은 `haruchip_app.html`(디자인 프로토타입)의 색상·톤·컴포넌트 스타일을 따른다. 임의로 새 컬러 팔레트나 UI 패턴을 만들지 않는다.

---

## 6. 색상 시스템

- D-day/캘린더 등록 시 색상은 **무료 프리셋 7개 고정** (`lib/design_system/colors.dart`의 `kFreeColorPresets`)
- 프리셋 외 커스텀 컬러피커는 프리미엄 유료 기능
- 커플 공용 캘린더 색상은 방 생성 시 지정, 변경 시 상대에게 즉시 반영
- 색상은 항상 디자인 토큰 참조, 하드코딩 금지
- 모든 화면은 `haruchip_app.html`(디자인 프로토타입)의 색상·톤·컴포넌트 스타일을 따른다. 임의로 새 컬러 팔레트나 UI 패턴을 만들지 않는다.

---

## 7. 핵심 도메인 로직

### 7-1. 재회 로직
- 총 연애일수 = (오늘 − 처음 만난 날) − Σ(이별 기간)
- 이별 시 소프트 삭제 → 30일 보관 → 30일 내 재회 시 자동 복구, 경과 시 영구 삭제
- 날짜 입력은 이전 날짜 이후로만 선택 가능 (역전 방지)
- 재회 무제한, 요약형(총일수+재회후 D+n) / 타임라인형(이력) 뷰 제공

### 7-2. 기념일
- 100일 단위 + 1주년 자동 계산, 푸시 D-1 + 당일
- 사진첩 무료 50장, 초과 시 RevenueCat 결제로 확장

### 7-3. AI 스케줄링 (학업·시험)
- 균등 분배 기본 + 주말 제외 옵션
- 미완료 시 순연 제안(과거 기록 불변), 완료/부분완료/미완료 3단계
- 목표일 초과 위험 시 경고 + 압축 제안

### 7-4. 하루칩 캘린더
- 개인 캘린더 표시는 항상 강제 ON (토글 UI 자체를 만들지 않는다)
- 구글/네이버는 카테고리별 기본값 저장 방식
- 공개/비공개 항목별 토글(기본 비공개), 친구 탐색은 초대링크(1회용)로 승인된 관계로만 제한

### 7-5. 일정 방 — 방 상세 플로우
```
방 클릭 → 방 상세
  1. 날짜 그리드 노출 → 탭으로 본인 가능여부 토글 (room.dates[date])
  2. 다른 멤버 표시도 같은 화면에서 확인
  3. 전원 겹침 강조, 최다인원 자동 계산
  4. 안 겹치면 → 과반수 추천 → 불참 예외처리 → 5개 후보 투표(24시간, 조기종료 가능)
  5. 확정 → 방에서 제거, 개인 캘린더로 전환 등록 → 구글 등록 팝업 → 색상 선택
```

### 7-6. 정산

```js
function calculateSettlement(payments, members) {
    const total = Object.values(payments).reduce((a, b) => a + b, 0);
    const share = Math.round(total / members.length);
    let balances = members.map(name => ({ name, balance: (payments[name] || 0) - share }));
    let creditors = balances.filter(b => b.balance > 0).sort((a, b) => b.balance - a.balance);
    let debtors = balances.filter(b => b.balance < 0).sort((a, b) => a.balance - b.balance);
    let i = 0, j = 0, tx = [];
    while (i < debtors.length && j < creditors.length) {
        const d = debtors[i], c = creditors[j];
        const amt = Math.min(-d.balance, c.balance);
        if (amt > 0) tx.push({ from: d.name, to: c.name, amount: amt });
        d.balance += amt; c.balance -= amt;
        if (Math.abs(d.balance) < 1) i++;
        if (Math.abs(c.balance) < 1) j++;
    }
    return { total, share, tx };
}
```
- 부채 최소화 그리디 알고리즘, Dart 포팅 시 로직 그대로 이식
- 송금: 카카오페이/토스 딥링크(URL 스킴), 제휴 불필요, 금액 미리 채움
- **확정 시점 = 실제 송금 진행 시점**, 확정 후에도 재계산 항상 허용

---

## 8. 화면별 명세 요약

| 화면 | 핵심 동작 |
|---|---|
| 온보딩 | 스플래시 → 권한요청 → 로그인 → 카테고리 선택(다중) → 대시보드 뷰모드 → 완료 화면 → 메인 셸(대시보드 탭) |
| 대시보드 | 인사 + 뷰모드 전환 + 카테고리 카드(전용/범용) + "+ 새 카테고리 추가하기" |
| 캘린더 | 통합 미니뷰(하루칩/구글/네이버 색상 구분) + 날짜별 일정 + 등록 팝업 + "연동 설정"(→ 캘린더 연동 설정 화면) |
| 일정·정산방 | 방 목록 → 방 상세(가능일 토글/추천/확정) → 정산(차액계산+딥링크) |
| 커플 방 | 아바타 매칭 애니메이션, 공동 꾸미기, 기념일 자동계산, 사진첩(사진첩은 아직 미구현) — "기록 관리" 진입점으로 이별/재회 기록·요약형/타임라인형 화면 연결 |

> (2025 재구현 갱신) 캘린더 연동 선택은 온보딩에서 제거되고 캘린더 탭 "연동 설정" 버튼 뒤 설정 화면으로 재배치됐다. 위젯 안내는 온보딩에서 제거되고 설정 모달의 "홈 화면 위젯 가이드 → 보기"로 재배치됐다. 두 화면 모두 완전 삭제 대신 용도를 바꿔 재활용했다(`lib/features/onboarding/screens/calendar_integration_screen.dart`, `widget_guide_screen.dart`). 근거: `reference/haruchip_app.html`이 온보딩/메인 4탭의 유일한 디자인·기능 기준이다.

### 공통 UI — 모달 닫기
X 버튼 / 하단 "닫기" 버튼 / 배경 클릭 3가지 모두 지원:
```html
<div class="... backdrop" onclick="closeModal()">
  <div onclick="event.stopPropagation()" class="modal-card">...</div>
</div>
```
Flutter에서는 `GestureDetector`/`Dismissible` 패턴으로 동일 적용.

---

## 9. 보안 요구사항 — OWASP Top 10 대응 필수

1. **Broken Access Control** — Firestore 규칙 기본 거부, 방 데이터는 참여자 UID만 read/write, 서버단에서 미승인 접근 차단
2. **Cryptographic Failures** — 토큰/개인정보 암호화 저장, 로그/코드에 평문 노출 금지
3. **Injection** — Firestore 쿼리 파라미터 바인딩만, 외부 API 호출 시 입력 검증
4. **Insecure Design** — 정산/송금 위변조 가능성 사전 검토, 재회 삭제 30일 유예 유지
5. **Security Misconfiguration** — 프로덕션에 테스트모드 전체허용 규칙 금지, 환경변수는 §3 방식만
6. **Vulnerable Components** — `flutter pub outdated` 정기 점검
7. **Auth Failures** — 토큰은 `flutter_secure_storage`, 세션 만료/갱신 명시적 구현
8. **Integrity Failures** — 미검증 외부 코드 금지, 클라이언트 계산값은 서버 재검증
9. **Logging Failures** — 주요 액션 로그 기록, 개인정보는 로그 제외
10. **SSRF** — 외부 URL 호출은 허용 도메인만 (카카오페이/토스/구글·네이버 캘린더)

인증·결제·타인 데이터 접근 기능은 구현 후 이 체크리스트로 자체 리뷰한다.

---

## 10. Git 협업 규칙

- `main`(배포 가능 상태 유지) + 짧은 수명 feature 브랜치 → PR 머지
- 브랜치명: `feature/영역-기능명`

---

## 11. 작업 우선순위 (서브에이전트에게 순서대로 위임)

1. Firebase 세팅 + §4 데이터 모델대로 Firestore 구조 생성
2. 온보딩 → 대시보드 → 카테고리 카드
3. `calculateSettlement` Dart 포팅 + 정산 화면
4. 방 상세(가능일 토글) — Firestore 실시간 동기화
5. 커플 재회/기념일 로직
6. 색상 프리셋/프리미엄 커스텀
7. 사진첩, 친구탐색, 공개/비공개, 딥링크 실연동

---

## 12. 코드 작성 시 체크리스트

- [ ] 폴더 구조(§2)를 따르는가
- [ ] 색상/디자인 값을 토큰으로 참조하는가 (하드코딩 아닌지)
- [ ] §7 도메인 로직과 충돌하지 않는가
- [ ] 사용자/타인 데이터 접근 시 §9 OWASP 체크리스트를 통과하는가
- [ ] §1 담당 폴더를 벗어나지 않는가
- [ ] 판단 기준 세 줄(위 참고) 중 해당하는 게 있다면 지켰는가
