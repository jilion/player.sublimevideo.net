require 'stage'
require 'cdn_file'

class LoaderFileGenerator
  extend Forwardable

  attr_reader :site, :stage, :options

  def_delegator :site, :token

  def initialize(site, stage, options = {})
    @site, @stage, @options = site, stage, options
  end

  def self.update(site_token, options = {})
    site = Site.find(site_token)

    Array(options.delete(:stage) { Stage.stages }).each do |stage|
      new(site, stage, options).update
    end
  end

  def update
    if options[:delete]
      delete
    else
      generate
    end
  end

  def generate
    cdn_file.upload
    _increment_librato('update')
  end

  def delete
    CDNFile.new(nil, _path, nil).delete
    _increment_librato('delete')
  end

  def cdn_file
    @cdn_file ||= CDNFile.new(_generate_file, _path, _s3_headers)
  end

  def app_md5
    @app_md5 ||= (options[:app_md5] || Digest::MD5.digest(_dependencies.sort.to_s))
  end

  private

  def _dependencies
    @_dependencies ||= PackagesDependenciesSolver.dependencies(site.packages(stage), stage)
  end

  def _generate_file
    template_path = Rails.root.join('app', 'templates', "loader-#{stage}.js.erb")
    template = ERB.new(File.new(template_path).read)
    file = Tempfile.new("l-#{token}.js", Rails.root.join('tmp'))
    file.print template.result(binding)
    file.flush
    file
  end

  def _path
    case stage
    when 'stable'
      "js/#{token}.js"
    else
      "js/#{token}-#{stage}.js"
    end
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
