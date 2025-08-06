# 🏀 BDR 프로젝트 Claude 가이드

이 문서는 Claude가 BDR 프로젝트를 효과적으로 이해하고 작업할 수 있도록 돕는 참고 자료입니다.

## 프로젝트 개요

BDR(Basketball Daily Routine)은 농구 경기 예약 및 관리를 위한 Rails 기반 웹 플랫폼입니다.

### 핵심 가치
- **3초 룰**: 3번의 클릭으로 경기 참가 완료
- **신뢰성**: 안전한 결제와 검증된 사용자 시스템
- **커뮤니티**: 활발한 농구 커뮤니티 구축

## 프로젝트 구조

```
BDR_PJT/
├── app/                    # Rails 애플리케이션 코드
│   ├── controllers/        # 컨트롤러 (MVC의 C)
│   ├── models/            # 모델 (MVC의 M)
│   ├── views/             # 뷰 템플릿 (MVC의 V)
│   ├── javascript/        # JavaScript 코드
│   └── assets/            # CSS, 이미지 등
├── config/                # 설정 파일
├── db/                    # 데이터베이스 관련
│   ├── migrate/           # 마이그레이션 파일
│   └── seeds.rb           # 초기 데이터
├── test/                  # 테스트 코드
├── document/              # 프로젝트 문서
└── public/               # 정적 파일
```

## 주요 기능 및 현재 상태

### ✅ 완료된 기능
1. **사용자 시스템**
   - 회원가입/로그인 (세션 기반)
   - 프로필 관리 (완성도 체크)
   - 호스트 인증 시스템

2. **경기 관리**
   - 3단계 경기 생성 프로세스
   - 경기 신청/승인 시스템
   - 유니폼 색상 선택

3. **결제 시스템**
   - TossPayments 통합
   - 플랫폼 수수료 5%
   - 직접 결제 방식

4. **관리자 기능**
   - 대시보드
   - 사용자/경기/결제 관리

### 🚧 진행 중인 기능
1. **평가 시스템**
   - 플레이어 상호 평가
   - 평점 통계

2. **알림 시스템**
   - 경기 알림
   - 신청 상태 알림

### 📋 예정된 기능
1. 실시간 채팅
2. 모바일 앱
3. 지도 기반 검색

## 코드 작성 가이드

### Rails 컨벤션
- RESTful 라우팅 준수
- Strong Parameters 사용
- 모델 검증 활용

### 스타일 가이드
```ruby
# Good
def calculate_platform_fee
  total_amount * 0.05
end

# Bad
def calc_fee
  amt * 0.05
end
```

### Tailwind CSS 사용
```erb
<!-- Good -->
<div class="bg-blue-500 text-white p-4 rounded-lg">
  콘텐츠
</div>

<!-- Avoid inline styles -->
<div style="background: blue;">
  콘텐츠
</div>
```

## 테스트 실행

### 전체 테스트
```bash
rails test
```

### 특정 테스트
```bash
rails test test/models/user_test.rb
```

### 린트 검사
```bash
rubocop
```

## 자주 사용하는 명령어

### 데이터베이스
```bash
rails db:migrate        # 마이그레이션 실행
rails db:seed          # 시드 데이터 생성
rails db:reset         # DB 초기화
```

### 서버
```bash
rails server           # 개발 서버 시작
rails console          # Rails 콘솔
```

### 생성기
```bash
rails generate model ModelName
rails generate controller ControllerName
rails generate migration MigrationName
```

## 주요 모델 관계

### User (사용자)
- has_many :games (호스트로서)
- has_many :game_applications (참가 신청)
- has_many :payments (결제)
- has_many :player_evaluations

### Game (경기)
- belongs_to :host (User)
- has_many :game_applications
- has_many :game_participations
- belongs_to :court (optional)

### GameApplication (경기 신청)
- belongs_to :user
- belongs_to :game
- has_one :payment

### Payment (결제)
- belongs_to :user
- belongs_to :game_application

## 상태 흐름

### 경기 신청 상태
```
pending → approved → waiting_payment → final_approved
         ↘ rejected
```

### 결제 상태
```
pending → completed
         ↘ failed
```

## 환경 변수

필수 환경 변수 (.env 파일):
```
TOSS_CLIENT_KEY=your_client_key
TOSS_SECRET_KEY=your_secret_key
PLATFORM_FEE_PERCENTAGE=5.0
```

## 디버깅 팁

### Rails 콘솔에서 데이터 확인
```ruby
# 사용자 조회
User.find_by(email: "user@example.com")

# 최근 경기 조회
Game.order(created_at: :desc).limit(5)

# 신청 상태 확인
GameApplication.where(status: "pending")
```

### 로그 확인
```bash
tail -f log/development.log
```

## 주의사항

1. **프로필 완성도**: 70% 이상이어야 경기 신청 가능
2. **취소 제한**: 24시간 내 3회 이상 취소 시 제한
3. **플랫폼 수수료**: 모든 유료 경기에서 5% 수수료
4. **경기 ID**: BDR-YYYYMMDD-TYPE-SEQ 형식 자동 생성

## 문제 해결

### 일반적인 오류

1. **마이그레이션 오류**
   ```bash
   rails db:migrate:status  # 상태 확인
   rails db:rollback       # 롤백
   ```

2. **캐시 문제**
   ```bash
   rails tmp:clear
   rails assets:clean
   ```

3. **의존성 문제**
   ```bash
   bundle install
   npm install
   ```

## 유용한 리소스

- [프로젝트 요구사항](requirement.md)
- [기능 명세서](document/feature-specifications.md)
- [개발 진행 상황](document/development-progress.md)
- [데이터베이스 스키마](database_schema.md)

## MCP 도구 활용

### Sequential Thinking
복잡한 문제 해결 시 사용:
```
1. 문제 분석
2. 단계별 해결 방안 도출
3. 구현 및 검증
```

### TossPayments Integration Guide
결제 관련 작업 시 참고

---
*이 문서는 Claude가 프로젝트를 효과적으로 이해하고 작업할 수 있도록 지속적으로 업데이트됩니다.*