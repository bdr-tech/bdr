# frozen_string_literal: true

# 컨트롤러에서 사용할 수 있는 캐싱 관련 기능 모듈
module Cacheable
  extend ActiveSupport::Concern

  included do
    helper_method :cache_key_for_collection
  end

  # 현재 사용자 캐싱 개선
  def cached_current_user
    return @cached_current_user if defined?(@cached_current_user)
    
    if session[:user_id]
      @cached_current_user = Rails.cache.fetch(user_cache_key(session[:user_id]), expires_in: 10.minutes) do
        User.find_by(id: session[:user_id])
      end
    else
      @cached_current_user = nil
    end
  end

  # Location 데이터 캐싱
  def cached_location_data
    @cached_location_data ||= Rails.cache.fetch("locations/all", expires_in: 1.day) do
      {
        cities: Location.distinct.pluck(:city).sort,
        by_city: Location.all.group_by(&:city)
      }
    end
  end

  # 컬렉션을 위한 캐시 키 생성
  def cache_key_for_collection(collection_name, scope = nil)
    count = scope ? scope.count : collection_name.count
    max_updated = scope ? scope.maximum(:updated_at) : collection_name.maximum(:updated_at)
    
    "#{collection_name.model_name.cache_key}/collection-#{count}-#{max_updated&.to_i}"
  end

  # 대시보드 통계 캐싱
  def cached_dashboard_stats
    Rails.cache.fetch("dashboard/stats/#{Date.current}", expires_in: 5.minutes) do
      yield
    end
  end

  # 캐시 무효화 헬퍼
  def expire_cache_for(key_pattern)
    Rails.cache.delete_matched(key_pattern) if Rails.cache.respond_to?(:delete_matched)
  end

  private

  def user_cache_key(user_id)
    "user/#{user_id}/data"
  end
end