class PaymentsController < ApplicationController
  before_action :require_login
  before_action :set_game_and_application, except: [ :success, :fail ]
  before_action :verify_payment_permission, except: [ :success, :fail ]

  def new
    @payment = @application.payment || @application.build_payment
  end

  def create
    # 토스페이먼츠로만 결제 처리 (이 메서드는 실제로 사용되지 않음)
    redirect_to new_game_game_application_payment_path(@game, @application),
                alert: "토스페이먼츠를 통해 결제해주세요."
  end

  def show
    @payment = @application.payment
    redirect_to @game, alert: "결제 정보를 찾을 수 없습니다." unless @payment
  end

  # 토스페이먼츠 결제 성공 처리
  def success
    payment_key = params[:paymentKey]
    order_id = params[:orderId]
    amount = params[:amount]

    # 주문 ID에서 게임과 신청 정보 추출
    if order_id.match(/BDR-(.+)-(\d+)-\d+/)
      game_id = $1
      application_id = $2

      @game = Game.find_by(game_id: game_id)
      @application = GameApplication.find(application_id)

      if @game && @application
        # 결제 정보 업데이트
        @payment = @application.payment || @application.create_payment(
          amount: @game.fee,  # 실제 게임 참가비 사용
          status: "paid",
          payment_method: "toss_payments",
          toss_payment_key: payment_key,
          toss_order_id: order_id,
          paid_at: Time.current
        )

        # 결제 완료 처리
        @application.update!(
          status: "final_approved",
          payment_confirmed_at: Time.current,
          final_approved_at: Time.current
        )

        # 결제 완료 이메일 발송
        UserMailer.payment_confirmed(@payment).deliver_later

        redirect_to @game, notice: "결제가 완료되었습니다! 경기 참가가 확정되었습니다."
      else
        redirect_to root_path, alert: "결제 정보를 찾을 수 없습니다."
      end
    else
      redirect_to root_path, alert: "잘못된 주문 정보입니다."
    end
  end

  # 토스페이먼츠 결제 실패 처리
  def fail
    error_code = params[:code]
    error_message = params[:message]

    redirect_to root_path, alert: "결제가 실패했습니다: #{error_message}"
  end

  private

  def set_game_and_application
    @game = Game.find_by!(game_id: params[:game_id])
    @application = GameApplication.find(params[:game_application_id])
  end

  def verify_payment_permission
    unless @application.user == current_user && @application.status == "waiting_payment"
      redirect_to @game, alert: "결제 권한이 없습니다."
    end
  end
end
