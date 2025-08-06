# 스키마 정리 - 호스트 인증 시스템 제거 (2025-07-23)

## 개요
호스트 인증 시스템을 제거하고 프리미엄 시스템으로 통합하였습니다.

## 1. 제거된 요소들

### 1.1 데이터베이스
- **테이블**: `host_certifications`
- **컬럼**: 해당 없음 (기존 `users.is_host`는 유지)

### 1.2 모델 및 관련 파일
- `app/models/host_certification.rb`
- `app/controllers/host_certifications_controller.rb`
- `app/views/host_certifications/` 디렉터리 전체
- `app/javascript/host_certification.js`

### 1.3 라우트
```ruby
# 제거됨
resource :host_certification
```

## 2. 수정된 시스템

### 2.1 User 모델
```ruby
# 제거된 연관관계
has_one :host_certification, dependent: :destroy

# 수정된 메서드
def can_host_games?
  true  # 모든 사용자가 경기를 주최할 수 있음
end

def max_concurrent_games
  if admin?
    999  # 관리자는 무제한
  elsif premium?
    10   # 프리미엄 사용자는 10개까지
  else
    3    # 일반 사용자는 3개까지
  end
end

# 개선된 메서드
def membership_badge_text
  # premium_type별로 다른 텍스트 반환
end

def skill_level
  # old_skill_level이 없으면 평점 기반 계산
end

def basketball_experience_text
  # 경력별 레벨 텍스트 추가
end
```

### 2.2 Game 모델
```ruby
# 제거된 검증
validate :host_game_limit         # 제거됨
validate :host_game_type_restriction  # 제거됨

# 수정된 검증
def host_date_restriction
  # 제한 없음 - 호스트는 동일 날짜에 여러 경기 주최 가능
end
```

### 2.3 프리미엄 시스템 통합
- 호스트 권한은 이제 모든 사용자에게 기본 제공
- 동시 주최 가능한 경기 수로 차별화
  - 일반: 3개
  - 프리미엄: 10개
  - 관리자: 무제한

## 3. 뷰 파일 수정

### 3.1 프로필 페이지
- 호스트 인증 관련 버튼 제거
- 호스트 평점 별도 표시 제거

### 3.2 프리미엄 페이지
- 현재 회원 상태 명확히 표시
- 프리미엄 타입별 표시 (월간/연간/평생)

### 3.3 경기 상세 페이지
- 신청자 정보에 평점 추가
- 주최자 정보 섹션 개선

## 4. 마이그레이션 필요사항

```bash
# 호스트 인증 테이블 제거
rails db:migrate

# 캐시 클리어
rails tmp:clear
rails assets:precompile
```

## 5. 주의사항

1. **기존 데이터**: `is_host` 필드는 유지되지만 사용하지 않음
2. **권한 체계**: 관리자 > 프리미엄 > 일반으로 단순화
3. **동시 경기 제한**: 활성 상태(upcoming, recruiting)인 경기만 카운트

## 6. 향후 개선사항

1. `is_host` 필드 제거 고려
2. 프리미엄 만료 알림 시스템 구축
3. 호스트 평가 시스템 별도 구현