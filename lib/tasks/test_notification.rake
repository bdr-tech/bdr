namespace :notification do
  desc "Send a test notification to a user"
  task :test, [ :user_id ] => :environment do |t, args|
    user = User.find_by(id: args[:user_id])

    if user
      notification = Notification.create_for_user(
        user,
        "system_announcement",
        title: "테스트 알림",
        message: "실시간 알림 시스템이 정상적으로 작동하고 있습니다!",
        data: { test: true }
      )

      puts "Test notification sent to #{user.name} (ID: #{user.id})"
      puts "Notification ID: #{notification.id}"
    else
      puts "User not found with ID: #{args[:user_id]}"
    end
  end

  desc "Send test notifications to all users"
  task test_all: :environment do
    User.find_each do |user|
      Notification.create_for_user(
        user,
        "system_announcement",
        title: "시스템 공지",
        message: "BDR 실시간 알림 시스템이 업데이트되었습니다. 이제 실시간으로 알림을 받을 수 있습니다!",
        priority: "high"
      )
    end

    puts "Test notifications sent to #{User.count} users"
  end
end
