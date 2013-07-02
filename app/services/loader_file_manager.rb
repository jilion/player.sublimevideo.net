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
    loader_file.upload
  end

  def delete
    CDNFile.new(nil, _path, nil).delete
  end

  # Binded in the template.
  #
  def host
    case Rails.env
    when 'staging'
      '//cdn.sublimevideo-staging.net'
    else
      '//cdn.sublimevideo.net'
    end
  end

  # The actual loader file that will be uploaded.
  #
  def loader_file
    CDNFile.new(_loader_file_content, _path, _s3_headers)
  end

  private

  def _app_token
    app.token
  end

  def _path
    path = "js2/#{site_token}"
    path += "-#{stage}" unless stage == 'stable'

    path.to_s + '.js'
  end

  def _loader_file_content
    template_path = Rails.root.join('app', 'templates', "loader-#{stage}.js.erb")
    template = ERB.new(File.new(template_path).read)
    file = Tempfile.new(["l-#{site_token}-#{stage}", '.js'], Rails.root.join('tmp'))
    file.print template.result(binding)
    file.rewind
    file
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
