#!/usr/bin/env ruby
# 전체 라우트 테스트 스크립트

require 'net/http'
require 'json'

# 색상 코드
class String
  def green; "\e[32m#{self}\e[0m" end
  def red; "\e[31m#{self}\e[0m" end
  def yellow; "\e[33m#{self}\e[0m" end
  def blue; "\e[34m#{self}\e[0m" end
end

puts "=" * 80
puts "BDR 프로젝트 전체 라우트 테스트".blue
puts "=" * 80

# 테스트할 라우트 목록
routes_to_test = [
  # 기본 페이지
  { path: '/', method: 'GET', name: 'Home Page' },
  { path: '/login', method: 'GET', name: 'Login Page' },
  { path: '/signup', method: 'GET', name: 'Signup Page' },
  
  # 경기 관련
  { path: '/games', method: 'GET', name: 'Games Index' },
  { path: '/games/new', method: 'GET', name: 'New Game', auth_required: true },
  { path: '/games/quick_match', method: 'GET', name: 'Quick Match' },
  { path: '/games/today', method: 'GET', name: 'Today Games' },
  { path: '/games/nearby', method: 'GET', name: 'Nearby Games' },
  
  # 코트 관련
  { path: '/courts', method: 'GET', name: 'Courts Index' },
  { path: '/outdoor-courts', method: 'GET', name: 'Outdoor Courts' },
  
  # 커뮤니티
  { path: '/community', method: 'GET', name: 'Community Index' },
  { path: '/community/free_board', method: 'GET', name: 'Free Board' },
  { path: '/community/teams', method: 'GET', name: 'Teams' },
  { path: '/posts', method: 'GET', name: 'Posts Index' },
  
  # 대회 관련
  { path: '/tournaments', method: 'GET', name: 'Tournaments Index' },
  { path: '/tournaments/past', method: 'GET', name: 'Past Tournaments' },
  { path: '/tournament_templates', method: 'GET', name: 'Tournament Templates', auth_required: true },
  
  # 프로필
  { path: '/profile', method: 'GET', name: 'Profile', auth_required: true },
  { path: '/stats', method: 'GET', name: 'Stats', auth_required: true },
  { path: '/achievements', method: 'GET', name: 'Achievements', auth_required: true },
  { path: '/points', method: 'GET', name: 'Points', auth_required: true },
  
  # 프리미엄
  { path: '/premium', method: 'GET', name: 'Premium' },
  
  # 알림
  { path: '/notifications', method: 'GET', name: 'Notifications', auth_required: true },
  
  # 매치 풀
  { path: '/match_pools', method: 'GET', name: 'Match Pools' },
  
  # 관리자
  { path: '/admin', method: 'GET', name: 'Admin Dashboard', auth_required: true, admin_required: true },
]

# 테스트 실행
base_url = 'http://localhost:3000'
success_count = 0
fail_count = 0
auth_skip_count = 0

routes_to_test.each_with_index do |route, index|
  print "[#{index + 1}/#{routes_to_test.length}] Testing #{route[:name]}... "
  
  begin
    uri = URI("#{base_url}#{route[:path]}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 5
    http.read_timeout = 5
    
    request = case route[:method]
              when 'POST' then Net::HTTP::Post.new(uri)
              when 'PUT' then Net::HTTP::Put.new(uri)
              when 'DELETE' then Net::HTTP::Delete.new(uri)
              else Net::HTTP::Get.new(uri)
              end
    
    response = http.request(request)
    
    # 상태 코드 체크
    if response.code == '200'
      puts "✓".green + " (200 OK)"
      success_count += 1
    elsif response.code == '302' || response.code == '303'
      # 리다이렉트는 대부분 인증이 필요한 경우
      if route[:auth_required] || route[:admin_required]
        puts "→".yellow + " (#{response.code} Redirect - Auth Required)"
        auth_skip_count += 1
      else
        puts "→".yellow + " (#{response.code} Redirect)"
        success_count += 1
      end
    elsif response.code == '401' || response.code == '403'
      if route[:auth_required] || route[:admin_required]
        puts "🔒".yellow + " (#{response.code} Auth Required - Expected)"
        auth_skip_count += 1
      else
        puts "✗".red + " (#{response.code} Unauthorized)"
        fail_count += 1
      end
    elsif response.code == '404'
      puts "✗".red + " (404 Not Found)"
      fail_count += 1
    elsif response.code == '500'
      puts "✗".red + " (500 Server Error)"
      fail_count += 1
    else
      puts "?".yellow + " (#{response.code})"
      fail_count += 1
    end
    
  rescue => e
    puts "✗".red + " (Error: #{e.message})"
    fail_count += 1
  end
end

puts "\n" + "=" * 80
puts "테스트 결과 요약".blue
puts "=" * 80
puts "✓ 성공: #{success_count}".green
puts "✗ 실패: #{fail_count}".red
puts "🔒 인증 필요 (스킵): #{auth_skip_count}".yellow
puts "총 테스트: #{routes_to_test.length}"

# 성공률 계산
total_testable = success_count + fail_count
success_rate = total_testable > 0 ? (success_count.to_f / total_testable * 100).round(2) : 0
puts "\n성공률: #{success_rate}%"

if fail_count > 0
  puts "\n⚠️  일부 라우트에 문제가 있습니다. 로그를 확인하세요.".red
else
  puts "\n✅ 모든 공개 라우트가 정상 작동합니다!".green
end