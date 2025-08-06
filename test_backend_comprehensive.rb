#!/usr/bin/env ruby
# 종합적인 백엔드 테스트

require 'net/http'
require 'json'
require 'rails'

# String 색상 확장
class String
  def green; "\e[32m#{self}\e[0m" end
  def red; "\e[31m#{self}\e[0m" end
  def yellow; "\e[33m#{self}\e[0m" end
  def blue; "\e[34m#{self}\e[0m" end
end

# Rails 환경 로드
ENV['RAILS_ENV'] ||= 'test'
require_relative 'config/environment'

puts "=" * 80
puts "BDR 백엔드 종합 테스트".blue
puts "=" * 80

class BackendTester
  def self.run_tests
    puts "\n📊 데이터베이스 연결 테스트".blue
    test_database_connection
    
    puts "\n🔧 모델 테스트".blue
    test_models
    
    puts "\n🎯 서비스 클래스 테스트".blue
    test_services
    
    puts "\n📋 컨트롤러 응답 테스트".blue
    test_controllers
    
    puts "\n🔄 라우트 테스트".blue
    test_routes
    
    puts "\n✅ 테스트 완료!".green
  end
  
  def self.test_database_connection
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      puts "✓ 데이터베이스 연결 성공".green
      
      # 테이블 수 확인
      tables = ActiveRecord::Base.connection.tables
      puts "  - 테이블 수: #{tables.count}"
      puts "  - 주요 테이블: #{tables.select { |t| ['users', 'tournaments', 'games'].include?(t) }.join(', ')}"
    rescue => e
      puts "✗ 데이터베이스 연결 실패: #{e.message}".red
    end
  end
  
  def self.test_models
    models_to_test = [
      User, Tournament, TournamentTemplate, TournamentTeam, 
      TournamentChecklist, Game, Court, Notification
    ]
    
    models_to_test.each do |model|
      begin
        count = model.count
        puts "✓ #{model.name}: #{count} records".green
      rescue => e
        puts "✗ #{model.name}: #{e.message}".red
      end
    end
  end
  
  def self.test_services
    services_to_test = [
      { name: 'BracketGenerationService', test: -> { 
        tournament = Tournament.first || Tournament.new(name: 'Test')
        BracketGenerationService.new(tournament)
        true
      }},
      { name: 'TournamentNotificationService', test: -> {
        tournament = Tournament.first || Tournament.new(name: 'Test')
        TournamentNotificationService.new(tournament)
        true
      }},
      { name: 'QuickMatchService', test: -> {
        user = User.first || User.new(name: 'Test')
        QuickMatchService.new(user)
        true
      }},
      { name: 'TournamentReportService', test: -> {
        tournament = Tournament.first || Tournament.new(name: 'Test')
        TournamentReportService.new(tournament)
        true
      }}
    ]
    
    services_to_test.each do |service|
      begin
        if service[:test].call
          puts "✓ #{service[:name]} 초기화 성공".green
        end
      rescue => e
        puts "✗ #{service[:name]}: #{e.message}".red
      end
    end
  end
  
  def self.test_controllers
    # 컨트롤러 액션 직접 테스트
    app = ActionDispatch::Integration::Session.new(Rails.application)
    
    test_cases = [
      { path: '/', method: :get, name: 'Home' },
      { path: '/games', method: :get, name: 'Games' },
      { path: '/tournaments', method: :get, name: 'Tournaments' },
      { path: '/courts', method: :get, name: 'Courts' },
      { path: '/community', method: :get, name: 'Community' }
    ]
    
    test_cases.each do |test|
      begin
        app.send(test[:method], test[:path])
        if app.response.successful? || app.response.redirect?
          puts "✓ #{test[:name]}: #{app.response.status}".green
        else
          puts "✗ #{test[:name]}: #{app.response.status}".red
        end
      rescue => e
        puts "✗ #{test[:name]}: #{e.message}".red
      end
    end
  end
  
  def self.test_routes
    routes = Rails.application.routes.routes
    
    # 라우트 통계
    total_routes = routes.count
    named_routes = routes.select { |r| r.name.present? }.count
    
    puts "📊 라우트 통계:"
    puts "  - 총 라우트: #{total_routes}"
    puts "  - 명명된 라우트: #{named_routes}"
    
    # 주요 라우트 확인
    important_routes = [
      'tournaments', 'tournament_dashboard', 'tournament_checklists',
      'tournament_check_ins', 'tournament_templates'
    ]
    
    important_routes.each do |route_name|
      matching_routes = routes.select { |r| r.name&.include?(route_name) }
      if matching_routes.any?
        puts "✓ #{route_name}: #{matching_routes.count} routes".green
      else
        puts "✗ #{route_name}: 라우트 없음".red
      end
    end
  end
end

# 테스트 실행
BackendTester.run_tests