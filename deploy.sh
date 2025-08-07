#!/bin/bash

# Fly.io 배포 스크립트
# 사용법: ./deploy.sh

echo "🚀 BDR 프로젝트 Fly.io 배포 시작"
echo "================================"

# Fly CLI 경로 설정
FLYCTL="/Users/grizrider/.fly/bin/flyctl"

# 1. 로그인 상태 확인
echo "📋 로그인 상태 확인 중..."
$FLYCTL auth whoami
if [ $? -ne 0 ]; then
    echo "❌ Fly.io 로그인이 필요합니다."
    echo "다음 명령어를 실행해주세요:"
    echo "$FLYCTL auth login"
    exit 1
fi

# 2. 앱 이름 확인
echo ""
echo "📱 현재 설정된 앱 이름: bdr-app"
echo "실제 생성한 앱 이름이 다르다면 fly.toml 파일을 수정해주세요."
read -p "계속 진행하시겠습니까? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "배포를 취소합니다."
    exit 1
fi

# 3. 환경 변수 설정
echo ""
echo "🔐 환경 변수 설정 중..."
echo "RAILS_MASTER_KEY 설정..."
$FLYCTL secrets set RAILS_MASTER_KEY=19476ca4d42323891a0f2c2c00745d2b --stage

echo "PLATFORM_FEE_PERCENTAGE 설정..."
$FLYCTL secrets set PLATFORM_FEE_PERCENTAGE=5.0 --stage

# Toss Payments 키가 있다면 설정
read -p "Toss Payments 키를 설정하시겠습니까? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "TOSS_CLIENT_KEY: " TOSS_CLIENT_KEY
    read -p "TOSS_SECRET_KEY: " TOSS_SECRET_KEY
    $FLYCTL secrets set TOSS_CLIENT_KEY=$TOSS_CLIENT_KEY TOSS_SECRET_KEY=$TOSS_SECRET_KEY --stage
fi

# 4. 배포 실행
echo ""
echo "🚀 배포를 시작합니다..."
$FLYCTL deploy

# 5. 배포 상태 확인
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 배포가 성공적으로 완료되었습니다!"
    echo ""
    echo "📊 앱 상태 확인 중..."
    $FLYCTL status
    
    echo ""
    echo "🌐 앱 URL 열기..."
    $FLYCTL open
else
    echo ""
    echo "❌ 배포 중 오류가 발생했습니다."
    echo "로그를 확인하려면 다음 명령어를 실행하세요:"
    echo "$FLYCTL logs"
fi

echo ""
echo "================================"
echo "배포 스크립트 완료"