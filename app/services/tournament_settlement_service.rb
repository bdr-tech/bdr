class TournamentSettlementService
  def initialize(tournament)
    @tournament = tournament
  end

  def process!
    return { success: false, error: "대회가 아직 종료되지 않았습니다." } unless @tournament.completed?
    return { success: false, error: "이미 정산이 완료되었습니다." } if already_settled?

    ActiveRecord::Base.transaction do
      # 1. 총 수입 계산
      total_income = calculate_total_income

      # 2. 플랫폼 수수료 계산 (5%)
      platform_fee = total_income * 0.05

      # 3. 총 지출 계산
      total_expenses = calculate_total_expenses

      # 4. 순수익 계산
      net_profit = total_income - platform_fee - total_expenses

      # 5. 플랫폼 수수료 기록
      @tournament.tournament_budgets.create!(
        category: "platform_fee",
        description: "BDR 플랫폼 수수료 (5%)",
        amount: platform_fee,
        is_income: false,
        transaction_date: Time.current
      )

      # 6. 정산 요약 생성
      settlement_summary = {
        settled_at: Time.current,
        total_income: total_income,
        platform_fee: platform_fee,
        total_expenses: total_expenses,
        net_profit: net_profit,
        teams_participated: @tournament.approved_teams.count,
        matches_played: @tournament.tournament_matches.completed.count
      }

      # 7. 대회 정보 업데이트
      @tournament.update!(
        post_event_summary: generate_summary_text(settlement_summary),
        budget_settings: @tournament.budget_settings.merge(settlement_summary)
      )

      # 8. 주최자에게 정산 내역 알림
      send_settlement_notification(settlement_summary)

      # 9. 정산 완료 처리
      mark_as_settled!

      { success: true, summary: settlement_summary }
    end
  rescue => e
    { success: false, error: e.message }
  end

  private

  def already_settled?
    @tournament.budget_settings["settled_at"].present?
  end

  def calculate_total_income
    # 참가비 수입
    entry_fee_income = @tournament.approved_teams.count * @tournament.entry_fee

    # 기타 수입 (예산 테이블에서)
    other_income = @tournament.tournament_budgets.income.sum(:amount)

    entry_fee_income + other_income
  end

  def calculate_total_expenses
    @tournament.tournament_budgets.expenses.sum(:amount)
  end

  def generate_summary_text(summary)
    <<~TEXT
      대회 정산 요약
      ================
      정산일시: #{summary[:settled_at].strftime('%Y년 %m월 %d일 %H:%M')}

      참가 팀: #{summary[:teams_participated]}팀
      진행된 경기: #{summary[:matches_played]}경기

      [수입]
      총 수입: #{number_to_currency(summary[:total_income])}

      [지출]
      플랫폼 수수료: #{number_to_currency(summary[:platform_fee])}
      기타 지출: #{number_to_currency(summary[:total_expenses])}

      [결과]
      순수익: #{number_to_currency(summary[:net_profit])}
    TEXT
  end

  def send_settlement_notification(summary)
    @tournament.organizer.notifications.create!(
      notification_type: "tournament_settled",
      title: "대회 정산 완료",
      message: "#{@tournament.name} 대회 정산이 완료되었습니다. 순수익: #{number_to_currency(summary[:net_profit])}",
      data: summary,
      source_type: "Tournament",
      source_id: @tournament.id
    )
  end

  def mark_as_settled!
    # 정산 완료 플래그 설정
    @tournament.update_column(:settled, true) if @tournament.respond_to?(:settled)
  end

  def number_to_currency(amount)
    return "0원" if amount == 0
    "#{amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
  end
end
