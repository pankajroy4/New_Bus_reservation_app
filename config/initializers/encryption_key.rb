require 'securerandom'
ENV['ENCRYPTION_KEY'] = SecureRandom.hex(32)