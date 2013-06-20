require 'cdn_file'

class LoaderManager

  attr_reader :site, :stage, :app

  def initialize(site, app = nil, stage = 'stable')
    @site, @app, @stage = site, app, stage
  end

  def update
    loader = Loader.find_or_initialize_by(site_token: _site_token, stage: stage)
    loader.app = app
    loader.save!

    _upload_loader_file
    _increment_librato('update.succeed')

    true

  rescue ActiveRecord::RecordInvalid
    _increment_librato('update.failed')
    false
  end

  def delete
    if loader = Loader.find_by(site_token: _site_token, stage: stage)
      loader.destroy!

      _delete_loader_file

      _increment_librato('delete.succeed')
    end
  end

  def loader_file
    CDNFile.new(_loader_file_content, _path, _s3_headers)
  end

  private

  def _host
    case Rails.env
    when 'staging'
      '//cdn.sublimevideo-staging.net'
    else
      '//cdn.sublimevideo.net'
    end
  end

  def _site_token
    site.token
  end

  def _app_token
    app.token
  end

  def _path
    path = "js2/#{_site_token}"
    path += "-#{stage}" unless stage == 'stable'

    path.to_s + '.js'
  end

  def _upload_loader_file
    loader_file.upload
  end

  def _delete_loader_file
    CDNFile.new(nil, _path, nil).delete
  end

  def _loader_file_content
    template_path = Rails.root.join('app', 'templates', "loader-#{stage}.js.erb")
    template = ERB.new(File.new(template_path).read)
    file = Tempfile.new(["l-#{_site_token}-#{stage}", '.js'], Rails.root.join('tmp'))
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

  def _increment_librato(action)
    Librato.increment "player.loader.#{action}", source: stage
  end

end
