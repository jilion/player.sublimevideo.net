require 's3_wrapper'

class CDNFile
  attr_accessor :file, :path, :headers

  def initialize(file, path, headers)
    @file, @path, @headers = file, path, headers
  end

  def upload
    File.open(file) do |f|
      S3Wrapper.put(S3Wrapper.buckets[:sublimevideo], path, f.read, headers)
    end
  end

  def delete
    S3Wrapper.delete(S3Wrapper.buckets[:sublimevideo], path)
  end

  def present?
    _s3_headers.present?
  end

  private

  def _s3_headers
    S3Wrapper.head(S3Wrapper.buckets[:sublimevideo], path).headers
  rescue Excon::Errors::NotFound
    {}
  end
end
