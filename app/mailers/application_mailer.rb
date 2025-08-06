class ApplicationMailer < ActionMailer::Base
  default from: "BDR 플랫폼 <noreply@bdr-platform.com>"
  layout "mailer"

  # Helper methods for all mailers
  helper :application

  # Include URL helpers
  include Rails.application.routes.url_helpers

  # Default URL options
  def default_url_options
    { host: Rails.application.config.action_mailer.default_url_options[:host] }
  end
end
