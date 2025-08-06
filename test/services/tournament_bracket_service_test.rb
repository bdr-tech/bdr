require "test_helper"

class TournamentBracketServiceTest < ActiveSupport::TestCase
  def setup
    @tournament = tournaments(:one)
    @service = TournamentBracketService.new(@tournament)

    # 승인된 팀 생성
    8.times do |i|
      TournamentTeam.create!(
        tournament: @tournament,
        name: "Team #{i + 1}",
        captain: users(:one),
        status: "approved"
      )
    end
  end

  test "should generate single elimination bracket" do
    @tournament.update!(tournament_type: "single_elimination")

    @service.generate_bracket!

    matches = @tournament.tournament_matches

    # 8팀 토너먼트는 3라운드 (8->4->2->1)
    assert_equal 7, matches.count # 4 + 2 + 1
    assert_equal 4, matches.where(round: 1).count
    assert_equal 2, matches.where(round: 2).count
    assert_equal 1, matches.where(round: 3).count
  end

  test "should generate round robin bracket" do
    @tournament.update!(tournament_type: "round_robin")

    @service.generate_bracket!

    matches = @tournament.tournament_matches

    # 8팀 라운드 로빈은 각 팀이 7경기 = 총 28경기
    assert_equal 28, matches.count
    assert matches.all? { |m| m.round == 1 }
  end

  test "should generate group stage bracket" do
    @tournament.update!(tournament_type: "group_stage", group_size: 4)

    @service.generate_bracket!

    matches = @tournament.tournament_matches

    # 8팀을 4팀씩 2그룹으로 나누면, 각 그룹 6경기씩 = 12경기
    assert_equal 12, matches.count
    assert_equal 6, matches.where(group: "A").count
    assert_equal 6, matches.where(group: "B").count
  end

  test "should advance winner to next match" do
    @tournament.update!(tournament_type: "single_elimination")
    @service.generate_bracket!

    # 첫 번째 경기
    match1 = @tournament.tournament_matches.find_by(round: 1, match_number: 1)
    match1.update!(
      team_a_score: 50,
      team_b_score: 40,
      status: "completed",
      winner: match1.team_a
    )

    # 승자 진출
    @service.advance_winner(match1)

    # 다음 라운드 경기 확인
    next_match = @tournament.tournament_matches.find_by(round: 2, match_number: 1)
    assert_equal match1.winner, next_match.team_a
  end

  test "should schedule matches automatically" do
    @tournament.update!(
      tournament_type: "single_elimination",
      tournament_start_at: Time.current,
      courts_count: 2,
      match_duration: 30
    )

    @service.generate_bracket!
    @service.schedule_matches!

    matches = @tournament.tournament_matches.order(:scheduled_at)

    # 첫 경기들은 동시에 시작 (코트 2개)
    first_matches = matches.first(2)
    assert_equal @tournament.tournament_start_at, first_matches[0].scheduled_at
    assert_equal @tournament.tournament_start_at, first_matches[1].scheduled_at
    assert_equal 1, first_matches[0].court_number
    assert_equal 2, first_matches[1].court_number

    # 다음 경기들은 30분 후
    next_matches = matches[2..3]
    assert_equal @tournament.tournament_start_at + 30.minutes, next_matches[0].scheduled_at
    assert_equal @tournament.tournament_start_at + 30.minutes, next_matches[1].scheduled_at
  end

  test "should calculate correct number of rounds" do
    service = TournamentBracketService.new(@tournament)

    assert_equal 2, service.send(:calculate_rounds, 4)  # 4팀 = 2라운드
    assert_equal 3, service.send(:calculate_rounds, 8)  # 8팀 = 3라운드
    assert_equal 4, service.send(:calculate_rounds, 16) # 16팀 = 4라운드
    assert_equal 4, service.send(:calculate_rounds, 12) # 12팀 = 4라운드 (올림)
  end
end
