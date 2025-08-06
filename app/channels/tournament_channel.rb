class TournamentChannel < ApplicationCable::Channel
  def subscribed
    tournament = Tournament.find(params[:tournament_id])
    stream_for tournament
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def update_score(data)
    tournament = Tournament.find(params[:tournament_id])
    match = tournament.tournament_matches.find(data["match_id"])

    # 권한 체크
    if can_update?(tournament)
      match.update!(
        team_a_score: data["team_a_score"],
        team_b_score: data["team_b_score"]
      )

      # 브로드캐스트
      TournamentChannel.broadcast_to(
        tournament,
        {
          type: "score_update",
          match_id: match.id,
          data: {
            team_a_score: data["team_a_score"],
            team_b_score: data["team_b_score"]
          },
          user: {
            id: current_user.id,
            name: current_user.name
          }
        }
      )
    end
  end

  private

  def can_update?(tournament)
    current_user == tournament.organizer ||
    current_user.admin? ||
    tournament.tournament_check_ins.where(user: current_user, role: "staff").exists?
  end
end
