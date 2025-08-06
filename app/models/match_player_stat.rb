class MatchPlayerStat < ApplicationRecord
  belongs_to :tournament_match
  belongs_to :user
  belongs_to :tournament_team

  validates :team_type, inclusion: { in: %w[home away] }

  # 슈팅 퍼센티지 계산
  def field_goal_percentage
    return 0.0 if field_goals_attempted == 0
    (field_goals_made.to_f / field_goals_attempted * 100).round(1)
  end

  def three_point_percentage
    return 0.0 if three_pointers_attempted == 0
    (three_pointers_made.to_f / three_pointers_attempted * 100).round(1)
  end

  def free_throw_percentage
    return 0.0 if free_throws_attempted == 0
    (free_throws_made.to_f / free_throws_attempted * 100).round(1)
  end

  def effective_field_goal_percentage
    return 0.0 if field_goals_attempted == 0
    ((field_goals_made + 0.5 * three_pointers_made).to_f / field_goals_attempted * 100).round(1)
  end

  def true_shooting_percentage
    total_shooting_possessions = field_goals_attempted + 0.44 * free_throws_attempted
    return 0.0 if total_shooting_possessions == 0
    (points.to_f / (2 * total_shooting_possessions) * 100).round(1)
  end

  # 더블더블/트리플더블 체크
  def double_double?
    count = 0
    count += 1 if points >= 10
    count += 1 if total_rebounds >= 10
    count += 1 if assists >= 10
    count += 1 if steals >= 10
    count += 1 if blocks >= 10
    count >= 2
  end

  def triple_double?
    count = 0
    count += 1 if points >= 10
    count += 1 if total_rebounds >= 10
    count += 1 if assists >= 10
    count += 1 if steals >= 10
    count += 1 if blocks >= 10
    count >= 3
  end

  # 게임 스코어 (John Hollinger's formula)
  def game_score
    score = points + 0.4 * field_goals_made - 0.7 * field_goals_attempted
    score -= 0.4 * (free_throws_attempted - free_throws_made)
    score += 0.7 * offensive_rebounds + 0.3 * defensive_rebounds
    score += 0.7 * assists + steals + 0.7 * blocks - 0.4 * personal_fouls - turnovers
    score.round(1)
  end

  # 플러스마이너스 계산용
  def minutes_percentage
    return 0 if tournament_match.nil?
    # 일반적으로 40분 경기 기준
    (minutes_played.to_f / 40 * 100).round(1)
  end
end
