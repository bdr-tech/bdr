class UserCancellation < ApplicationRecord
  belongs_to :user

  # 추가 필드: weekly_cancellation_count, first_weekly_cancelled_at

  def can_apply_for_games?
    # 1주일 내 5회 이상 취소 확인
    if weekly_cancellation_count && weekly_cancellation_count >= 5
      if first_weekly_cancelled_at && first_weekly_cancelled_at > 1.week.ago
        return false
      end
    end

    # 24시간 내 3회 이상 취소 확인
    if cancellation_count && cancellation_count >= 3
      if last_cancelled_at && last_cancelled_at > 24.hours.ago
        return false
      end
    end

    true
  end

  def self.increment_cancellation(user)
    cancellation = find_or_create_by(user: user) do |c|
      c.cancellation_count = 0
      c.weekly_cancellation_count = 0
    end

    # 24시간이 지났으면 일일 카운트 리셋
    if cancellation.last_cancelled_at && cancellation.last_cancelled_at < 24.hours.ago
      cancellation.cancellation_count = 0
    end

    # 1주일이 지났으면 주간 카운트 리셋
    if cancellation.first_weekly_cancelled_at && cancellation.first_weekly_cancelled_at < 1.week.ago
      cancellation.weekly_cancellation_count = 0
      cancellation.first_weekly_cancelled_at = nil
    end

    # 주간 첫 취소 시간 기록
    if cancellation.weekly_cancellation_count == 0
      cancellation.first_weekly_cancelled_at = Time.current
    end

    cancellation.cancellation_count += 1
    cancellation.weekly_cancellation_count ||= 0
    cancellation.weekly_cancellation_count += 1
    cancellation.last_cancelled_at = Time.current
    cancellation.save!

    cancellation
  end

  def hours_until_reset
    # 1주일 제한 중인 경우
    if weekly_cancellation_count && weekly_cancellation_count >= 5
      if first_weekly_cancelled_at && first_weekly_cancelled_at > 1.week.ago
        return ((first_weekly_cancelled_at + 1.week - Time.current) / 1.hour).to_i
      end
    end

    # 24시간 제한 중인 경우
    if cancellation_count && cancellation_count >= 3
      if last_cancelled_at && last_cancelled_at > 24.hours.ago
        return 24 - ((Time.current - last_cancelled_at) / 1.hour).to_i
      end
    end

    0
  end

  def restriction_message
    if weekly_cancellation_count && weekly_cancellation_count >= 5
      if first_weekly_cancelled_at && first_weekly_cancelled_at > 1.week.ago
        return "1주일 내 5회 이상 취소로 인해 #{hours_until_reset}시간 동안 신청이 제한됩니다."
      end
    end

    if cancellation_count && cancellation_count >= 3
      if last_cancelled_at && last_cancelled_at > 24.hours.ago
        return "24시간 내 3회 이상 취소로 인해 #{hours_until_reset}시간 동안 신청이 제한됩니다."
      end
    end

    nil
  end
end
