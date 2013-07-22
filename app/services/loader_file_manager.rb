require 'cdn_file'

# This class is responsible for creating / uploading / removing a loader file
# associated to a site, an app and a stage.
#
class LoaderFileManager

  attr_reader :site_token, :app_token, :stage

  def initialize(site_token, app_token, stage = 'stable')
    @site_token, @app_token, @stage = site_token, app_token, stage
  end

  def upload
    cdn_loader_file.upload
  end

  def delete
    CDNFile.new(nil, _loader_file.path, nil).delete
  end

  def cdn_loader_file
    CDNFile.new(_loader_file.content, _loader_file.path, _s3_headers)
  end

  private

  def _loader_file
    @_loader_file ||= LoaderFile.new(site_token, app_token, stage)
  end

  def _s3_headers
    {
      'Cache-Control' => _cache_control,
      'Content-Type'  => 'text/javascript',
      'x-amz-acl'     => 'public-read'
    }
  end

  def _cache_control
    case stage
    when 'alpha'
      'no-cache'
    else
      's-maxage=300, max-age=120, public' # 5 minutes / 2 minutes
    end
  end

end
