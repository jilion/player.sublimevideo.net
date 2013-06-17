require 'stage'
require 'cdn_file'
require 'settings_formatter'

class SettingsFileGenerator

  attr_reader :site, :stage, :options

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

  # TODO
  def license
    hash = { hosts: [site.hostname], wildcard: site.wildcard, path: site.path, stage: site.accessible_stage }
    hash[:hosts]        += (site.extra_hostnames || '').split(/,\s*/)
    hash[:staging_hosts] = (site.staging_hostnames || '').split(/,\s*/)
    hash[:dev_hosts]     = (site.dev_hostnames || '').split(/,\s*/)
    hash
  end

  # TODO
  def kits
    # # addons = ...
    # site.kits.reduce({}) do |hash, kit|
    #   # addons.each
    #   # package = kit.design + addons
    #   hash[kit.identifier] = {}
    #   hash[kit.identifier][:skin] = { module: kit.design.skin_mod }
    #   hash[kit.identifier][:plugins] = _kits_plugins(kit, nil, with_module)
    #   hash
    # end
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
    Librato.increment "player.#{action}", source: 'settings'
  end

end
