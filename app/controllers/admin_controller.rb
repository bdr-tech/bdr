class AdminController < ApplicationController
  before_action :require_admin
  layout "admin"

  def dashboard
    @stats = {
      total_users: User.count,
      active_users: User.where(status: "active").count,
      total_games: Game.count,
      active_games: Game.where(status: "active").count,
      total_applications: GameApplication.count,
      pending_applications: GameApplication.where(status: "pending").count,
      waiting_payment_applications: GameApplication.where(status: "waiting_payment").count,
      total_payments: Payment.count,
      completed_payments: Payment.where(status: "paid").count,
      today_revenue: Payment.calculate_revenue(Payment.today_range),
      monthly_revenue: Payment.calculate_revenue(Payment.current_month_range),
      today_platform_fee: Payment.calculate_platform_fee(Payment.today_range),
      monthly_platform_fee: Payment.calculate_platform_fee(Payment.current_month_range),
      today_host_revenue: Payment.calculate_host_revenue(Payment.today_range),
      monthly_host_revenue: Payment.calculate_host_revenue(Payment.current_month_range),
      pending_tournaments: Tournament.pending_approval.count
    }

    @recent_activities = get_recent_activities
    @payment_issues = get_payment_issues
  end

  def users
    @users = User.includes(:organized_games, :game_applications)
                 .order(created_at: :desc)
                 .page(params[:page])

    if params[:search].present?
      @users = @users.where("name ILIKE ? OR email ILIKE ? OR nickname ILIKE ?",
                           "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:status].present?
      @users = @users.where(status: params[:status])
    end
  end

  def games
    @games = Game.includes(:organizer, :game_applications)
                 .order(created_at: :desc)
                 .page(params[:page])

    if params[:search].present?
      @games = @games.where("title ILIKE ? OR game_id ILIKE ?",
                           "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:status].present?
      @games = @games.where(status: params[:status])
    end
  end

  def payments
    @payments = Payment.includes(game_application: [ :user, :game ])
                      .order(created_at: :desc)
                      .page(params[:page])

    if params[:status].present?
      @payments = @payments.where(status: params[:status])
    end

    if params[:search].present?
      @payments = @payments.joins(game_application: [ :user, :game ])
                           .where("users.name ILIKE ? OR users.email ILIKE ? OR games.title ILIKE ? OR games.game_id ILIKE ?",
                                 "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
  end

  def applications
    @applications = GameApplication.joins(:user, :game)
                                  .includes(:user, :game)
                                  .order(created_at: :desc)
                                  .page(params[:page])

    if params[:status].present?
      @applications = @applications.where(status: params[:status])
    end

    if params[:search].present?
      @applications = @applications.where("users.name ILIKE ? OR users.email ILIKE ? OR games.title ILIKE ? OR games.game_id ILIKE ?",
                                        "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
  end

  def analytics
    @user_stats = {
      total_users: User.count,
      active_users: User.where(status: "active").count,
      new_users_today: User.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).count,
      new_users_this_week: User.where(created_at: 1.week.ago..Time.current).count,
      avg_profile_completion: calculate_avg_profile_completion,
      top_cities: User.group(:city).count.sort_by { |_, count| -count }.first(5)
    }

    @game_stats = {
      total_games: Game.count,
      active_games: Game.where(status: "active").count,
      completed_games: Game.where(status: "completed").count,
      cancelled_games: Game.where(status: "cancelled").count,
      avg_applications: Game.average(:application_count) || 0,
      avg_completion_rate: Game.average(:completion_rate) || 0,
      total_revenue: Game.sum(:revenue_generated),
      avg_rating: Game.average(:average_rating) || 0
    }

    @payment_stats = {
      total_payments: Payment.count,
      completed_payments: Payment.where(status: "paid").count,
      refunded_payments: Payment.where(status: "refunded").count,
      total_amount: Payment.sum(:amount),
      total_fees: Payment.sum(:fee_amount),
      avg_processing_time: Payment.average(:processing_time) || 0
    }

    @daily_stats = get_daily_stats
    @recent_activities = AdminLog.includes(:user).recent.limit(20)
  end

  def reports
    @reports = Report.all.order(:name) if defined?(Report)
    @report_results = {}

    # Calculate report statistics
    current_period = Date.current.beginning_of_month..Date.current.end_of_month
    previous_period = 1.month.ago.beginning_of_month..1.month.ago.end_of_month

    current_new_users = User.where(created_at: current_period).count
    previous_new_users = User.where(created_at: previous_period).count
    new_users_growth = previous_new_users > 0 ? ((current_new_users - previous_new_users).to_f / previous_new_users * 100).round(1) : 0

    current_games = Game.where(created_at: current_period).count
    previous_games = Game.where(created_at: previous_period).count
    games_growth = previous_games > 0 ? ((current_games - previous_games).to_f / previous_games * 100).round(1) : 0

    current_revenue = Payment.where(created_at: current_period, status: "paid").sum(:amount)
    previous_revenue = Payment.where(created_at: previous_period, status: "paid").sum(:amount)
    revenue_growth = previous_revenue > 0 ? ((current_revenue - previous_revenue).to_f / previous_revenue * 100).round(1) : 0

    active_users = User.where(status: "active").count
    total_users = User.count
    active_user_ratio = total_users > 0 ? (active_users.to_f / total_users * 100).round(1) : 0

    # User report stats
    @user_report = {
      total: User.count,
      new: User.where(created_at: current_period).count,
      deleted: User.where(status: "deleted").count,
      premium: User.where(is_premium: true).count
    }

    # Game report stats
    avg_participants = begin
      games_with_participants = Game.joins(:game_applications)
                                   .where(game_applications: { status: "final_approved" })
                                   .group("games.id")
                                   .count

      if games_with_participants.any?
        total_participants = games_with_participants.values.sum
        total_games = games_with_participants.keys.count
        (total_participants.to_f / total_games).round(1)
      else
        0
      end
    rescue
      0
    end

    @game_report = {
      total: Game.count,
      active: Game.where(status: "active").count,
      completed: Game.where(status: "completed").count,
      cancelled: Game.where(status: "cancelled").count,
      avg_participants: avg_participants
    }

    # Payment report stats (also used as revenue report in view)
    @payment_report = {
      total_amount: Payment.where(status: "paid").sum(:amount),
      total_fee: Payment.where(status: "paid").sum(:fee_amount),
      refunded: Payment.where(status: "refunded").count,
      average: Payment.where(status: "paid").average(:amount)&.to_i || 0
    }

    # Revenue report stats
    @revenue_report = {
      total: Payment.sum(:amount),
      success: Payment.where(status: "paid").sum(:amount),
      refund: Payment.where(status: "refunded").sum(:amount),
      average: Payment.where(status: "paid").average(:amount)&.to_i || 0
    }

    # Application report stats
    @application_report = {
      total: GameApplication.count,
      approved: GameApplication.where(status: "final_approved").count,
      pending: GameApplication.where(status: "pending").count,
      rejected: GameApplication.where(status: "rejected").count
    }

    # Popular courts
    @popular_courts = Court.joins(:games)
                          .select("courts.*, COUNT(games.id) as game_count")
                          .group("courts.id")
                          .order("game_count DESC")
                          .limit(5)
                          .map { |court| { name: court.name, game_count: court.game_count } }

    @report_stats = {
      new_users: current_new_users,
      new_users_growth: new_users_growth,
      total_games: Game.count,
      games_growth: games_growth,
      total_revenue: Payment.where(status: "paid").sum(:amount),
      revenue_growth: revenue_growth,
      active_users: active_users,
      active_user_ratio: active_user_ratio
    }

    if params[:report_id].present? && defined?(Report)
      @selected_report = Report.find(params[:report_id])
      begin
        @report_results[@selected_report.id] = @selected_report.execute
      rescue => e
        flash[:alert] = "리포트 실행 중 오류가 발생했습니다: #{e.message}"
      end
    end
  end

  def settings
    @settings = SystemSetting.all.group_by(&:category)
    @categories = SystemSetting.categories
  end

  def update_setting
    setting = SystemSetting.find(params[:id])

    if setting.update(setting_params)
      AdminLog.log_action(
        current_user,
        "update_setting",
        "SystemSetting",
        setting.id,
        "Updated #{setting.key} to #{setting.value}",
        request
      )
      flash[:notice] = "설정이 업데이트되었습니다."
    else
      flash[:alert] = "설정 업데이트에 실패했습니다."
    end

    redirect_to admin_settings_path
  end

  def logs
    @logs = AdminLog.includes(:user)
                   .order(created_at: :desc)
                   .page(params[:page])

    if params[:action_filter].present?
      @logs = @logs.by_action(params[:action_filter])
    end

    if params[:resource_type_filter].present?
      @logs = @logs.by_resource_type(params[:resource_type_filter])
    end

    if params[:user_filter].present?
      @logs = @logs.by_user(User.find(params[:user_filter]))
    end

    @actions = AdminLog.distinct.pluck(:action)
    @resource_types = AdminLog.distinct.pluck(:resource_type)
  end

  def suggestions
    @suggestions = Suggestion.includes(:user)
                            .where.not(status: [ "resolved", "closed" ])
                            .order(created_at: :desc)
                            .page(params[:page])

    if params[:status].present?
      @suggestions = @suggestions.where(status: params[:status])
    end

    if params[:search].present?
      @suggestions = @suggestions.joins(:user)
                                 .where("suggestions.title ILIKE ? OR suggestions.content ILIKE ? OR users.name ILIKE ? OR users.nickname ILIKE ?",
                                       "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
  end

  def resolved_suggestions
    @suggestions = Suggestion.includes(:user)
                            .where(status: [ "resolved", "closed" ])
                            .order(created_at: :desc)
                            .page(params[:page])

    if params[:status].present?
      @suggestions = @suggestions.where(status: params[:status])
    end

    if params[:search].present?
      @suggestions = @suggestions.joins(:user)
                                 .where("suggestions.title ILIKE ? OR suggestions.content ILIKE ? OR users.name ILIKE ? OR users.nickname ILIKE ?",
                                       "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
  end

  def export_data
    case params[:data_type]
    when "users"
      @data = User.all
      @columns = %w[id name email status created_at total_games_hosted total_games_participated total_revenue]
    when "games"
      @data = Game.includes(:organizer)
      @columns = %w[id title organizer_name status created_at application_count revenue_generated]
    when "payments"
      @data = Payment.includes(:game_application)
      @columns = %w[id amount status created_at fee_amount net_amount currency]
    when "applications"
      @data = GameApplication.includes(:user, :game)
      @columns = %w[id user_name game_title status created_at showed_up rating_given]
    else
      flash[:alert] = "잘못된 데이터 타입입니다."
      redirect_to admin_analytics_path and return
    end

    respond_to do |format|
      format.csv { send_data generate_csv(@data, @columns), filename: "#{params[:data_type]}_#{Date.current}.csv" }
      format.json { render json: @data }
    end
  end

  def user_action
    @user = User.find(params[:id])

    case params[:action_type]
    when "suspend"
      @user.update(status: "suspended", suspended_at: Time.current, suspension_reason: params[:reason])
      flash[:notice] = "사용자 #{@user.name}을(를) 정지했습니다."
    when "activate"
      @user.update(status: "active", suspended_at: nil, suspension_reason: nil)
      flash[:notice] = "사용자 #{@user.name}을(를) 활성화했습니다."
    when "make_admin"
      @user.make_admin!
      flash[:notice] = "사용자 #{@user.name}을(를) 관리자로 지정했습니다."
    when "remove_admin"
      @user.remove_admin!
      flash[:notice] = "사용자 #{@user.name}의 관리자 권한을 제거했습니다."
    end

    redirect_to admin_users_path
  end

  def game_action
    @game = Game.find(params[:id])

    case params[:action_type]
    when "cancel"
      @game.update(status: "cancelled")
      flash[:notice] = "경기 '#{@game.title}'를 취소했습니다."
    when "activate"
      @game.update(status: "active")
      flash[:notice] = "경기 '#{@game.title}'를 활성화했습니다."
    end

    redirect_to admin_games_path
  end

  def payment_action
    @payment = Payment.find(params[:id])

    case params[:action_type]
    when "refund"
      @payment.update(
        status: "refunded",
        refund_reason: params[:refund_reason],
        refunded_at: Time.current
      )
      flash[:notice] = "결제 ID #{@payment.id}를 환불 처리했습니다."
    when "cancel"
      @payment.update(status: "cancelled")
      flash[:notice] = "결제 ID #{@payment.id}를 취소했습니다."
    end

    redirect_to admin_payments_path
  end

  def application_action
    @application = GameApplication.find(params[:id])

    case params[:action_type]
    when "approve"
      @application.update(status: "waiting_payment")
      flash[:notice] = "신청 ID #{@application.id}를 승인했습니다. 결제 대기 상태로 변경되었습니다."
    when "reject"
      @application.update(
        status: "rejected",
        rejection_reason: params[:rejection_reason]
      )
      flash[:notice] = "신청 ID #{@application.id}를 거절했습니다."
    when "confirm_payment"
      @application.update(status: "final_approved")
      flash[:notice] = "결제를 확인했습니다. 신청 ID #{@application.id}가 최종 승인되었습니다."
    when "mark_attended"
      @application.update(showed_up: true)
      flash[:notice] = "신청 ID #{@application.id}를 참석으로 표시했습니다."
    when "mark_absent"
      @application.update(showed_up: false)
      flash[:notice] = "신청 ID #{@application.id}를 불참으로 표시했습니다."
    end

    redirect_to admin_applications_path
  end

  def suggestion_action
    @suggestion = Suggestion.find(params[:id])

    status = params[:status]
    admin_response = params[:admin_response]

    case status
    when "reviewing"
      @suggestion.mark_as_reviewing!
    when "resolved"
      @suggestion.mark_as_resolved!(admin_response)
    when "closed"
      @suggestion.mark_as_closed!(admin_response)
    end

    render json: { success: true }
  rescue => e
    render json: { success: false, error: e.message }
  end

  def tournaments
    @tournaments = Tournament.includes(:organizer)
                           .order(created_at: :desc)
                           .page(params[:page])

    if params[:status].present?
      @tournaments = @tournaments.where(status: params[:status])
    end

    if params[:search].present?
      @tournaments = @tournaments.where("name ILIKE ? OR description ILIKE ?",
                                     "%#{params[:search]}%", "%#{params[:search]}%")
    end

    @pending_tournaments = Tournament.pending_approval.includes(:organizer)
  end

  def tournament_action
    @tournament = Tournament.find(params[:id])

    case params[:action_type]
    when "approve"
      if @tournament.approve!(params[:approval_notes])
        AdminLog.log_action(current_user, "approve_tournament", "Tournament", @tournament.id,
                          "대회 '#{@tournament.name}' 승인", request)
        flash[:notice] = "대회 '#{@tournament.name}'을(를) 승인했습니다."
      else
        flash[:alert] = "대회 승인에 실패했습니다."
      end
    when "reject"
      if @tournament.reject!(params[:rejection_reason])
        AdminLog.log_action(current_user, "reject_tournament", "Tournament", @tournament.id,
                          "대회 '#{@tournament.name}' 거절: #{params[:rejection_reason]}", request)
        flash[:notice] = "대회 '#{@tournament.name}'을(를) 거절했습니다."
      else
        flash[:alert] = "대회 거절에 실패했습니다."
      end
    end

    redirect_to admin_tournaments_path
  end

  private

  def setting_params
    params.require(:system_setting).permit(:value)
  end

  def get_daily_stats
    last_30_days = 30.days.ago.to_date..Date.current

    stats = {}
    last_30_days.each do |date|
      stats[date] = {
        new_users: User.where(created_at: date.beginning_of_day..date.end_of_day).count,
        new_games: Game.where(created_at: date.beginning_of_day..date.end_of_day).count,
        completed_payments: Payment.where(created_at: date.beginning_of_day..date.end_of_day, status: "paid").count,
        revenue: Payment.where(created_at: date.beginning_of_day..date.end_of_day, status: "paid").sum(:amount) || 0
      }
    end

    stats
  end

  def generate_csv(data, columns)
    CSV.generate(headers: true) do |csv|
      csv << columns
      data.each do |record|
        row = columns.map do |column|
          case column
          when "organizer_name"
            record.organizer&.name
          when "user_name"
            record.user&.name
          when "game_title"
            record.game&.title
          else
            record.send(column) if record.respond_to?(column)
          end
        end
        csv << row
      end
    end
  end


  def calculate_avg_profile_completion
    users = User.all
    return 0 if users.empty?

    total_completion = users.sum { |user| user.profile_completion_percentage }
    (total_completion.to_f / users.count).round(1)
  end

  def get_recent_activities
    activities = []

    # 최근 사용자 가입
    recent_users = User.where(created_at: 24.hours.ago..Time.current).order(created_at: :desc).limit(5)
    recent_users.each do |user|
      activities << {
        type: "user_joined",
        message: "새 사용자 가입: #{user.name}",
        time: user.created_at,
        icon: "👤"
      }
    end

    # 최근 경기 생성
    recent_games = Game.where(created_at: 24.hours.ago..Time.current).order(created_at: :desc).limit(5)
    recent_games.each do |game|
      activities << {
        type: "game_created",
        message: "새 경기 생성: #{game.title}",
        time: game.created_at,
        icon: "🏀"
      }
    end

    # 최근 결제
    recent_payments = Payment.where(created_at: 24.hours.ago..Time.current, status: "paid").order(created_at: :desc).limit(5)
    recent_payments.each do |payment|
      activities << {
        type: "payment_completed",
        message: "결제 완료: #{payment.amount}원",
        time: payment.created_at,
        icon: "💳"
      }
    end

    activities.sort_by { |a| a[:time] }.reverse.first(10)
  end

  def get_payment_issues
    issues = []

    # 결제 실패 건수
    failed_payments = Payment.where(status: "failed").count
    if failed_payments > 0
      issues << {
        type: "payment_failed",
        message: "결제 실패 #{failed_payments}건",
        severity: "high",
        icon: "⚠️"
      }
    end

    # 대기 중인 결제
    waiting_payments = GameApplication.where(status: "waiting_payment").count
    if waiting_payments > 10
      issues << {
        type: "payment_waiting",
        message: "결제 대기 중 #{waiting_payments}건",
        severity: "medium",
        icon: "⏳"
      }
    end

    # 정지된 사용자
    suspended_users = User.where(status: "suspended").count
    if suspended_users > 0
      issues << {
        type: "users_suspended",
        message: "정지된 사용자 #{suspended_users}명",
        severity: "medium",
        icon: "🚫"
      }
    end

    issues
  end
end
