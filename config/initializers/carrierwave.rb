module CarrierWave
  class << self
    def fog_configuration
      configure do |config|
        config.cache_dir       = Rails.root.join('tmp/uploads')
        config.storage         = :fog
        config.fog_public      = false
        config.fog_attributes  = {}
        config.fog_credentials = {
          provider:              'AWS',
          aws_access_key_id:     ENV['S3_ACCESS_KEY_ID'],
          aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
          region:                'us-east-1'
        }
      end
    end

    def file_configuration
      configure do |config|
        config.storage           = :file
        config.enable_processing = true
        config.fog_public        = false
      end
    end
  end
end

case ENV['RAILS_ENV'] || Rails.env
when 'test'
  CarrierWave.file_configuration
else
  CarrierWave.fog_configuration
end
