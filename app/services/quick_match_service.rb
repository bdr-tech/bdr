class QuickMatchService
  def initialize(user)
    @user = user
    @preferences = user.quick_match_preference || create_default_preferences
  end

  # 즉시 매치 찾기
  def find_match
    # 1. 현재 진행 중인 적합한 경기 찾기
    suitable_game = find_suitable_game

    if suitable_game
      return { type: :instant_match, game: suitable_game }
    end

    # 2. 매치 풀에서 대기 중인 매치 찾기
    match_pool = find_or_create_match_pool

    { type: :pool_match, match_pool: match_pool }
  end

  # 자동 매칭 활성화/비활성화
  def toggle_auto_match(enabled)
    @preferences.update!(auto_match_enabled: enabled)
  end

  # 선호도 업데이트
  def update_preferences(params)
    @preferences.update!(params)
  end

  private

  def create_default_preferences
    @user.create_quick_match_preference!(
      preferred_level_range: 1,
      max_distance_km: 10,
      auto_match_enabled: false,
      preferred_game_types: [ "pickup" ],
      min_players: 6,
      max_players: 10
    )
  end

  def find_suitable_game
    games = Game.upcoming
                .joins(:court)
                .where(game_type: @preferences.preferred_game_types)
                .where("games.scheduled_at >= ?", 30.minutes.from_now)
                .where("games.scheduled_at <= ?", 7.days.from_now)

    # 지역 필터링
    if @preferences.preferred_locations.present?
      locations = @preferences.preferred_locations
      games = games.where(
        "courts.city IN (?) OR courts.district IN (?)",
        locations, locations
      )
    elsif @user.city.present?
      # 사용자 도시 기준으로 필터링
      games = games.where("courts.city = ?", @user.city)
    end

    # 레벨 필터링
    user_level = @user.skill_level
    level_range = @preferences.preferred_level_range || 1
    games = games.where(
      required_skill_level: (user_level - level_range)..(user_level + level_range)
    )

    # 시간대 필터링
    if @preferences.preferred_times.present?
      games = filter_by_preferred_times(games)
    end

    # 자리가 있는 경기만
    games = games.select do |game|
      game.confirmed_participants_count < game.max_players
    end

    # 가장 가까운 시간의 경기 선택
    games.min_by { |game| game.scheduled_at }
  end

  def filter_by_preferred_times(games)
    preferred_times = @preferences.preferred_times

    games.select do |game|
      day_name = game.scheduled_at.strftime("%A").downcase
      hour = game.scheduled_at.hour

      if preferred_times[day_name].present?
        time_slots = preferred_times[day_name]

        time_slots.any? do |slot|
          case slot
          when "morning"
            hour >= 6 && hour < 12
          when "afternoon"
            hour >= 12 && hour < 18
          when "evening"
            hour >= 18 && hour < 22
          when "night"
            hour >= 22 || hour < 6
          else
            true
          end
        end
      else
        false
      end
    end
  end

  def find_or_create_match_pool
    # 비슷한 조건의 매치 풀 찾기
    existing_pool = find_existing_match_pool

    if existing_pool
      join_match_pool(existing_pool)
      existing_pool
    else
      create_new_match_pool
    end
  end

  def find_existing_match_pool
    pools = MatchPool.where(status: "forming")
                     .where("match_time >= ?", 30.minutes.from_now)
                     .where("match_time <= ?", 7.days.from_now)

    # 지역 필터링
    if @user.city.present?
      pools = pools.where(city: @user.city)
    end

    # 레벨 필터링
    user_level = @user.skill_level
    level_range = @preferences.preferred_level_range || 1
    pools = pools.where(
      skill_level: (user_level - level_range)..(user_level + level_range)
    )

    # 이미 참가 중이지 않은 풀만
    pools = pools.where.not(
      id: @user.match_pool_participants.pluck(:match_pool_id)
    )

    # 자리가 있는 풀만
    pools.find { |pool| pool.current_players < pool.max_players }
  end

  def join_match_pool(pool)
    return if pool.match_pool_participants.exists?(user: @user)

    ActiveRecord::Base.transaction do
      # 참가자 추가
      pool.match_pool_participants.create!(
        user: @user,
        status: "waiting"
      )

      # 참가자 수 업데이트
      pool.increment!(:current_players)

      # player_ids 업데이트
      player_ids = pool.player_ids || []
      player_ids << @user.id
      pool.update!(player_ids: player_ids.uniq)

      # 풀이 가득 찼는지 확인
      check_pool_ready(pool)
    end
  end

  def create_new_match_pool
    # 다음 선호 시간 계산
    next_time = calculate_next_preferred_time

    pool = MatchPool.create!(
      city: @user.city || "서울",
      district: @user.district,
      match_time: next_time,
      skill_level: @user.skill_level,
      current_players: 1,
      min_players: @preferences.min_players || 6,
      max_players: @preferences.max_players || 10,
      status: "forming",
      game_type: @preferences.preferred_game_types.first || "pickup",
      player_ids: [ @user.id ]
    )

    # 참가자로 추가
    pool.match_pool_participants.create!(
      user: @user,
      status: "waiting"
    )

    pool
  end

  def calculate_next_preferred_time
    return 2.hours.from_now unless @preferences.preferred_times.present?

    current_time = Time.current
    7.times do |i|
      check_time = current_time + i.days
      day_name = check_time.strftime("%A").downcase

      if @preferences.preferred_times[day_name].present?
        time_slots = @preferences.preferred_times[day_name]

        time_slots.each do |slot|
          slot_time = case slot
          when "morning"
                        check_time.change(hour: 9)
          when "afternoon"
                        check_time.change(hour: 14)
          when "evening"
                        check_time.change(hour: 19)
          when "night"
                        check_time.change(hour: 22)
          else
                        check_time.change(hour: 19)
          end

          return slot_time if slot_time > current_time + 30.minutes
        end
      end
    end

    # 기본값: 다음 주말 오후 2시
    next_saturday = current_time.next_occurring(:saturday)
    next_saturday.change(hour: 14)
  end

  def check_pool_ready(pool)
    if pool.current_players >= pool.min_players * 0.8
      # 80% 이상 차면 게임 생성 준비
      MatchPoolProcessingJob.perform_later(pool.id)
    end
  end
end
