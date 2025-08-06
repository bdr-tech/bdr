class BracketGenerationService
  def initialize(tournament)
    @tournament = tournament
    @teams = tournament.tournament_teams.approved
  end
  
  def generate_and_publish
    generate
    publish_brackets
  end
  
  def generate(teams: nil, seeding_method: 'random', bracket_type: nil)
    teams ||= @teams
    bracket_type ||= @tournament.tournament_type
    
    case bracket_type
    when 'single_elimination'
      generate_single_elimination(teams, seeding_method)
    when 'double_elimination'
      generate_double_elimination(teams, seeding_method)
    when 'round_robin'
      generate_round_robin(teams)
    when 'group_stage'
      generate_group_stage(teams, seeding_method)
    else
      raise "Unknown bracket type: #{bracket_type}"
    end
  end
  
  private
  
  def generate_single_elimination(teams, seeding_method)
    seeded_teams = seed_teams(teams, seeding_method)
    rounds = calculate_rounds(seeded_teams.count)
    
    # Create first round matches
    current_round_teams = seeded_teams
    round_number = 1
    
    while current_round_teams.count > 1
      round_name = get_round_name(round_number, rounds)
      matches_in_round = []
      
      current_round_teams.each_slice(2) do |team1, team2|
        match = @tournament.tournament_matches.create!(
          home_team: team1,
          away_team: team2,
          round_number: round_number,
          round_name: round_name,
          match_number: matches_in_round.count + 1,
          status: 'scheduled'
        )
        matches_in_round << match
      end
      
      # Prepare for next round (winners will advance)
      current_round_teams = []
      round_number += 1
      
      # For now, break after first round
      # In real implementation, this would continue after matches are completed
      break
    end
    
    @tournament.update!(current_round: get_round_name(1, rounds))
  end
  
  def generate_double_elimination(teams, seeding_method)
    # Winners bracket
    generate_single_elimination(teams, seeding_method)
    
    # TODO: Implement losers bracket
    # This is more complex and requires tracking eliminated teams
  end
  
  def generate_round_robin(teams)
    matches = []
    
    teams.each_with_index do |team1, i|
      teams[(i + 1)..-1].each do |team2|
        matches << @tournament.tournament_matches.create!(
          home_team: team1,
          away_team: team2,
          round_number: 1,
          round_name: 'Round Robin',
          status: 'scheduled'
        )
      end
    end
    
    @tournament.update!(current_round: 'Round Robin')
    matches
  end
  
  def generate_group_stage(teams, seeding_method)
    # Divide teams into groups
    group_size = 4
    groups = teams.each_slice(group_size).to_a
    
    groups.each_with_index do |group_teams, group_index|
      group_name = "Group #{('A'.ord + group_index).chr}"
      
      # Round robin within each group
      group_teams.each_with_index do |team1, i|
        group_teams[(i + 1)..-1].each do |team2|
          @tournament.tournament_matches.create!(
            home_team: team1,
            away_team: team2,
            round_number: 1,
            round_name: group_name,
            group: group_name,
            status: 'scheduled'
          )
        end
      end
    end
    
    @tournament.update!(current_round: 'Group Stage')
  end
  
  def seed_teams(teams, method)
    case method
    when 'random'
      teams.shuffle
    when 'skill_based'
      # Sort by team rating/skill level
      teams.sort_by { |t| t.team_rating || 0 }.reverse
    when 'regional'
      # Group by region, then randomize within regions
      teams.group_by(&:region).values.flatten.shuffle
    else
      teams
    end
  end
  
  def calculate_rounds(team_count)
    Math.log2(team_count).ceil
  end
  
  def get_round_name(round_number, total_rounds)
    rounds_from_final = total_rounds - round_number
    
    case rounds_from_final
    when 0
      'Final'
    when 1
      'Semi-Final'
    when 2
      'Quarter-Final'
    when 3
      'Round of 16'
    when 4
      'Round of 32'
    else
      "Round #{round_number}"
    end
  end
  
  def publish_brackets
    # Send notifications to all teams
    @tournament.tournament_teams.approved.each do |team|
      Notification.create!(
        user: team.captain,
        notification_type: 'bracket_published',
        related_id: @tournament.id,
        related_type: 'Tournament',
        content: "#{@tournament.name} 대진표가 확정되었습니다. 확인해주세요!"
      )
    end
    
    # Update tournament status
    @tournament.update!(brackets_published: true, brackets_published_at: Time.current)
  end
end