# BDR - Basketball Daily Routine 🏀

> 농구를 사랑하는 사람들을 위한 3초 룰 기반 매칭 플랫폼

## 프로젝트 소개

BDR은 농구 경기를 쉽고 빠르게 예약하고 관리할 수 있는 웹 플랫폼입니다. 
3초 룰(3번의 클릭으로 경기 참가)을 기반으로 한 직관적인 UX를 제공합니다.

### 주요 기능

- **경기 매칭 시스템**: 픽업게임, 게스트모집, TvT 연습경기 지원
- **스마트 예약 시스템**: 2단계 승인 프로세스 (신청 → 승인 → 결제 → 최종승인)
- **결제 시스템**: TossPayments 연동, 플랫폼 수수료 자동 계산
- **평점 시스템**: 호스트/플레이어 상호 평가
- **커뮤니티**: 자유게시판, 중고거래, 팀 소개, 코트 정보 공유
- **관리자 대시보드**: 통계, 사용자/경기/결제 관리

## 기술 스택

- **Backend**: Ruby on Rails 8.0.2
- **Database**: SQLite3 (개발), PostgreSQL (운영)
- **Frontend**: Tailwind CSS, Turbo, Vanilla JavaScript
- **결제**: TossPayments API
- **인증**: 세션 기반

## 시작하기

### 필수 요구사항

- Ruby 3.2.0 이상
- Rails 8.0.2 이상
- Node.js 18.0 이상
- SQLite3 (개발환경)

### 설치 방법

1. **저장소 클론**
   ```bash
   git clone https://github.com/yourusername/BDR_PJT.git
   cd BDR_PJT
   ```

2. **의존성 설치**
   ```bash
   bundle install
   npm install
   ```

3. **데이터베이스 설정**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed  # 초기 데이터 생성
   ```

4. **환경 변수 설정**
   `.env` 파일을 생성하고 다음 내용을 추가:
   ```
   # TossPayments API Keys
   TOSS_CLIENT_KEY=your_client_key
   TOSS_SECRET_KEY=your_secret_key
   
   # Application Settings
   PLATFORM_FEE_PERCENTAGE=5.0
   ```

5. **서버 실행**
   ```bash
   rails server
   ```
   
   브라우저에서 http://localhost:3000 접속

## 주요 기능 사용법

### 경기 생성 (3단계 프로세스)
1. **기본 정보**: 경기 종류, 팀명, 지역 선택
2. **세부 내용**: 날짜, 시간, 장소, 참가비 설정
3. **추가 요구사항**: 시설 요구사항, 유니폼 색상 지정

### 경기 참가
1. 경기 목록에서 원하는 경기 선택
2. "참가하기" 버튼 클릭
3. 유료 경기의 경우 결제 진행
4. 호스트 승인 대기

### 관리자 기능
- URL: `/admin`
- 기본 관리자 계정: 시드 데이터 참조
- 주요 기능: 통계 대시보드, 사용자/경기/결제 관리, 시스템 설정

## 프로젝트 구조

```
BDR_PJT/
├── app/
│   ├── controllers/    # 컨트롤러
│   ├── models/         # 모델
│   ├── views/          # 뷰 템플릿
│   ├── javascript/     # JavaScript 파일
│   └── assets/         # 정적 자산
├── config/             # 설정 파일
├── db/                 # 데이터베이스 관련
├── test/              # 테스트 파일
└── public/            # 공개 파일
```

## 주요 모델 관계

- **User**: 사용자 (호스트/게스트)
- **Game**: 경기 정보
- **GameApplication**: 경기 신청
- **Payment**: 결제 정보
- **Court**: 코트 정보

## API 엔드포인트

### 경기 관련
- `GET /games` - 경기 목록
- `GET /games/:id` - 경기 상세
- `POST /games` - 경기 생성
- `POST /games/:id/apply` - 경기 신청

### 사용자 관련
- `GET /profile` - 프로필 조회
- `PATCH /profile` - 프로필 수정
- `GET /profile/history` - 활동 내역

## 개발 가이드

### 코드 스타일
- Ruby: [Ruby Style Guide](https://rubystyle.guide/) 준수
- JavaScript: ES6+ 문법 사용
- CSS: Tailwind CSS 유틸리티 클래스 활용

### 브랜치 전략
- `main`: 안정적인 운영 버전
- `develop`: 개발 버전
- `feature/*`: 기능 개발
- `hotfix/*`: 긴급 수정

### 커밋 메시지 규칙
```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 코드 리팩토링
test: 테스트 추가
chore: 빌드 업무 수정
```

## 테스트

```bash
# 전체 테스트 실행
rails test

# 특정 테스트 실행
rails test test/models/user_test.rb
```

## 배포

### Heroku 배포 (예시)
```bash
heroku create your-app-name
heroku addons:create heroku-postgresql:hobby-dev
git push heroku main
heroku run rails db:migrate
heroku run rails db:seed
```

## 문제 해결

### 일반적인 문제

1. **데이터베이스 연결 오류**
   ```bash
   rails db:reset
   ```

2. **자산 컴파일 오류**
   ```bash
   rails assets:precompile
   ```

3. **의존성 충돌**
   ```bash
   bundle update
   ```

## 기여 방법

1. 이슈 생성 또는 기존 이슈 확인
2. 포크 및 브랜치 생성
3. 변경사항 커밋
4. 풀 리퀘스트 생성

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.

## 연락처

- 이메일: your-email@example.com
- 이슈 트래커: [GitHub Issues](https://github.com/yourusername/BDR_PJT/issues)

---

Made with ❤️ by BDR Team