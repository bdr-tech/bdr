# frozen_string_literal: true

# 모델 변경 시 관련 캐시를 자동으로 무효화하는 모듈
module CacheInvalidation
  extend ActiveSupport::Concern

  included do
    after_commit :invalidate_related_caches
  end

  private

  def invalidate_related_caches
    case self.class.name
    when "User"
      invalidate_user_caches
    when "Game"
      invalidate_game_caches
    when "Location"
      invalidate_location_caches
    when "Payment"
      invalidate_payment_caches
    end
  end

  def invalidate_user_caches
    Rails.cache.delete("user/#{id}/data")
    Rails.cache.delete("users/leaderboard")
    Rails.cache.delete_matched("admin/dashboard*") if admin_changed?
  end

  def invalidate_game_caches
    Rails.cache.delete("games/upcoming")
    Rails.cache.delete("games/today")
    Rails.cache.delete("games/stats/#{Date.current}")
    Rails.cache.delete_matched("game/#{id}/*")
    
    # 관련 사용자 캐시도 무효화
    Rails.cache.delete("user/#{organizer_id}/games") if organizer_id
  end

  def invalidate_location_caches
    Rails.cache.delete("locations/all")
    Rails.cache.delete_matched("locations/city/*")
  end

  def invalidate_payment_caches
    Rails.cache.delete_matched("dashboard/stats/*")
    Rails.cache.delete_matched("admin/revenue/*")
  end
end