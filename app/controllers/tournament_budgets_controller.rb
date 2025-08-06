class TournamentBudgetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tournament
  before_action :authorize_budget_management

  # 예산 대시보드
  def index
    @budgets = @tournament.tournament_budgets.includes(:tournament)
    @income = @budgets.income
    @expenses = @budgets.expenses
    @balance = @budgets.balance
    @expenses_by_category = @budgets.expenses_by_category

    # 예상 vs 실제 비교
    @expected_income = calculate_expected_income
    @actual_income = @income.sum(:amount)
  end

  # 새 항목 추가
  def new
    @budget = @tournament.tournament_budgets.build
  end

  # 항목 생성
  def create
    @budget = @tournament.tournament_budgets.build(budget_params)

    if @budget.save
      update_tournament_budget_summary
      redirect_to tournament_budgets_path(@tournament),
                  notice: "예산 항목이 추가되었습니다."
    else
      render :new
    end
  end

  # 항목 수정
  def edit
    @budget = @tournament.tournament_budgets.find(params[:id])
  end

  # 항목 업데이트
  def update
    @budget = @tournament.tournament_budgets.find(params[:id])

    if @budget.update(budget_params)
      update_tournament_budget_summary
      redirect_to tournament_budgets_path(@tournament),
                  notice: "예산 항목이 수정되었습니다."
    else
      render :edit
    end
  end

  # 항목 삭제
  def destroy
    @budget = @tournament.tournament_budgets.find(params[:id])
    @budget.destroy
    update_tournament_budget_summary
    redirect_to tournament_budgets_path(@tournament),
                notice: "예산 항목이 삭제되었습니다."
  end

  # 예산 리포트
  def report
    @budgets = @tournament.tournament_budgets
    @summary = {
      total_income: @budgets.income.sum(:amount),
      total_expenses: @budgets.expenses.sum(:amount),
      balance: @budgets.balance,
      platform_fee: calculate_platform_fee,
      net_profit: calculate_net_profit
    }

    respond_to do |format|
      format.html
      format.pdf { render_budget_pdf }
      format.xlsx { render_budget_excel }
    end
  end

  # 자동 정산
  def settlement
    if @tournament.completed?
      settlement_service = TournamentSettlementService.new(@tournament)
      result = settlement_service.process!

      if result[:success]
        redirect_to tournament_budgets_path(@tournament),
                    notice: "정산이 완료되었습니다."
      else
        redirect_to tournament_budgets_path(@tournament),
                    alert: result[:error]
      end
    else
      redirect_to tournament_budgets_path(@tournament),
                  alert: "대회가 종료된 후에 정산할 수 있습니다."
    end
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def authorize_budget_management
    unless current_user == @tournament.organizer || current_user.admin?
      redirect_to tournament_path(@tournament),
                  alert: "예산 관리 권한이 없습니다."
    end
  end

  def budget_params
    params.require(:tournament_budget).permit(
      :category, :description, :amount, :is_income,
      :transaction_date, :receipt_url
    )
  end

  def calculate_expected_income
    @tournament.max_teams * @tournament.entry_fee
  end

  def calculate_platform_fee
    actual_income = @tournament.tournament_budgets.income.sum(:amount)
    actual_income * 0.05
  end

  def calculate_net_profit
    @tournament.tournament_budgets.balance - calculate_platform_fee
  end

  def update_tournament_budget_summary
    @tournament.update!(
      budget_settings: {
        total_income: @tournament.tournament_budgets.income.sum(:amount),
        total_expenses: @tournament.tournament_budgets.expenses.sum(:amount),
        balance: @tournament.tournament_budgets.balance,
        last_updated: Time.current
      }
    )
  end

  def render_budget_pdf
    pdf = TournamentBudgetPdf.new(@tournament, @budgets)
    send_data pdf.render,
              filename: "#{@tournament.name}_budget_#{Date.current}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end

  def render_budget_excel
    excel = TournamentBudgetExcel.new(@tournament, @budgets)
    send_data excel.generate,
              filename: "#{@tournament.name}_budget_#{Date.current}.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
              disposition: "attachment"
  end
end
