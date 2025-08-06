#!/usr/bin/env ruby
# 팀 멤버 자동 불러오기 기능 간단 테스트

require 'rails'
ENV['RAILS_ENV'] ||= 'development'
require_relative 'config/environment'

puts "=" * 80
puts "팀 멤버 자동 불러오기 기능 테스트"
puts "=" * 80

# 랜덤 식별자 생성
timestamp = Time.now.to_i

puts "\n1. 사용자 및 팀 생성..."

# 사용자 생성
captain = User.create!(
  name: "김주장_#{timestamp}",
  email: "captain_#{timestamp}@test.com",
  phone: "010-1111-#{rand(1000..9999)}",
  nickname: "Captain_#{timestamp}",
  positions: ["PG"]
)

players = []
5.times do |i|
  players << User.create!(
    name: "선수#{i+1}_#{timestamp}",
    email: "player#{i+1}_#{timestamp}@test.com",
    phone: "010-2222-#{rand(1000..9999)}",
    nickname: "Player#{i+1}_#{timestamp}",
    positions: [["PG", "SG", "SF", "PF", "C"].sample]
  )
end

puts "✅ 사용자 생성: #{captain.name} + #{players.count}명"

# 팀 생성
team = Team.create!(
  name: "Thunder_#{timestamp}",
  captain: captain,
  description: "테스트 팀",
  city: "서울",
  district: "강남구"
)

puts "✅ 팀 생성: #{team.name}"

# 팀 멤버 추가
team.add_member(captain, 'captain')
players.each_with_index do |player, index|
  member = team.add_member(player, 'player')
  member.update(jersey_number: index + 1) if member
end

puts "✅ 팀 멤버 추가: #{team.member_count}명"

puts "\n2. 팀 로스터 확인..."
roster = team.roster
roster.each do |player|
  puts "  - #{player[:name]} (#{player[:nickname]}) | #{player[:position]} | ##{player[:jersey_number]} | #{player[:role]}"
end

puts "\n3. 팀 멤버 검색 테스트..."

# 팀에 없는 새 사용자 생성
new_user = User.create!(
  name: "새선수_#{timestamp}",
  email: "new_#{timestamp}@test.com",
  phone: "010-3333-#{rand(1000..9999)}",
  nickname: "NewPlayer_#{timestamp}",
  positions: ["SF"]
)

# 검색 시뮬레이션
search_results = User.where("name LIKE ?", "%새선수%")
                     .where.not(id: team.users.pluck(:id))
                     .limit(5)

puts "검색 결과 (팀에 없는 선수):"
search_results.each do |user|
  puts "  - #{user.name} (#{user.nickname}) | #{user.positions&.join(', ')}"
end

puts "\n4. 팀 관련 기능 테스트..."
puts "  - 팀 활성 상태: #{team.is_active}"
puts "  - 대회 참가 가능: #{team.available_for_tournament?}"
puts "  - 주장 확인: #{team.captain.name}"
puts "  - 멤버 수: #{team.member_count}"

# 멤버 추가/제거 테스트
puts "\n5. 멤버 관리 테스트..."
puts "  - 새 멤버 추가 전: #{team.member_count}명"
team.add_member(new_user, 'player')
puts "  - 새 멤버 추가 후: #{team.member_count}명"
team.remove_member(new_user)
puts "  - 멤버 제거 후: #{team.member_count}명"

puts "\n✅ 모든 테스트 완료!"
puts "=" * 80

# 정리
team.destroy
captain.destroy
players.each(&:destroy)
new_user.destroy

puts "테스트 데이터 정리 완료"