class TournamentReportService
  def initialize(tournament)
    @tournament = tournament
  end
  
  def generate_report
    generate
  end
  
  def generate
    {
      tournament: {
        name: @tournament.name,
        code: @tournament.display_code,
        status: @tournament.status,
        dates: {
          start: @tournament.tournament_start_at,
          end: @tournament.tournament_end_at
        }
      },
      statistics: {
        total_teams: @tournament.tournament_teams.count,
        approved_teams: @tournament.tournament_teams.approved.count,
        total_matches: @tournament.tournament_matches.count,
        completed_matches: @tournament.tournament_matches.where.not(winner_id: nil).count
      },
      financial: {
        total_revenue: calculate_total_revenue,
        platform_fee: @tournament.calculate_platform_fee,
        net_revenue: calculate_net_revenue
      },
      participants: gather_participant_data,
      winners: gather_winners_data
    }
  end
  
  def to_pdf
    # PDF generation would go here
    # For now, return a placeholder
    "PDF Generation Not Implemented"
  end
  
  def to_json
    generate.to_json
  end
  
  private
  
  def calculate_total_revenue
    @tournament.tournament_teams.approved.count * (@tournament.entry_fee || 0)
  end
  
  def calculate_net_revenue
    calculate_total_revenue - @tournament.calculate_platform_fee
  end
  
  def gather_participant_data
    @tournament.tournament_teams.approved.map do |team|
      {
        name: team.team_name,
        captain: team.captain.name,
        status: team.status,
        checked_in: team.checked_in?
      }
    end
  end
  
  def gather_winners_data
    # Gather top 3 teams
    []
  end
end