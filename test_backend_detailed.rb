#!/usr/bin/env ruby
# 상세 백엔드 테스트

require 'net/http'
require 'json'
require 'rails'

# String 색상 확장
class String
  def green; "\e[32m#{self}\e[0m" end
  def red; "\e[31m#{self}\e[0m" end
  def yellow; "\e[33m#{self}\e[0m" end
  def blue; "\e[34m#{self}\e[0m" end
  def cyan; "\e[36m#{self}\e[0m" end
  def magenta; "\e[35m#{self}\e[0m" end
end

# Rails 환경 로드
ENV['RAILS_ENV'] ||= 'test'
require_relative 'config/environment'

puts "=" * 80
puts "BDR 백엔드 상세 테스트".blue
puts "=" * 80

class DetailedBackendTester
  def self.run_all_tests
    @results = {
      total: 0,
      passed: 0,
      failed: 0,
      warnings: 0,
      errors: []
    }
    
    puts "\n1️⃣  데이터베이스 테스트".cyan
    test_database
    
    puts "\n2️⃣  모델 관계 테스트".cyan
    test_model_relationships
    
    puts "\n3️⃣  서비스 클래스 테스트".cyan
    test_service_classes
    
    puts "\n4️⃣  컨트롤러 테스트".cyan
    test_controllers
    
    puts "\n5️⃣  대회 관리 기능 테스트".cyan
    test_tournament_features
    
    puts "\n6️⃣  보안 및 권한 테스트".cyan
    test_security
    
    print_summary
  end
  
  def self.test_database
    puts "데이터베이스 연결 확인...".yellow
    
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      record_success("데이터베이스 연결")
      
      # 테이블 확인
      tables = ActiveRecord::Base.connection.tables
      puts "  총 테이블 수: #{tables.count}"
      
      required_tables = %w[
        users tournaments tournament_teams tournament_templates
        games courts notifications brackets
      ]
      
      required_tables.each do |table|
        if tables.include?(table)
          record_success("테이블 '#{table}' 존재")
        else
          record_failure("테이블 '#{table}' 누락")
        end
      end
    rescue => e
      record_failure("데이터베이스 연결", e.message)
    end
  end
  
  def self.test_model_relationships
    puts "모델 관계 검증...".yellow
    
    # User 모델 관계
    begin
      user = User.new(name: "Test User", email: "test@example.com")
      
      # 관계 메서드 존재 확인
      relationships = [:games, :game_applications, :tournament_teams, :notifications]
      relationships.each do |rel|
        if user.respond_to?(rel)
          record_success("User.#{rel} 관계")
        else
          record_failure("User.#{rel} 관계 누락")
        end
      end
    rescue => e
      record_failure("User 모델 관계", e.message)
    end
    
    # Tournament 모델 관계
    begin
      tournament = Tournament.new(name: "Test Tournament")
      
      relationships = [:tournament_teams, :tournament_templates, :brackets, :notifications]
      relationships.each do |rel|
        if tournament.respond_to?(rel)
          record_success("Tournament.#{rel} 관계")
        else
          record_failure("Tournament.#{rel} 관계 누락")
        end
      end
    rescue => e
      record_failure("Tournament 모델 관계", e.message)
    end
  end
  
  def self.test_service_classes
    puts "서비스 클래스 테스트...".yellow
    
    services = [
      { 
        name: "BracketGenerationService",
        test: -> {
          tournament = Tournament.new(name: "Test", tournament_type: "single_elimination")
          service = BracketGenerationService.new(tournament)
          service.respond_to?(:generate)
        }
      },
      {
        name: "TournamentNotificationService",
        test: -> {
          tournament = Tournament.new(name: "Test")
          service = TournamentNotificationService.new(tournament)
          service.respond_to?(:send_reminder)
        }
      },
      {
        name: "TournamentReportService",
        test: -> {
          tournament = Tournament.new(name: "Test")
          service = TournamentReportService.new(tournament)
          service.respond_to?(:generate_report)
        }
      }
    ]
    
    services.each do |service_info|
      begin
        if service_info[:test].call
          record_success("#{service_info[:name]} 초기화")
        else
          record_failure("#{service_info[:name]} 메서드 누락")
        end
      rescue => e
        record_failure("#{service_info[:name]}", e.message)
      end
    end
  end
  
  def self.test_controllers
    puts "컨트롤러 응답 테스트...".yellow
    
    app = ActionDispatch::Integration::Session.new(Rails.application)
    
    routes = [
      { path: '/', name: 'Home', auth_required: false },
      { path: '/tournaments', name: 'Tournaments', auth_required: false },
      { path: '/games', name: 'Games', auth_required: false },
      { path: '/courts', name: 'Courts', auth_required: false },
      { path: '/login', name: 'Login', auth_required: false },
      { path: '/signup', name: 'Signup', auth_required: false },
      { path: '/profile', name: 'Profile', auth_required: true },
      { path: '/admin', name: 'Admin', auth_required: true, admin: true }
    ]
    
    routes.each do |route|
      begin
        app.get(route[:path])
        
        if route[:auth_required]
          if app.response.redirect?
            record_success("#{route[:name]} - 인증 리다이렉트")
          else
            record_warning("#{route[:name]} - 인증 없이 접근 가능")
          end
        else
          if app.response.successful?
            record_success("#{route[:name]} - 200 OK")
          elsif app.response.redirect?
            record_success("#{route[:name]} - 리다이렉트")
          else
            record_failure("#{route[:name]} - #{app.response.status}")
          end
        end
      rescue => e
        record_failure("#{route[:name]} 라우트", e.message)
      end
    end
  end
  
  def self.test_tournament_features
    puts "대회 관리 기능 테스트...".yellow
    
    begin
      # 템플릿 기능
      template = TournamentTemplate.new(
        name: "테스트 템플릿",
        template_type: "preset",
        configuration: { tournament_type: "single_elimination" }
      )
      
      if template.valid?
        record_success("TournamentTemplate 유효성 검사")
      else
        record_failure("TournamentTemplate 유효성", template.errors.full_messages.join(", "))
      end
      
      # QR 코드 기능
      team = TournamentTeam.new(
        name: "Test Team",
        tournament: Tournament.new(name: "Test")
      )
      
      if team.respond_to?(:generate_qr_token)
        record_success("TournamentTeam QR 토큰 생성")
      else
        record_warning("TournamentTeam QR 토큰 메서드 누락")
      end
      
      # 대시보드 컨트롤러
      if defined?(TournamentDashboardsController)
        record_success("TournamentDashboardsController 정의됨")
      else
        record_failure("TournamentDashboardsController 누락")
      end
      
      # 체크인 컨트롤러
      if defined?(TournamentCheckInsController)
        record_success("TournamentCheckInsController 정의됨")
      else
        record_failure("TournamentCheckInsController 누락")
      end
      
    rescue => e
      record_failure("대회 기능", e.message)
    end
  end
  
  def self.test_security
    puts "보안 및 권한 테스트...".yellow
    
    app = ActionDispatch::Integration::Session.new(Rails.application)
    
    # CSRF 토큰 확인
    begin
      app.get('/')
      if app.response.body.include?('csrf-token')
        record_success("CSRF 보호 활성화")
      else
        record_warning("CSRF 토큰 미발견")
      end
    rescue => e
      record_failure("CSRF 확인", e.message)
    end
    
    # 관리자 라우트 보호
    admin_routes = ['/admin', '/admin/users', '/admin/tournaments']
    admin_routes.each do |route|
      begin
        app.get(route)
        if app.response.redirect?
          record_success("#{route} 보호됨")
        else
          record_failure("#{route} 보호 안됨")
        end
      rescue => e
        # 라우트가 없을 수 있음
        record_warning("#{route} 확인 불가")
      end
    end
  end
  
  def self.record_success(test_name)
    @results[:total] += 1
    @results[:passed] += 1
    puts "  ✅ #{test_name}".green
  end
  
  def self.record_failure(test_name, message = nil)
    @results[:total] += 1
    @results[:failed] += 1
    error_msg = message ? "#{test_name}: #{message}" : test_name
    @results[:errors] << error_msg
    puts "  ❌ #{error_msg}".red
  end
  
  def self.record_warning(test_name)
    @results[:total] += 1
    @results[:warnings] += 1
    puts "  ⚠️  #{test_name}".yellow
  end
  
  def self.print_summary
    puts "\n" + "=" * 80
    puts "테스트 결과 요약".blue
    puts "=" * 80
    
    success_rate = @results[:total] > 0 ? (@results[:passed].to_f / @results[:total] * 100).round(2) : 0
    
    puts "총 테스트: #{@results[:total]}"
    puts "✅ 성공: #{@results[:passed]}".green
    puts "❌ 실패: #{@results[:failed]}".red if @results[:failed] > 0
    puts "⚠️  경고: #{@results[:warnings]}".yellow if @results[:warnings] > 0
    puts "성공률: #{success_rate}%"
    
    if @results[:errors].any?
      puts "\n실패 항목:".red
      @results[:errors].each_with_index do |error, index|
        puts "  #{index + 1}. #{error}"
      end
    end
    
    if success_rate >= 90
      puts "\n✨ 우수한 테스트 결과입니다!".green
    elsif success_rate >= 70
      puts "\n📌 일부 개선이 필요합니다.".yellow
    else
      puts "\n⚠️  즉시 수정이 필요합니다!".red
    end
  end
end

# 테스트 실행
DetailedBackendTester.run_all_tests