require 'stage'
require 'cdn_file'
require 'settings_formatter'

class SettingsFileManager

  attr_reader :site, :stage

  def initialize(site, stage)
    @site, @stage = site, stage
  end

  def upload
    settings_file.upload
  end

  def delete
    CDNFile.new(nil, _path, nil).delete
  end

  # The actual settings file that will be uploaded.
  #
  def settings_file
    CDNFile.new(_settings_file_content, _path, _s3_headers)
  end

  def license
    hash = { hosts: [site.hostname], wildcard: site.wildcard, path: site.path, stage: site.accessible_stage }
    hash[:hosts]        += (site.extra_hostnames || '').split(/,\s*/)
    hash[:staging_hosts] = (site.staging_hostnames || '').split(/,\s*/)
    hash[:dev_hosts]     = (site.dev_hostnames || '').split(/,\s*/)
    hash
  end

  # TODO
  def kits
    site.kits.reduce({}) do |hash, kit|
      hash[kit.identifier] = {}
      hash[kit.identifier][:skin] = { module: kit.design['module'] }
      hash[kit.identifier][:plugins] = kit.settings
      hash
    end
  end

  # TODO
  def app_settings
    {}
  end

  def default_kit
    site.default_kit.identifier
  end

  def format(hash)
    SettingsFormatter.format(hash)
  end

  private

  def _path
    path = "s3/#{site.token}"
    path += "-#{stage}" unless stage == 'stable'

    path.to_s + '.js'
  end

  def _settings_file_content
    template_path = Rails.root.join('app', 'templates', 'settings.js.erb')
    template = ERB.new(File.new(template_path).read)
    file = Tempfile.new(["s-#{site.token}-#{stage}", '.js'], Rails.root.join('tmp'))
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
