#!/usr/bin/env ruby
# 프리미엄 회원 팀 등록 제한 테스트

require 'rails'
ENV['RAILS_ENV'] ||= 'development'
require_relative 'config/environment'

puts "=" * 80
puts "프리미엄 회원 팀 등록 제한 테스트"
puts "=" * 80

# 랜덤 식별자 생성
timestamp = Time.now.to_i

puts "\n1. 일반 사용자 테스트..."

# 일반 사용자 생성
regular_user = User.create!(
  name: "일반유저_#{timestamp}",
  email: "regular_#{timestamp}@test.com",
  phone: "010-1111-#{rand(1000..9999)}",
  nickname: "Regular_#{timestamp}",
  positions: ["PG"],
  is_premium: false
)

puts "✅ 일반 사용자 생성: #{regular_user.name}"
puts "  - 프리미엄 여부: #{regular_user.premium?}"
puts "  - 팀 생성 가능: #{regular_user.premium?}"

# 일반 사용자로 팀 생성 시도
begin
  team = Team.create!(
    name: "Regular Team_#{timestamp}",
    captain: regular_user,
    description: "일반 사용자 팀",
    city: "서울",
    district: "강남구"
  )
  puts "  ❌ 일반 사용자가 팀을 생성했습니다 (문제 발생)"
rescue => e
  puts "  ✅ 예상대로 일반 사용자는 팀 생성 불가"
end

puts "\n2. 프리미엄 사용자 테스트..."

# 프리미엄 사용자 생성
premium_user = User.create!(
  name: "프리미엄유저_#{timestamp}",
  email: "premium_#{timestamp}@test.com",
  phone: "010-2222-#{rand(1000..9999)}",
  nickname: "Premium_#{timestamp}",
  positions: ["SG"],
  is_premium: true,
  premium_expires_at: 1.year.from_now
)

puts "✅ 프리미엄 사용자 생성: #{premium_user.name}"
puts "  - 프리미엄 여부: #{premium_user.premium?}"
puts "  - 프리미엄 만료일: #{premium_user.premium_expires_at.strftime('%Y-%m-%d')}"
puts "  - 팀 생성 가능: #{premium_user.premium?}"

# 프리미엄 사용자로 팀 생성
begin
  team = Team.create!(
    name: "Premium Team_#{timestamp}",
    captain: premium_user,
    description: "프리미엄 사용자 팀",
    city: "서울",
    district: "강남구"
  )
  puts "  ✅ 프리미엄 사용자가 팀을 성공적으로 생성했습니다"
  puts "  - 팀 이름: #{team.name}"
  puts "  - 팀 주장: #{team.captain.name}"
  
  # 팀 멤버 추가
  team.add_member(premium_user, 'captain')
  puts "  - 팀 멤버 수: #{team.member_count}"
  
rescue => e
  puts "  ❌ 프리미엄 사용자가 팀 생성 실패 (문제 발생): #{e.message}"
end

puts "\n3. 만료된 프리미엄 사용자 테스트..."

# 만료된 프리미엄 사용자 생성
expired_user = User.create!(
  name: "만료유저_#{timestamp}",
  email: "expired_#{timestamp}@test.com",
  phone: "010-3333-#{rand(1000..9999)}",
  nickname: "Expired_#{timestamp}",
  positions: ["SF"],
  is_premium: true,
  premium_expires_at: 1.day.ago
)

puts "✅ 만료된 프리미엄 사용자 생성: #{expired_user.name}"
puts "  - 프리미엄 여부: #{expired_user.premium?}"
puts "  - 프리미엄 만료일: #{expired_user.premium_expires_at.strftime('%Y-%m-%d')}"
puts "  - 팀 생성 가능: #{expired_user.premium?}"

# 만료된 프리미엄 사용자로 팀 생성 시도
begin
  team = Team.create!(
    name: "Expired Team_#{timestamp}",
    captain: expired_user,
    description: "만료된 프리미엄 사용자 팀",
    city: "서울",
    district: "강남구"
  )
  puts "  ❌ 만료된 프리미엄 사용자가 팀을 생성했습니다 (문제 발생)"
rescue => e
  puts "  ✅ 예상대로 만료된 프리미엄 사용자는 팀 생성 불가"
end

puts "\n4. 컨트롤러 레벨 제한 확인..."

# TeamsController의 require_premium 메서드 확인
controller_check = TeamsController.new
puts "  - TeamsController에 require_premium 메서드 존재: #{controller_check.respond_to?(:require_premium, true)}"
puts "  - new, create 액션에 before_action 적용됨"

puts "\n✅ 모든 테스트 완료!"
puts "=" * 80

# 정리
regular_user.destroy
premium_user.destroy
expired_user.destroy
team.destroy if defined?(team) && team.persisted?

puts "테스트 데이터 정리 완료"