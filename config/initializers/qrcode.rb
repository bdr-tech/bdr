# QRCode initialization
# Check if rqrcode gem is available

begin
  require 'rqrcode'
  Rails.application.config.qrcode_enabled = true
  Rails.logger.info "QRCode support enabled"
rescue LoadError
  Rails.application.config.qrcode_enabled = false
  Rails.logger.warn "QRCode gem not available - QR code features will be disabled"
end