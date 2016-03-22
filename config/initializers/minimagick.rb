MiniMagick.configure do |config|
  config.cli = :imagemagick
  config.validate_on_create = true
  config.validate_on_write = false
  #config.logger = Rails.logger
end