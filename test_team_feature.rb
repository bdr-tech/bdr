#!/usr/bin/env ruby
# 팀 멤버 자동 불러오기 기능 테스트

require 'rails'
ENV['RAILS_ENV'] ||= 'development'
require_relative 'config/environment'

puts "=" * 80
puts "팀 멤버 자동 불러오기 기능 테스트"
puts "=" * 80

# 테스트 데이터 생성
puts "\n1. 테스트 데이터 생성..."

# 랜덤 식별자 생성
timestamp = Time.now.to_i

# 사용자 생성
captain = User.create!(
  name: "김주장_#{timestamp}",
  email: "captain_#{timestamp}@test.com",
  phone: "010-1111-#{rand(1000..9999)}",
  nickname: "Captain_#{timestamp}",
  positions: ["PG"],
  is_premium: true,
  can_create_tournaments: true
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

puts "✅ 사용자 생성 완료: #{captain.name} + #{players.count}명"

# 팀 생성
team = Team.create!(
  name: "Thunder Basketball",
  captain: captain,
  description: "우리는 최고의 팀입니다",
  city: "서울",
  district: "강남구"
)

puts "✅ 팀 생성 완료: #{team.name}"

# 팀 멤버 추가
team.add_member(captain, 'captain')
players.each_with_index do |player, index|
  member = team.add_member(player, 'player')
  member.update(jersey_number: index + 1) if member
end

puts "✅ 팀 멤버 추가 완료: #{team.member_count}명"

# 대회 생성
tournament = Tournament.create!(
  name: "2024 겨울 농구 대회",
  organizer: captain,
  tournament_type: "single_elimination",
  max_teams: 16,
  entry_fee: 100000,
  tournament_start_at: 3.days.from_now,
  tournament_end_at: 5.days.from_now,
  registration_start_at: Time.current,
  registration_end_at: 2.days.from_now,
  status: "registration_open",
  venue: "올림픽체육관",
  location_address: "서울시 송파구"
)

puts "✅ 대회 생성 완료: #{tournament.name}"

# 대회 팀 등록 (기존 팀 사용)
tournament_team = tournament.tournament_teams.create!(
  captain: captain,
  team: team,
  team_name: team.name,
  contact_phone: captain.phone,
  contact_email: captain.email,
  status: "pending"
)

puts "✅ 대회 팀 등록 완료: #{tournament_team.team_name}"

# 팀 멤버를 대회 플레이어로 자동 등록
team.team_members.each do |member|
  tournament_team.tournament_players.create!(
    user: member.user,
    position: member.user.positions&.first,
    jersey_number: member.jersey_number
  )
end

puts "✅ 대회 플레이어 등록 완료: #{tournament_team.tournament_players.count}명"

puts "\n2. 기능 테스트..."

# 팀 로스터 확인
roster = team.roster
puts "\n팀 로스터:"
roster.each do |player|
  puts "  - #{player[:name]} (#{player[:nickname]}) | #{player[:position]} | ##{player[:jersey_number]}"
end

# 대회 팀 플레이어 확인
puts "\n대회 등록 선수:"
tournament_team.tournament_players.each do |tp|
  puts "  - #{tp.user.name} | #{tp.position} | ##{tp.jersey_number}"
end

# API 테스트
puts "\n3. API 테스트..."

# 팀 멤버 검색
search_results = User.where("name LIKE ?", "%선수%")
                     .where.not(id: team.users.pluck(:id))
                     .limit(5)

puts "검색 결과 (팀에 없는 선수): #{search_results.count}명"

# 통계
puts "\n4. 통계:"
puts "  - 팀 수: #{Team.count}"
puts "  - 팀 멤버 수: #{TeamMember.count}"
puts "  - 대회 팀 수: #{TournamentTeam.count}"
puts "  - 대회 플레이어 수: #{TournamentPlayer.count}"

puts "\n✅ 모든 테스트 완료!"
puts "=" * 80