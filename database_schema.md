# BDR_PJT 데이터베이스 스키마

최종 업데이트: 2025-07-28

## 목차
1. [사용자 관련 테이블](#사용자-관련-테이블)
2. [경기 관련 테이블](#경기-관련-테이블)
3. [대회 관련 테이블](#대회-관련-테이블)
4. [결제 관련 테이블](#결제-관련-테이블)
5. [코트 관련 테이블](#코트-관련-테이블)
6. [커뮤니티 관련 테이블](#커뮤니티-관련-테이블)
7. [평가 및 평점 관련 테이블](#평가-및-평점-관련-테이블)
8. [통계 관련 테이블](#통계-관련-테이블)
9. [알림 및 활동 관련 테이블](#알림-및-활동-관련-테이블)
10. [관리자 관련 테이블](#관리자-관련-테이블)
11. [기타 테이블](#기타-테이블)
12. [퀵매치 관련 테이블](#퀵매치-관련-테이블)

---

## 사용자 관련 테이블

### 1. users 테이블
사용자 기본 정보를 저장하는 핵심 테이블

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 사용자 고유 ID | PK |
| name | string | 사용자명 | NOT NULL |
| email | string | 이메일 | NOT NULL, UNIQUE |
| phone | string | 전화번호 | UNIQUE |
| nickname | string | 닉네임 | UNIQUE |
| real_name | string | 실명 | |
| height | integer | 키(cm) | |
| weight | integer | 몸무게(kg) | |
| positions | text | 포지션 (JSON 배열) | |
| city | string | 시/도 | |
| district | string | 구/군 | |
| team_name | string | 소속팀명 | |
| bio | text | 자기소개 | |
| profile_completed | boolean | 프로필 완성 여부 | DEFAULT false |
| birth_date | date | 생년월일 | |
| basketball_experience | integer | 농구 경력(년) | DEFAULT 0 |
| bank_name | string | 은행명 | |
| account_number | string | 계좌번호 | |
| account_holder | string | 예금주명 | |
| email_notifications | boolean | 이메일 알림 허용 | DEFAULT true |
| sms_notifications | boolean | SMS 알림 허용 | DEFAULT true |
| push_notifications | boolean | 푸시 알림 허용 | DEFAULT true |
| notification_preferences | text | 알림 상세 설정 (JSON) | |
| timezone | string | 타임존 | DEFAULT 'Asia/Seoul' |
| last_login_at | datetime | 마지막 로그인 시간 | |
| login_count | integer | 로그인 횟수 | DEFAULT 0 |
| status | string | 계정 상태 (active, suspended, inactive, banned) | DEFAULT 'active' |
| suspended_at | datetime | 정지 시작일 | |
| suspension_reason | text | 정지 사유 | |
| admin | boolean | 관리자 여부 | DEFAULT false, NOT NULL |
| last_activity_at | datetime | 마지막 활동 시간 | |
| registration_source | string | 가입 경로 | |
| referrer_url | string | 유입 URL | |
| marketing_consent | boolean | 마케팅 수신 동의 | DEFAULT false |
| profile_views | integer | 프로필 조회수 | DEFAULT 0 |
| total_games_hosted | integer | 주최한 경기 수 | DEFAULT 0 |
| total_games_participated | integer | 참가한 경기 수 | DEFAULT 0 |
| total_revenue | decimal(10,2) | 총 수익 | DEFAULT 0.0 |
| average_rating | decimal(3,2) | 평균 평점 | DEFAULT 0.0 |
| reliability_score | decimal(3,2) | 신뢰도 점수 | DEFAULT 5.0 |
| total_points | integer | 총 포인트 | DEFAULT 0 |
| is_premium | boolean | 프리미엄 회원 여부 | DEFAULT false |
| premium_expires_at | datetime | 프리미엄 만료일 | |
| premium_type | string | 프리미엄 타입 (monthly, yearly, lifetime) | |
| evaluation_rating | decimal(5,3) | 평가 레이팅 (0-100) | DEFAULT 50.0 |
| is_host | boolean | 호스트 인증 여부 | DEFAULT false, NOT NULL |
| rating_count | integer | 받은 평점 수 | DEFAULT 0 |
| tournaments_hosted_count | integer | 개최한 대회 수 | DEFAULT 0 |
| tournament_host_rating | decimal(3,2) | 대회 주최자 평점 | |
| can_create_tournaments | boolean | 대회 개최 가능 여부 | DEFAULT false |
| max_concurrent_tournaments | integer | 동시 개최 가능 대회 수 | DEFAULT 0 |
| quick_match_priority | integer | 퀵매치 우선순위 | DEFAULT 0 |
| last_quick_match_at | datetime | 마지막 퀵매치 시간 | |
| old_position | string | (레거시) 포지션 | |
| old_skill_level | integer | (레거시) 스킬 레벨 | |
| old_location | string | (레거시) 지역 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_users_on_nickname` (UNIQUE)
- `index_users_on_phone` (UNIQUE)
- `index_users_on_email`
- `index_users_on_city_and_district`
- `index_users_on_is_premium`
- `index_users_on_is_host`
- `index_users_on_admin`
- `index_users_on_status`
- `index_users_on_can_create_tournaments`
- `index_users_on_quick_match_priority`

**연관관계:**
- has_many :organized_games (Game)
- has_many :game_applications
- has_many :game_participations
- has_many :game_results
- has_many :posts
- has_many :comments
- has_many :reviews
- has_one :user_stat
- has_one :play_style
- has_many :user_achievements
- has_many :court_visits
- has_many :premium_subscriptions
- has_many :billing_keys
- has_many :given_evaluations (PlayerEvaluation)
- has_many :received_evaluations (PlayerEvaluation)
- has_many :activities
- has_many :outdoor_courts
- has_one :user_cancellation
- has_many :user_rating_histories
- has_many :court_activities
- has_many :given_ratings (Rating)
- has_many :received_ratings (Rating)
- has_many :user_points
- has_many :suggestions
- has_many :notifications
- has_many :player_stats
- has_many :season_averages
- has_many :organized_tournaments (Tournament)
- has_one :quick_match_preference
- has_many :match_pool_participants
- has_many :quick_match_histories

**상수 및 Enum:**
- SKILL_LEVELS: 1(초보자) ~ 7(프로급)
- POSITIONS: 포인트가드, 슈팅가드, 스몰포워드, 파워포워드, 센터

### 2. user_stats 테이블
사용자 게임 통계 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| rating | decimal(3,2) | 평점 | DEFAULT 0.0 |
| wins | integer | 승리 수 | DEFAULT 0 |
| losses | integer | 패배 수 | DEFAULT 0 |
| games_played | integer | 참가 경기 수 | DEFAULT 0 |
| mvp_count | integer | MVP 수상 횟수 | DEFAULT 0 |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

### 3. play_styles 테이블
사용자 플레이 스타일 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| assist_percentage | integer | 어시스트 성향 | DEFAULT 0 |
| three_point_percentage | integer | 3점슛 성향 | DEFAULT 0 |
| defense_percentage | integer | 수비 성향 | DEFAULT 0 |
| rebound_percentage | integer | 리바운드 성향 | DEFAULT 0 |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

### 4. user_cancellations 테이블
사용자 취소 기록 관리

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| cancellation_count | integer | 총 취소 횟수 | DEFAULT 0 |
| last_cancelled_at | datetime | 마지막 취소 시각 | |
| weekly_cancellation_count | integer | 주간 취소 횟수 | |
| first_weekly_cancelled_at | datetime | 주간 첫 취소 시각 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

### 5. user_points 테이블
사용자 포인트 거래 내역

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| points | integer | 포인트 | DEFAULT 0, NOT NULL |
| description | string | 설명 | NOT NULL |
| transaction_type | string | 거래 유형 | NOT NULL |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

### 6. user_achievements 테이블
사용자 업적 획득 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| achievement_id | integer | 업적 ID | FK, NOT NULL |
| earned_at | datetime | 획득일시 | NOT NULL |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_user_achievements_on_user_id_and_achievement_id` (UNIQUE)

### 7. user_rating_histories 테이블
사용자 레이팅 변동 이력

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| rating_before | decimal(5,3) | 변경 전 레이팅 | |
| rating_after | decimal(5,3) | 변경 후 레이팅 | |
| rating_change | decimal(5,3) | 레이팅 변화량 | |
| change_reason | string | 변경 사유 | |
| game_id | integer | 관련 경기 ID | FK, NOT NULL |
| evaluation_count | integer | 평가 수 | |
| positive_count | integer | 긍정 평가 수 | |
| negative_count | integer | 부정 평가 수 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

---

## 경기 관련 테이블

### 1. games 테이블
경기 정보를 저장하는 핵심 테이블

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 경기 고유 ID | PK |
| court_id | integer | 코트 ID | FK (optional) |
| organizer_id | integer | 주최자 ID | FK, NOT NULL |
| scheduled_at | datetime | 경기 예정일시 | NOT NULL |
| status | string | 경기 상태 | scheduled/active/closed/completed/cancelled |
| max_players | integer | 최대 참가자 수 | NOT NULL, > 1 |
| home_team_color | string | 홈팀 유니폼 색상 | DEFAULT '흰색' |
| away_team_color | string | 어웨이팀 유니폼 색상 | DEFAULT '검은색' |
| description | text | 경기 설명 | |
| game_type | string | 경기 유형 | 픽업게임/게스트모집/TvT연습경기 |
| team_name | string | 팀명 | NOT NULL |
| city | string | 시/도 | NOT NULL |
| district | string | 구/군 | NOT NULL |
| title | string | 경기 제목 | NOT NULL |
| venue_name | string | 경기장명 | NOT NULL |
| venue_address | string | 경기장 주소 | NOT NULL |
| start_time | time | 시작 시간 | NOT NULL |
| end_time | time | 종료 시간 | NOT NULL |
| level | integer | 난이도 (1-5) | NOT NULL |
| fee | integer | 참가비 | NOT NULL, >= 0 |
| parking_required | boolean | 주차 필요 여부 | DEFAULT false |
| shower_required | boolean | 샤워시설 필요 여부 | DEFAULT false |
| water_fountain_required | boolean | 식수대 필요 여부 | DEFAULT false |
| air_conditioning_required | boolean | 에어컨 필요 여부 | DEFAULT false |
| message | text | 호스트 메시지 | |
| game_id | string | 경기 고유 코드 | NOT NULL, UNIQUE |
| payment_deadline_hours | integer | 결제 마감 시간 | DEFAULT 24 |
| auto_approve_applications | boolean | 자동 승인 여부 | DEFAULT false |
| requires_payment | boolean | 결제 필요 여부 | DEFAULT true |
| payment_instructions | text | 결제 안내사항 | |
| host_payment_transferred_at | datetime | 호스트 정산일 | |
| host_payment_amount | decimal(10,2) | 호스트 정산액 | |
| platform_fee_amount | decimal(10,2) | 플랫폼 수수료액 | |
| platform_fee_percentage | decimal(5,2) | 플랫폼 수수료율 | DEFAULT 5.0 |
| cancelled_at | datetime | 취소일시 | |
| cancelled_by_user_id | integer | 취소한 사용자 ID | FK |
| cancellation_reason | text | 취소 사유 | |
| is_recurring | boolean | 반복 경기 여부 | DEFAULT false |
| recurring_pattern | string | 반복 패턴 | daily/weekly/monthly/custom |
| parent_game_id | integer | 부모 경기 ID | FK |
| max_waitlist | integer | 대기자 최대 수 | DEFAULT 0 |
| waitlist_enabled | boolean | 대기자 기능 사용 | DEFAULT false |
| uniform_colors | text | 유니폼 색상 목록 (JSON) | |
| view_count | integer | 조회수 | DEFAULT 0 |
| application_count | integer | 신청자 수 | DEFAULT 0 |
| completion_rate | decimal(5,2) | 완료율 | DEFAULT 0.0 |
| average_rating | decimal(3,2) | 평균 평점 | DEFAULT 0.0 |
| revenue_generated | decimal(10,2) | 발생 수익 | DEFAULT 0.0 |
| platform_fee | decimal(10,2) | 플랫폼 수수료 | DEFAULT 0.0 |
| host_payout | decimal(10,2) | 호스트 지급액 | DEFAULT 0.0 |
| weather_cancelled | boolean | 날씨로 인한 취소 | DEFAULT false |
| no_show_count | integer | 노쇼 수 | DEFAULT 0 |
| final_player_count | integer | 최종 참가자 수 | |
| closed_at | datetime | 마감일시 | |
| actual_revenue | decimal(10,2) | 실제 수익 | |
| actual_platform_fee | decimal(10,2) | 실제 플랫폼 수수료 | |
| actual_host_revenue | decimal(10,2) | 실제 호스트 수익 | |
| is_partial_settlement | boolean | 부분 정산 여부 | DEFAULT false |
| settlement_notified_at | datetime | 정산 알림일시 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_games_on_game_id` (UNIQUE)
- `index_games_on_organizer_id`
- `index_games_on_scheduled_at`
- `index_games_on_status`
- `index_games_on_city_and_district`
- `index_games_on_game_type`
- `index_games_on_level`

**연관관계:**
- belongs_to :court (optional)
- belongs_to :organizer (User)
- has_many :game_participations
- has_many :game_applications
- has_many :game_results
- has_many :ratings
- has_many :player_evaluations
- has_one :evaluation_deadline

**상수 및 Enum:**
- GAME_TYPES: 픽업게임, 게스트모집, TvT연습경기
- LEVELS: 1(입문자) ~ 5(고급자)
- UNIFORM_COLORS: white, black, blue, yellow, red

### 2. game_applications 테이블
경기 참가 신청 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| user_id | integer | 신청자 ID | FK, NOT NULL |
| game_id | integer | 경기 ID | FK, NOT NULL |
| status | string | 신청 상태 | pending/waiting_payment/final_approved/rejected |
| applied_at | datetime | 신청일시 | NOT NULL |
| approved_at | datetime | 1차 승인일시 | |
| rejected_at | datetime | 거절일시 | |
| message | text | 신청 메시지 | |
| payment_confirmed_at | datetime | 결제 확인일시 | |
| final_approved_at | datetime | 최종 승인일시 | |
| payment_deadline | datetime | 결제 마감일시 | |
| auto_rejected_at | datetime | 자동 거절일시 | |
| rejection_reason | text | 거절 사유 | |
| status_changed_by_user_id | integer | 상태 변경자 ID | FK |
| status_change_reason | text | 상태 변경 사유 | |
| host_notes | text | 호스트 메모 | |
| guest_notes | text | 게스트 메모 | |
| reminder_sent_at | datetime | 리마인더 발송일시 | |
| reminder_count | integer | 리마인더 발송 횟수 | DEFAULT 0 |
| last_contacted_at | datetime | 마지막 연락일시 | |
| response_time | integer | 응답 시간(분) | |
| cancellation_reason | string | 취소 사유 | |
| showed_up | boolean | 출석 여부 | |
| rating_given | decimal(3,2) | 준 평점 | |
| rating_received | decimal(3,2) | 받은 평점 | |
| cancelled_at | datetime | 취소일시 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_game_applications_unique_user_game` (UNIQUE: user_id, game_id)
- `index_game_applications_on_status`
- `index_game_applications_on_game_id_and_status`

**연관관계:**
- belongs_to :user
- belongs_to :game
- has_one :payment

### 3. game_participations 테이블
경기 참가 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| user_id | integer | 참가자 ID | FK, NOT NULL |
| game_id | integer | 경기 ID | FK, NOT NULL |
| joined_at | datetime | 참가일시 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

### 4. game_results 테이블
경기 결과 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| game_id | integer | 경기 ID | FK, NOT NULL |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| team | string | 팀 구분 | |
| won | boolean | 승리 여부 | DEFAULT false |
| player_rating | decimal(3,2) | 플레이어 평점 | DEFAULT 0.0 |
| points_scored | integer | 득점 | DEFAULT 0 |
| assists | integer | 어시스트 | DEFAULT 0 |
| rebounds | integer | 리바운드 | DEFAULT 0 |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_game_results_on_game_id_and_user_id` (UNIQUE)

### 5. evaluation_deadlines 테이블
경기 평가 마감 시간 관리

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| game_id | integer | 경기 ID | FK, NOT NULL |
| deadline | datetime | 평가 마감일시 | |
| is_active | boolean | 활성 여부 | DEFAULT true, NOT NULL |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

---

## 대회 관련 테이블

### 1. tournaments 테이블
대회 기본 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 대회 고유 ID | PK |
| name | string | 대회명 | NOT NULL |
| description | text | 대회 설명 | |
| tournament_type | string | 대회 방식 | single_elimination/double_elimination/round_robin/group_stage |
| status | string | 대회 상태 | DEFAULT 'draft' |
| registration_start_at | datetime | 신청 시작일 | |
| registration_end_at | datetime | 신청 마감일 | |
| tournament_start_at | datetime | 대회 시작일 | |
| tournament_end_at | datetime | 대회 종료일 | |
| min_teams | integer | 최소 팀 수 | DEFAULT 4 |
| max_teams | integer | 최대 팀 수 | DEFAULT 16 |
| players_per_team | integer | 팀당 선수 수 | DEFAULT 5 |
| entry_fee | decimal(10,2) | 참가비 | DEFAULT 0.0 |
| prize_pool | decimal(10,2) | 총 상금 | DEFAULT 0.0 |
| location_name | string | 경기장 이름 | |
| location_address | string | 경기장 주소 | |
| location_latitude | decimal(10,6) | 위도 | |
| location_longitude | decimal(10,6) | 경도 | |
| organizer_id | integer | 주최자 ID | FK (users) |
| contact_phone | string | 연락처 전화번호 | |
| contact_email | string | 연락처 이메일 | |
| rules | text | 대회 규칙 | |
| prizes | text | 상금 정보 (JSON) | |
| sponsor_names | string | 후원사명 | |
| poster_image | string | 포스터 이미지 | |
| banner_image | string | 배너 이미지 | |
| featured | boolean | 추천 대회 여부 | DEFAULT false |
| view_count | integer | 조회수 | DEFAULT 0 |
| tournament_code | string | 대회 코드 | UNIQUE |
| venue | string | 경기장 | |
| contact_info | text | 연락처 정보 | |
| is_featured | boolean | 추천 대회 여부 | DEFAULT false |
| prize_info | text | 상금 정보 | |
| approved_at | datetime | 승인일시 | |
| rejected_at | datetime | 거절일시 | |
| approval_notes | text | 승인 메모 | |
| rejection_reason | text | 거절 사유 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_tournaments_on_tournament_code` (UNIQUE)
- `index_tournaments_on_status`
- `index_tournaments_on_organizer_id`

**연관관계:**
- belongs_to :organizer (User)
- has_many :tournament_teams
- has_many :tournament_matches

### 2. tournament_teams 테이블
대회 참가팀 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 팀 고유 ID | PK |
| tournament_id | integer | 대회 ID | FK, NOT NULL |
| team_name | string | 팀명 | NOT NULL |
| captain_id | integer | 팀 대표 ID | FK (users) |
| status | string | 상태 | DEFAULT 'pending' |
| roster | text | 팀 로스터 (JSON) | |
| contact_phone | string | 연락처 전화번호 | |
| contact_email | string | 연락처 이메일 | |
| notes | text | 추가 메모 | |
| registered_at | datetime | 등록일시 | |
| approved_at | datetime | 승인일시 | |
| payment_completed | boolean | 결제 완료 여부 | DEFAULT false |
| payment_completed_at | datetime | 결제 완료일시 | |
| seed_number | integer | 시드 번호 | |
| final_rank | integer | 최종 순위 | |
| wins | integer | 승수 | DEFAULT 0 |
| losses | integer | 패수 | DEFAULT 0 |
| points_for | integer | 득점 | DEFAULT 0 |
| points_against | integer | 실점 | DEFAULT 0 |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_tournament_teams_on_tournament_id_and_team_name` (UNIQUE)

**연관관계:**
- belongs_to :tournament
- belongs_to :captain (User)
- has_many :home_matches (TournamentMatch)
- has_many :away_matches (TournamentMatch)
- has_many :won_matches (TournamentMatch)

### 3. tournament_matches 테이블
대회 경기 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 경기 고유 ID | PK |
| tournament_id | integer | 대회 ID | FK, NOT NULL |
| home_team_id | integer | 홈팀 ID | FK |
| away_team_id | integer | 어웨이팀 ID | FK |
| round | string | 라운드 | |
| match_number | integer | 경기 번호 | |
| scheduled_at | datetime | 경기 일정 | |
| court_name | string | 코트명 | |
| status | string | 상태 | DEFAULT 'scheduled' |
| home_score | integer | 홈팀 점수 | |
| away_score | integer | 어웨이팀 점수 | |
| winner_team_id | integer | 승리팀 ID | FK |
| match_notes | text | 경기 메모 | |
| referee_names | string | 심판 이름 | |
| quarter_scores | json | 쿼터별 점수 | |
| overtime_scores | json | 연장전 점수 | |
| game_duration | integer | 경기 시간(분) | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**연관관계:**
- belongs_to :tournament
- belongs_to :home_team (TournamentTeam)
- belongs_to :away_team (TournamentTeam)
- belongs_to :winner_team (TournamentTeam)
- has_many :match_player_stats

### 4. match_player_stats 테이블
대회 경기별 선수 통계

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 통계 고유 ID | PK |
| tournament_match_id | integer | 경기 ID | FK, NOT NULL |
| user_id | integer | 선수 ID | FK, NOT NULL |
| tournament_team_id | integer | 팀 ID | FK, NOT NULL |
| team_type | string | 팀 타입 (home/away) | |
| minutes_played | integer | 출전 시간(분) | DEFAULT 0 |
| starter | boolean | 선발 출전 여부 | DEFAULT false |
| points | integer | 득점 | DEFAULT 0 |
| field_goals_made | integer | 필드골 성공 | DEFAULT 0 |
| field_goals_attempted | integer | 필드골 시도 | DEFAULT 0 |
| three_pointers_made | integer | 3점슛 성공 | DEFAULT 0 |
| three_pointers_attempted | integer | 3점슛 시도 | DEFAULT 0 |
| free_throws_made | integer | 자유투 성공 | DEFAULT 0 |
| free_throws_attempted | integer | 자유투 시도 | DEFAULT 0 |
| offensive_rebounds | integer | 공격 리바운드 | DEFAULT 0 |
| defensive_rebounds | integer | 수비 리바운드 | DEFAULT 0 |
| total_rebounds | integer | 총 리바운드 | DEFAULT 0 |
| assists | integer | 어시스트 | DEFAULT 0 |
| steals | integer | 스틸 | DEFAULT 0 |
| blocks | integer | 블락 | DEFAULT 0 |
| turnovers | integer | 턴오버 | DEFAULT 0 |
| personal_fouls | integer | 개인 파울 | DEFAULT 0 |
| plus_minus | decimal(5,1) | +/- | DEFAULT 0.0 |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_match_player_stats_on_tournament_match_id_and_user_id` (UNIQUE)

---

## 결제 관련 테이블

### 1. payments 테이블
결제 정보 관리

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 결제 고유 ID | PK |
| game_application_id | integer | 경기 신청 ID | FK, NOT NULL |
| amount | decimal | 결제 금액 | NOT NULL |
| status | string | 결제 상태 | pending/paid/transferred/refunded |
| payment_method | string | 결제 방법 | |
| bdr_account_info | text | BDR 계좌 정보 | |
| paid_at | datetime | 결제일시 | |
| transferred_to_host_at | datetime | 호스트 송금일시 | |
| toss_payment_key | string | 토스 결제 키 | |
| toss_order_id | string | 토스 주문 ID | |
| payment_type | string | 결제 유형 | DEFAULT 'participation_fee' |
| refund_reason | text | 환불 사유 | |
| refunded_at | datetime | 환불일시 | |
| refund_amount | decimal(10,2) | 환불 금액 | |
| transaction_id | string | 거래 ID | |
| payment_gateway_response | text | 결제 게이트웨이 응답 | |
| failure_reason | text | 실패 사유 | |
| retry_count | integer | 재시도 횟수 | DEFAULT 0 |
| processed_by_user_id | integer | 처리자 ID | FK |
| created_by_user_id | integer | 생성자 ID | FK |
| updated_by_user_id | integer | 수정자 ID | FK |
| admin_notes | text | 관리자 메모 | |
| processing_time | integer | 처리 시간(초) | |
| fee_amount | decimal(10,2) | 수수료 금액 | DEFAULT 0.0 |
| net_amount | decimal(10,2) | 순수익 금액 | DEFAULT 0.0 |
| currency | string | 통화 | DEFAULT 'KRW' |
| toss_refund_id | string | 토스 환불 ID | |
| refund_status | string | 환불 상태 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**연관관계:**
- belongs_to :game_application
- has_one :user (through game_application)
- has_one :game (through game_application)

### 2. premium_subscriptions 테이블
프리미엄 구독 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 구독 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| plan_type | string | 플랜 타입 | NOT NULL |
| payment_key | string | 결제 키 | NOT NULL, UNIQUE |
| order_id | string | 주문 ID | NOT NULL, UNIQUE |
| amount | integer | 결제 금액 | NOT NULL |
| status | string | 상태 | DEFAULT 'active', NOT NULL |
| started_at | datetime | 시작일시 | NOT NULL |
| cancelled_at | datetime | 취소일시 | |
| refunded_at | datetime | 환불일시 | |
| refund_amount | integer | 환불 금액 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

### 3. billing_keys 테이블
자동결제용 빌링키 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 빌링키 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| customer_key | string | 고객 키 | NOT NULL, UNIQUE |
| billing_key | string | 빌링 키 | NOT NULL, UNIQUE |
| card_number | string | 카드 번호 (마스킹) | NOT NULL |
| card_company | string | 카드사 | |
| card_type | string | 카드 종류 | |
| is_active | boolean | 활성 여부 | DEFAULT true |
| last_used_at | datetime | 마지막 사용일시 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

---

## 코트 관련 테이블

### 1. courts 테이블
실내 코트 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 코트 고유 ID | PK |
| name | string | 코트명 | |
| address | string | 주소 | |
| latitude | decimal | 위도 | |
| longitude | decimal | 경도 | |
| court_type | string | 코트 유형 | |
| capacity | integer | 수용 인원 | |
| water_fountain | boolean | 식수대 여부 | DEFAULT false |
| shower_available | boolean | 샤워시설 여부 | DEFAULT false |
| parking_available | boolean | 주차가능 여부 | DEFAULT false |
| smoking_allowed | boolean | 흡연가능 여부 | DEFAULT false |
| air_conditioning | boolean | 에어컨 여부 | DEFAULT false |
| locker_room | boolean | 라커룸 여부 | DEFAULT false |
| equipment_rental | boolean | 장비대여 여부 | DEFAULT false |
| image1 | string | 이미지1 | |
| image2 | string | 이미지2 | |
| current_occupancy | integer | 현재 인원 | DEFAULT 0 |
| last_activity_at | datetime | 마지막 활동 시간 | |
| peak_hours | json | 피크 시간대 | DEFAULT {} |
| average_occupancy | float | 평균 점유율 | DEFAULT 0.0 |
| realtime_enabled | boolean | 실시간 기능 활성화 | DEFAULT false |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**연관관계:**
- has_many :games
- has_many :court_visits
- has_many :court_activities
- has_many :reviews (polymorphic)

### 2. outdoor_courts 테이블
야외 코트 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 코트 고유 ID | PK |
| title | string | 코트명 | NOT NULL |
| image1 | string | 이미지1 | NOT NULL |
| image2 | string | 이미지2 | NOT NULL |
| latitude | decimal(10,6) | 위도 | NOT NULL |
| longitude | decimal(10,6) | 경도 | NOT NULL |
| address | string | 주소 | NOT NULL |
| user_id | integer | 등록자 ID | FK, NOT NULL |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

### 3. court_visits 테이블
코트 방문 기록

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| court_id | integer | 코트 ID | FK, NOT NULL |
| visit_count | integer | 방문 횟수 | DEFAULT 0 |
| is_favorite | boolean | 즐겨찾기 여부 | DEFAULT false |
| last_visited_at | datetime | 마지막 방문일시 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_court_visits_on_user_id_and_court_id` (UNIQUE)

### 4. court_activities 테이블
코트 활동 기록

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| court_id | integer | 코트 ID | FK, NOT NULL |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| activity_type | string | 활동 유형 | NOT NULL |
| player_count | integer | 플레이어 수 | DEFAULT 0 |
| recorded_at | datetime | 기록일시 | NOT NULL |
| metadata | json | 메타데이터 | DEFAULT {} |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

---

## 커뮤니티 관련 테이블

### 1. posts 테이블
게시글 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 게시글 고유 ID | PK |
| user_id | integer | 작성자 ID | FK, NOT NULL |
| title | string | 제목 | NOT NULL |
| content | text | 내용 | NOT NULL |
| category | string | 카테고리 | NOT NULL |
| image1 | string | 이미지1 | |
| image2 | string | 이미지2 | |
| views_count | integer | 조회수 | DEFAULT 0 |
| comments_count | integer | 댓글 수 | DEFAULT 0 |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**연관관계:**
- belongs_to :user
- has_many :comments

### 2. comments 테이블
댓글 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 댓글 고유 ID | PK |
| post_id | integer | 게시글 ID | FK, NOT NULL |
| user_id | integer | 작성자 ID | FK, NOT NULL |
| content | text | 내용 | NOT NULL |
| parent_id | integer | 부모 댓글 ID | FK |
| depth | integer | 댓글 깊이 | DEFAULT 0 |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**연관관계:**
- belongs_to :post
- belongs_to :user
- belongs_to :parent (Comment)
- has_many :replies (Comment)

### 3. reviews 테이블
리뷰 정보 (다형성)

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 리뷰 고유 ID | PK |
| user_id | integer | 작성자 ID | FK, NOT NULL |
| reviewable_type | string | 리뷰 대상 타입 | NOT NULL |
| reviewable_id | integer | 리뷰 대상 ID | NOT NULL |
| rating | integer | 평점 | NOT NULL |
| comment | text | 코멘트 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_reviews_on_user_and_reviewable` (UNIQUE: user_id, reviewable_type, reviewable_id)

---

## 평가 및 평점 관련 테이블

### 1. player_evaluations 테이블
플레이어 상세 평가

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 평가 고유 ID | PK |
| game_id | integer | 경기 ID | FK, NOT NULL |
| evaluator_type | string | 평가자 타입 | NOT NULL |
| evaluator_id | integer | 평가자 ID | NOT NULL |
| evaluated_user_id | integer | 평가받는 사용자 ID | FK, NOT NULL |
| skill_level | integer | 스킬 레벨 (1-5) | |
| teamwork | integer | 팀워크 (1-5) | |
| manner | integer | 매너 (1-5) | |
| memorable | boolean | 기억에 남는 플레이어 | |
| comment | text | 코멘트 | |
| evaluated_at | datetime | 평가일시 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `unique_evaluation_index` (UNIQUE: game_id, evaluator_id, evaluator_type, evaluated_user_id)

**연관관계:**
- belongs_to :game
- belongs_to :evaluator (polymorphic)
- belongs_to :evaluated_user (User)

### 2. ratings 테이블
간단한 평점 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 평점 고유 ID | PK |
| user_id | integer | 평가자 ID | FK, NOT NULL |
| game_id | integer | 경기 ID | FK, NOT NULL |
| rated_user_id | integer | 평가받는 사용자 ID | FK, NOT NULL |
| rating | integer | 평점 (1-5) | NOT NULL |
| comment | text | 코멘트 | |
| rating_type | string | 평점 유형 | DEFAULT 'player', NOT NULL |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_ratings_on_user_id_and_game_id_and_rated_user_id` (UNIQUE)

---

## 통계 관련 테이블

### 1. player_stats 테이블
경기별 선수 통계

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 통계 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| game_id | integer | 경기 ID | FK, NOT NULL |
| game_result_id | integer | 경기 결과 ID | FK |
| minutes_played | integer | 출전 시간(분) | DEFAULT 0 |
| points | integer | 득점 | DEFAULT 0 |
| field_goals_made | integer | 필드골 성공 | DEFAULT 0 |
| field_goals_attempted | integer | 필드골 시도 | DEFAULT 0 |
| three_pointers_made | integer | 3점슛 성공 | DEFAULT 0 |
| three_pointers_attempted | integer | 3점슛 시도 | DEFAULT 0 |
| free_throws_made | integer | 자유투 성공 | DEFAULT 0 |
| free_throws_attempted | integer | 자유투 시도 | DEFAULT 0 |
| offensive_rebounds | integer | 공격 리바운드 | DEFAULT 0 |
| defensive_rebounds | integer | 수비 리바운드 | DEFAULT 0 |
| total_rebounds | integer | 총 리바운드 | DEFAULT 0 |
| assists | integer | 어시스트 | DEFAULT 0 |
| steals | integer | 스틸 | DEFAULT 0 |
| blocks | integer | 블락 | DEFAULT 0 |
| turnovers | integer | 턴오버 | DEFAULT 0 |
| personal_fouls | integer | 개인 파울 | DEFAULT 0 |
| plus_minus | decimal(5,1) | +/- | DEFAULT 0.0 |
| player_efficiency_rating | decimal(5,2) | PER | DEFAULT 0.0 |
| true_shooting_percentage | decimal(5,2) | TS% | DEFAULT 0.0 |
| effective_field_goal_percentage | decimal(5,2) | eFG% | DEFAULT 0.0 |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_player_stats_on_user_id_and_game_id` (UNIQUE)

### 2. season_averages 테이블
시즌별 평균 통계

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 통계 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| season_name | string | 시즌명 | |
| season_start | date | 시즌 시작일 | |
| season_end | date | 시즌 종료일 | |
| games_played | integer | 경기 수 | DEFAULT 0 |
| games_started | integer | 선발 출전 수 | DEFAULT 0 |
| wins | integer | 승리 수 | DEFAULT 0 |
| losses | integer | 패배 수 | DEFAULT 0 |
| minutes_per_game | decimal(5,2) | 평균 출전시간 | DEFAULT 0.0 |
| points_per_game | decimal(5,2) | 평균 득점 | DEFAULT 0.0 |
| rebounds_per_game | decimal(5,2) | 평균 리바운드 | DEFAULT 0.0 |
| assists_per_game | decimal(5,2) | 평균 어시스트 | DEFAULT 0.0 |
| steals_per_game | decimal(5,2) | 평균 스틸 | DEFAULT 0.0 |
| blocks_per_game | decimal(5,2) | 평균 블락 | DEFAULT 0.0 |
| turnovers_per_game | decimal(5,2) | 평균 턴오버 | DEFAULT 0.0 |
| field_goal_percentage | decimal(5,2) | FG% | DEFAULT 0.0 |
| three_point_percentage | decimal(5,2) | 3P% | DEFAULT 0.0 |
| free_throw_percentage | decimal(5,2) | FT% | DEFAULT 0.0 |
| player_efficiency_rating | decimal(5,2) | PER | DEFAULT 0.0 |
| true_shooting_percentage | decimal(5,2) | TS% | DEFAULT 0.0 |
| usage_rate | decimal(5,2) | USG% | DEFAULT 0.0 |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_season_averages_on_user_id_and_season_name` (UNIQUE)

---

## 알림 및 활동 관련 테이블

### 1. notifications 테이블
알림 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 알림 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| notification_type | string | 알림 유형 | NOT NULL |
| title | string | 제목 | NOT NULL |
| message | text | 메시지 | NOT NULL |
| data | json | 추가 데이터 | |
| notifiable_type | string | 알림 대상 타입 | |
| notifiable_id | integer | 알림 대상 ID | |
| status | integer | 상태 | DEFAULT 0, NOT NULL |
| priority | integer | 우선순위 | DEFAULT 1, NOT NULL |
| read_at | datetime | 읽은 시간 | |
| sent_at | datetime | 발송 시간 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**연관관계:**
- belongs_to :user
- belongs_to :notifiable (polymorphic)

### 2. activities 테이블
활동 로그

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 활동 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| activity_type | string | 활동 유형 | NOT NULL |
| trackable_type | string | 추적 대상 타입 | NOT NULL |
| trackable_id | integer | 추적 대상 ID | NOT NULL |
| metadata | text | 메타데이터 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**연관관계:**
- belongs_to :user
- belongs_to :trackable (polymorphic)

---

## 관리자 관련 테이블

### 1. admin_logs 테이블
관리자 활동 로그

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 로그 고유 ID | PK |
| user_id | integer | 관리자 ID | FK, NOT NULL |
| action | string | 액션 | NOT NULL |
| resource_type | string | 리소스 타입 | NOT NULL |
| resource_id | integer | 리소스 ID | |
| details | text | 상세 내용 | |
| ip_address | string | IP 주소 | |
| user_agent | string | 유저 에이전트 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

### 2. system_settings 테이블
시스템 설정

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 설정 고유 ID | PK |
| key | string | 설정 키 | NOT NULL, UNIQUE |
| value | text | 설정 값 | |
| description | text | 설명 | |
| category | string | 카테고리 | NOT NULL |
| editable | boolean | 편집 가능 여부 | DEFAULT true |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

### 3. reports 테이블
리포트 설정

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 리포트 고유 ID | PK |
| name | string | 리포트명 | NOT NULL |
| description | text | 설명 | |
| query | text | 쿼리 | NOT NULL |
| schedule | string | 스케줄 | |
| last_run | datetime | 마지막 실행일시 | |
| next_run | datetime | 다음 실행일시 | |
| active | boolean | 활성 여부 | DEFAULT true |
| parameters | json | 파라미터 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

---

## 기타 테이블

### 1. achievements 테이블
업적 정의

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 업적 고유 ID | PK |
| name | string | 업적명 | |
| description | text | 설명 | |
| icon | string | 아이콘 | |
| category | string | 카테고리 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

### 2. locations 테이블
지역 정보

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 지역 고유 ID | PK |
| city | string | 시/도 | NOT NULL |
| district | string | 구/군 | NOT NULL |
| full_name | string | 전체 이름 | NOT NULL |
| latitude | decimal(10,6) | 위도 | |
| longitude | decimal(10,6) | 경도 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_locations_on_city_and_district` (UNIQUE)

### 3. suggestions 테이블
사용자 제안사항

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 제안 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| title | string | 제목 | NOT NULL |
| content | text | 내용 | NOT NULL |
| status | string | 상태 | DEFAULT 'pending', NOT NULL |
| admin_response | text | 관리자 답변 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

---

## 주요 연관관계 다이어그램

### 사용자-경기 관계
```
User (1) -----> (*) Game (as organizer)
User (1) -----> (*) GameApplication
User (1) -----> (*) GameParticipation
User (1) -----> (*) GameResult
```

### 경기-신청-결제 플로우
```
Game (1) <----- (*) GameApplication
GameApplication (1) -----> (1) Payment
```

### 대회 관계
```
Tournament (1) <----- (*) TournamentTeam
Tournament (1) <----- (*) TournamentMatch
TournamentMatch (1) <----- (*) MatchPlayerStat
TournamentTeam (1) <----- (*) TournamentMatch (as home_team/away_team)
```

### 평가 시스템
```
Game (1) <----- (*) PlayerEvaluation
Game (1) <----- (*) Rating
User (1) -----> (*) PlayerEvaluation (as evaluator)
User (1) <----- (*) PlayerEvaluation (as evaluated_user)
```

---

## 주요 비즈니스 로직

### 1. 경기 신청 및 결제 플로우
1. **신청 (pending)**: 사용자가 경기 신청
2. **승인 대기 (waiting_payment)**: 호스트가 승인하면 결제 대기 상태로 변경
3. **결제 완료 (final_approved)**: 결제 확인 후 최종 승인
4. **거절 (rejected)**: 호스트가 거절하거나 결제 기한 초과

### 2. 평가 시스템
- 경기 종료 30분 후부터 24시간 동안 평가 가능
- PlayerEvaluation: 상세 평가 (스킬, 팀워크, 매너)
- Rating: 간단한 5점 평점

### 3. 프리미엄 회원 혜택
- 동시 주최 가능 경기 수 증가 (3개 → 10개)
- 대회 생성 권한
- 고급 통계 열람

### 4. 포인트 시스템
- 경기 참가, 평가 작성 등으로 포인트 획득
- UserPoint 테이블에 모든 거래 내역 기록

### 5. 취소 정책
- 주간 3회 이상 취소 시 48시간 신청 제한
- UserCancellation 테이블로 취소 이력 관리

---

## 퀵매치 관련 테이블

### 1. quick_match_preferences 테이블
사용자 퀵매치 선호도 설정

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| preferred_times | json | 선호 시간대 ({"monday": ["evening"], "tuesday": ["evening", "night"]}) | |
| preferred_locations | json | 선호 지역 (["gangnam", "seocho"]) | |
| preferred_level_range | integer | 선호 레벨 범위 | DEFAULT 1 |
| max_distance_km | integer | 최대 거리(km) | DEFAULT 10 |
| auto_match_enabled | boolean | 자동 매칭 활성화 | DEFAULT false |
| preferred_game_types | json | 선호 경기 유형 (["pickup", "guest", "team_vs_team"]) | DEFAULT [] |
| min_players | integer | 최소 인원 | DEFAULT 6 |
| max_players | integer | 최대 인원 | DEFAULT 10 |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_quick_match_preferences_on_user_id`
- `index_quick_match_preferences_on_auto_match_enabled`

**연관관계:**
- belongs_to :user

### 2. match_pools 테이블
매칭 대기열 (매칭 풀)

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| city | string | 도시 | NOT NULL |
| district | string | 구/군 | |
| match_time | datetime | 매치 시간 | NOT NULL |
| skill_level | integer | 스킬 레벨 | |
| current_players | integer | 현재 인원 | DEFAULT 0 |
| min_players | integer | 최소 인원 | DEFAULT 6 |
| max_players | integer | 최대 인원 | DEFAULT 10 |
| status | string | 상태 (forming/ready/game_created/cancelled) | DEFAULT 'forming' |
| game_type | string | 경기 유형 | DEFAULT 'pickup' |
| created_game_id | integer | 생성된 경기 ID | FK |
| player_ids | json | 참가자 ID 목록 | DEFAULT [] |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_match_pools_on_city_and_district`
- `index_match_pools_on_match_time`
- `index_match_pools_on_status`

**연관관계:**
- belongs_to :created_game (Game)
- has_many :match_pool_participants

### 3. match_pool_participants 테이블
매치 풀 참가자

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| match_pool_id | integer | 매치 풀 ID | FK, NOT NULL |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| status | string | 상태 (waiting/confirmed/declined) | DEFAULT 'waiting' |
| joined_at | datetime | 참가 시간 | DEFAULT CURRENT_TIMESTAMP |
| confirmed_at | datetime | 확정 시간 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_match_pool_participants_on_match_pool_id_and_user_id` (UNIQUE)

**연관관계:**
- belongs_to :match_pool
- belongs_to :user

### 4. quick_match_histories 테이블
퀵매치 기록

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| user_id | integer | 사용자 ID | FK, NOT NULL |
| game_id | integer | 경기 ID | FK |
| match_pool_id | integer | 매치 풀 ID | FK |
| match_type | string | 매치 유형 (instant_match/pool_match) | |
| search_time_seconds | integer | 검색 시간(초) | |
| successful | boolean | 성공 여부 | DEFAULT false |
| search_criteria | json | 검색 조건 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_quick_match_histories_on_successful`

**연관관계:**
- belongs_to :user
- belongs_to :game (optional)
- belongs_to :match_pool (optional)

---

## 대회 AI 및 자동화 관련 테이블

### 1. ai_poster_generations 테이블
AI 포스터 생성 기록

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| tournament_id | integer | 대회 ID | FK, NOT NULL |
| prompt_used | string(1000) | 사용된 프롬프트 | |
| style_selected | string | 선택된 스타일 | |
| image_url | string | 이미지 URL | |
| selected_by_user | boolean | 사용자 선택 여부 | DEFAULT false |
| generation_time_ms | integer | 생성 시간(ms) | |
| api_cost | decimal(10,2) | API 비용 | |
| status | string | 상태 | DEFAULT 'pending' |
| error_message | text | 에러 메시지 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_ai_poster_generations_on_selected_by_user`

**연관관계:**
- belongs_to :tournament

### 2. tournament_templates 테이블
대회 템플릿

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| name | string | 템플릿명 | NOT NULL |
| template_type | string | 템플릿 유형 | |
| default_team_count | integer | 기본 팀 수 | |
| estimated_duration_hours | integer | 예상 소요 시간 | |
| default_format | string | 기본 형식 | |
| default_rules | text | 기본 규칙 | |
| is_popular | boolean | 인기 템플릿 여부 | DEFAULT false |
| usage_count | integer | 사용 횟수 | DEFAULT 0 |
| category | string | 카테고리 (official/community/enterprise/special) | |
| is_premium_only | boolean | 프리미엄 전용 여부 | DEFAULT false |
| configuration | json | 추가 설정 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_tournament_templates_on_template_type`
- `index_tournament_templates_on_is_popular`

### 3. tournament_automations 테이블
대회 자동화 워크플로우

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| tournament_id | integer | 대회 ID | FK, NOT NULL |
| automation_type | string | 자동화 유형 | |
| status | string | 상태 | DEFAULT 'scheduled' |
| configuration | json | 설정 | |
| scheduled_at | datetime | 예약 시간 | |
| executed_at | datetime | 실행 시간 | |
| execution_log | text | 실행 로그 | |
| retry_count | integer | 재시도 횟수 | DEFAULT 0 |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_tournament_automations_on_automation_type`
- `index_tournament_automations_on_status`
- `index_tournament_automations_on_scheduled_at`

**연관관계:**
- belongs_to :tournament

### 4. tournament_marketing_campaigns 테이블
대회 마케팅 캠페인

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| id | integer | 고유 ID | PK |
| tournament_id | integer | 대회 ID | FK, NOT NULL |
| campaign_type | string | 캠페인 유형 | |
| channel | string | 채널 (email/sms/push/sns) | |
| recipients_count | integer | 수신자 수 | |
| opens_count | integer | 오픈 수 | DEFAULT 0 |
| clicks_count | integer | 클릭 수 | DEFAULT 0 |
| sent_at | datetime | 발송 시간 | |
| content | json | 콘텐츠 | |
| created_at | datetime | 생성일시 | NOT NULL |
| updated_at | datetime | 수정일시 | NOT NULL |

**주요 인덱스:**
- `index_tournament_marketing_campaigns_on_campaign_type`

**연관관계:**
- belongs_to :tournament

---

## 대회 관련 테이블 업데이트

### tournaments 테이블 추가 필드

| 컬럼명 | 타입 | 설명 | 제약조건 |
|--------|------|------|----------|
| is_official | boolean | BDR 공식 대회 여부 | DEFAULT false |
| created_by_premium_user | boolean | 프리미엄 사용자 생성 여부 | DEFAULT false |
| template_used | string | 사용된 템플릿 | |
| ai_poster_generated | boolean | AI 포스터 생성 여부 | DEFAULT false |
| poster_style | string | 포스터 스타일 | |
| poster_image_url | string | 포스터 이미지 URL | |
| auto_bracket_generated | boolean | 자동 대진표 생성 여부 | DEFAULT false |
| live_streaming_enabled | boolean | 라이브 스트리밍 활성화 | DEFAULT false |
| auto_notification_enabled | boolean | 자동 알림 활성화 | DEFAULT true |
| platform_fee_percentage | decimal(5,2) | 플랫폼 수수료율 | DEFAULT 5.0 |
| actual_platform_fee | decimal(10,2) | 실제 플랫폼 수수료 | |
| total_revenue | decimal(10,2) | 총 수익 | |
| settlement_status | string | 정산 상태 | |
| settlement_completed_at | datetime | 정산 완료 시간 | |

**추가 인덱스:**
- `index_tournaments_on_is_official`
- `index_tournaments_on_created_by_premium_user`
- `index_tournaments_on_settlement_status`

**추가 연관관계:**
- has_many :ai_poster_generations
- has_many :tournament_automations
- has_many :tournament_marketing_campaigns