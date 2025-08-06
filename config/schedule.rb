# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# 환경 설정
set :output, "/path/to/log/cron_log.log"
set :environment, "production"

# 매시간 실행 - 24시간 전 경기 리마인더 발송
every 1.hour do
  rake "games:send_reminders"
end

# 매일 오전 10시 - 정산 가능 알림 발송
every 1.day, at: "10:00 am" do
  rake "games:send_settlement_notifications"
end

# 매일 오전 9시 - 프리미엄 만료 예정 알림
every 1.day, at: "9:00 am" do
  rake "games:check_premium_expiration"
end

# 매 30분마다 - 자동 결제 마감 처리
every 30.minutes do
  rake "games:check_payment_deadlines"
end

# 매일 자정 - 완료된 경기 상태 업데이트
every 1.day, at: "12:00 am" do
  rake "games:update_completed_games"
end

# 매주 월요일 오전 6시 - 주간 취소 횟수 초기화
every :monday, at: "6am" do
  rake "users:reset_weekly_cancellations"
end

# Learn more: http://github.com/javan/whenever
