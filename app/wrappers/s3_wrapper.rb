module S3Wrapper

  def self.all(*args)
    _fog_connection.directories.get(_packages_bucket, *args)
  end

  def self.head(*args)
    _fog_connection.head_object(_packages_bucket, *args)
  end

  def self.get(*args)
    _fog_connection.get_object(_packages_bucket, *args)
  end

  def self.put(*args)
    _fog_connection.put_object(_packages_bucket, *args)
  end

  def self.delete(*args)
    _fog_connection.delete_object(_packages_bucket, *args)
  end

  def self._packages_bucket
    ENV['S3_PACKAGES_BUCKET']
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
