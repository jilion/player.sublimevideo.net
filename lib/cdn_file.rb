class CDNFile
  attr_accessor :file, :path, :headers

  def initialize(file, path, headers)
    @file = file
    @path = path
    @headers = headers
  end

  def upload
    File.open(file) do |f|
      S3Wrapper.put(path, f.read, headers)
    end
  end

  def delete
    S3Wrapper.delete(path)
  end

  def present?
    _s3_headers.present?
  end

  private

  def _s3_headers
    S3Wrapper.head(path).headers
  rescue Excon::Errors::NotFound
    {}
  end
end
