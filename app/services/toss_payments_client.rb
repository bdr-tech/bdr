class TossPaymentsClient
  include HTTParty

  base_uri "https://api.tosspayments.com/v1"

  def initialize
    @secret_key = ENV["TOSS_SECRET_KEY"]
    @options = {
      headers: {
        "Authorization" => "Basic #{Base64.strict_encode64("#{@secret_key}:")}",
        "Content-Type" => "application/json"
      }
    }
  end

  # 결제 취소 (환불)
  def cancel_payment(payment_key:, cancel_reason:, cancel_amount: nil)
    body = {
      cancelReason: cancel_reason
    }
    body[:cancelAmount] = cancel_amount if cancel_amount

    response = self.class.post(
      "/payments/#{payment_key}/cancel",
      @options.merge(body: body.to_json)
    )

    if response.success?
      {
        success: true,
        cancellation_id: response["cancels"]&.first&.dig("transactionKey"),
        cancelled_amount: response["cancels"]&.first&.dig("cancelAmount"),
        data: response.parsed_response
      }
    else
      {
        success: false,
        error: response["message"] || "Unknown error",
        code: response["code"],
        data: response.parsed_response
      }
    end
  rescue => e
    Rails.logger.error "TossPayments API Error: #{e.message}"
    {
      success: false,
      error: e.message
    }
  end

  # 결제 조회
  def get_payment(payment_key)
    response = self.class.get(
      "/payments/#{payment_key}",
      @options
    )

    if response.success?
      {
        success: true,
        data: response.parsed_response
      }
    else
      {
        success: false,
        error: response["message"] || "Unknown error",
        data: response.parsed_response
      }
    end
  rescue => e
    Rails.logger.error "TossPayments API Error: #{e.message}"
    {
      success: false,
      error: e.message
    }
  end

  # 결제 승인
  def confirm_payment(payment_key:, order_id:, amount:)
    body = {
      paymentKey: payment_key,
      orderId: order_id,
      amount: amount
    }

    response = self.class.post(
      "/payments/confirm",
      @options.merge(body: body.to_json)
    )

    if response.success?
      {
        success: true,
        data: response.parsed_response
      }
    else
      {
        success: false,
        error: response["message"] || "Unknown error",
        code: response["code"],
        data: response.parsed_response
      }
    end
  rescue => e
    Rails.logger.error "TossPayments API Error: #{e.message}"
    {
      success: false,
      error: e.message
    }
  end

  # 빌링키 발급
  def issue_billing_key(customer_key:, auth_key:)
    body = {
      authKey: auth_key,
      customerKey: customer_key
    }

    response = self.class.post(
      "/billing/authorizations/issue",
      @options.merge(body: body.to_json)
    )

    if response.success?
      {
        success: true,
        billing_key: response["billingKey"],
        card_company: response["card"]["company"],
        card_number: response["card"]["number"],
        data: response.parsed_response
      }
    else
      {
        success: false,
        error: response["message"] || "Unknown error",
        code: response["code"]
      }
    end
  rescue => e
    Rails.logger.error "TossPayments Billing Key Error: #{e.message}"
    {
      success: false,
      error: e.message
    }
  end

  # 빌링키로 자동결제
  def billing_payment(billing_key:, customer_key:, amount:, order_id:, order_name:)
    body = {
      billingKey: billing_key,
      customerKey: customer_key,
      amount: amount,
      orderId: order_id,
      orderName: order_name
    }

    response = self.class.post(
      "/billing/#{billing_key}",
      @options.merge(body: body.to_json)
    )

    if response.success?
      {
        success: true,
        payment_key: response["paymentKey"],
        order_id: response["orderId"],
        data: response.parsed_response
      }
    else
      {
        success: false,
        error: response["message"] || "Unknown error",
        code: response["code"]
      }
    end
  rescue => e
    Rails.logger.error "TossPayments Billing Payment Error: #{e.message}"
    {
      success: false,
      error: e.message
    }
  end
end
