# BDR 프로젝트 배포 가이드

## ⚡ 현재 상태

✅ **완료된 작업:**
- Docker 컨테이너 구성 완료
- Fly.io 설정 파일 (fly.toml) 생성 완료
- GitHub Actions CI/CD 파이프라인 구성 완료
- 보안 강화 (CSRF, Security Headers) 적용 완료
- 성능 최적화 (N+1 쿼리 해결, 캐싱) 완료
- 환경 변수 템플릿 (.env.example) 생성 완료

⏳ **배포 실행 필요:**
아래 가이드를 따라 Fly.io에 배포를 진행하세요.

## 🚀 Fly.io 배포

### 사전 준비

1. **Fly.io CLI 설치**
```bash
# macOS
brew install flyctl

# 또는 설치 스크립트 사용
curl -L https://fly.io/install.sh | sh
```

2. **Fly.io 계정 생성 및 로그인**
```bash
flyctl auth signup
# 또는
flyctl auth login
```

### 초기 배포 설정

1. **Fly.io 앱 생성**
```bash
flyctl launch --name bdr-app --region nrt
```

2. **PostgreSQL 데이터베이스 생성**
```bash
flyctl postgres create --name bdr-db --region nrt
flyctl postgres attach bdr-db
```

3. **환경 변수 설정**
```bash
# Rails Master Key 설정
flyctl secrets set RAILS_MASTER_KEY=19476ca4d42323891a0f2c2c00745d2b

# Toss Payments 설정
flyctl secrets set TOSS_CLIENT_KEY=your_toss_client_key
flyctl secrets set TOSS_SECRET_KEY=your_toss_secret_key

# 플랫폼 수수료 설정
flyctl secrets set PLATFORM_FEE_PERCENTAGE=5.0
```

### 배포 실행

1. **수동 배포**
```bash
flyctl deploy
```

2. **GitHub Actions 자동 배포 설정**
```bash
# Fly.io API 토큰 생성
flyctl auth token

# GitHub Secrets에 추가
# Settings > Secrets and variables > Actions > New repository secret
# Name: FLY_API_TOKEN
# Value: [위에서 생성한 토큰]
```

### 배포 후 작업

1. **데이터베이스 마이그레이션**
```bash
flyctl ssh console -C "rails db:migrate"
```

2. **초기 데이터 설정**
```bash
flyctl ssh console -C "rails db:seed"
```

3. **Rails 콘솔 접속**
```bash
flyctl ssh console -C "rails console"
```

### 모니터링

1. **로그 확인**
```bash
flyctl logs
```

2. **앱 상태 확인**
```bash
flyctl status
```

3. **대시보드 접속**
```bash
flyctl dashboard
```

### 스케일링

1. **인스턴스 수 조정**
```bash
flyctl scale count 2
```

2. **머신 사양 변경**
```bash
flyctl scale vm shared-cpu-1x --memory 512
```

## 🔧 트러블슈팅

### 일반적인 문제 해결

1. **빌드 실패**
```bash
# Docker 캐시 정리
flyctl deploy --no-cache
```

2. **데이터베이스 연결 실패**
```bash
# 연결 정보 확인
flyctl postgres config show

# 연결 재설정
flyctl postgres attach bdr-db --database-name bdr_production
```

3. **환경 변수 확인**
```bash
flyctl secrets list
```

### 롤백

1. **이전 버전으로 롤백**
```bash
# 배포 이력 확인
flyctl releases

# 특정 버전으로 롤백
flyctl deploy --image registry.fly.io/bdr-app:v[VERSION_NUMBER]
```

## 📊 성능 최적화

### 캐싱 설정

1. **Redis 추가 (선택사항)**
```bash
flyctl redis create --name bdr-redis --region nrt
flyctl redis attach bdr-redis
```

2. **캐시 스토어 설정**
```ruby
# config/environments/production.rb
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  expires_in: 1.hour
}
```

### CDN 설정

1. **정적 파일 서빙**
```toml
# fly.toml
[[statics]]
  guest_path = "/rails/public"
  url_prefix = "/"
```

## 🔐 보안

### SSL/TLS

Fly.io는 자동으로 SSL 인증서를 제공하고 관리합니다.

```toml
# fly.toml
[http_service]
  force_https = true
```

### 보안 헤더

ApplicationController에 이미 구현되어 있습니다:
- X-Frame-Options: DENY
- X-Content-Type-Options: nosniff
- X-XSS-Protection: 1; mode=block
- Referrer-Policy: strict-origin-when-cross-origin

## 📈 모니터링 도구

### New Relic (선택사항)

1. **New Relic 설정**
```bash
flyctl secrets set NEW_RELIC_LICENSE_KEY=your_license_key
```

2. **Gemfile 추가**
```ruby
gem 'newrelic_rpm'
```

### Sentry (선택사항)

1. **Sentry 설정**
```bash
flyctl secrets set SENTRY_DSN=your_sentry_dsn
```

2. **Gemfile 추가**
```ruby
gem 'sentry-ruby'
gem 'sentry-rails'
```

## 🚨 긴급 대응

### 서비스 재시작

```bash
flyctl apps restart bdr-app
```

### 긴급 스케일 업

```bash
flyctl scale count 5 --yes
```

### 데이터베이스 백업

```bash
flyctl postgres backup create
```

## 📝 체크리스트

배포 전 확인사항:
- [ ] 모든 테스트 통과
- [ ] 환경 변수 설정 완료
- [ ] 데이터베이스 백업
- [ ] 마이그레이션 파일 확인
- [ ] Assets 프리컴파일 테스트

배포 후 확인사항:
- [ ] 헬스체크 응답 확인 (/health)
- [ ] 주요 기능 동작 테스트
- [ ] 로그 모니터링
- [ ] 성능 메트릭 확인

## 📞 지원

문제가 발생하면:
1. Fly.io 상태 페이지 확인: https://status.flyio.net/
2. Fly.io 커뮤니티: https://community.fly.io/
3. 프로젝트 이슈 트래커: https://github.com/[your-username]/BDR_PJT/issues