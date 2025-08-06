puts "시스템 설정 초기값 생성 중..."
SystemSetting.seed_defaults
puts "✅ 시스템 설정 완료: #{SystemSetting.count}개"

puts "리포트 템플릿 생성 중..."
Report.seed_defaults
puts "✅ 리포트 템플릿 완료: #{Report.count}개"

puts "관리자 로그 샘플 생성 중..."
admin_user = User.find_by(admin: true)
if admin_user
  AdminLog.log_action(admin_user, 'seed_data', 'SystemSetting', nil, 'Initial system setup', nil)
  AdminLog.log_action(admin_user, 'seed_data', 'Report', nil, 'Initial report templates', nil)
  puts "✅ 관리자 로그 샘플 완료"
else
  puts "⚠️  관리자 사용자가 없습니다. 관리자 계정을 먼저 생성해주세요."
end

puts "관리자 데이터 시드 완료!"
puts "이제 /admin 에서 관리자 기능을 사용할 수 있습니다."
