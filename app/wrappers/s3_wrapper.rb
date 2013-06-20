module S3Wrapper

  BUCKETS = {
    'development' => {
      sublimevideo: 'dev.sublimevideo',
      player:       'dev.sublimevideo.player'
    },
    'staging' => {
      sublimevideo: 'staging.sublimevideo',
      player:       'staging.sublimevideo.player'
    },
    'production' => {
      sublimevideo: 'sublimevideo',
      player:       'sublimevideo.player'
    }
  }

  def self.buckets
    case Rails.env.to_s
    when 'development', 'test'
      BUCKETS['development']
    else
      BUCKETS[Rails.env]
    end
  end

  def self.all(*args)
    _fog_connection.directories.get(*args)
  end

  def self.head(*args)
    _fog_connection.head_object(*args)
  end

  def self.get(*args)
    _fog_connection.get_object(*args)
  end

  def self.put(*args)
    _fog_connection.put_object(*args)
  end

  def self.delete(*args)
    _fog_connection.delete_object(*args)
  end

  # @private
  def self._fog_connection
    @_fog_connection ||= Fog::Storage.new(
      provider:              'AWS',
      aws_access_key_id:     ENV['S3_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
      region:                'us-east-1'
    )
  end

end
