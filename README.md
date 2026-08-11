# 하루칩 (HaruChip)

D-day 카운팅, 캘린더, 친구 약속 조율/정산 기능을 담은 Flutter + Firebase 앱입니다.
디자인/기능 기준은 [`reference/haruchip_app.html`](reference/haruchip_app.html) (프로토타입) 이고,
프로젝트 규칙 전체는 [`CLAUDE.md`](CLAUDE.md) 에 정리돼 있습니다. **코드를 고치기 전에 `CLAUDE.md`를 먼저 읽어주세요.**

---

## 1. 시작하기 전에 설치할 것

| 항목 | 버전 / 참고 |
|---|---|
| Flutter SDK | `3.27.x` (Dart `3.6.x`) — [설치 가이드](https://docs.flutter.dev/get-started/install) |
| Xcode | iOS 시뮬레이터/빌드용 (Mac만 해당). App Store에서 설치 후 `xcode-select --install` |
| CocoaPods | iOS 빌드 의존성 관리자. `sudo gem install cocoapods` |
| Android Studio | Android 에뮬레이터/SDK용. 설치 후 Android SDK + 에뮬레이터 1개 이상 세팅 |
| Git | — |

설치가 끝나면 아래 명령으로 환경이 정상인지 확인하세요 (⚠ 항목이 있어도 iOS/Android 둘 다 초록불이면 진행 가능):

```bash
flutter doctor
```

---

## 2. 처음 받아서 실행하기

```bash
# 1) 저장소 클론
git clone https://github.com/ssoeun-y/Haruchip.git
cd Haruchip

# 2) 패키지 설치
flutter pub get

# 3) (iOS만) CocoaPods 의존성 설치
cd ios && pod install && cd ..

# 4) 연결 가능한 기기/시뮬레이터 목록 확인
flutter devices

# 5) 실행 — 원하는 기기를 골라서
flutter run                    # devices 목록에서 자동 선택 물어봄
flutter run -d "iPhone 15"     # iOS 시뮬레이터로 실행
flutter run -d emulator-5554   # Android 에뮬레이터로 실행
flutter run -d chrome          # (참고용) 웹으로도 뜨긴 하나 타겟 플랫폼 아님
```

> 아직 Firebase/카카오·애플·구글 로그인·결제 키 등 **실제 시크릿 연동이 안 된 단계**라
> `env/dev.json` 같은 별도 설정 파일 없이 위 명령만으로 바로 실행됩니다.
> 이후 시크릿이 추가되면 `CLAUDE.md` §3(시크릿 관리 원칙)에 따라 `env/dev.json.example`이
> 먼저 커밋되고, 실제 값은 별도 비공개 채널로 공유됩니다 — 커밋/채팅에 값 자체가 올라오지 않습니다.

### iOS 실기기로 돌리고 싶다면
Xcode에서 `ios/Runner.xcworkspace`를 열어 Signing & Capabilities에서 본인 Apple 계정으로
Team을 지정해야 합니다(무료 계정으로도 개발 기기 실행은 가능).

---

## 3. 테스트

```bash
flutter analyze   # 정적 분석 (경고/에러 0이어야 정상)
flutter test      # 위젯/유닛 테스트 전체 실행
```

---

## 4. 폴더 구조

```
haruchip/
├── lib/
│   ├── core/                 # 공통 유틸, 상수, 테마, 라우팅
│   ├── design_system/        # 색상/타이포 토큰 (colors.dart, typography.dart)
│   ├── features/
│   │   ├── onboarding/       # 스플래시 → 로그인 → 카테고리선택 → 뷰모드 → 완료
│   │   ├── home/             # 메인 셸(상단바+하단탭) + 대시보드 탭
│   │   ├── calendar/         # 캘린더 탭 + 일정·정산방(방 목록/상세/정산)
│   │   ├── couple/           # 우리의방 탭 + 재회/기념일 기록
│   │   └── plan/             # 계획/시험/생일 등 D-day 항목 데이터
│   └── services/             # Firebase, 결제, 딥링크 등 외부 서비스 래퍼 (예정)
├── test/                     # lib/과 동일한 폴더 구조로 테스트 미러링
├── reference/
│   └── haruchip_app.html     # 디자인/기능의 유일한 기준 프로토타입
├── android/ , ios/           # 네이티브 프로젝트 (플랫폼별 설정)
├── pubspec.yaml               # 패키지 의존성
└── CLAUDE.md                  # 프로젝트 규칙 · 담당자 정의 · 기능 명세 (필독)
```

화면 하나가 어떻게 생겨야 하는지 궁금하면 `reference/haruchip_app.html`을 브라우저로
직접 열어보면 실제 인터랙션까지 확인할 수 있습니다.

---

## 5. 작업/브랜치 규칙 (CLAUDE.md §10 요약)

- `main` 브랜치에는 직접 커밋하지 않습니다. 항상 `feature/영역-기능명` 브랜치를 새로 파서 작업 → PR로 머지.
- 담당 폴더 밖(다른 사람 영역)을 고쳐야 하면 먼저 상대에게 알리고 진행합니다 (`CLAUDE.md` §1 팀 구성표 참고).
- 시크릿(API 키/토큰)은 절대 평문 커밋하지 않습니다.

```bash
git checkout -b feature/영역-기능명
# 작업 ...
git add -A
git commit -m "무엇을 왜 바꿨는지 한 줄"
git push -u origin feature/영역-기능명
# 이후 GitHub에서 Pull Request 생성
```

---

## 6. 막히면

1. `flutter doctor -v` 로 환경 문제부터 확인
2. iOS 빌드 에러면 `cd ios && pod install && cd ..` 다시 실행
3. 이상하게 캐시가 꼬였다 싶으면:
   ```bash
   flutter clean
   flutter pub get
   ```
4. 그래도 안 되면 `CLAUDE.md`를 다시 읽고, 그래도 모르겠으면 팀에 물어보기
