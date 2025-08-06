class TournamentMatchesController < ApplicationController
  before_action :set_tournament
  before_action :set_match

  def show
    # 경기 참가 선수들의 통계
    @home_team_stats = @match.match_player_stats.includes(:user)
                             .where(team_type: "home")
                             .order(minutes_played: :desc)

    @away_team_stats = @match.match_player_stats.includes(:user)
                             .where(team_type: "away")
                             .order(minutes_played: :desc)

    # 데이터가 없으면 샘플 데이터 생성
    if @home_team_stats.empty? && @away_team_stats.empty? && @match.completed?
      generate_sample_stats
      @home_team_stats = @match.match_player_stats.includes(:user)
                               .where(team_type: "home")
                               .order(minutes_played: :desc)

      @away_team_stats = @match.match_player_stats.includes(:user)
                               .where(team_type: "away")
                               .order(minutes_played: :desc)
    end

    # 팀 총계 계산
    @home_team_totals = calculate_team_totals(@home_team_stats)
    @away_team_totals = calculate_team_totals(@away_team_stats)

    # 쿼터별 득점
    @quarter_scores = @match.quarter_scores || generate_quarter_scores

    # 주요 플레이어 (경기 MVP)
    @game_mvp = find_game_mvp

    # 팀 통계 비교
    @team_comparison = generate_team_comparison
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def set_match
    @match = @tournament.tournament_matches.find(params[:id])
  end

  def calculate_team_totals(stats)
    {
      points: stats.sum(&:points),
      field_goals_made: stats.sum(&:field_goals_made),
      field_goals_attempted: stats.sum(&:field_goals_attempted),
      three_pointers_made: stats.sum(&:three_pointers_made),
      three_pointers_attempted: stats.sum(&:three_pointers_attempted),
      free_throws_made: stats.sum(&:free_throws_made),
      free_throws_attempted: stats.sum(&:free_throws_attempted),
      offensive_rebounds: stats.sum(&:offensive_rebounds),
      defensive_rebounds: stats.sum(&:defensive_rebounds),
      total_rebounds: stats.sum(&:total_rebounds),
      assists: stats.sum(&:assists),
      steals: stats.sum(&:steals),
      blocks: stats.sum(&:blocks),
      turnovers: stats.sum(&:turnovers),
      personal_fouls: stats.sum(&:personal_fouls)
    }
  end

  def generate_quarter_scores
    # 실제 쿼터별 점수가 없으면 총점에서 추정
    return nil unless @match.completed?

    # 이미 저장된 쿼터 스코어가 있으면 사용
    if @match.quarter_scores.present?
      # JSON 문자열인 경우 파싱
      scores = @match.quarter_scores.is_a?(String) ? JSON.parse(@match.quarter_scores) : @match.quarter_scores

      # 심볼 키로 변환
      return {
        q1: { home: scores["q1"]["home"], away: scores["q1"]["away"] },
        q2: { home: scores["q2"]["home"], away: scores["q2"]["away"] },
        q3: { home: scores["q3"]["home"], away: scores["q3"]["away"] },
        q4: { home: scores["q4"]["home"], away: scores["q4"]["away"] }
      }
    end

    home_total = @match.home_score
    away_total = @match.away_score

    # 간단한 배분 (실제로는 쿼터별 기록이 있어야 함)
    {
      q1: { home: (home_total * 0.25).round, away: (away_total * 0.25).round },
      q2: { home: (home_total * 0.25).round, away: (away_total * 0.25).round },
      q3: { home: (home_total * 0.25).round, away: (away_total * 0.25).round },
      q4: { home: home_total - (home_total * 0.75).round,
            away: away_total - (away_total * 0.75).round }
    }
  end

  def find_game_mvp
    all_stats = @match.match_player_stats.includes(:user)
    return nil if all_stats.empty?

    # Game Score 기준으로 MVP 선정
    mvp_stat = all_stats.max_by(&:game_score)
    {
      player: mvp_stat.user,
      stats: mvp_stat,
      team: mvp_stat.team_type
    }
  end

  def generate_team_comparison
    home_totals = @home_team_totals
    away_totals = @away_team_totals

    {
      field_goal_percentage: {
        home: calculate_percentage(home_totals[:field_goals_made], home_totals[:field_goals_attempted]),
        away: calculate_percentage(away_totals[:field_goals_made], away_totals[:field_goals_attempted])
      },
      three_point_percentage: {
        home: calculate_percentage(home_totals[:three_pointers_made], home_totals[:three_pointers_attempted]),
        away: calculate_percentage(away_totals[:three_pointers_made], away_totals[:three_pointers_attempted])
      },
      free_throw_percentage: {
        home: calculate_percentage(home_totals[:free_throws_made], home_totals[:free_throws_attempted]),
        away: calculate_percentage(away_totals[:free_throws_made], away_totals[:free_throws_attempted])
      },
      rebounds: {
        home: home_totals[:total_rebounds],
        away: away_totals[:total_rebounds]
      },
      assists: {
        home: home_totals[:assists],
        away: away_totals[:assists]
      },
      turnovers: {
        home: home_totals[:turnovers],
        away: away_totals[:turnovers]
      }
    }
  end

  def calculate_percentage(made, attempted)
    return 0.0 if attempted == 0
    (made.to_f / attempted * 100).round(1)
  end

  def generate_sample_stats
    # 홈팀 선수 통계 생성
    home_roster = @match.home_team.roster
    home_roster = if home_roster.is_a?(String)
                    JSON.parse(home_roster) rescue []
    else
                    home_roster || []
    end
    home_roster = home_roster.take(5) # 최대 5명

    # 홈팀에 선수가 없으면 기본 선수 생성
    if home_roster.empty?
      5.times do |i|
        home_roster << {
          "name" => "홈팀 선수#{i+1}",
          "position" => [ "PG", "SG", "SF", "PF", "C" ][i],
          "number" => (i+1).to_s
        }
      end
    end

    # 홈팀 점수 분배
    home_points_to_distribute = @match.home_score
    home_roster.each_with_index do |player, index|
      # 가상의 사용자 찾기 또는 생성
      user = User.find_by(name: player["name"]) ||
             User.create!(
               name: player["name"],
               email: "player_home_#{index}_#{Time.now.to_i}@example.com",
               nickname: player["name"],
               phone: "010-0000-#{1000 + index}",
               real_name: player["name"],
               height: rand(170..200),
               weight: rand(65..100),
               positions: [ player["position"] || "PG" ],
               city: "서울특별시",
               district: "강남구"
             )

      # 이미 존재하는 통계는 건너뛰기
      next if @match.match_player_stats.exists?(user: user)

      # 선수별 점수 할당 (스타터일수록 높은 점수)
      player_points = if index == 0
        (home_points_to_distribute * 0.25).round
      elsif index < 3
        (home_points_to_distribute * 0.20).round
      else
        (home_points_to_distribute * 0.075).round
      end

      # 필드골, 3점슛, 자유투 계산
      threes = rand(0..4)
      three_attempts = threes + rand(0..3)
      fts = rand(0..6)
      ft_attempts = fts + rand(0..2)
      twos = ((player_points - (threes * 3) - fts) / 2.0).round
      two_attempts = twos + rand(0..4)

      # 기타 스탯
      rebounds = rand(2..10)
      assists = rand(0..8)

      @match.match_player_stats.create!(
        user: user,
        tournament_team: @match.home_team,
        team_type: "home",
        starter: index < 5,
        minutes_played: index < 5 ? rand(25..35) : rand(10..20),
        points: player_points,
        field_goals_made: twos + threes,
        field_goals_attempted: two_attempts + three_attempts,
        three_pointers_made: threes,
        three_pointers_attempted: three_attempts,
        free_throws_made: fts,
        free_throws_attempted: ft_attempts,
        offensive_rebounds: rand(0..3),
        defensive_rebounds: rebounds - rand(0..3),
        total_rebounds: rebounds,
        assists: assists,
        steals: rand(0..3),
        blocks: rand(0..2),
        turnovers: rand(0..4),
        personal_fouls: rand(0..4),
        plus_minus: @match.home_score > @match.away_score ? rand(1..15) : rand(-15..-1)
      )
    end

    # 원정팀 선수 통계 생성
    away_roster = @match.away_team.roster
    away_roster = if away_roster.is_a?(String)
                    JSON.parse(away_roster) rescue []
    else
                    away_roster || []
    end
    away_roster = away_roster.take(5)

    if away_roster.empty?
      5.times do |i|
        away_roster << {
          "name" => "원정팀 선수#{i+1}",
          "position" => [ "PG", "SG", "SF", "PF", "C" ][i],
          "number" => (i+1).to_s
        }
      end
    end

    # 원정팀 점수 분배
    away_points_to_distribute = @match.away_score
    away_roster.each_with_index do |player, index|
      user = User.find_by(name: player["name"]) ||
             User.create!(
               name: player["name"],
               email: "player_away_#{index}_#{Time.now.to_i}@example.com",
               nickname: player["name"],
               phone: "010-0000-#{2000 + index}",
               real_name: player["name"],
               height: rand(170..200),
               weight: rand(65..100),
               positions: [ player["position"] || "PG" ],
               city: "서울특별시",
               district: "강남구"
             )

      # 이미 존재하는 통계는 건너뛰기
      next if @match.match_player_stats.exists?(user: user)

      player_points = if index == 0
        (away_points_to_distribute * 0.25).round
      elsif index < 3
        (away_points_to_distribute * 0.20).round
      else
        (away_points_to_distribute * 0.075).round
      end

      threes = rand(0..4)
      three_attempts = threes + rand(0..3)
      fts = rand(0..6)
      ft_attempts = fts + rand(0..2)
      twos = ((player_points - (threes * 3) - fts) / 2.0).round
      two_attempts = twos + rand(0..4)

      rebounds = rand(2..10)
      assists = rand(0..8)

      @match.match_player_stats.create!(
        user: user,
        tournament_team: @match.away_team,
        team_type: "away",
        starter: index < 5,
        minutes_played: index < 5 ? rand(25..35) : rand(10..20),
        points: player_points,
        field_goals_made: twos + threes,
        field_goals_attempted: two_attempts + three_attempts,
        three_pointers_made: threes,
        three_pointers_attempted: three_attempts,
        free_throws_made: fts,
        free_throws_attempted: ft_attempts,
        offensive_rebounds: rand(0..3),
        defensive_rebounds: rebounds - rand(0..3),
        total_rebounds: rebounds,
        assists: assists,
        steals: rand(0..3),
        blocks: rand(0..2),
        turnovers: rand(0..4),
        personal_fouls: rand(0..4),
        plus_minus: @match.away_score > @match.home_score ? rand(1..15) : rand(-15..-1)
      )
    end

    # 쿼터별 득점 생성
    home_q1 = (@match.home_score * 0.25).round
    home_q2 = (@match.home_score * 0.25).round
    home_q3 = (@match.home_score * 0.25).round
    home_q4 = @match.home_score - home_q1 - home_q2 - home_q3

    away_q1 = (@match.away_score * 0.25).round
    away_q2 = (@match.away_score * 0.25).round
    away_q3 = (@match.away_score * 0.25).round
    away_q4 = @match.away_score - away_q1 - away_q2 - away_q3

    @match.update!(
      quarter_scores: {
        "q1" => { "home" => home_q1, "away" => away_q1 },
        "q2" => { "home" => home_q2, "away" => away_q2 },
        "q3" => { "home" => home_q3, "away" => away_q3 },
        "q4" => { "home" => home_q4, "away" => away_q4 }
      }
    )
  end
end
