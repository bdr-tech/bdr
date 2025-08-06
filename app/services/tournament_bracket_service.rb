class TournamentBracketService
  def initialize(tournament)
    @tournament = tournament
  end

  # 자동 대진표 생성
  def generate_bracket!
    case @tournament.tournament_type
    when "single_elimination"
      generate_single_elimination
    when "double_elimination"
      generate_double_elimination
    when "round_robin"
      generate_round_robin
    when "group_stage"
      generate_group_stage
    end
  end

  # 승자 진출 처리
  def advance_winner(match)
    return unless match.winner.present?

    next_match = find_next_match(match)
    return unless next_match

    # 다음 경기에 승자 배정
    if next_match.team_a_id.nil?
      next_match.update!(team_a: match.winner)
    else
      next_match.update!(team_b: match.winner)
    end

    # 다음 경기가 준비되었는지 확인
    check_match_ready(next_match)
  end

  # 경기 일정 자동 배정
  def schedule_matches!
    unscheduled_matches = @tournament.tournament_matches.where(scheduled_at: nil)

    current_time = @tournament.tournament_start_at
    court_count = @tournament.courts_count || 1
    match_duration = @tournament.match_duration || 30 # 분

    unscheduled_matches.find_each.each_slice(court_count) do |match_group|
      match_group.each_with_index do |match, index|
        match.update!(
          scheduled_at: current_time,
          court_number: index + 1
        )
      end
      current_time += match_duration.minutes
    end
  end

  private

  def generate_single_elimination
    teams = @tournament.approved_teams.shuffle
    rounds = calculate_rounds(teams.count)

    # 첫 라운드 생성
    first_round_matches = []
    teams.each_slice(2) do |team_pair|
      match = @tournament.tournament_matches.create!(
        round: 1,
        match_number: first_round_matches.count + 1,
        team_a: team_pair[0],
        team_b: team_pair[1],
        status: "scheduled"
      )
      first_round_matches << match
    end

    # 나머지 라운드 생성
    (2..rounds).each do |round|
      matches_in_round = 2 ** (rounds - round)

      matches_in_round.times do |i|
        @tournament.tournament_matches.create!(
          round: round,
          match_number: i + 1,
          status: "scheduled"
        )
      end
    end
  end

  def generate_round_robin
    teams = @tournament.approved_teams

    # 모든 팀 간의 경기 생성
    teams.combination(2).each_with_index do |(team_a, team_b), index|
      @tournament.tournament_matches.create!(
        round: 1,
        match_number: index + 1,
        team_a: team_a,
        team_b: team_b,
        status: "scheduled"
      )
    end
  end

  def generate_group_stage
    teams = @tournament.approved_teams.shuffle
    group_size = @tournament.group_size || 4
    groups = teams.each_slice(group_size).to_a

    groups.each_with_index do |group_teams, group_index|
      # 그룹 내 라운드 로빈
      group_teams.combination(2).each do |(team_a, team_b)|
        @tournament.tournament_matches.create!(
          round: 1,
          group: ("A".ord + group_index).chr,
          team_a: team_a,
          team_b: team_b,
          status: "scheduled"
        )
      end
    end
  end

  def generate_double_elimination
    # 위너스 브라켓 생성
    generate_single_elimination

    # 루저스 브라켓 생성
    # (구현 복잡도가 높아 기본 버전에서는 생략)
  end

  def calculate_rounds(team_count)
    Math.log2(team_count).ceil
  end

  def find_next_match(current_match)
    return nil unless current_match.round

    # 다음 라운드에서 현재 매치와 연결된 경기 찾기
    next_round = current_match.round + 1
    next_match_number = (current_match.match_number + 1) / 2

    @tournament.tournament_matches.find_by(
      round: next_round,
      match_number: next_match_number
    )
  end

  def check_match_ready(match)
    if match.team_a.present? && match.team_b.present?
      match.update!(status: "ready")

      # 알림 발송
      TournamentNotificationService.new(@tournament).notify_match_ready(match)
    end
  end
end
