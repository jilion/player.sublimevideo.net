require 'site'
require 'kit'
require 'cdn_file'

class SettingsFileGenerator

  attr_reader :site

  def initialize(site)
    @site = site
  end

  def generate_and_upload
    cdn_file.upload!
    _increment_librato('update')
  end

  def license
    hash = { hosts: [site.hostname], wildcard: site.wildcard, path: site.path, stage: site.accessible_stage }
    hash[:hosts]        += (site.extra_hostnames || '').split(/,\s*/)
    hash[:staging_hosts] = (site.staging_hostnames || '').split(/,\s*/)
    hash[:dev_hosts]     = (site.dev_hostnames || '').split(/,\s*/)
    hash
  end

  def kits
    Kit.all(site_token: token).reduce({}) do |hash, kit|
      hash[kit.identifier] = {}
      hash[kit.identifier][:skin] = if with_module
        { module: kit.skin_mod }
      else
        { id: kit.skin_token }
      end
      hash[kit.identifier][:plugins] = _kits_plugins(kit, nil, with_module)
      hash
    end
  end

  def default_kit
    site.default_kit.identifier
  end

  # TODO
  #
  def format(hash)
    hash
    # SettingsFormatter.format(hash)
  end

  def cdn_file
    @cdn_file ||= CDNFile.new(_generate_file, _path, _s3_headers)
  end

  private

  def _generate_file
    template_path = Rails.root.join('app', 'templates', 'settings.js.erb')
    template = ERB.new(File.new(template_path).read)
    file = Tempfile.new("s-#{site.token}.js", Rails.root.join('tmp'))
    file.print template.result(binding)
    file.flush
    file
  end

  def _path
    "s3/#{site.token}.js"
  end

  def _s3_headers
    {
      'Cache-Control' => 's-maxage=300, max-age=120, public', # 5 minutes / 2 minutes
      'Content-Type'  => 'text/javascript',
      'x-amz-acl'     => 'public-read'
    }
  end

  def _increment_librato(action)
    Librato.increment "settings.#{action}"
  end

end
