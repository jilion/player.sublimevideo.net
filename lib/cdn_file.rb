class CDNFile
  attr_accessor :file, :path, :headers

  def initialize(file, path, headers)
    @file = file
    @path = path
    @headers = headers
  end

  def upload
    File.open(file) do |f|
      S3Wrapper.fog_connection.put_object(_bucket, path, f.read, headers)
    end
  end

  def delete
    S3Wrapper.fog_connection.delete_object(_bucket, path)
  end

  def present?
    _s3_headers.present?
  end

  private

  def _bucket
    @_bucket ||= ENV['S3_PACKAGES_BUCKET']
  end

  def _s3_headers
    S3Wrapper.fog_connection.head_object(_bucket, path).headers
  rescue Excon::Errors::NotFound
    {}
  end
end
